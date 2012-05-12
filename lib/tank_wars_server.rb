require 'eventmachine'

$next_id = 0
$clients = {}
Space = 150
$next_position = 0

module Tank
  include EM::Protocols::LineText2
  attr_reader :x, :id

  def broadcast_positions
    messages = $clients.collect do |id, client|
      "#{id}:#{client.x}"
    end
    message = "POSITIONS #{messages.join(" ")}\n"
    $clients.values.each do |client|
      puts "sending #{message} to #{client.id}"
      client.send_data(message)
    end
  end

  def broadcast_shot(angle, power)
    message = "SHOT #{@id} #{angle} #{power}"
    $clients.values.each do |client|
      puts "sending #{message} to #{client.id}"
      client.send_data(message)
    end
  end

  def broadcast_angle(angle)
    message = "ANGLE #{@id} #{angle}"
    $clients.values.each do |client|
      puts "sending #{message} to #{client.id}"
      client.send_data(message)
    end
  end

  def post_init
    @id = $next_id
    $next_id += 1
    $clients[id] = self
    @x = $next_position
    $next_position += Space
    send_data("ASSIGN #{id}\n")
    broadcast_angle(270)
    broadcast_positions
  end

  def unbind
    puts "client #{@id} unbound"
    $clients.delete(@id)
    broadcast_positions
  end
  
  def receive_line(line)
    case line
    when /^SHOOT (.*)$/
      angle, power = $1.split(" ")
      broadcast_shot(angle, power)
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
