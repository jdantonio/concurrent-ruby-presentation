require 'concurrent'

class Ping < Concurrent::Actor

  def initialize(count, pong)
    super()
    @pong = pong
    @remaining = count
  end
  
  def act(msg)

    if msg == :pong
      print "Ping: pong\n" if @remaining % 1000 == 0
      @pong.post(:ping)

      if @remaining > 0
        @pong << :ping
        @remaining -= 1
      else
        print "Ping :stop\n"
        @pong << :stop
        self.stop
      end
    end
  end
end

class Pong < Concurrent::Actor

  attr_writer :ping

  def initialize
    super()
    @count = 0
  end

  def act(msg)

    if msg == :ping
      print "Pong: ping\n" if @count % 1000 == 0
      @ping << :pong
      @count += 1

    elsif msg == :stop
      print "Pong :stop\n"
      self.stop
    end
  end
end

pong = Pong.new
ping = Ping.new(10000, pong)
pong.ping = ping

t1 = ping.run!
t2 = pong.run!
sleep(0.1)

ping << :pong
