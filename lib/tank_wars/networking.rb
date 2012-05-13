require 'eventmachine'
require 'thread'

Thread.abort_on_exception = true

module TankWars
  class Network
    def initialize(host, port)
      @network_event_queue = Queue.new
      @thread = Thread.new do
        EM.run do
          EM.connect(host, port, NetworkClient, @network_event_queue) do |connection|
            @connection = connection
          end
        end
      end
    end

    def dispatch_network_events_to(receiver)
      @network_event_queue.size.times do
        @network_event_queue.pop.call(receiver)
      end
    end

    def send_to_network(name, *args)
      EM.schedule { @connection.send(name, *args) }
    end
  end


  module NetworkClient
    include EM::Protocols::LineText2

    def initialize(event_queue)
      super
      @event_queue = event_queue
    end

    def push_event(symbol, *args)
      @event_queue.push(proc { |receiver| receiver.send(symbol, *args) })
    end

    def receive_line(line)
      case line
        when /^ASSIGN (\d+)$/
          push_event(:on_self_id, $1.to_i)

        when /^POSITIONS (.*?)$/
          clients = $1.split(" ").map do |client|
            id, pos, angle = client.split(":").map(&:to_i)
          end

          push_event(:on_update_positions, clients)

        when /^ANGLE (\d+) (\d+)$/
          push_event(:on_change_angle, $1.to_i, $2.to_i)

        when /^SHOT_FIRED (\d+) (\d+) (\d+)$/
          push_event(:on_shot_fired, $1.to_i, $2.to_i, $3.to_i)

        when /^KILLED_BY (\d+) (\d+)$/
          push_event(:on_kill_event, $1.to_i, $2.to_i)

        else
          puts "Unsupported message: #{line.inspect}"
      end
    end

    def send_killed_by(player)
      send_data("KILLED_BY #{player}\n")
    end


    def send_position(x)
      send_data("POSITION #{x}\n")
    end


    def send_fire(angle, power)
      send_data("FIRE #{angle} #{power}\n")
    end

    def send_change_angle(value)
      send_data("ANGLE #{value}\n")
    end
  end
end
