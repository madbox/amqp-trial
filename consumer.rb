# Simple message consumer.
# Infinitely waits for messages and prints them.

require "rubygems"
require "amqp"

EventMachine.run do
  AMQP.connect(:host => '127.0.0.1') do |connection|
    puts "Connected to AMQP broker. Running #{AMQP::VERSION} version of the gem..."

    channel = AMQP::Channel.new(connection)

    channel.queue("tasks").subscribe do |metadata, payload|
      puts "Received a shout, obeying to producer"
      # Lets find any digits in payload and do some 'hard work' to consume more time and CPU
      if payload.match(/(\d+)/)
        count = $1 
        puts "Doing something #{count} times"
        t1 = Time.now; count.to_i.times { rand (8) }
        time_diff = (Time.now - t1) * 1000.0
        puts "Done in #{time_diff} msec"

        # Replying to queue given in metadata.reply_to by producer
        channel.direct("").publish("Task done in #{time_diff} msec",
                                   :routing_key => metadata.reply_to,
                                   :correlation_id => metadata.correlation_id)
      else
        puts "Something wrong! There is no digits!"
      end
    end
  end
end
