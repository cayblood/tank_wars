class Player < Chingu::GameObject
  trait :bounding_box, :scale => 1.0
  trait :collision_detection

  attr_accessor :x, :y, :width, :height, :blocked_on_left, :blocked_on_right

  COLORS = [Gosu::Color::GRAY, Gosu::Color::GREEN, Gosu::Color::RED, Gosu::Color::BLUE]
  GUN_LENGTH = 20

  def initialize(options)
    super
    @width = 50
    @height = 20
    @player_number = options[:player_number] % COLORS.length + 1
    @x = options.fetch(:x, $window.width - ($window.width / 5 * @player_number) - (@width / 2))
    @gun_base_x = @x + (@width / 2)
    @y = 600
    @color = COLORS[@player_number - 1]
    @target_angle = 270
    calculate_angle!(0)
  end

  def draw_gun
    $window.draw_line(@gun_base_x, @y, @color, @gun_tip_x, @gun_tip_y, @color)
  end

  def draw
    @rect = Chingu::Rect.new(@x, @y, @width, @height)
    $window.fill_rect(@rect, @color, 1)
    draw_gun
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
    calculate_angle!(1) if @target_angle < 360
    Sound["select.wav"].play
  end

  def decrease_angle
    calculate_angle!(-1) if @target_angle > 180
    Sound["select.wav"].play
  end

  def play_select
    @time_since_select_was_played 
    if @time_since_select_was_played > 1
      Sound["select.wav"].play
    end
  end

  private

  def calculate_angle!(modifier)
    @target_angle += modifier
    radians = @target_angle * Math::PI / 180
    line_width = GUN_LENGTH * Math.cos(radians)
    line_height = GUN_LENGTH * Math.sin(radians)
    @gun_tip_x = @gun_base_x + line_width.round
    @gun_tip_y = @y + line_height.round

    #send_to_server
  end
end
