$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'grimes'
require 'active_support/concern'
require 'rake'

# https://www.eliotsykes.com/test-rails-rake-tasks-with-rspec
module TaskExampleGroup
  extend ActiveSupport::Concern

  included do
    let(:task_name) { self.class.top_level_description.sub(/\Arake /, "") }
    let(:tasks) { Rake::Task }

    # Make the Rake task available as `task` in your examples:
    subject(:task) { tasks[task_name] }
  end
end

# Preload all rake file
path = File.expand_path("lib/grimes")
Dir.glob("#{path}/tasks/**/*.rake").each { |f| load f }


RSpec.configure do |config|
  # Tag Rake specs with `:task` metadata or put them in the spec/tasks dir
  config.define_derived_metadata(:file_path => %r{/spec/tasks/}) do |metadata|
    metadata[:type] = :task
  end
  config.include TaskExampleGroup, type: :task
end
