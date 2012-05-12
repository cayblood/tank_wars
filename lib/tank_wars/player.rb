class Player < Chingu::GameObject
  trait :bounding_box, :scale => 1.0
  trait :collision_detection
  trait :timer

  attr_accessor :x, :y, :width, :height, :blocked_on_left, :blocked_on_right
  attr_reader :target_angle

  COLORS = [Gosu::Color::GRAY, Gosu::Color::GREEN, Gosu::Color::RED, Gosu::Color::BLUE]
  GUN_LENGTH = 20

  def initialize(options)
    super
    @width = 50
    @height = 20
    @id = options[:id]
    @player_number = options[:player_number] % COLORS.length + 1
    @x = options.fetch(:x, $window.width - ($window.width / 5 * @player_number) - (@width / 2))
    @gun_base_x = @x + (@width / 2)
    @y = 600
    @color = COLORS[@player_number - 1]
    @target_angle = 270
    @server = options[:networking].server
    calculate_angle!
    @power = 25

    if me?
      self.input = {
        holding_left: :decrease_angle,
        holding_right: :increase_angle,
        holding_up: :increase_power,
        holding_down: :decrease_power
      }
    end
  end

  def me?
    options[:is_me]
  end

  def draw_gun
    $window.draw_line(@gun_base_x, @y, @color, @gun_tip_x, @gun_tip_y, @color)
  end

  def draw_power
    @power_text = Chingu::Text.new(@power.to_s, x: @x + 13, y: @y, zorder: 1, font: "Arial", size: 23)
    @power_text.x = @gun_base_x + ((@power_text.width - @width ) / 2)
    @power_text.draw
  end

  def draw
    @rect = Chingu::Rect.new(@x, @y, @width, @height)
    $window.fill_rect(@rect, @color, 1)
    draw_gun
    draw_power
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
    if @target_angle < 360
      @target_angle += 1
      calculate_angle!
      play_select_sound
    end
  end

  def play_select_sound
    if @select_sound
      unless @select_sound.playing?
        @select_sound = Sound["select.wav"].play
      end
    else
      @select_sound = Sound["select.wav"].play
    end
  end

  def play_power_sound
    if @power_sound
      unless @power_sound.playing?
        @power_sound = Sound["power.wav"].play
      end
    else
      @power_sound = Sound["power.wav"].play
    end
  end

  def decrease_angle
    if @target_angle > 180
      @target_angle -= 1
      calculate_angle!
      play_select_sound
    end
  end

  def target_angle=(value)
    @target_angle = value
    calculate_angle!
  end

  def increase_power
    @power += 1 unless @power >= 100
    play_power_sound
  end

  def decrease_power
    @power -= 1 unless @power <= 0
    play_power_sound
  end

  private

  def calculate_angle!
    radians = @target_angle * Math::PI / 180
    line_width = GUN_LENGTH * Math.cos(radians)
    line_height = GUN_LENGTH * Math.sin(radians)
    @gun_tip_x = @gun_base_x + line_width.round
    @gun_tip_y = @y + line_height.round

    send_angle(@target_angle) if me?
  end

  def send_shot
    dispatch(:send_shot, @target_angle, @power)
  end

  def send_angle(value)
    dispatch(:send_change_angle, value)
  end

  def dispatch(name, *args)
    @server.dispatch(name, *args)
  end
end
