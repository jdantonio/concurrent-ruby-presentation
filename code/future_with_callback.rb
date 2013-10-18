require 'concurrent'
require_relative 'finance'

class Ticker
  Stock = Struct.new(:symbol, :name, :exchange)

  def update(time, value, reason)
    ticker = value.collect do |symbol|
      Stock.new(symbol['symbol'], symbol['name'], symbol['exch'])
    end

    output = ticker.join("\n")
    print "#{output}\n"
  end
end

yahoo = Finance.new('YAHOO')
future = Concurrent::Future.new { yahoo.update.suggested_symbols }
future.add_observer(Ticker.new)

# do important stuff...

#>> #<struct Ticker::Stock symbol="YHOO", name="Yahoo! Inc.", exchange="NMS">
#>> #<struct Ticker::Stock symbol="YHO.DE", name="Yahoo! Inc.", exchange="GER">
#>> #<struct Ticker::Stock symbol="YAHOY", name="Yahoo Japan Corporation", exchange="PNK">
#>> #<struct Ticker::Stock symbol="YAHOF", name="YAHOO JAPAN CORP", exchange="PNK">
#>> #<struct Ticker::Stock symbol="YOJ.SG", name="YAHOO JAPAN", exchange="STU">
#>> #<struct Ticker::Stock symbol="YHO.SG", name="YAHOO", exchange="STU">
#>> #<struct Ticker::Stock symbol="YHOO.BA", name="Yahoo! Inc.", exchange="BUE">
#>> #<struct Ticker::Stock symbol="YHO.DU", name="YAHOO", exchange="DUS">
#>> #<struct Ticker::Stock symbol="YHO.HM", name="YAHOO", exchange="HAM">
#>> #<struct Ticker::Stock symbol="YHO.BE", name="YAHOO", exchange="BER">
