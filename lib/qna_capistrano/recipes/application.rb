Capistrano::Configuration.instance.load do

  # Server settings
  set :app_server, :passenger       unless exists?(:app_server)
  set :web_server, :apache          unless exists?(:web_server)
  if exists?(:user)
    set :runner, user             unless exists?(:runner)
  end
  set :application_port, 80       unless exists?(:application_port)

  set :application_uses_ssl, true unless exists?(:application_uses_ssl)
  set :application_port_ssl, 443  unless exists?(:application_port_ssl)

  # Database settings
  set :database, :mongodb unless exists?(:database)

  # SCM settings
  set :scm, :git
  set :branch, 'master' unless exists?(:branch)
  if exists?(:user)
    set :deploy_to, "/home/#{user}/rails/#{application}" unless exists?(:deploy_to) and not exists?(:user)
  end
  set :deploy_via, :checkout unless exists?(:deploy_via)
  set :keep_releases, 3 unless exists?(:keep_releases)
  set :run_method, :run
  set :git_enable_submodules, true
  set :git_shallow_clone, 1
  set :rails_env, 'production' unless exists?(:rails_env)

  # Git settings for capistrano
  default_run_options[:pty] = true
  ssh_options[:forward_agent] = true

  # RVM settings
  set :using_rvm, true unless exists?(:using_rvm)

  if using_rvm
    $:.unshift(File.expand_path('./lib', ENV['rvm_path']))  # Add RVM's lib directory to the load path.
    require "rvm/capistrano"                                # Load RVM's capistrano plugin.

    # Sets the rvm to a specific version (or whatever env you want it to run in)
    set :rvm_ruby_string, '1.9.2' unless exists?(:rvm_ruby_string)
  end

  # Daemons settings
  # The unix socket that unicorn will be attached to.
  # Also, nginx will upstream to this guy.
  # The *nix place for socks is /var/run, so we should probably put it there
  # Make sure the runner can access this though.
  set :sockets_path, "/var/run/#{application}" unless exists?(:sockets_path)

  # Just to be safe, put the pid somewhere that survives deploys. shared/pids is
  # a good choice as any.
  set(:pids_path) { File.join(shared_path, "pids") } unless exists?(:pids_path)

  set :monitorer, 'bluepill' unless exists?(:monitorer)

  # Application settings
  set :shared_dirs, %w(config config/pills uploads backup bundle tmp sockets pids log system) unless exists?(:shared_dirs)

  namespace :app do
    task :setup, :roles => :app do
      commands = shared_dirs.map do |path|
        "if [ ! -d '#{path}' ]; then mkdir -p #{path}; fi;"
      end
      run "cd #{shared_path}; #{commands.join(' ')}"
    end
  end
end
