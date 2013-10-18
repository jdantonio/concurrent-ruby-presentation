require 'concurrent'
require_relative 'finance'

ticker = Concurrent::Promise.new([]) {|suggested_symbols|
  suggested_symbols + Finance.new('YAHOO').update.suggested_symbols
}.then {|suggested_symbols|
  suggested_symbols + Finance.new('Microsoft').update.suggested_symbols
}
ticker.pending? #=> true

# wait for it...
ticker.pending?     #=> false
ticker.value.length #=> 20

# --------

ticker = Concurrent::Promise.new([]) {|suggested_symbols|
  suggested_symbols + Finance.new('YAHOO').update.suggested_symbols
}.then {|suggested_symbols|
  raise ArgumentError.new("You're a bad monkey Mojo Jojo")
}.rescue(StandardError) {|ex|
  print ex
}
ticker.pending?  #=> true

# wait for it...
ticker.rejected? #=> true
ticker.reason    #=> => #<ArgumentError: You're a bad monkey Mojo Jojo>
