class ActorImpl

  def initialize(&block)
    raise ArgumentError unless block_given?
    @mailbox = Queue.new
    @task = block
    @thread = Thread.new do
      loop do
        msg = @mailbox.pop
        @task.call(msg)
      end
    end
  end

  def post(message)
    @mailbox.push(message)
  end
end

bryan_cranston = ActorImpl.new do |message|
  print "Say my name. #{message}.\n"
end

3.times do
  bryan_cranston.post('Heisenberg')
end

#>> Say my name. Heisenberg.
#>> Say my name. Heisenberg.
#>> Say my name. Heisenberg.
