require 'bundler'
require "cucumber/rake/task"

Bundler::GemHelper.install_tasks

task default: [:cucumber]

Cucumber::Rake::Task.new(:cucumber) do |task|
  task.cucumber_opts = ["features"]
end

