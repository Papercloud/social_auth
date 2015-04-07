# SocialLogin

Designed specifically for API authentication it makes supporting multiple login sources a breeze. 

### Overview
Each social network eg. `Twitter, Facebook` is known as a service. A user can have multiple services. 
Each service is definifed by a `method` which can either be `Authenticated` (The user has used this server to authenticate and login with) or `Connected` (Which associates that service and allows importing of contacts and api access). 

A user cannot use a `Connected` service to authenticate with except for the scenario that the `remote_id` of that service is unique to the backend.   

####Supported Social Networks 
- Facebook: https://github.com/nov/fb_graph2
- Twitter:  https://github.com/sferik/twitter
- Google+: https://github.com/seejohnrun/google_plus

###Install
```
gem 'social_login', github: 'papercloud/social_login'
```

*Note you'll need to update the migration to `uuids` if thats what your using.*

```
rails g social_login:install
rake db:migrate
```
**Type and Token chart**

Type | Token
--- | --- 
`facebook`| `{access_token: "token"}`
`google_plus`| `{access_token: "token"}`
`twitter`| `{access_token: "token", access_token_secret: "secret_token"}`

###Usage
**Authenticating**

```ruby
SocialLogin.authenticate(type, auth_token)
```

**Connecting a service**

```ruby
SocialLogin.connect(user, type, auth_token)
```

**User create callbacks**

*Each time an authentication request needs to create a user it makes these callbacks to `User` which return a none persisted user. 
(Example responses can be found in the VCR records or you can have a play around in specs but the typical payload returns everything you need to know about the user)* 

```ruby
class User 
  def self.create_with_facebook_request(response)
    User.new(
      display_name: "#{response.first_name} #{response.last_name[0]}."
    )
  end
  
  def self.create_with_twitter_request(response)
    User.new(
      display_name: "#{response.screen_name.capitalize}"
    )
  end
  
  def self.create_with_google_plus_request(response)
    User.new(
      display_name: "#{response.name.given_name} #{response.name.family_name[0]}."
    )
  end
end
```
