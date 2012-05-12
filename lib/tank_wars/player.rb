class Player < Chingu::GameObject
  trait :bounding_box, :scale => 1.0
  trait :collision_detection

  attr_accessor :x, :y, :width, :height, :blocked_on_left, :blocked_on_right

  COLORS = [Gosu::Color::GRAY, Gosu::Color::GREEN, Gosu::Color::RED, Gosu::Color::BLUE]

  def initialize(options)
    super
    @width = 50
    @height = 20
    @player_number = options[:player_number]
    @x = $window.width - ($window.width / 5 * @player_number) - (@width / 2)
    @cannon_x = @x + (@width / 2)
    @y = 600
    @color = COLORS[@player_number - 1]
  end

  def draw_cannon
    $window.draw_line(@cannon_x, @y, @color, @cannon_x - 30, @y - 30, @color)
  end

  def draw
    @rect = Chingu::Rect.new(@x, @y, @width, @height)
    $window.fill_rect(@rect, @color, 1)
    draw_cannon
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

  def increase_angle
  end

  def decrease_angle
  end
end
