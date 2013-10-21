# Presentation: Concurrent Ruby

This is a presentation on Ruby concurrency I gave at [Cascadia Ruby](http://cascadiaruby.com/)
in Portland, OR on Tuesday, October 22nd.

## Presentation Abstract

The presentation was formally titled *Advanced Multithreading in Ruby* and had the following abstract:

> By now we've all heard apocalyptic pronouncements that because of multi-core processors all programmers are doomed to the eternal abyss of concurrent programming. I'm here to tell you that despite what the Chicken Littles say, the sky is not falling. Yes, concurrent programming is hard. Especially when you have to do it in the old-school lock-and-synchronize paradigm. But we live in the brave new world of asynchronous concurrency, event-driven programming, and actors. Between the native threads introduced in MRI 1.9 and the Java threading available to JRuby, Ruby is now a valid platform for concurrent applications. What we've been missing--until now--are the advanced concurrency tools available to other languages like Clojure, Scala, Erlang, and JavaScript. In this presentation we'll talk about the specific challenges faced when writing concurrent applications; we'll explore modern concurrency techniques such as agents, futures, and promises; and we'll use the concurrent-ruby gem to implement safe, reliable, and efficient concurrent code.

## Sample Code

All of the source code shwon in the presentation is available in the `code` folder of this repo.
It has all been tested in IRB running under MRI 2.0. As always, YMMV.

## Copyright

This presentation is Copyright &copy; 2013 [Jerry D'Antonio](https://twitter.com/jerrydantonio).
All Rights Reserved.

All source code in the `code` folder is Copyright &copy; 2013 [Jerry D'Antonio](https://twitter.com/jerrydantonio).
It is free software and may be redistributed under the terms of the [MIT license](http://www.opensource.org/licenses/mit-license.php).
