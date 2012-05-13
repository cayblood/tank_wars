module TankWars
  class ProjectileExplosion < Chingu::GameObject
    trait :timer

    attr_accessor :x, :y, :radis

    def initialize(options)
      @@image_of_explosion ||= Image["example_explosion.png"]
      options[:image] =  @@image_of_explosion
      super
      @x = options[:x]
      @y = options[:y]
      @radius = 100
      @factor_x = 0.1
      @factor_y = 0.1

      during(500) { self.alpha -= 1; self.factor_x += 0.01; self.factor_y += 0.01 }.then { self.destroy }
    end


  end
end
