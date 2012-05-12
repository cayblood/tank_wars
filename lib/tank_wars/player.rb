require 'tank_wars/projectile'
require 'tank_wars/projectile_explosion'
require 'tank_wars/player_draw'
require 'tank_wars/player_sound'
require 'tank_wars/player_shooting'

module TankWars
  class Player < Chingu::GameObject
    include PlayerDraw
    include PlayerSound
    include PlayerShooting

    trait :bounding_box, :scale => 1.0
    trait :collision_detection

    attr_accessor :x, :y, :width, :height, :blocked_on_left, :blocked_on_right, :id
    attr_reader :target_angle

    COLORS = [Gosu::Color::GRAY, Gosu::Color::GREEN, Gosu::Color::RED, Gosu::Color::BLUE]


    def initialize(options)
      super
      #drawing logic
      @center_x = @center_y = 0
      @width = 50
      @height = 20
      @player_number = options[:player_number] % COLORS.length + 1
      @color = COLORS[@player_number - 1]
      @x = options.fetch(:x, $window.width - ($window.width / 5 * @player_number) - (@width / 2))
      @gun_base_x = @x + (@width / 2)
      @y = 600

      @id = options[:id]
      @target_angle = options[:target_angle]
      @server = options[:networking].server
      calculate_angle!
      @power = 0
      @last_shot = Time.now - 5
      @cooldown = 1

      if me?
        self.input = {
          holding_left: :decrease_angle,
          holding_right: :increase_angle,
          holding_space: :charge,
          released_space: :fire,
        }
      end
    end

    def me?
      options[:is_me]
    end

    def update
      self.blocked_on_left = false
      self.blocked_on_right = false
      each_bounding_box_collision(Player) do |player, other_player|
        if player.x < other_player.x
          player.blocked_on_right = true
        else
          player.blocked_on_left = true
        end
      end
      draw
    end

    def move_left
      self.x -= 2 unless blocked_on_left
    end

    def move_right
      self.x += 2 unless blocked_on_right
    end

    def killed_by(shooter)
      notify_killed_by(shooter.id) if me?
      options = {
        x: @x,
        y: @y
      }
      ProjectileExplosion.create(options)
      play_explosion_sound
    end

    private
    def calculate_angle!
      @radians = @target_angle * Math::PI / 180
      notify_angle_change(@target_angle) if me?
    end

    def notify_shot_fired
      dispatch(:send_fire, @target_angle, @power)
    end

    def notify_angle_change(value)
      dispatch(:send_change_angle, value)
    end

    def notify_killed_by(id)
      dispatch(:send_killed_by, id)
    end

    def dispatch(name, *args)
      @server.dispatch(name, *args)
    end


  end
end
