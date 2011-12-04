# Simple message producer.
# Generates one message and dies.

require "rubygems"
require "amqp"

EventMachine.run do
  AMQP.connect(:host => '127.0.0.1') do |connection|
    puts "Connected to AMQP broker. Running #{AMQP::VERSION} version of the gem..."

    AMQP::Channel.new(connection).direct("").publish("Package at #{Time.now}",
                                                     :routing_key => "q1") do
      connection.close { EventMachine.stop }
    end
    
  end
end
