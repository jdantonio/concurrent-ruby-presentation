require 'concurrent'

timer_task = Concurrent::TimerTask.new(execution_interval: 1) do |task|

  task.execution_interval.times{ print 'Boom! ' }
  print "\n"
  task.execution_interval += 1
  
  if task.execution_interval > 5
    puts 'Stopping...'
    task.stop
  end
end

timer_task.run # blocking call - this task will stop itself
#=> Boom!
#=> Boom! Boom!
#=> Boom! Boom! Boom!
#=> Boom! Boom! Boom! Boom!
#=> Boom! Boom! Boom! Boom! Boom!
#=> Stopping...
