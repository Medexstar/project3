require 'rubygems'  
require 'rufus/scheduler'
require 'rake'

if defined?(Rails::Server)
	Project3::Application.load_tasks
	seed = Rake::Task["scrape:seed_locations"]
	forecast = Rake::Task["scrape:forecast"]
	# seed.invoke
	# Thread.new {forecast.invoke}
	

	# scheduler = Rufus::Scheduler.new

	# scheduler.every("30m") do
	# 	Thread.new {forecast.invoke}
	# end
end