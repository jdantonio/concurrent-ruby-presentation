require 'concurrent'

channel = Concurrent::Channel.new { |*message|
  print "#{message} handled by #{Thread.current}\n"
}

channel.run!
channel.post("Wibbly Wobbly Timey Wimey... Stuff") #=> 1
#=> ["Wibbly Wobbly Timey Wimey... Stuff"] handled by #<Thread:0x007fcfe336cd00>

# --------

mailbox, pool = Concurrent::Channel.pool(5) { |*message|
  print "#{message} handled by #{Thread.current}\n"
}

pool.each{|echo| echo.run! }

10.times{|i| mailbox.post(i) } #=> 10
#=> [0] handled by #<Thread:0x007fcfe3324398>
#=> [1] handled by #<Thread:0x007fcfe3324230>
#=> [2] handled by #<Thread:0x007fcfe331fed8>
#=> [3] handled by #<Thread:0x007fcfe3324028>
#=> [4] handled by #<Thread:0x007fcfe33261c0>
#=> [5] handled by #<Thread:0x007fcfe3324398>
#=> [6] handled by #<Thread:0x007fcfe3324028>
#=> [7] handled by #<Thread:0x007fcfe331fed8>
#=> [8] handled by #<Thread:0x007fcfe3324398>
#=> [9] handled by #<Thread:0x007fcfe3324028>
