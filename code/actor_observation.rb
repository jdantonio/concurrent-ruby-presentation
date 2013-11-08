require 'concurrent'

class ActorObserver
  def update(time, message, result, ex)
    if result
      print "(#{time}) Message #{message} returned #{result}\n"
    elsif ex.is_a?(Concurrent::TimeoutError)
      print "(#{time}) Message #{message} timed out\n"
    else
      print "(#{time}) Message #{message} failed with error #{ex}\n"
    end
  end
end

class SimpleActor < Concurrent::Actor
  def act(*message)
    message
  end
end

actor = SimpleActor.new
actor.add_observer(ActorObserver.new)
actor.run!
sleep(0.1)

actor.post(1)
#=> (2013-11-07 18:35:33 -0500) Message [1] returned [1]

actor.post(1,2,3)
#=> (2013-11-07 18:35:54 -0500) Message [1, 2, 3] returned [1, 2, 3]

actor.post('The Nightman Cometh')
#=> (2013-11-07 18:36:11 -0500) Message ["The Nightman Cometh"] returned ["The Nightman Cometh"]
