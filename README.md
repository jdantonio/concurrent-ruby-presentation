# Presentation: Concurrent Ruby

This is a presentation on Ruby concurrency I gave at [RubyConf 2013](http://rubyconf.org/)
in Miami Beach, FL on Saturday, November 9th. I previously gave a variation of this
presentation at [Cascadia Ruby 2013](http://cascadiaruby.com/) in Portland, OR
on Tuesday, October 22nd.

## Presentation Abstract

The presentation was formally titled [Advanced Concurrent Programming in Ruby](http://rubyconf.org/program#jerry-dantonio)
and had the following abstract:

> Rumor has it that you can't write concurrent programs in Ruby. People once believed
> that the world was flat and we all know how that turned out. Between the native threads
> introduced in MRI 1.9 and the JVM threading available to JRuby, Ruby is now a valid
> platform for concurrent applications. What we've been missing--until now--are the
> advanced concurrency tools available to other languages like Clojure, Scala, Erlang,
> and Go. In this session we'll talk about the specific challenges faced when writing
> concurrent applications; we'll explore modern concurrency techniques such as agents,
> futures, promises, reactors, and supervisors; and we'll use various open source tools
> to craft safe, reliable, and efficient concurrent code. We'll write most of our code
> using the Concurrent Ruby gem but we'll also explore EventMachine and Celluloid.

## Sample Code

All of the source code shwon in the presentation is available in the `code` folder of this repo.
It has all been tested in IRB running under MRI 2.0. It should work fine under MRI 1.9 and above
and both JRuby and Rubinius running in 1.9 mode. As always, YMMV.

## Copyright

All source code in the `code` folder is Copyright &copy; 2013 [Jerry D'Antonio](https://twitter.com/jerrydantonio).
It is free software and may be redistributed under the terms of the [MIT license](http://www.opensource.org/licenses/mit-license.php).
