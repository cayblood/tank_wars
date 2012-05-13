require 'tank_wars/player'
require 'tank_wars/background'
require 'tank_wars/networking'


module TankWars
  class MainWindow < Chingu::Window
    def initialize(host, port = 9876)
      super(1024, 768, false)
      self.input = {escape: :exit} # exits example on Escape
      @background = Background.create
      @network = Network.new(host, port)
      @players = {}
    end

    def update
      super
      @network.dispatch_network_events_to(self)
      self.caption = "FPS: #{self.fps} ms since last tick: " +
          "#{self.milliseconds_since_last_tick}"
    end

    # Events
    def on_self_id(id)
      @self_id = id
    end

    def on_update_positions(clients)
      left = @players.keys
      clients.each do |id, pos, angle|
        left.delete(id)

        @players[id] ||= Player.create(
            :x => pos,
            :id => id,
            :player_number => id,
            :target_angle => angle,
            :is_me => (id == @self_id),
            :network => @network)
      end

      left.each do |id|
        player = @players.delete(id)
        player.input = {}
        player.destroy
      end
    end

    def on_change_angle(id, value)
      # I know my own angle
      return if @self_id == id

      if player = @players[id]
        player.target_angle = value
      end
    end

    def on_shot_fired(id, angle, power)
      if player = @players[id]
        player.shot_fired(angle, power)
      end
    end
  end
end

