#!/usr/bin/env ruby
require 'rubygems' rescue nil
$LOAD_PATH.unshift File.join(File.expand_path(__FILE__), "..", "..", "lib")
require 'chingu'
include Gosu
include Chingu

#
# viewport-trait / edit-trait example
#
# Press 'E' when demo is running to edit the playfield!
# 
class Game < Chingu::Window 
  def initialize()
    super(500,600,false)    
  end
  
  def setup
    retrofy
    self.factor = 3
    switch_game_state(Example19.new)
  end    
end

class Example19 < GameState
  #
  # This adds accessor 'viewport' to class and overrides draw() to use it.
  #
  trait :viewport
  
  #
  # We create our 3 different game objects in this order: 
  # 1) map 2) stars 3) player
  # Since we don't give any zorders Chingu automatically increments zorder between each object created, putting player on top
  #
  def initialize(options = {})
    super
    
    self.input = { :escape => :exit, :e => :edit } 

    Sound["laser.wav"] # cache sound by accessing it once
    
    self.viewport.lag = 0                           # 0 = no lag, 0.99 = a lot of lag.
    self.viewport.game_area = [0, 0, 1000, 1000]    # Viewport restrictions, full "game world/map/area"
    
    #
    # Create 40 stars scattered around the map. This is now replaced by load_game_objects()
    # ## 40.times { |nr| Star.create(:x => rand * self.viewport.x_max, :y => rand * self.viewport.y_max) }
    #
    # load_game_objects( :file => "example19_game_objects.yml" )
    #
    
    # We can skip the :file argument and Level19 will as default load from "level19.yml"
    load_game_objects
  
    # Create our mechanic star-hunter
    @droid = Droid.create(:x => 100, :y => 100)    
  end

  def edit
    #
    # Manually specify classes in editor
    #
    # state = GameStates::Edit.new(:file => "example19_game_objects.yml", :classes => [Star, StoneWall])

    #
    # Let Edit automatically detect available GameObjects (this includes Text etc)
    #
    # state = GameStates::Edit.new(:file => "example19_game_objects.yml")
    
    #
    # Let Edit decide what game objects to paint with + file to save to.
    # With this you can use a clean: self.input = { :e => GameStates::Edit }
    #
    state = GameStates::Edit
        
    #
    # This will show game objects classes except Droid-instances in the toolbar
    #
    # state = GameStates::Edit.new(:except => Droid)
    #
    
    push_game_state(state)
  end
  
  def update    
    super

    # Droid can pick up starts
    @droid.each_collision(Star) do |droid, star|
      star.destroy
      Sound["laser.wav"].play(0.5)
    end
    
    # Bullets collide with stone_walls
    #Bullet.each_collision(StoneWall) do |bullet, stone_wall|
    #  bullet.die
    #  stone_wall.destroy
    #end
    
    # Destroy game objects that travels outside the viewport
    game_objects.destroy_if { |game_object| self.viewport.outside_game_area?(game_object) }
    
    #
    # Align viewport with the droid in the middle.
    # This will make droid will be in the center of the screen all the time...
    # ...except when hitting outer borders and viewport x_min/max & y_min/max kicks in.
    #
    self.viewport.center_around(@droid)
        
    $window.caption = "viewport/edit-trait example. Move with arrows! Press 'E' to Edit. x/y: #{@droid.x.to_i}/#{@droid.y.to_i} - viewport x/y: #{self.viewport.x.to_i}/#{self.viewport.y.to_i} - FPS: #{$window.fps}"
  end
end

class Droid < Chingu::GameObject
  trait :bounding_box, :debug => false
  traits :timer, :collision_detection , :timer
  attr_accessor :last_x, :last_y, :direction
  
  def setup
    #
    # This shows up the shortened version of input-maps, where each key calls a method of the very same name.
    # Use this by giving an array of symbols to self.input
    #
    self.input = {  [:holding_left, :holding_a] => :holding_left, 
                    [:holding_right, :holding_d] => :holding_right,
                    [:holding_up, :holding_w] => :holding_up,
                    [:holding_down, :holding_s] => :holding_down,
                    :space => :fire
                  }
    
    # Load the full animation from tile-file media/droid.bmp
    @animations = Chingu::Animation.new(:file => "droid_11x15.bmp")
    @animations.frame_names = { :scan => 0..5, :up => 6..7, :down => 8..9, :left => 10..11, :right => 12..13 }
    
    # Start out by animation frames 0-5 (contained by @animations[:scan])
    @animation = @animations[:scan]
    @speed = 3
    @last_x, @last_y = @x, @y
    
    update
  end
    
  def holding_left
    move(-@speed, 0)
    @animation = @animations[:left]
  end

  def holding_right
    move(@speed, 0)
    @animation = @animations[:right]
  end

  def holding_up
    move(0, -@speed)
    @animation = @animations[:up]
  end

  def holding_down
    move(0, @speed)
    @animation = @animations[:down]
  end

  def fire
    Bullet.create(:x => self.x, :y => self.y, :velocity => @direction)
  end
  
  #
  # Revert player to last positions when:
  # - player is outside the viewport
  # - player is colliding with at least one object of class StoneWall
  #
  def move(x,y)
    @x += x
    @x = @last_x  if self.parent.viewport.outside_game_area?(self) || self.first_collision(StoneWall)

    @y += y
    @y = @last_y  if self.parent.viewport.outside_game_area?(self) || self.first_collision(StoneWall)
  end
  
  # We don't need to call super() in update().
  # By default GameObject#update is empty since it doesn't contain any gamelogic to speak of.
  def update
    
    # Move the animation forward by fetching the next frame and putting it into @image
    # @image is drawn by default by GameObject#draw
    @image = @animation.next
    
    if @x == @last_x && @y == @last_y
      # droid stands still, use the scanning animation
      @animation = @animations[:scan]
    else
      # Save the direction to use with bullets when firing
      @direction = [@x - @last_x, @y - @last_y]
    end
    
    @last_x, @last_y = @x, @y
  end
end

class Star < GameObject
  trait :bounding_circle, :debug => false
  trait :collision_detection
  
  def setup    
    @animation = Chingu::Animation.new(:file => "Star.png", :size => 25)
    @image = @animation.next
    self.color = Gosu::Color.new(0xff000000)
    self.color.red = rand(255 - 40) + 40
    self.color.green = rand(255 - 40) + 40
    self.color.blue = rand(255 - 40) + 40
    self.factor = 1
    #self.rotation_center = :center
    
    #
    # A cached bounding circle will not adapt to changes in size, but it will follow objects X / Y
    # Same is true for "cache_bounding_box"
    #
    cache_bounding_circle
  end
  
  def update
    # Move the animation forward by fetching the next frame and putting it into @image
    # @image is drawn by default by GameObject#draw
    @image = @animation.next
  end
end

class StoneWall < GameObject
  trait :bounding_box, :debug => false
  trait :collision_detection
  
  def setup
    @image = Image["stone_wall.bmp"]
    self.factor = 1
  end
end

class Bullet < GameObject
  traits :bounding_circle, :collision_detection, :velocity, :timer
  
  def setup
    @image = Image["fire_bullet.png"]
    self.factor = 1
    self.velocity_x *= 2
    self.velocity_y *= 2
  end
  
  def die
    self.velocity = [0,0]   
    between(0,50) { self.factor += 0.3; self.alpha -= 10; }.then { destroy }
  end
end

Game.new.show
