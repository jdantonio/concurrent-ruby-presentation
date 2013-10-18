require 'concurrent'
require_relative 'finance'

ticker = Concurrent::Agent.new([])
ticker.value #=> []

yahoo = Finance.new('YAHOO')
ticker.post{|suggested_symbols| suggested_symbols + yahoo.update.suggested_symbols }
ticker.value.length #=> 0

# wait for it...
ticker.value.length #=> 10

ms = Finance.new('Microsoft')
ticker.post{|suggested_symbols| ms.update.suggested_symbols + suggested_symbols }
ticker.value.count #=> 10

# wait for it...
ticker.value.count #=> 20

ticker.post{|suggested_symbols| raise StandardError }
ticker.value.count #=> 20

# wait for it...
ticker.value.count #=> 20
