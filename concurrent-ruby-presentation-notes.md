# Ruby Concurrency

Hello, my name is Jerry D'Antonio. I work for VHT (forerly Virtual Hold Technology),
an Erlang and Ruby shop in Akron, Ohio. Today I'm here to talk to you about concurrency.

## Slide 1: Introduction

### Asynchronous

The word of the day is "Asynchronous"

* Old-school concurrency is "lock and synchronize"--synchronize threads by locking shared resources
* With asynchronous concurrency we *coordinate* independent operations without locking
* There are many patterns for performing asynchronous concurrency

### What We'll Cover

Today we will look at numerous asynchronous concurrency abstractions

* Each is available in one or more programming languages other than Ruby--either as a widely-followed specification, in the standard library, or in the language itself
* We will look at a *ton* of source code
* All the source code is available in a GitHub repo along with the slides and the notes
* Most of the code we will look at will use the Concurrent Ruby gem
  * An MIT licensed open source gem that I created
  * We use it at VHT
  * Intended to be a "utility belt" with a bunch of useful concurrency tools
  * Simple-yet-powerful tools, loosely coupled, each with a single purpose
  * Each is based on a concurrency tool available in another language
  * It has no dependencies outside of the Ruby standard library
  * It does not use Fibers so behaves consistently across interpreters
  * It has no known incompatabilities with any major gems
  * It should be usable in any program you want to use it in--programs that already exist and that you have yet to write
  * It is available on GitHub (https://github.com/jdantonio/concurrent-ruby)
  * And Rubygems (https://rubygems.org/gems/concurrent-ruby)
* Time permitting we will also look at two other gems
  * EventMachine (http://rubyeventmachine.com/)
  * Celluloid (http://celluloid.io/)
* We don't have time to go over all the code line-by-line so I ask that you focus on the *concepts* and examine the code in detail later

## Slide 2: Crash Test Dummy

Before we start looking at the code, we need a crash test dummy.

* Often when showing sample concurrent code we use `sleep` statements to simulate non-determinism
* This works, but is something of a co-out
* For this presentation I have created a small class for test driving our sample code

## Slide 3: Finance class

This class will serve as our crash test dummy. We will use this class in almost all of our sample code. It isn't a very well-designed class but it exhibits several characteristics which are important when writing concurrent code.

### What does it do?

This class:

* Takes the name of a company (say, "Yahoo") in the constructor
* Uses the `#update` method to query a Yahoo API and retrieve a list of stock ticker symbols for that company on all known international stock exchanges
* It parses the returned data, removing the AJAX wrapper and converting what remains into an array of hashes
* It then stores the data in an instance variable

### Characteristics of the code

* Performs blocking I/O--one of the main reasons for concurrency
* It performs a computationally-intensive tasks--requires true *parallelism* for improved performance
* Is a *mutable* object (shared mutable data is bad)
* Exposes a reference to a mutable data structure via an attribute reader (again, shared mutable data is bad)

## Slide 4: Back to the Future

The first abstraction we are going to look at is the *future*.

* http://clojuredocs.org/clojure_core/clojure.core/future
* One of the core concurrency abstractions in Clojure
* Represents the *result* of a computation that will be performed at some future time
* On creation the task is scheduled for execution by the runtime
* The main thread can then do other stuff and retrieve the result of the operation later

## Slide 5: Simple Future code sample

The first code example shows a successful operation:

* Creates a new `Finance` object and send it to the future
* The state of the future is `:pending`
* The value of the future is 'nil`
* The main thread then does important stuff with the operation completes
* On success the state of the object becomes `:fulfilled` and the value of the future becomes the result of the operation
* From  this point forward the future is *immutable*
* A future does one thing and then is done forever

The second example is similar to the first but shows the failure case:

* The operation raises an *exception*
* An exception thrown from the operation is the only way to signal failure
* The state of the future becomes `:rejected`
* The exception that was raised is now accessible through the `#reason` accessor

## Slide 6: Future with a callback

There are two ways to act upon the result of an asynchronous operation:

* Query the asynchronous for the result (occurs on a different thread than the operation)
* Provide a *callbac* operation to run when the operation is complete
* The callback usually happens on the same thread as the asynchronous operation
* The term *errorback* is occasionally used when a callback is only run in response to an error

### Observable

* The Ruby standard library provides a very good callback mechanism via the `Observable` module
* http://ruby-doc.org/stdlib-2.0/libdoc/observer/rdoc/Observable.html
* This implementation of future supports Ruby's `Observable`
* This code example creates an observer class
* The `#update` method receives a `Time` object (representing the completion time of the future) and the final values of the `value` and `reason` attributes (one of which will always be `nil`)
* The `#add_observer` method of the `Future` class is concurrency-aware and will behave correctly in the off-chance the future completes *beefore* the `#add_observer` method is called

## Slide 7: Secret Agent Man

The next abstraction we will look at is the agent

* http://clojuredocs.org/clojure_core/clojure.core/agent
* Another of the core concurrency abstractions in Clojure
* Represents an atomic value that changes over time
* Rather than placing a lock around a variable and letting threads compete for access, we hide the variable and let threads send *operations* against the variable
* The agent queues the operations and performs them in the order received
* The value of an agent is the value at that exact moment in time, irrespective of an in-progress operation and any queued operations
* A good example is the score in a video game

## Slide 8: Agent code sample

* A new agent is created and given an initial value at construction (in this case an empty array)
* Several modification operations are then sent to the agent
* Each operation receives the current value of the agent and returns the new value
* The important thing to note is that operations on an agent need no *a priori* knowledge of the agent's value--it gets the current value when the operation is run
* Although not shown on this slide, this implementation of agen supports the `Observable` module, validation of the result of each operation, and exception handling callbacks (errorback)
* It also provides options for how to handle the return value when the `#value` method is called

### Possible Bug

This code does one *very* bad thing:

* There is a very serious source of potential bugs in this code
* The bug occurs every time we call the `#value` method
* This bad practice leads us directly to our next topic…

## Slide 9: Mutation

Shard mutable variables are *bad*

* When discussing concurrent programming one common mantra is "avoid shared mutable data"
* This true--when possible *avoid shared mutable data*
* This isn't always possible--sometimes data must be shared across threads
* Many functional programming languages (Erlang, Clojurs, Haskell, F#) get around this by having *immutable* variables
* Not in Ruby--all our variables are *references to mutable objects*
* In the previous slide we passed such a reference out of our agent every time we called the `#value` method
* *Any* thread with a reference to the array can change the value
* Plus, access to the array is not thread safe (no locking)
* This is *very, very bad*

## Slide 10: Enter the Hamster

* Ideal hash trees are an extremely efficient data structure that can be used, among other things, to create immutable data structures that are still extremely high-performance
* Ideal hash trees are the underlying tech in Clojure's immutable data structures
* The Hamster gem is an excellent Ruby library providing thread safe immutable data structures based on ideal hash trees

* http://infoscience.epfl.ch/record/64394
* http://infoscience.epfl.ch/record/64394/files/triesearches.pdf
* http://lampwww.epfl.ch/papers/idealhashtrees.pdf

## Slide 11: Hamster and thread_safe

### Hamster

https://github.com/harukizaemon/hamster

* The first example uses a Hamster vector instead of an array
* Because the vector is immutable we need to copy it on every operation rather than modify it in-place
* Because of the internal ideal hash tree implementation this is an incredibly fast operation
* Our agent is now thread safe *and* calls to `#value` returns and immutable vector
* Of course, that hashes in the vector are still mutable...

### thread_safe

https://github.com/headius/thread_safe

* thread_safe is an excellent library providing thread-safe implementation of Ruby's Array and Hash classes
* Built be a member of the JRuby core team (but supports MRI and Rbx, too)
* Access to the internal array in this example is thread-safe, but we still provide a mutable reference

### Remember...

*Thread-safety and immutability are not the same thing*

*Always be aware of what you are passing across threads and protect your data accordingly*

Note: This agent implementation provides a couple of constructor arguments that can help--see the README

## Slide 12: Promises, Promises

A `Promise` is a variation of the Future abstraction we saw earlier. It's the most prominent asynchronous
concurrency abstraction in JavaScript. jQuery calls them *defers*.

* http://wiki.commonjs.org/wiki/Promises/A
* http://promises-aplus.github.io/promises-spec/

* Colloquialially, "future" (with a lowercase "f") is any asynchronous abstraction that represents
  an operation that will occur at some nondeterministic time in the future
* The Future class we saw early is just one possible variation
* "Promise" and "Defer" are also names for futures
* Different libraries implement them differently, or implement them the same but call
  them different things
* It is common to hear/read the phrase "method X returns a future"
* The Concurrent Ruby library uses the `Oblgation` mixin to define the "future" API

## Slide 13: Simple Promise code sample

* Popular in JavaScript (called *defer* in jQuery)
* Similar to the future we saw earlier but chainiable
* A promise begets a promise which begets a promise…
* There are strict rules for the ordering of operations in promise chains, specifically regarding failure/rejection
* This implementation is also very true to the Promises/A and Promises/A+ specifications
* This implementation does *not* support `Observable`--it uses the built-in callback mechanism instead

## Slide 14: Ticking time bomb

* We've all used `cron` and it's awesome. But sometimes we want `cron`-like functionality within our code
* For one-time scheduling of an event we can use `ScheduledTask`
* This implementation is loosely based on Java's `ScheduledExecutorService`
* http://docs.oracle.com/javase/7/docs/api/java/util/concurrent/ScheduledExecutorService.html

## Slide 15: ScheduledTask

* `ScheduledTask` looks and acts much like `Future` except that execution is delayed
* Execution time is defined at object creation
  * A number of seconds from now
  * Or a specific `Time`
* The resulting object is a "future" in the context we previously discussed
* And this implementation supports the same `Obligation` API of `Future` and `Promise`

## Slide 16: More fun with ScheduledTask

* This implementation of `ScheduledTask` mixes in Ruby's `Observable` module
* And a `:pending` task can also be cancelled with the `#cancel` method

## Slide 17: And so on and so on and so on...

* The other `cron`-ish goodness we sometimes want to implement in code is a repetitive task that happens over and over and over again at regular intervals.
* For this we use the `TimerTask` class.
* This implementation is loosely based on the Java class of the same name
* http://docs.oracle.com/javase/7/docs/api/java/util/TimerTask.html)

## Slide 18: Simple TimerTask

* Want to perform an operation at regular intervals (every 10 seconds, every 5 minutes, etc.)
* Can be stopped and restarted at will

## Slide 19: TimerTask with observation

* The `TimerTask` class includes the `Observable` mixin module

## Slide 20: TimerTask that changes its own execution

* In rare cases a `TimerTask` may want to update its own execution lifecycle
* On execution a reference to the task object will be passed as the first block parameter
* The task can then alter its own lifecycle, even shutting itself down

## Slide 21: All the world's a stage

The actor model is becoming very popular lately, largely due to interest in Erlang. Actors are also surprisingly controversial in some circles.

* The actor model was first proposed in 1973 by Originally proposed in 1973 by Carl Hewitt, Peter Bishop, and Richard Steiger at the M.I.T. Artificial Intelligence Laboratory
* Much has changed since 1973
* There is not universally accepted strict definition of what an actor is
* Most would agree on the general idea but arguments over the details abound
* Actor implementations vary widely--no two are the same

### What is an actor?

My definition:

> An independent, concurrent, single-purpose, computational entity that communicates exclusively via message passing.

## Slide 22: Actor and an Actor pool

* The Actor class in this library is based solely on the Actor task defined in the Scala standard library.
* http://www.scala-lang.org/api/current/index.html#scala.actors.Actor
* It does not implement all the features of Scala's Actor
* But its behavior for what *has* been implemented is nearly identical
* The excluded features mostly deal with Scala's message semantics, strong typing,
  and other characteristics of Scala that don't really apply to Ruby.
* Unlike most of the abstractions in this library, `Actor` takes an *object-oriented*
  approach to asynchronous concurrency, rather than a *functional programming* approach
* Actors are defined by subclassing the `Concurrent::Actor` class and overriding the `#act` method
* Actors can also be pooled--a collection of actors share the same mailbox

## Slide 23: Different ways to post

* There are several variations of the `#post` method available
* The `#post?` method returns a "future" object that can be queried for the result
* The `post!` method blocks and waits for the result
  * `Concurrent::Runnable::LifecycleError` will be raised if the message cannot be
    queued, such as when the `Actor` is not running.
  * `Concurrent::TimeoutError` will be raised if the message is not processed within
    the designated timeout period
  * Any exception raised during message processing will be re-raised after all
    post-processing operations (such as observer callbacks) have completed

## Slide 24: Actor with observation

* It should be no surprise by this time that `Actor` includes the `Observable` mixin
  module and can be observed in standard fashion
* Note that the observer's `#update` method also receives the message as an argument

## Slide 25: Actor Ping Pong

* The canonical actor example seems to be two actors playing ping pong
* This is a Ruby variant of a Scala version implemented in a well-known tutorial
* http://www.scala-lang.org/old/node/242

## Slide 26: Who watches the Watchmen?

* Erlang is known for its fault tolerance, known to be helped achieve nine-nines of uptime (99.9999999%) in one well-known case (http://stackoverflow.com/questions/8426897/erlangs-99-9999999-nine-nines-reliability)
* The fault tolerance has less to do with the language and the virtual machine than it does deliberate design decisions
* One key tool for obtaining high uptime is the Supervisor module
* http://www.erlang.org/doc/man/supervisor.html

## Slide 27: The awesome power of the Supervisor

This complex example combines actors, actor pools, timer tasks, and supervisors to show the power of the Concurrent Library

* The supervisor class in the Concurrent Ruby library is a functionally-complete copy of Erlang's supervior in Ruby
* Can be used with any object that supports three methods: a blocking `#run` method, a `#running?` predicate method, and a `#stop` method that can be called from a different thread
* The `Runnable` mixin module in this library provides that functionality
* Simple add one or more workers to the Supervisor and it will manage the lifecycle of the workers, including restarting them on failure
* Supervisors can supervise other supervisors, creating supervisor trees, just like Erlang (http://www.erlang.org/documentation/doc-4.9.1/doc/design_principles/sup_princ.html)

### Code example

* Create a simple actor for obtaining finance information
* Create a pool of actors
* A pool is a set of actors that share a common mailbox and load balance the processing of messages to the shared mailbox
* Create two timer tasks that send messages to the pool at random intervals
* Create a supervisor
* Add the actors and the timer tasks to the supervisor as workers
* Run the supervisor, which runs the workers
* See spot run...
* Stop everything by stopping the supervisor

## Slide 28: Event-driven Programming

* The event-driven paradigm has become popular recently because of Node.js
* JavaScript itself is event-driven
* The core of the event-driven model is the *reactor* pattern
* The reactor patter was first documented in 2000 in the book "Pattern-Oriented Software Architecture Volume 2: Patterns for Concurrent and Networked Objects"
* Excellent choice when your program listens to event sources and responds to incoming messages

### Reactor-based programming

* Requires three components: the *reactor*, one or more *demultiplexers*, and one or more *event handlers*
* The reactor runs forever in a continuous loop, listening to the event sources
* The demultiplexers, one per event source, unmarshall messages from the event source and pass them to the reactor
* The reactor matches messages to event handlers and runs the appropriate event handlers when found
* The event handlers are callbacks
* All processing occurs on the reactor thread
* All I/O happens on threads other than the reactor thread

## Slide 29: Simple EventMachine echo server

* EventMachine (http://rubyeventmachine.com/) is a Ruby reactor-based framework
* It provides a reactor and numerous demultiplexers
* Each demux has its own behavior
* This example uses the simple server demux
* The `Echo` class is the event handler
* The `Echo` class handles two events
* The `post_init` event is triggered immediately after a TCP connection is made
* The `receive_data` event is triggered every time the client sends data

### Running the reactor

* The EventMachine reactor is started using the `#run` method
* This method takes a block which initializes the reactor
* This is *NOT* the event loop--it is an initializer block
* Everything related to EventMachine *must* occur withing this block
* The `#run`method blocks forever as the reactor loop runs and runs and runs
* The only way to exit the `#run` method is to `#stop` the reactor, preferrably from within a reactor callback
* The telnet session in the upper right-hand corner shows this code in action
* EventMchine is a great framework but it takes over your entire application when you use it

## Slide 30: Fun with EventMachine

* This is a deliberately contrived and complex example
* It shows several demultiplexers and several event handlers
* It shows the full power of EventMachine
* One demux listens to an AMQP (RabbitMQ) queue--it responds to messages on the queue (`#subscribe`) and also to connection lifecycle events (`#on_error`)
* It uses the same simple server `Echo` example from the previous slide
* It uses a periodic timer to trigger events at regular intervals (just like `TimerTask` from earlier in the presentation)
* It traps OS signals to shut down the reactor (control-c and control-z)
* And it sets up an RPC server that uses Arachni-RPC to proxy calls to an array object

## Slide 31: Meltdown

*Do NOT block the reactor!*

* When doing event-driven programming it is important to not block the reactor
* Event handlers run on the same thread as the reactor
* Long-running operations, such as blocking I/O, will block the reactor thread
* The reactor will be unable to respond to new requests
* Alway try to perform blocking operations on a thread other than the reactor thread
* But do *NOT* spawn your own threads

## Slide 32: EM-friendly libraries

* Whenever possible, use libraries specifically designed to work with EventMachine
* This example updates the `Finance` class from earlier
* It replaces `RestClient` with `EventMachine::HttpRequest`
* It also uses the simple TCP server, in a variation of the `Echo` example from earlier
* The code look very different because the new library is event-driven (callback-based)
* But the new code plays nicely with EventMachine

## Slide 33: EventMachine Defer

* Sometimes it will not be possible to rewrite the code using an EM-friendly library
* This example uses the unmodified `Finance` class from earlier
* It also uses the simple TCP server, in a variation of the `Echo` example from earlier
* This example runs the blocking `#update` call within an EventMachine `#defer` block
* The `#defer` in this example is very similar to the future we saw at the beginning of the presentation, but only provides callbacks
* Now the blocking I/O can happen on EventMachine's internal thread pool and not block the reactor

## Slide 34: Lights, camera, action!

Celluloid is a Ruby actor framework.

* https://github.com/celluloid/celluloid
* Celluloid is "opinionated software"
* Like Rails and EventMachine it is intended to provide a complete solution
* Everything within Celluloid is tightly coupled to everything else within Celluloid
* It works great with itself and the other projects within its ecosystem
* It doesn't necessarily work so well with libraries outside theecosystem
* Most actor implementations are in functional programming languages and follow FP design principles
* Celluloid is different--Celluloid fully embraces Object Orientation
* Celluloid conflates the message passing described by Hewitt et. al. with Alan Kay's classic Smalltalk quote in which he equates method calls with message passing
* As a result, actors in Celluloid are fully asynchronous objects on which any method can be called asynchronously

## Slide 35: Celluloid

* This is the same `Finance` class we have been using the entire presentation
* The only difference is the `include Celluloid` line which turns objects of this class into Celluloid actors
* As seen at the bottom, the `#update` method can still be called synchronously and will still behave the same
* It can also be calles asynchronously via the `#async` proxy method
* When called asynchronously it behaves similarly to the asynchronous abstractions we looked at earlier

## Slide 36: Linking actors

* This slide may seem odd at first, but it reveals important functionality
* Celluloid allows actors to be linked so that they all die together
* This is a feature inspired by the Erlang virtual machine ability to link Erlang processes
* This is part of Erlang's famous "let it fail" philospohy
* Under this philosophy, there are only two states: good and bad
* There is no intermediate state between good and bad
* When something goes wrong the whole structure, no matter how complex, should be broken down so that it can be rebuilt

### The code

* The `#trap_exit` method is used to declaratively indicate which method should be called when linked actors die (in this case it's the `#actor died` method)
* Our simple `#actor_died` method just prints output to the console
* Our `Financier` class creates several actors and links itself to them using the `#link` method
* We then call the `#update` method of `Financier` with a query that we know will cause an exception
* As we see from the output, when the first actor dies all the actors in the tree die, thus ensuring we have no "partial" or "intermediate" state
* What we need now is some way to restart the actor tree…

## Slide 37: Supervisors, Part Deux

* As with Concurrent Ruby, Celluloid provides mechanisms for actor pools and Erlang-inspired supervisors
* As is the norm with Celluloid, these faetures are all tightly coupled
* The `Celluloid::SupervisionGroup` superclass is used to declaratively create a pool of actors to load balance requests
* Celluloid provides a global registry wher actors can be references--this allows one or more actors to be gloablly available throughout the program
* Supervision groups (actor pools) are implicitly registered in the global registry
* The pool is then accessed through the global registry and and Celluloid will quietly load balance across actors in the pool

### Gotchas

* Celluloid is a powerful framework…
* But with great power comes great responsibility
* The Celluloid wiki list numerous "Gotchas" that programmers must be aware of when using Celluloid (https://github.com/celluloid/celluloid/wiki/Gotchas)
* There are incompatabilities with several versions of MRI and JRuby
* Celluloid has issues with UNIX signals
* Celluloid actor pools have several known bugs
* Instance variable changes should only occur through Celluloid's proxy methods
* Block arguments work differently in Celluloid
* Celloid's use of Fibers may be incompatable with Fiber use in your code
* Celluloid doesn't want to mix with threads it doesn't create
* The blocking/non-blocking behavior of some I/O operations will behave differently than expected
* And more…

*Using Celluloid in your program is a commitment to Celluloid. It wants to be your complete concurrency solution. Be aware of the Celluloid "gotchas" when you make the commitment.*

## Slide 38: Write Code!

*This is my challenge to you: go write concurrent code!*

* Concurrency is hard
* Concurrent code behavies different
* Concurrency requires different ways of thinking
* Concurrency uses different designs

*The only way to learn concurrency is to write concurrent code.*

* This presentation has shown many powerful things without ever showing `Thread.new`
* None of the code examples show more than 30 lines of code
* Most are less than 10 lines
* All of this code was tested in IRB (that's how the output was verified)
* This presentation and all the code is in GitHub and there is even a Gemfile

*Everyone here now has the ability to write concurrent code.*

* Open your favorite editor
* Open a console
* `git clone`
* `bundle install`
* `irb`

*Write Code*
