require 'concurrent'
require 'hamster'
require_relative 'finance'

ticker = Concurrent::Agent.new(Hamster.vector)
ticker.value #=> []

yahoo = Finance.new('YAHOO')
ticker.post do |suggested_symbols|
  yahoo.update.suggested_symbols.each do |symbol|
    suggested_symbols = suggested_symbols.cons(symbol)
  end
  suggested_symbols
end
ticker.value.length #=> 0

# wait for it...
ticker.value.length #=> 10

# -- or --

require 'concurrent'
require 'thread_safe'

ticker = Concurrent::Agent.new(ThreadSafe::Array.new)
ticker.value #=> []

yahoo = Finance.new('YAHOO')
ticker.post{|suggested_symbols| suggested_symbols + yahoo.update.suggested_symbols }
ticker.value.length #=> 0

# wait for it...
ticker.value.length #=> 10
