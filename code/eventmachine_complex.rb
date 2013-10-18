require 'eventmachine'
require 'amqp'
require 'arachni/rpc/em'

QUEUE_NAME = 'fun.with.eventmachine'

EventMachine.run do
  connection = AMQP.connect(:host => '127.0.0.1')
  channel  = AMQP::Channel.new(connection)
  queue    = channel.queue(QUEUE_NAME, :auto_delete => true)
  exchange = channel.direct('')
 
  queue.subscribe do |payload|
    exchange.publish(payload, :routing_key => queue.name)
  end

  connection.on_error do |conn, connection_close|
    puts 'AMQP Connection Error!'
  end
 
  EventMachine.start_server('127.0.0.1', 8081, Echo)

  EM.add_periodic_timer(10) do
    puts "[#{Time.now}] The cake is a lie.'"
  end

  Signal.trap('TERM'){ EventMachine.stop }
  Signal.trap('INT'){ EventMachine.stop }

  rpc_server = Arachni::RPC::EM::Server.new(host: 'localhost', port: 7332)
  rpc_server.add_handler('vector', Array.new)
  rpc_server.run
end

#-------------------------------------

require 'eventmachine'
require 'arachni/rpc/em'

rpc_client = Arachni::RPC::EM::Client.new(host: 'localhost', port: 7332)
vector = Arachni::RPC::RemoteObjectMapper.new(rpc_client, 'vector')

10.times{|i| vector.push(i){} }
vector.length #=> 10
vector.first  #=> 0
vector.last   #=> 9
