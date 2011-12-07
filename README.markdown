![](https://img.skitch.com/20111207-npqgk2tdkndf7enpgurgt9t48q.jpg)

FacilBook - Simple Facebook Navigation
======================================

Facilbook is a set of tools that makes navigation with Facebook easy. See usage below.

Facilbook is used in conjuction with Omniauth for Facebook.  It is recommended that you have authentication in place
using the `omniauth-facebook` gem (see the [Simple Omniauth Railscast](http://railscasts.com/episodes/241-simple-omniauth))

One of the best features of this gem is that it places the decrypted signed request into the request scope.
Anywhere in the application you can access this via @signed_request.

## Getting Started

0 - Prerequisite: You need a facebook app.  Have your API Key, Application
Secret, and Application ID handy.

1 - Add `gem 'facilbook'` to your Gemfile and run `bundle install`.

2 - Create `config/facilbook_config.yml` with the appropriate environments.

    production:
      app_id: <your application id>
      app_secret: <your application secret>
      facebook_app_url: http://apps.facebook.com/<your app name>

This data will be in your facebook settings. For example:

![](https://img.skitch.com/20111207-rwx33b5q4g7yk82gat5yrkhwtw.jpg)

3 - Create `config/initializers/load_facilbook_config.rb` and place the following in it

    raw_config = File.read("#{Rails.root}/config/facilbook_config.yml")
    FACILBOOK_CONFIG = YAML.load(raw_config)[Rails.env].symbolize_keys
    
This creates the static variable `FACILBOOK_CONFIG` which is used within the gem.

4 - Add the following line to your `app/controllers/application_controller.rb`
  
  (add it right after the line class `ApplicationController < ActionController::Base` so as to add the Facebooker2 instance methods to the Application controller)

    include Facilbook::ApplicationControllerMethods

5 - Add the following line to your `app/helpers/application_helper.rb`

  (add it right after the line `module ApplicationHelper`

    include Facilbook::ApplicationHelperMethods

## Usage

### Application Controller Methods

**redirect_to_facebook(target_path)**

Redirects to the Facebook url with the target path.

      redirect_to_facebook("/foo/bar")
      
      will redirect the user to the following url:
      
      http://apps.facebook.com/<your app name>/foo/bar


**current_user**

Returns the current user that is either in the session, or one that exists with the same 
UID as the current Facebook user account. This is done via the `signed_request` from Facebook.

This assumes that there is a `User` model with the attributes :provider (being 'facebook') and :uid
as explained in the [Railscast](http://railscasts.com/episodes/241-simple-omniauth) mentioned above.

**url_for_facebook(path)**

Creates a Facebook link using the relative path. This is accessible by any controller.

      url_for_facebook("/foo/bar")

      creates the following:

      "http://apps.facebook.com/<your app name>/foo/bar"

### Application Helper Methods

**facebook_image_tag(uid, options = {})**

*Loads the image of a Facebook user based on their Facebook UID.*
    
      Options
        :type - Type of image to display. Can be 'square', 'small' or 'large'.
        :size - Size of the image in width and height (example: 100x150)
    
      Examples:
    
        facebook_image_tag('100003043983036')
        facebook_image_tag('100003043983036', { :size => '100x150' })
        facebook_image_tag('100003043983036', { :type => 'small' })
        
**link_to_facebook(\*args, &block)**

Same as link_to but ensures that the link directs the user to the parent window via a javascript onclick action.
You should only use the relative path as the first argument and never the full url.

      link_to_facebook("/foo/bar")
      
      creates the following:
      
      <a href="#" onclick="window.top.location='http://apps.facebook.com/<your app name>/foo/bar'; return false;" />
      
**url_for_facebook(path)**

Creates a Facebook link using the relative path. This was created for use in Javascript.

      url_for_facebook("/foo/bar")

      creates the following:

      "http://apps.facebook.com/<your app name>/foo/bar"