module TankWars
module PlayerShooting
  attr_accessor :charging, :firing

  def increase_angle
    if @target_angle < 360
      @target_angle += 1
      calculate_angle!
      play_select_sound
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


  def shot_fired(angle, power)
    options = {
      initial_angle: angle,
      initial_power: power,
      x: @gun_tip_x,
      y: @gun_tip_y,
      image: Image["shell.png"],
      elevation: @rect.bottom,
    }
    Projectile.create(self, options)
    play_shot_fired_sound
  end

  def charge
    return if @firing
    @charging ||= 0
    @charging += $window.milliseconds_since_last_tick
    @power = [(@charging ** 2) / (100 ** 2), 100].min
  end

  def fire
    return unless @charging
    notify_shot_fired
    @firing = true
    @charging = nil
    @power = 0
  end
end
end
