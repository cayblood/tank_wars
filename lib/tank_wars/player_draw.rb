module TankWars
  module PlayerDraw
    GUN_LENGTH = 20

    def draw_gun
      line_width = GUN_LENGTH * Math.cos(@radians)
      line_height = GUN_LENGTH * Math.sin(@radians)
      @gun_tip_x = @gun_base_x + line_width.round
      @gun_tip_y = @y + line_height.round
      $window.draw_line(@gun_base_x, @y, @color, @gun_tip_x, @gun_tip_y, @color)
    end

    def draw_power
      power_height = (@height * @power / 100.0).round
      if power_height > 0 && @power > 1
        @power_rect = Chingu::Rect.new(@gun_base_x - 5, @y + @height - power_height, 10, power_height)
        $window.fill_rect(@power_rect, Gosu::Color::YELLOW, 1)
      elsif @firing && @power_rect
        $window.fill_rect(@power_rect, Gosu::Color::CYAN, 1)
      else
        @power_rect = nil
      end
    end

    def draw_shooting_indicator

    end

    def draw
      @rect = Chingu::Rect.new(@x, @y, @width, @height)
      $window.fill_rect(@rect, @color, 1)
      draw_gun
      draw_power
    end
  end
end