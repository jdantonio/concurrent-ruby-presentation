require 'eventmachine'
require 'em-http-request'
require 'json'

module EmFinance

  CALLBACK_TOKEN = 'YAHOO.Finance.SymbolSuggest.ssCallback'
  BASE_URL = 'http://d.yimg.com/autoc.finance.yahoo.com/autoc'
  BASE_QS = "query=%s&callback=YAHOO.Finance.SymbolSuggest.ssCallback"

  def self.suggested_symbols(query, peer)
    qs = {query: query, callback: 'YAHOO.Finance.SymbolSuggest.ssCallback'}
    http = EventMachine::HttpRequest.new(BASE_URL).get(query: qs)

    http.errback { peer.send_data("An error occurred retrieving data for '#{query}'") }

    http.callback {
      data = http.response.gsub(/^#{CALLBACK_TOKEN}\(\s*/, '').gsub(/\)\s*$/, '')
      data = JSON.parse(data)
      peer.send_data("#{data['ResultSet']['Result']}\n")
    }
  end
end

class AsyncFinance < EventMachine::Connection
  def receive_data(data)
    data = data.strip

    if data =~ /^goodbye$/i
      close_connection
    else
      EmFinance.suggested_symbols(data, self)
    end
  end
end

EventMachine.run do
  Signal.trap('TERM'){ EventMachine.stop }
  Signal.trap('INT'){ EventMachine.stop }

  EventMachine.start_server('127.0.0.1', 8081, AsyncFinance)
end
