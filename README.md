# SocialAuth

Designed specifically for API authentication it makes supporting multiple login sources a breeze.

### Overview
Each social network eg. `Twitter, Facebook` is known as a service. A user can have multiple services.
Each service is identified by a `method` which can either be `Authenticated` (The user has used this service to authenticate and login with) or `Connected` (Which associates that service and allows importing of contacts and api access).

####Supported Social Networks
- Facebook: https://github.com/nov/fb_graph2
- Twitter:  https://github.com/sferik/twitter
- Google+: https://github.com/seejohnrun/google_plus

###Install
```
gem 'social_auth'
```

*Note you'll need to update the migration to `uuids` if thats what your using.*

```
rails g social_auth:install
rake db:migrate
```
**Type and Token chart**

Type | Token | Notes
--- | --- | ---
`facebook`| `{access_token: "token"}`
`google_plus`| `{auth_token: "token"}`| *We exchange your auth_token for a refresh_token which we do store*
`twitter`| `{access_token: "token", access_token_secret: "secret_token"}`

###Usage
**Authenticating**

```ruby
SocialAuth.authenticate(type, auth_token)
```

**Connecting a service**

```ruby
SocialAuth.connect(user, type, auth_token)
```

**Disconnecting a service**

*Disconnecting destroys that the service but only if its a `Connected` service.*
```ruby
SocialAuth.disconnect(user, type)
```

**User create callbacks**

*Each time an authentication request needs to create a user it makes these callbacks to `User` which returns a non persisted user.
(Example responses can be found in the VCR records or you can have a play around in specs but the typical payload returns everything you need to know about the user)*

```ruby
class User
  def self.create_with_facebook_request(response)
    User.new(
      display_name: "#{response.first_name} #{response.last_name[0]}.",
      profile_picture_url: "http://graph.facebook.com/#{response.id}/picture?type=small"
    )
  end

  def self.create_with_twitter_request(response)
    User.new(
      display_name: "#{response.screen_name.capitalize}",
      profile_picture_url: "#{response.profile_image_uri(:bigger)}"
    )
  end

  def self.create_with_google_plus_request(response)
    User.new(
      display_name: "#{response.name.given_name} #{response.name.family_name[0]}.",
      profile_picture_url: response.image.url
    )
  end
end
```
**Other useful callbacks**

*SocialAuth will look for the existence of these methods and call them only if they respond*
```ruby
class User

  #called when a service is abruptly invalidated. Gives you the opportunity to act or inform your users
  def service_disconnected_callback(service)
  end

  def friend_joined_the_app_callback(user)
  end

  #I needed the ability to validate or swap out a user before it was created so this method can perform
  #last minute checks on the user.
  def validate_existing_user(remote_id, service.type)
    return self
  end
end
```

##Friends and Associated Services

As each Service has their own set of `friends` we've created an easy way to access all your friends across each service. `acts_as_social_user` gives our `user` access to the following methods
- `friends_that_use_the_app` (returns a collection of users)
- `remote_ids` (returns a flattened array of all your friends ids across all connected services)
- `services` (returns all your related services)

```ruby
class user
  acts_as_social_user
end
```

**friends_that_use_the_app explained**

I wanted to create a quick and easy way to access your friends without querying each service's api or maintaining them in a database.

So what I do is store a list of `remote_ids` in Redis cache for `n` days.
*You might ask what if I friend `user_x` and they join the app, I won't see `user_x` for n days*

How I've gone about this is created the concept of `related_services` where by when `user_x` joins the app I append their `remote_id` to all their friend's `remote_ids`, so you never miss a friend!

**Exception handling inside friends_that_use_the_app:**
If for any reason the `token` stored on the service becomes invalidated and the user attempts to make an external  friends request we will catch that exception and mark that service for disconnection (which means notifying the user and destroying that service). *Note** the service will only be destroyed if its a `Connected` service, if it's an `Authenticated` service we rethrow the exception.

###Running specs

```ruby
BUNDLE_GEMFILE=gemfiles/rails42.gemfile bundle install
BUNDLE_GEMFILE=gemfiles/rails42.gemfile bundle exec rspec spec
```

###Exception handling
Because were integrating a variety of different gems to save us handling every exception they can throw at us I'm catching most of them and throwing our own blanket Exception. The most commonly used one is `SocialAuth::InvalidToken` which uses the error message from the original exception as its own.

Exception | Notes
--- | ---
`InvalidToken`| Raised whenever a service returns an invalid token error.
`ServiceDoesNotExist`| Raised when your trying to disconnect a service from a user and it doesn't exist
`Error`| General exception for artbitrary assertions
