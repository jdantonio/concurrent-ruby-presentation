require 'eventmachine'

class Echo < EventMachine::Connection
  def post_init
    send_data "CONNECTED >>\n"
  end

  def receive_data(data)
    data = data.strip
    if data == 'stop'
      puts 'Stopping...'
      EventMachine.stop
    else
      send_data ">> #{data}\n"
      puts "ECHO: #{data}"
    end
  end
end

EventMachine.run {
  EventMachine.start_server('127.0.0.1', 8081, Echo)
}

#=> ECHO: Say my name.
#=> ECHO: Heisenberg
#=> ECHO: I am not in danger, Skylar.
#=> ECHO: I am the danger.
#=> ECHO: No. I am the one who knocks!
#=> Stopping...
#=> nil 
