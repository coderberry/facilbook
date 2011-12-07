## FacilBook - Simple Facebook Navigation

### Getting Started

0- Prerequisite: You need a facebook app.  Have your API Key, Application
Secret, and Application ID handy.

1- Add `gem 'facilbook'` to your Gemfile and run `bundle install`.

2- Create `config/facilbook_config.yml` with the appropriate environments.

    production:
      app_id: <your application id>
      app_secret: <your application secret>
      facebook_app_url: http://apps.facebook.com/<your app name>

3- Create `config/initializers/load_facilbook_config.rb` and place the following in it

    raw_config = File.read("#{Rails.root}/config/facilbook_config.yml")
    FACILBOOK_CONFIG = YAML.load(raw_config)[Rails.env].symbolize_keys

4- Add the following line to your `app/controllers/application_controller.rb`
  
  (add it right after the line class `ApplicationController < ActionController::Base` so as to add the Facebooker2 instance methods to the Application controller)

    include Facilbook::ApplicationControllerMethods

5- Add the following line to your `app/helpers/application_helper.rb`

  (add it right after the line `module ApplicationHelper`

    include Facilbook::ApplicationHelperMethods

### Usage

TBD