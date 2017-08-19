namespace :tar do
  desc "Synchronise local and remote wp content folders via rsync"
  task :up do
    files = fetch(:syncfiles)
    files.each do |local_path, config|
      archive_name  = "transfere-#{local_path.hash}.tar.gz"
      tar_verbose   = fetch(:syncfiles_tar_verbose, true) ? "v" : ""
      exclude_dir   = Array(config[:exclude])
      exclude_args  = exclude_dir.map { |dir| "--exclude '#{dir}'"}

      cmd = ["tar -c#{tar_verbose}zf #{archive_name} -C #{local_path} .", *exclude_args]
      puts cmd.join(' ')
      system cmd.join(' ')

      tmp_file    = fetch(:syncfiles_temp_file, "/tmp/#{archive_name}")
      remote_path = config[:remote]
      sync_roles  = fetch(:syncfiles_roles, :all)

      on release_roles sync_roles do
        upload!(archive_name, tmp_file)
        execute :tar, "-xzf", tmp_file, "-C", "#{release_path}/#{remote_path}"
        execute :rm, tmp_file
      end
      system "rm -f #{archive_name}"
    end
  end

  desc "Synchronise local and remote wp content folders via rsync"
  task :down do
    files = fetch(:syncfiles)
    files.each do |local_path, config|
      remote_path  = config[:remote]
      archive_name = "transfere-#{remote_path.hash}.tar.gz"
      tmp_file     = fetch(:syncfiles_temp_file, "/tmp/#{archive_name}")
      tar_verbose  = fetch(:syncfiles_tar_verbose, true) ? "v" : ""
      exclude_dir  = Array(config[:exclude])
      exclude_args = exclude_dir.map { |dir| "--exclude '#{dir}'"}
      sync_roles   = fetch(:syncfiles_roles, :all)

      on primary sync_roles do
        execute :tar, "-c#{tar_verbose}zf", tmp_file, "-C", "#{release_path}/#{remote_path} .", *exclude_args

        download!(tmp_file, archive_name)
        execute :rm, tmp_file
      end

      cmd = "tar -xz#{tar_verbose}f #{archive_name} -C #{local_path}"
      puts cmd
      system cmd

      system "rm -f #{archive_name}"
    end
  end
end
