# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.fixture_path = ::Rails.root.join('spec', 'fixtures')

  config.use_transactional_fixtures = true

  config.infer_spec_type_from_file_location!

  config.before :suite do
    FactoryGirl.lint
    DatabaseRewinder.clean_all
  end

  config.after :each do
    DatabaseRewinder.clean
  end

  config.include FactoryGirl::Syntax::Methods
end
