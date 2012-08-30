# -*- coding: utf-8 -*-
Ace::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # In the development environment your application's code is reloaded on every request.  This slows
  # down response time but is perfect for development since you don't have to restart the webserver
  # when you make code changes.
  config.cache_classes = true

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = true

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Compress assets.  For CSS, take out whitespace, comments, etc.  For JS, use a compressor (yui).
  config.assets.compress = false

  # Configures Rails to serve static assets. Defaults to true, but in the production environment is
  # turned off as the server software (e.g. Nginx or Apache) used to run the application should
  # serve static assets instead. Unlike the default setting set this to true when running
  # (absolutely not recommended!) or testing your app in production mode using WEBrick. Otherwise
  # you won´t be able use page caching and requests for files that exist regularly under the public
  # directory will anyway hit your Rails app.
  # config.serve_static_assets = false

  # Live Compilation of assets.  In this mode all requests for assets in the pipeline are handled by
  # Sprockets directly.  On the first request the assets are compiled and cached as outlined in
  # development above, and the manifest names used in the helpers are altered to include the MD5
  # hash.  This mode uses more memory, performs more poorly than the default and is not recommended.
  config.assets.compile = true

  # Append the file's md5 digest to the end of asset filenames.
  config.assets.digest = true

  # config.assets.debug Default 'true' for all environments but production If true, make sure that
  # 'require' directives in application.js and application.css are expanded to individual <script>
  # and <link> tags.  If false, all 'require's are combined into a single file.
  config.assets.debug = false

  config.force_ssl = true
end
