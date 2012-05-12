require 'eventmachine'

Thread.abort_on_exception = true

class TankWars
  class Networking
    PORT = 9876
    attr_reader :client, :server

    def initialize(delegate)
      @client = EventEmitter.new(delegate)
      @server = EMEmitter.new(self)

      @events = []
      @thread = Thread.new(@channel) do |c|
        EM.run do
          EM.connect('ses-thinkpad-w510.local', 9876, Client, self)
        end
      end
    end

    class EventEmitter
      def initialize(delegate)
        @delegate = delegate
        @events = []
      end

      def dispatch(name, *args)
        @events << proc { @delegate.send(name, *args) }
      end

      def run
        while evt = @events.shift
          evt.call
        end
      end
    end

    class EMEmitter < EventEmitter
      def dispatch(*args)
        super
        EM.schedule { run }
      end
    end

    module Client
      include EM::Protocols::LineText2

      def initialize(network)
        super
        @network = network
      end

      def receive_line(line)
        case line
        when /^ASSIGN (\d+)$/
          @network.client.dispatch(:on_myself, $1.to_i)
        when /^POSITIONS (.*?)$/
          clients = $1.split(" ").map do |client|
            id, pos = client.split(":").map(&:to_i)
          end

          @network.client.dispatch(:on_update_positions, clients)
        else
          puts "Unsupported message: #{line.inspect}"
        end
      end
    end
  end
end

