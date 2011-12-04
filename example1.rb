#!/usr/bin/env ruby
# encoding: utf-8

# Slightly changed example from ruby-amqp tutorial

require "rubygems"
require "amqp"

EventMachine.run do
  AMQP.connect(:host => '127.0.0.1') do |connection|
    puts "Connected to AMQP broker. Running #{AMQP::VERSION} version of the gem..."

    channel = AMQP::Channel.new(connection)

    channel.queue("amqpgem.examples.helloworld1", :auto_delete => true).subscribe do |payload|
      puts "Received a message on queue 1: #{payload}. Disconnecting..."
      connection.close { EventMachine.stop }
    end

    # i've added another queue, just for fun
    channel.queue("amqpgem.examples.helloworld2", :auto_delete => true).subscribe do |payload|
      puts "Received a message on queue 2: #{payload}. Disconnecting..."
      connection.close { EventMachine.stop }
    end

    channel.direct("").publish "Hello, world!", :routing_key => "amqpgem.examples.helloworld2"
  end
end
