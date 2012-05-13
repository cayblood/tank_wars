module TankWars
  module PlayerSound
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

    def play_shot_fired_sound
      Sound["shot_fired.wav"].play
    end

    def self.play_explosion_sound
      Sound["explosion.wav"].play
    end
  end
end

