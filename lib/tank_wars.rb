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

    # initialize players
    @players = []
    (1..4).each do |player_number|
      @players << Player.create(player_number: player_number)
      if player_number == OUR_PLAYER_NUMBER
        @players[player_number - 1].input = { holding_left: :increase_angle, holding_right: :decrease_angle }
      end
    end
  end
  
  def update
    super
    @background.draw
    self.caption = "FPS: #{self.fps} ms since last tick: " +
                   "#{self.milliseconds_since_last_tick}"
  end
end
