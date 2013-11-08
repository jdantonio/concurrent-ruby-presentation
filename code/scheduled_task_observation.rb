require 'concurrent'

observer = Class.new{
  def update(time, value, reason)
    puts "The task completed at #{time} with value:\n\t'#{value}'"
  end
}.new

task = Concurrent::ScheduledTask.new(2) do
  'What does the fox say?'
end
task.add_observer(observer)
task.pending?      #=> true
task.schedule_time #=> 2013-11-07 12:20:07 -0500

sleep(3) # wait for it...

#=> The task completed at 2013-11-07 17:30:41 -0500 with value:
#=> 	'What does the fox say?'

# --------

task = Concurrent::ScheduledTask.new(10) do
  raise StandardError.new('Call me maybe?')
end
sleep(1)
task.cancel #=> true
