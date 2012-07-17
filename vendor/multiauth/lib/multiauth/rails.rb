::ActionView::Base.send :include, Multiauth::ViewsHelper

module Multiauth
  class Engine < ::Rails::Engine
    paths[File.expand_path("../../../app/controllers", __FILE__)]
    paths[File.expand_path("../../../app/views", __FILE__)]
    paths[File.expand_path("../routes.rb", __FILE__)]


    initializer "multiauth" do |app|

      config_file = Rails.root+"config/auth_providers.yml"

      if File.exist?(config_file)
        providers = YAML::load(ERB.new(File.read(config_file)).result)
        if providers.blank?
          raise ArgumentError, "#{config_file} is invalid"
        elsif providers[Rails.env].nil?
          raise ArgumentError, "cannot find section for #{Rails.env} environment in #{config_file}"
        end

        Multiauth.providers = providers[Rails.env]

        Multiauth.providers.each do |provider, config|
          next if config["token"].blank?

          puts ">> Setting up #{provider} provider"
          Devise.omniauth provider.underscore.to_sym, config["id"], config["token"]
        end

        Multiauth.providers.select{|p,_| p=~/ldap/i}.each do |provider, config|
          Devise.omniauth :ldap, config
        end
      else
        $stderr.puts "Config file doesn't exist: #{config_file}"
      end
    end

    config.to_prepare do
      ApplicationController.send(:include, Multiauth::Helpers)
    end
  end
end
