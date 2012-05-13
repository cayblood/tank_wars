require 'rubygems'
require 'bundler/setup'

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "lib")
require 'tank_wars'

desc "Run the game"
task :run do
  server_address = ENV['TANK_WARS_SERVER'] || 'localhost'
	TankWars::MainWindow.new(server_address).show
end

task :default => :run
