#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

require 'chingu'
include Gosu

ROOT_DIR = File.expand_path(File.join('..', '..'), __FILE__)
Image.autoload_dirs << File.join(ROOT_DIR, "media")
Sound.autoload_dirs << File.join(ROOT_DIR, "media")

require 'tank_wars/player'
require 'tank_wars/background'

class TankWars < Chingu::Window
  def initialize
    super(1024, 768, false)
    self.input = { :escape => :exit } # exits example on Escape
    
    @background = Background.create
    @player = Player.create(:x => 200, :y => 200, :image => Image["spaceship.png"])
    @player.input = { :holding_left => :move_left, :holding_right => :move_right, 
                      :holding_up => :move_up, :holding_down => :move_down }
  end
  
  def update
    super
    @background.draw
    self.caption = "FPS: #{self.fps} ms since last tick: " +
                   "#{self.milliseconds_since_last_tick}"
  end
end