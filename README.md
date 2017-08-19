# capistrano-syncfiles

This gem provides up and down file syncing with rsync or tar. This could be usefull if you are in a shared hosting environment.

## Installation
First make sure you install the capistrano-syncfiles by adding it to your `Gemfile`:

    gem "capistrano-syncfiles"

Add to Capfile

    require 'capistrano/syncfiles'

## Configuration (deploy.rb)
Configure your files and folders like these:
```
set :syncfiles, {
  'wordpress/wp-content/uploads' => {                     # local path
      remote: 'wordpress/wp-content/uploads',             # remote path
      exclude: ['fvm', 'ithemes-security', 'wc-logs']     # excluded files
  }
}

set :syncfiles_roles, :all  # roles to run on, default: :all

set :syncfiles_temp_file    # applies only to tar strategy, default: "/tmp/transfere-#{local_path.hash}.tar.gz"

set :syncfiles_tar_verbose  # applies only to tar strategy, default: true
```

## Usage
The following tasks will be added
```
cap syncfiles:rsync:down
cap syncfiles:rsync:up
cap syncfiles:tar:down
cap syncfiles:tar:up    
```

You can invoke this tasks(Rake) as you do normally: https://github.com/ruby/rake

Capistrano tasks: http://capistranorb.com/documentation/getting-started/flow/

### License
The MIT License (MIT)

### Changelog

0.1.0
-----

- Initial release
