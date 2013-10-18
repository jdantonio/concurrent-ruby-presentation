require 'eventmachine'
require 'socket'
require_relative 'finance'

class AsyncFinance < EventMachine::Connection

  def post_init
    @peername = "%s:%s" % Socket.unpack_sockaddr_in(get_peername).reverse
    puts "Connected to #{@peername}"
  end

  def unbind
    puts "Disconnected from #{@peername}"
  end

  def receive_data(data)
    data = data.strip

    if data =~ /^goodbye$/i
      close_connection
    else
      EventMachine.defer do
        puts "Getting stock symbol information for '#{data}'"
        suggested_symbols = Finance.new(data).update.suggested_symbols
        send_data("#{suggested_symbols.to_s}\n")
      end
    end
  end
end

EventMachine.run do
  Signal.trap('TERM'){ EventMachine.stop }
  Signal.trap('INT'){ EventMachine.stop }

  EventMachine.start_server('127.0.0.1', 8081, AsyncFinance)
end
