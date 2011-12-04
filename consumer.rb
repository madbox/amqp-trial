# Simple message consumer.
# Infinitely waits for messages and prints them.

require "rubygems"
require "amqp"

EventMachine.run do
  AMQP.connect(:host => '127.0.0.1') do |connection|
    puts "Connected to AMQP broker. Running #{AMQP::VERSION} version of the gem..."

    channel = AMQP::Channel.new(connection)

    channel.queue("q1").subscribe do |payload|
      puts "Received a message on q1: #{payload}."
    end

    channel.direct("").publish "Initializing", :routing_key => "q1"
  end
end
