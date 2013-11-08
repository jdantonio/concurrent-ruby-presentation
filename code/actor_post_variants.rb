require 'concurrent'

class EverythingActor < Concurrent::Actor
  def act(message)
    sleep(5)
    return 42
  end
end

life = EverythingActor.new
life.run!

universe = life.post?('What do you get when you multiply six by nine?')
universe.pending? #=> true

# wait for it...
universe.fulfilled? #=> true
universe.value      #=> 42

life.post!(1, 'Mostly harmless.')

# wait for it...
#=> Concurrent::TimeoutError: Concurrent::TimeoutError
