require 'rubygems'

require 'thread'

iterations = 3
mutex = Mutex.new
resource = ConditionVariable.new

def pingpong(name, mutex, resource, count)
  return Thread.new do
    count.times do
      mutex.synchronize do
        resource.wait(mutex)
        print "#{name}!\n"
        resource.signal
      end
    end
  end
end

puts 'Ready... Set... Go!'
puts

ping = pingpong('Ping', mutex, resource, iterations)
pong = pingpong('Pong', mutex, resource, iterations)

resource.signal

ping.join
pong.join

puts 'Done!'
