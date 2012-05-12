module TankWars
  class Projectile < Chingu::GameObject
    traits :collision_detection, :bounding_box
    attr_accessor :v0, :a0, :t0, :x0, :y0, :x, :y, :elev

    PIXELS_PER_METER = 75 / 7.93 # M1 Abrams hull length
    G = 9.8 # earth gravity is 9.8 m/sˆ2

    def initialize(shooter, options)
      @shooter = shooter
      options[:image] = Image["shell.png"]
      super options
      @v0 = options[:initial_velocity]
      @a0 = options[:initial_angle] * Math::PI / 180
      @t = 0
      @x0 = options[:x]
      @y0 = options[:y]
      @x_delta = @v0 * Math.cos(@a0) * PIXELS_PER_METER
      @y_delta = @v0 * Math.sin(@a0)
      @elevation = options[:elevation]

      cache_bounding_box # This does a lot for performance
    end

    def draw
      @t += $window.milliseconds_since_last_tick / 1000.0
      @x = (@x0 + (@x_delta * @t)).round
      @y = (@y0 + (((@y_delta * @t) + (0.5 * G * @t * @t)) * PIXELS_PER_METER)).round

      super

      if @y >= @elevation
        shot_missed
      end

      each_bounding_box_collision(Player) do |projectile, hostile_tank|
        hostile_tank.death
        @shooter.kill
        destroy
      end
    end

    def shot_missed
      destroy
    end

    def update
      draw
    end
  end
end
