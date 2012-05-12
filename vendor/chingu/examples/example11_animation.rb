#!/usr/bin/env ruby
require 'rubygems' rescue nil
$LOAD_PATH.unshift File.join(File.expand_path(__FILE__), "..", "..", "lib")
require 'chingu'
include Gosu
include Chingu

#
# Animation / retrofy example
#
class Game < Chingu::Window  
  def initialize
    super    
    self.factor = 6
    self.input = { :escape => :exit }
		self.caption = "Chingu::Animation / retrofy example. Move with arrows!"
    retrofy
    Droid.create(:x => $window.width/2, :y => $window.height/2)
  end
end

class Droid < Chingu::GameObject
  traits :timer
  
  def initialize(options = {})
    super
    
    #
    # This shows up the shorten versio of input-maps, where each key calls a method of the very same name.
    # Use this by giving an array of symbols to self.input
    #
    self.input = [:holding_left, :holding_right, :holding_up, :holding_down]
    
    # Load the full animation from tile-file media/droid.bmp
    @animation = Chingu::Animation.new(:file => "droid_11x15.bmp")
    @animation.frame_names = { :scan => 0..5, :up => 6..7, :down => 8..9, :left => 10..11, :right => 12..13 }
    
    # Start out by animation frames 0-5 (contained by @animation[:scan])
    @frame_name = :scan
    
    @last_x, @last_y = @x, @y
    update
  end
    
  def holding_left
    @x -= 2
    @frame_name = :left
  end

  def holding_right
    @x += 2
    @frame_name = :right
  end
  
  def holding_up
    @y -= 2
    @frame_name = :up
  end

  def holding_down
    @y += 2
    @frame_name = :down
  end

  # We don't need to call super() in update().
  # By default GameObject#update is empty since it doesn't contain any gamelogic to speak of.
  def update
    
    # Move the animation forward by fetching the next frame and putting it into @image
    # @image is drawn by default by GameObject#draw
    @image = @animation[@frame_name].next
    
    #
    # If droid stands still, use the scanning animation
    #
    @frame_name = :scan if @x == @last_x && @y == @last_y
    
    @x, @y = @last_x, @last_y if outside_window?  # return to previous coordinates if outside window
    @last_x, @last_y = @x, @y                     # save current coordinates for possible use next time
  end
end

Game.new.show