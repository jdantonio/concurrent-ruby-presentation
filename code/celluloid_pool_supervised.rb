require 'celluloid'
require 'rest_client'
require 'json'

class FinanceMinion
  include Celluloid

  CALLBACK_TOKEN = 'YAHOO.Finance.SymbolSuggest.ssCallback'
  BASE_URL = 'http://d.yimg.com/autoc.finance.yahoo.com/autoc'
  BASE_QS = "query=%s&callback=YAHOO.Finance.SymbolSuggest.ssCallback"

  attr_reader :suggested_symbols

  def update(query_string)
    @url = "%s?%s" % [BASE_URL, BASE_QS % query_string.downcase]
    data = RestClient.get(@url)
    data = data.gsub(/^#{CALLBACK_TOKEN}\(\s*/, '').gsub(/\)\s*$/, '')
    data = JSON.parse(data)
    return data['ResultSet']['Result']
  end
end

class FinancierGroup < Celluloid::SupervisionGroup
  pool FinanceMinion, as: :finance, size: 3
end

FinancierGroup.run!

['YAHOO', 'Microsoft', 'google'].each do |query|
  puts Celluloid::Actor[:finance].update(query)
end

# do important stuff...

#>> {"symbol"=>"YHOO", "name"=>"Yahoo! Inc."...
#>> {"symbol"=>"YOJ.SG", "name"=>"YAHOO JAPAN"...
#>> {"symbol"=>"YHOO.BA", "name"=>"Yahoo! Inc."...
#>> and many more...
