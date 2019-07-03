# Introduction
A library to help you track dead code.

# How it works
Remove dead code is a hard problem in computer science. And also a important task in software developement.
There are 2 approaches to detect dead code.
- Static: detect at build time, don't need to run the code
- Dynamic: detect at runtime.

This gem is follow the second approach.

## What it does
This gem has 2 important tasks:
- Get list of all the source files
- Tracking which files and methods is execute at runtime, group them then write them to somewhere after a period

## What it provides
- A rake task to get all the files you want to track: `rake grimes:track_files`
- Callback blocks to decide what to do with the files list
- Throttle helper to group all the files and write it after a period of time.

# Installation
Put this in the Gemfile

```ruby
gem 'grimes'
```

## Configuration

### Add `grimes.rb` to `initializers`
```ruby
# config/initializers/grimes.rb
STDOUT.sync = true
FIVE_MIN = 5 * 60  # This is the durtion between

Grimes.configure do |config|
  # path to files you want to track
  config.track_paths = ['app/controllers/**/*.rb', 'app/api/**/*.rb']

  # Whether tracking actions in controllers or not
  config.track_controller = true

  # This part is require for the gem to work
  config.rails_application = Rails.application
  config.app_root = Rails.root.to_s

  # Bug reporter to log exception in gem
  config.bug_reporter = BugReporter
  
  # namespace in the message since this gem might use in many services
  config.namespace = 'main_app'

  # Config this if you have grape api
  config.grape_routes = [
    SapAPI,
    EmploymentHeroAPI,
  ]

  # Callback blocks
  config.rake_task_block = -> (files_list) do
    Rails.logger.info(Grimes::LogFormatter.format_file_list_data(files_list))
  end

  config.call_grape_controller_block = -> (data) do
    Grimes::Throttle.track(Grimes::LogFormatter.grape_controller_path(data), data)
  end

  config.render_controller_block = -> (data) do
    Grimes::Throttle.track(Grimes::LogFormatter.controller_path(data), data)
  end

  config.render_template_block = -> (data) do
    Grimes::Throttle.track(Grimes::LogFormatter.view_path(data), data)
  end
end

# Start tracking rails view tempate and rails controller
Grimes.track_rails_templates
Grimes.track_rails_controllers

# config the time period and what to do with the data
Grimes::Throttle.start FIVE_MIN, -> (data) do 
  Rails.logger.info(Grimes::LogFormatter.format_tracking_data(data))
end

# Write all the pending data when exist
at_exit { Grimes::Throttle.flush_buffer }
```

### Add middleware to Grape API (if you use Grape)
```ruby
class EmploymentHeroAPI < Grape::API
  use Grimes::GrapeTrackingMiddleware
end

```

### Config Puma server (if you use Puma)
```
# config/puma.rb
if puma_workers > 1
  workers puma_workers
  activate_control_app
  on_worker_boot do
    # Add these lines
    Grimes::Throttle.start FIVE_MIN, -> (data) do 
      Rails.logger.info(Grimes::LogFormatter.format_tracking_data(data))
    end
  end
end
```

### Add rake task to schedule task
```
// app.json
"send_file_list_to_grimes": {
  "schedule": "15 2 * * *",
    "command": [
      "bundle",
    "exec",
    "rake",
    "grimes:track_files"
    ]
},
```
