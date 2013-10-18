require 'concurrent'

task = Concurrent::TimerTask.new(execution: 5, timeout: 5) do
  print "Boom!\n"
end

task.execution_interval #=> 5; default 60
task.timeout_interval   #=> 5; default 30
task.run!

# wait 5 seconds...
#=> 'Boom!'

# wait 5 seconds...
#=> 'Boom!'

# wait 5 seconds...
#=> 'Boom!'

task.stop #=> true
