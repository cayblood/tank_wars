#!/usr/bin/env ruby

require 'chingu'
include Gosu

ROOT_DIR = File.expand_path(File.join('..', '..'), __FILE__)
Image.autoload_dirs << File.join(ROOT_DIR, "media")
Sound.autoload_dirs << File.join(ROOT_DIR, "media")

require 'tank_wars/player'
require 'tank_wars/background'

OUR_PLAYER_NUMBER = 1

class TankWars < Chingu::Window
  def initialize
    super(1024, 768, false)
    self.input = { escape: :exit } # exits example on Escape
    
    @background = Background.create
    @networking = Networking.new(self)

    @players = {}
  end
  
  def update
    super
    @networking.client.run
    @background.draw
    self.caption = "FPS: #{self.fps} ms since last tick: " +
                   "#{self.milliseconds_since_last_tick}"
  end

  # Events
  def on_myself(id)
    @myself = id
  end

  def on_update_positions(clients)
    left = @players.keys
    clients.each do |id, pos|
      left.delete(id)
      player = @players[id] ||= Player.create(:player_number => id)

      if id == @myself
        player.input = { holding_left: :decrease_angle, holding_right: :increase_angle }
      end
    end

    left.each do |id|
      player = @players.delete(id)
      player.destroy
    end
  end
end

require 'tank_wars/networking'

