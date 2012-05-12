class Player < Chingu::GameObject
  trait :bounding_box, :scale => 1.0
  trait :collision_detection

  attr_accessor :blocked_on_left, :blocked_on_right


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
  end

  def move_left
    self.x -= 1 unless blocked_on_left
  end

  def move_right
    self.x += 1 unless blocked_on_right
  end

  def increase_angle
  end

  def decrease_angle

  end
end
