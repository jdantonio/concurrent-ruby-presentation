require 'concurrent'
require_relative 'finance'

yahoo = Finance.new('YAHOO')
shock = Concurrent::Future.new { yahoo.update.suggested_symbols }
shock.state #=> :pending
shock.value(0) #=> nil (call blocks for 0 seconds)

# do important stuff...

shock.state #=> :fulfilled
shock.value #=> [{"symbol"=>"YHOO", "name"=>"Yahoo! Inc."...
            #   (call blocks indefinitely) 

bogus = Finance.new('this creates a bogus URL')
awe = Concurrent::Future.new { bogus.update.suggested_symbols }
awe.state #=> :pending
awe.value(0) #=> nil (call blocks for 0 seconds)

# do important stuff...

awe.state  #=> :rejected
awe.reason #=> #<URI::InvalidURIError: bad URI(is not URI?)...
           #   (call blocks indefinitely) 
