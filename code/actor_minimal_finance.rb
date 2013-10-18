class SimpleFinancialActor

  def initialize
    @mailbox = Queue.new
    @thread = Thread.new do
      loop do
        query_string = @mailbox.pop
        get_suggected_symbols(query_string)
      end
    end
  end

  def post(query_string)
    @mailbox.push(query_string)
  end

  protected

  def get_suggected_symbols(query_string)
    finance = Finance.new(query_string)
    finance.update
    puts finance.suggested_symbols
  end
end

actor = SimpleFinancialActor.new
actor.post('YAHOO')
actor.post('Microsoft')
actor.post('google')

# do important stuff...

#>> {"symbol"=>"YHOO", "name"=>"Yahoo! Inc.", "exch"=>"NMS", "type"=>"S", "exchDisp"=>"NASDAQ", "typeDisp"=>"Equity"}
#>> {"symbol"=>"YOJ.SG", "name"=>"YAHOO JAPAN", "exch"=>"STU", "type"=>"S", "exchDisp"=>"Stuttgart", "typeDisp"=>"Equity"}
#>> {"symbol"=>"YHOO.BA", "name"=>"Yahoo! Inc.", "exch"=>"BUE", "type"=>"S", "exchDisp"=>"Buenos Aires", "typeDisp"=>"Equity"}
#>> and many more...
