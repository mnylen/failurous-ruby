require 'jeweler'

task :default => [:spec]

task :spec do
  system "rspec ."
end

Jeweler::Tasks.new do |gem|
  gem.name        = "failurous-ruby"
  gem.summary     = "Ruby notifier for Failurous"
  gem.description = "failurous-ruby is a Ruby notifier for sending notifications to Failurous"
  gem.homepage    = "http://github.com/mnylen/failurous-ruby"
  gem.authors     = ["Mikko Nylén", "Tero Parviainen", "Antti Forsell"]
  
  gem.files.exclude 'Gemfile'
  gem.files.exclude 'Gemfile.lock'
  gem.files.exclude '.rvmrc'
  
  gem.add_dependency('json')
end