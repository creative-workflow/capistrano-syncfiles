namespace :syncfiles do
  tasks = Dir[File.expand_path("syncfiles/*.rake", File.dirname(__FILE__))]
  tasks.each do |task|
    load task
  end
end
