require 'concurrent'

task = Concurrent::ScheduledTask.new(2) do
  'What does the fox say?'
end
task.pending?      #=> true
task.schedule_time #=> 2013-11-07 12:20:07 -0500

sleep(3) # wait for it...

task.fulfilled? #=> true
task.value      #=> 'What does the fox say?'

# --------

t = Time.now + 2
task = Concurrent::ScheduledTask.new(t) do
  raise StandardError.new('Call me maybe?')
end
task.pending?      #=> true
task.schedule_time #=> 2013-11-07 12:22:01 -0500

sleep(3) # wait for it...

task.rejected?  #=> true
task.reason     #=> #<StandardError: Call me maybe?> 
