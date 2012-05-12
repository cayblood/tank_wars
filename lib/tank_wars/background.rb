module TankWars
  class Background < Chingu::GameObject
    def draw
      draw_sky
      draw_land
    end

    def draw_sky
      c = Gosu::Color.new(232, 237, 255)
      r = Chingu::Rect.new(0, 0, $window.width, $window.height)
      $window.fill_rect(r, c)
      $window.draw_rect(r, c, 1)
    end

    def draw_land
      c = Gosu::Color.new(40, 40, 40)
      r = Chingu::Rect.new(0, 621, $window.width, $window.height)
      $window.fill_rect(r, c)
      $window.draw_rect(r, c, 1)
    end
  end
end