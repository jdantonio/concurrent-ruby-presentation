require 'concurrent'

class TaskObserver
  def update(time, result, ex)
    if result
      print "(#{time}) Execution successfully returned #{result}\n"
    elsif ex.is_a?(Concurrent::TimeoutError)
      print "(#{time}) Execution timed out\n"
    else
      print "(#{time}) Execution failed with error #{ex}\n"
    end
  end
end

task = Concurrent::TimerTask.new(execution_interval: 1){ 42 }
task.add_observer(TaskObserver.new)
task.run!

#=> (2013-10-13 19:08:58 -0400) Execution successfully returned 42
#=> (2013-10-13 19:08:59 -0400) Execution successfully returned 42
#=> (2013-10-13 19:09:00 -0400) Execution successfully returned 42
task.stop
