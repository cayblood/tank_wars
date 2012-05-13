require 'eventmachine'

class World
  GAP_BETWEEN_PLAYERS = 250
  WORLD_WIDTH = 1024

  def initialize
    @clients = {}
  end

  def broadcast(message)
    @clients.values.each do |client|
      puts "sending #{message} to #{client.id}"
      client.send_data(message)
    end
  end

  def next_free_position
    valid_positions = (50...WORLD_WIDTH).step(GAP_BETWEEN_PLAYERS).to_a
    valid_positions.shuffle.each do |xpos|
      unless @clients.values.any? { |each| each.x == xpos }
        return xpos
      end
    end
    raise "No more space available"
  end

  def put_tank_at(id, tank)
    @clients[id] = tank
  end

  def remove_tank_at(id)
    @clients.delete(id)
  end

  def broadcast_positions
    messages = @clients.select {|id, client| client.x }.collect do |id, client|
      "#{id}:#{client.x}:#{client.angle}"
    end
    message = "POSITIONS #{messages.join(" ")}\n"
    broadcast(message)
  end
end

$next_id = 0
$world = World.new

module Tank
  include EM::Protocols::LineText2
  attr_reader :x, :id, :angle

  def broadcast_message(name, *args)
    message = "#{name} #{@id} #{args.join(" ")}\n"
    $world.broadcast(message)
  end

  def post_init
    @id = $next_id
    $next_id += 1
    send_data("ASSIGN #{@id}\n")
    $world.put_tank_at(@id, self)
    respawn
  end

  def respawn
    @x = $world.next_free_position
    @angle = 270
    $world.broadcast_positions
  end

  def unbind
    puts "client #{@id} unbound"
    $world.remove_tank_at(@id)
    $world.broadcast_positions
  end

  def receive_line(line)
    case line
      when /^FIRE (.*)$/
        @angle, power = $1.split(" ")
        broadcast_message("SHOT_FIRED", @angle, power)
      when /^ANGLE (.*)$/
        @angle = $1
        broadcast_message("ANGLE", @angle)
      when /^KILLED_BY (.*)$/
        puts "#{line} received"
        killer_id = $1
        #$world.remove_tank_at(@id)
        @x = nil
        $world.broadcast_positions
        broadcast_message("KILLED_BY", killer_id)
        EM::add_timer(3) do
          respawn
        end
      when /^POSITION (.*)$/
        puts "#{line} recieved"
        @x = $1.to_i
        $world.broadcast_positions
      else
        puts "unsupported message #{line.inspect}"
    end
  end
end

EM::run {
  EM::start_server('0.0.0.0', 9876, Tank) do |connection|
    puts 'connected'
  end
}
