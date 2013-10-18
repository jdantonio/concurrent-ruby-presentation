require 'concurrent'
require_relative 'actor_ping_pong'

pong = Pong.new
ping = Ping.new(10000, pong)
pong.ping = ping

task = Concurrent::TimerTask.new{ print "Boom!\n" }

boss = Concurrent::Supervisor.new
boss.add_worker(ping)
boss.add_worker(pong)
boss.add_worker(task)

boss.run!

ping << :pong
