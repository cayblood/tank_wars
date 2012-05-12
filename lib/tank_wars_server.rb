require 'eventmachine'

Space = 150

class World
  def initialize
    #@next_id = 0
    @clients = {}
    #@next_position = 0
  end

  def broadcast(message)
    @clients.values.each do |client|
      puts "sending #{message} to #{client.id}"
      client.send_data(message)
    end    
  end

  def put_tank_at(id, tank)
    @clients[id] = tank
  end

  def remove_tank_at(id)
    @clients.delete(id)
  end

  def broadcast_positions
    messages = @clients.collect do |id, client|
      "#{id}:#{client.x}"
    end
    message = "POSITIONS #{messages.join(" ")}\n"
    broadcast(message)
  end
end

$next_id = 0
$clients = {}
$next_position = 0

$world = World.new

module Tank
  include EM::Protocols::LineText2
  attr_reader :x, :id

  def broadcast_message(name, *args)
    message = "#{name} #{@id} #{args.join(" ")}\n"
    $world.broadcast(message)
  end

  def post_init
    @id = $next_id
    $next_id += 1
    $world.put_tank_at(id, self)
    @x = $next_position
    $next_position += Space
    send_data("ASSIGN #{id}\n")
    broadcast_message("ANGLE", 270)
    $world.broadcast_positions
  end

  def unbind
    puts "client #{@id} unbound"
    $world.remove_tank_at(@id)
    $world.broadcast_positions
  end
  
  def receive_line(line)
    case line
    when /^SHOOT (.*)$/
      angle, power = $1.split(" ")
      broadcast_message("SHOT", angle, power)
    when /^ANGLE (.*)$/
      angle = $1
      broadcast_message("ANGLE", angle)
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
