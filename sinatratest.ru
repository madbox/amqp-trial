# The shortest web-server with amqp message generation i've found
# Launch string: thin start -p 3000 -R config.ru
# Thin based on EventMachine, so there is no need to run it

require "sinatra/base"
require "amqp"

class Test < Sinatra::Base
  def amqp &blk
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

  get "/" do
    amqp do
      p "publishing"
      AMQP::Channel.new(AMQP.connection).direct("").
        publish("WEB:Package at #{Time.now}", :routing_key => "q1")   
    end

    "o/"
  end
end

run Test.new
