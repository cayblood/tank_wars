require 'rubygems'
require 'bundler/setup'

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "lib")
require 'tank_wars'

desc "Run rspec tests"
task :spec do
	
end

desc "Run the game"
task :run do
	TankWars.new('ses-thinkpad-w510.local').show
end

task :default => :run
