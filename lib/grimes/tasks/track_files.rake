require 'rails'
require 'grimes/files_list/coordinator'

namespace :grimes do
  task track_files: :environment do
    config = Grimes.config
    files = FilesList::Coordinator.new(config).files_list
    config.rake_task_block && config.rake_task_block.call(files)
  end
end
