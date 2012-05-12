require 'eventmachine'

Thread.abort_on_exception = true

module TankWars
  class Networking
    attr_accessor :server, :client

    def initialize(host, port, delegate)
      @client = EventEmitter.new(delegate)
      @events = []
      @thread = Thread.new do
        EM.run do
          EM.connect(host, port, Client, self)
        end
      end
    end

    class EventEmitter
      def initialize(delegate)
        @delegate = delegate
        @events = []
      end

      def proc_for(name, *args)
        proc { @delegate.send(name, *args) }
      end

      def dispatch(name, *args)
        @events << proc_for(name, *args)
      end

      def run
        while evt = @events.shift
          evt.call
        end
      end
    end

    class EMEmitter < EventEmitter
      def dispatch(name, *args)
        EM.next_tick { proc_for(name, *args).call }
      end
    end

    module Client
      include EM::Protocols::LineText2

      def initialize(network)
        super
        @network = network
        @network.server = EMEmitter.new(self)
      end

      def receive_line(line)
        case line
        when /^ASSIGN (\d+)$/
          @network.client.dispatch(:on_self_id, $1.to_i)

        when /^POSITIONS (.*?)$/
          clients = $1.split(" ").map do |client|
            id, pos, angle = client.split(":").map(&:to_i)
          end

          @network.client.dispatch(:on_update_positions, clients)

        when /^ANGLE (\d+) (\d+)$/
          @network.client.dispatch(:on_change_angle, $1.to_i, $2.to_i)

        when /^SHOT_FIRED (\d+) (\d+) (\d+)$/
          @network.client.dispatch(:on_shot_fired, $1.to_i, $2.to_i, $3.to_i)

        else
          puts "Unsupported message: #{line.inspect}"
        end
      end

      def send_killed_by(player)
        send_data("KILLED_BY #{player}\n")
      end

      def send_fire(angle, power)
        send_data("FIRE #{angle} #{power}\n")
      end

      def send_change_angle(value)
        send_data("ANGLE #{value}\n")
      end
    end
  end
end

