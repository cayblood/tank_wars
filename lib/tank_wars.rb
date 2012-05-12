require 'chingu'
include Gosu

ROOT_DIR = File.expand_path(File.join('..', '..'), __FILE__)
Image.autoload_dirs << File.join(ROOT_DIR, "media")
Sound.autoload_dirs << File.join(ROOT_DIR, "media")



require 'tank_wars/main_window'