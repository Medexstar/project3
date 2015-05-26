require 'rubygems'  
require 'rufus/scheduler'
require 'rake'

if defined?(Rails::Server)
	Project3::Application.load_tasks
	seed = Rake::Task["scrape:seed_locations"]
	bom = Rake::Task["scrape:bom"]
	seed.invoke
	Thread.new {bom.invoke}
	

	scheduler = Rufus::Scheduler.new

	scheduler.every("5m") do
		bom.reenable
		Thread.new {bom.invoke}
	end
end