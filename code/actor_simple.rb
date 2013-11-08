require 'concurrent'

class EchoActor < Concurrent::Actor
  def act(*message)
    puts "#{message} handled by #{self}"
  end
end

echo = EchoActor.new
echo.run!
sleep(0.1)

echo.post("Don't panic") #=> true
#=> ["Don't panic"] handled by #<EchoActor:0x007fc8014d0668>

# --------

mailbox, pool = EchoActor.pool(5)
pool.each{|echo| echo.run! }

10.times{|i| mailbox.post(i) }
#=> [0] handled by #<EchoActor:0x007fc8014fb8b8>
#=> [1] handled by #<EchoActor:0x007fc8014fb890>
#=> [2] handled by #<EchoActor:0x007fc8014fb868>
#=> [3] handled by #<EchoActor:0x007fc8014fb890>
#=> [4] handled by #<EchoActor:0x007fc8014fb840>
#=> [5] handled by #<EchoActor:0x007fc8014fb8b8>
#=> [6] handled by #<EchoActor:0x007fc8014fb8b8>
#=> [7] handled by #<EchoActor:0x007fc8014fb818>
#=> [8] handled by #<EchoActor:0x007fc8014fb890>
