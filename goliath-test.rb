require 'goliath'
require 'amqp'

class Hello < Goliath::API
  use Goliath::Rack::Render, ['json']

  def response(env)

    puts env.inspect

    amqp do
      # q1 - just any queue name you want
      AMQP::Channel.new(AMQP.connection).direct("").
        publish("Yelling at #{Time.now}", :routing_key => "q1")
    end

    [200, {}, "Hello World"]
  end

  def amqp &blk
    EM.next_tick do
      if ! AMQP.connection
        AMQP.connection = AMQP.connect "amqp://127.0.0.1"
      end
      if ! AMQP.connection.connected?
        AMQP.connection.register_connection_callback do
          raise "Error couldn't connect" unless AMQP.connection.connected?
          blk.()
        end
      else
        blk.()
      end      
    end
  end

end
