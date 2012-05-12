require 'eventmachine'

module TankWarsSession
  include EM::Protocols::LineText2

  def receive_line(line)
    send("GOOD bye\n")
  end
end

EM::run {
  EM::start_server('0.0.0.0', 9876, TankWarsSession) do |connection|
    
  end
}
