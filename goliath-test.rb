# Simple goliath-based web server. Creates amqp message on every
# request.

require 'goliath'
require 'amqp'
# Don't work for me. Getting 'error: unexpected return'
# require 'em-synchrony'
# require 'em-synchrony/amqp'

require 'pp'

class Hello < Goliath::API
  use Goliath::Rack::Render, ['json']

  def response(env)
    puts "Request: '#{env['REQUEST_METHOD']}' on '#{env['REQUEST_URI']}'"
    puts "Responce fiber: #{Fiber.current}"

    connection = AMQP.connect "amqp://127.0.0.1"
    channel = AMQP::Channel.new(connection)

    corr_id = Time.now.to_f.to_s
    channel.direct("").
      publish("Do something wicked #{rand(10000000)} times my stuid consumer",
              :routing_key => "tasks",
              :reply_to => 'results',
              :correlation_id => corr_id )
    puts "Task posted. Correlation id: #{corr_id}"

    # Global variable. Is there another way?
    $f = Fiber.current

    channel.queue("results").subscribe do |metadata, payload|
      puts "Subscribe fiber: #{Fiber.current}, f:#{$f}"
      puts "Result recieved"
      puts "Payload: #{payload}\nCorrelation id: #{metadata.correlation_id}"
      $f.resume
    end

    # TODO: Timeout should be added here. I should wait some time then consider RPC failed.
    Fiber.yield

    # amqp do
    #   # q1 - just any queue name you want
    #   AMQP::Channel.new(AMQP.connection).direct("").
    #     publish("Do something wicked #{rand(10000000)} times my stuid consumer",
    #             :routing_key => "tasks",
    #             :reply_to => 'results',
    #             :correlation_id => '123')
    # end

    [200, {}, "Hello World"]
  end

  # def amqp &blk
  #   EM.next_tick do
  #     if ! AMQP.connection
  #       AMQP.connection = AMQP.connect "amqp://127.0.0.1"
  #     end
  #     if ! AMQP.connection.connected?
  #       AMQP.connection.register_connection_callback do
  #         raise "Error couldn't connect" unless AMQP.connection.connected?
  #         blk.()
  #       end
  #     else
  #       blk.()
  #     end      
  #   end
  # end

end
