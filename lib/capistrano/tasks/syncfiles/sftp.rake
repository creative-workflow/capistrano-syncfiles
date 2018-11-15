require 'fun_sftp'

namespace :sftp do
  def connection(server, username, password)
    @connection ||= FunSftp::SFTPClient.new(server, username, password)
  end

  def ensure_directory_exsits_remote(handle, remote_directory)
    return if handle.has_directory? remote_directory

    parent_directory = ::File.dirname(remote_directory)
    if !handle.has_directory? parent_directory
      ensure_directory_exsits_remote(handle, parent_directory)
    end

    puts "mkdir #{remote_directory}"
    handle.mkdir!(remote_directory)
  end

  desc "Synchronise from local to remote folder via sftp"
  task :up do
    files = fetch(:syncfiles)
    files.each do |local_path, config|
      remote_path  = "#{get_syncfiles_base_path}#{config[:remote]}"
      exclude_dir  = Array(config[:exclude])
      exclude_args = exclude_dir.map { |dir| "! -path '#{dir}/*'"}
      sync_roles   = fetch(:syncfiles_roles, :all)

      cmd = ["find #{local_path} -type fl ", *exclude_args]
      puts cmd.join(' ')
      filtered_files = `#{cmd.join(' ')}`.lines

      on release_roles sync_roles do |role|
        handle = connection(role.hostname, role.user, fetch(:syncfiles_sftp_password))

        uploads = filtered_files.map do |local_file|
          local_file.strip!

          remote_file      = local_file.sub(local_path, remote_path)

          remote_directory = ::File.dirname(remote_file)

          ensure_directory_exsits_remote(handle, remote_directory)

          handle.upload!(local_file, remote_file)
        end
      end
    end
  end

  desc "Synchronise from remote to local folder via sftp"
  task :down do
    files = fetch(:syncfiles)
    files.each do |local_path, config|
      remote_path  = "#{get_syncfiles_base_path}#{config[:remote]}"
      exclude_dir  = Array(config[:exclude])
      sync_roles   = fetch(:syncfiles_roles, :all)

      on primary sync_roles do |role|
        handle = connection(role.hostname, role.user, fetch(:syncfiles_sftp_password))

        puts "collecting files in #{remote_path}"
        handle.glob(remote_path, "**/*").each do |remote_file|

          remote_file = "#{remote_path}/#{remote_file}"

          local_file = remote_file.sub(remote_path, local_path)

          next if exclude_dir.any? do |exclude|
            local_file.start_with?(exclude)
          end

          `mkdir -p #{::File.dirname(local_file)}`

          handle.download!(remote_file, local_file)
        end
      end
    end
  end

end
