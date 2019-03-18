namespace :grimes do
  task track_files: :environment do
    config = Grimes.config
    white_list_files = config.track_paths.map { |path| Dir[path] }.flatten
    ignore_files = config.ignore_paths.map { |path| Dir[path] }.flatten
    files_list = white_list_files - ignore_files
    track_data = {
      files_list: files_list
    }
    config.rake_task_block && config.rake_task_block.call(track_data)
  end
end
