# Presentation: Concurrent Ruby

*NOTE: This presentation pre-dates the [API changes in the 0.5.0 release](https://github.com/jdantonio/concurrent-ruby/wiki/API-Updates-in-v0.5.0).
Some of the code examples will no longer work. With all of the work we've been doing on the gem
itself I haven't had an opportunity to update the code samples. The Gemfile in this repo specifies
the version of the gem for which all the code examples will work. I recommend using that version
when running the code in this presentation. I will update the code examples as soon as I can.
-- Jerry*

This is a presentation on Ruby concurrency I've given at several conferences and meetups in the
fall of 2013. Tags mark the version of the presentation used at each conference/meetup.
All the source code examples in the latest version of the presentation use my
[Concurrent Ruby](https://github.com/jdantonio/concurrent-ruby) gem.

Here is the conference/meetup list thus far:

* ["Advanced Concurrent Programming in Ruby"](http://rubyconf.org/program#jerry-dantonio) at [RubyConf 2013](http://rubyconf.org/),
  available for viewing on [Confreaks](http://www.confreaks.com/videos/2872-rubyconf2013-advanced-concurrent-programming-in-ruby)
* ["Advanced Multithreading in Ruby"](http://cascadiaruby.com/#advanced-multithreading-in-ruby) at [Cascadia Ruby 2013](http://cascadiaruby.com/),
  available for viewing on [Confreaks](http://www.confreaks.com/videos/2790-cascadiaruby2013-advanced-multithreading-in-ruby)
* [Cleveland Ruby Brigade](http://www.meetup.com/ClevelandRuby/events/149981942/) meetup on 12/5/2013
* I'll be giving ["Advanced Concurrent Programming in Ruby"](http://codemash.org/sessions) at [CodeMash 2014](http://codemash.org/)

## Presentation Abstract

> Rumor has it that you can't write concurrent programs in Ruby. People once believed
> that the world was flat and we all know how that turned out. Between the native threads
> introduced in MRI 1.9 and the JVM threading available to JRuby, Ruby is now a valid
> platform for concurrent applications. What we've been missing--until now--are the
> advanced concurrency tools available to other languages like Clojure, Scala, Erlang,
> Java, and Go. In this session we'll talk about the specific challenges faced when writing
> concurrent applications; we'll explore modern concurrency techniques such as agents,
> futures, promises, actors, supervisors, and others. We'll use various open source tools
> to craft safe, reliable, and efficient concurrent code.

## Sample Code

All of the source code shwon in the presentation is available in the `code` folder of this repo.
It has all been tested in IRB running under MRI 2.0. It should work fine under MRI 1.9 and above
and both JRuby and Rubinius running in 1.9 mode. As always, YMMV.

## Copyright

All source code in the `code` folder is Copyright &copy; 2013 [Jerry D'Antonio](https://twitter.com/jerrydantonio).
It is free software and may be redistributed under the terms of the [MIT license](http://www.opensource.org/licenses/mit-license.php).
