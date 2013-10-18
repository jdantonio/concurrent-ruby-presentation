require 'celluloid'
require 'rest_client'
require 'json'

class FinanceActor
  include Celluloid

  CALLBACK_TOKEN = 'YAHOO.Finance.SymbolSuggest.ssCallback'
  BASE_URL = 'http://d.yimg.com/autoc.finance.yahoo.com/autoc'
  BASE_QS = "query=%s&callback=YAHOO.Finance.SymbolSuggest.ssCallback"

  attr_reader :suggested_symbols
  attr_reader :url

  def initialize(query_string)
    @url = "%s?%s" % [BASE_URL, BASE_QS % query_string.downcase]
    @suggested_symbols = []
  end

  def update
    data = RestClient.get(@url)
    data = data.gsub(/^#{CALLBACK_TOKEN}\(\s*/, '').gsub(/\)\s*$/, '')
    data = JSON.parse(data)
    @suggested_symbols = data['ResultSet']['Result']
    return self
  end
end

yahoo = FinanceActor.new('YAHOO')
yahoo.update.suggested_symbols #=> [{"symbol"=>"YHOO", "name"=>"Yahoo! Inc."...

microsoft = FinanceActor.new('Microsoft')
microsoft.async.update
microsoft.suggested_symbols #=> []

# do important stuff...
microsoft.suggested_symbols #=> [{"symbol"=>"MSFT", "name"=>"Microsoft Corporation"...
