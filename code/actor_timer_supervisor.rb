require 'concurrent'
require_relative 'finance'

QUERIES = %w[YAHOO Microsoft google]

class FinanceActor < Concurrent::Actor
  def act(query)
    finance = Finance.new(query)
    print "[#{Time.now}] RECEIVED '#{query}' to #{self} returned #{finance.update.suggested_symbols}\n\n"
  end
end

financial, pool = FinanceActor.pool(5)

timer_proc = proc do
  query = QUERIES[rand(QUERIES.length)]
  financial.post(query)
  print "[#{Time.now}] SENT '#{query}' from #{self} to worker pool\n\n"
end

t1 = Concurrent::TimerTask.new(execution_interval: rand(5)+1, &timer_proc)
t2 = Concurrent::TimerTask.new(execution_interval: rand(5)+1, &timer_proc)

overlord = Concurrent::Supervisor.new

overlord.add_worker(t1)
overlord.add_worker(t2)
pool.each{|actor| overlord.add_worker(actor)}

overlord.run! # the #run method blocks, #run! does not

#>> [2013-10-18 09:35:28 -0400] SENT 'YAHOO' from main to worker pool
#>> [2013-10-18 09:35:28 -0400] RECEIVED 'YAHOO' to #<FinanceActor:0x0000010331af70>...
#>> [2013-10-18 09:35:30 -0400] SENT 'google' from main to worker pool
#>> [2013-10-18 09:35:30 -0400] RECEIVED 'google' to #<FinanceActor:0x0000010331ae58>...
#>> [2013-10-18 09:35:31 -0400] SENT 'google' from main to worker pool
#>> [2013-10-18 09:35:31 -0400] RECEIVED 'google' to #<FinanceActor:0x0000010331ad40>...
#>> [2013-10-18 09:35:34 -0400] SENT 'YAHOO' from main to worker pool
#>> [2013-10-18 09:35:34 -0400] RECEIVED 'YAHOO' to #<FinanceActor:0x0000010331ac28>...
#>> [2013-10-18 09:35:35 -0400] SENT 'google' from main to worker pool
#>> [2013-10-18 09:35:35 -0400] RECEIVED 'google' to #<FinanceActor:0x0000010331ab10>...
#>> [2013-10-18 09:35:37 -0400] SENT 'Microsoft' from main to worker pool
#>> [2013-10-18 09:35:37 -0400] RECEIVED 'Microsoft' to #<FinanceActor:0x0000010331af70>...
#>> [2013-10-18 09:35:39 -0400] SENT 'google' from main to worker pool
#>> [2013-10-18 09:35:39 -0400] SENT 'Microsoft' from main to worker pool
#>> [2013-10-18 09:35:39 -0400] RECEIVED 'Microsoft' to #<FinanceActor:0x0000010331ae58>...
#>> [2013-10-18 09:35:39 -0400] RECEIVED 'google' to #<FinanceActor:0x0000010331ad40>...

overlord.stop #=> true
