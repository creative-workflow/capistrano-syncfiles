namespace :rsync do
  def build_server_string(role)
    user = role.user + "@" if !role.user.nil?
    "#{user}#{role.hostname}"
  end

  desc "Synchronise from local to remote folder via rsync"
  task :up do
    files = fetch(:syncfiles)
    files.each do |local_path, config|
      remote_path  = config[:remote]
      exclude_dir  = Array(config[:exclude])
      exclude_args = exclude_dir.map { |dir| "--exclude '#{dir}'"}
      sync_roles   = fetch(:syncfiles_roles, :all)

      on release_roles sync_roles do |role|
        server = build_server_string(role)

        cmd  = ["rsync -avzO #{local_path}/ #{server}:#{release_path}/#{remote_path}", *exclude_args]
        puts cmd.join(' ')
        system cmd.join(' ')
      end
    end
  end

  desc "Synchronise from remote to local folder via rsync"
  task :down do
    files = fetch(:syncfiles)
    files.each do |local_path, config|
      remote_path  = config[:remote]
      exclude_dir  = Array(config[:exclude])
      exclude_args = exclude_dir.map { |dir| "--exclude '#{dir}'"}
      sync_roles   = fetch(:syncfiles_roles, :all)

      on release_roles sync_roles do |role|
        server = build_server_string(role)

        cmd  = ["rsync -avzO #{server}:#{release_path}/#{remote_path}/ #{local_path}", *exclude_args]
        puts cmd.join(' ')
        system cmd.join(' ')
      end
    end
  end
end
