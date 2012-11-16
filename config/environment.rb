ENV["RAILS_ENV"] = %x[hostname].start_with?("prod") ? "production" : "development"

# Load the rails application
require File.expand_path('../application', __FILE__)

Rails.env = ENV["RAILS_ENV"]

# Initialize the rails application
Qna::Application.initialize!

