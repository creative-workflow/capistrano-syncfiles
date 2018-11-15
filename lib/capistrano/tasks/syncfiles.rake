def get_syncfiles_base_path
  fetch(:syncfiles_base_path, "#{current_path}/")
end

namespace :syncfiles do
  tasks = Dir[File.expand_path("syncfiles/*.rake", File.dirname(__FILE__))]
  tasks.each do |task|
    load task
  end
end

namespace :load do
  task :defaults do
    set :syncfiles_rsync_options, '-avzuO'
  end
end
