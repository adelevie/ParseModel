# About

ParseModel provides an Active Record pattern to your Parse models on RubyMotion.

## Usage

Create a model:

```ruby
class Post
  include Parse::Model

  fields :title, :body, :author
end
```

Create an instance:

```ruby
p = Post.new
p.title = "Why RubyMotion Is Better Than Objective-C"
p.author = "Josh Symonds"
p.body = "trololol"
p.saveEventually
```

`Parse::Model` objects will `respond_to?` to all methods available to [`PFObject`](https://parse.com/docs/ios/api/Classes/PFObject.html) in the Parse iOS SDK. You can also access the `PFObject` instance directly with, you guessed it, `Parse::Model#PFObject`.

### Users

```ruby
class User
  include Parse::User
end

user = User.new
user.username = "adelevie"
user.email = "adelevie@gmail.com"
user.password = "foobar"
user.signUp

users = User.all # for more User query methods, see: https://parse.com/questions/why-does-querying-for-a-user-create-a-second-user-class 
users.map {|u| u.objectId}.include?(user.objectId) #=> true
```

`Parse::User` delegates to `PFUser` in a very similar fashion as `Parse::Model` delegates to `PFOBject`.

### Queries

For now, just use Parse's native methods:

```ruby
query = PFQuery.queryWithClassName("Post")
query.whereKey("title", equalTo:"Why RubyMotion Is Better Than Objective-C")
results = query.findObjects
```

Note that this will return an `Array` of `PFObjects`, not `Parse::Model` objects. To convert, just pass the `PFObject` instance into `Parse::Model#new`:

```ruby
results.map! {|result| Post.new(result)}
```


## Installation

Either `gem install ParseModel` then `require 'ParseModel'` in your `Rakefile`, OR

`gem "ParseModel"` in your Gemfile. ([Instructions for Bundler setup with Rubymotion)](http://thunderboltlabs.com/posts/using-bundler-with-rubymotion)

Somewhere in your code, such as `app/app_delegate.rb` set your API keys:

```ruby
Parse.setApplicationId("1234567890", clientKey:"abcdefghijk")
```

To install the Parse iOS SDK in your RubyMotion project, read [this](http://www.rubymotion.com/developer-center/guides/project-management/#_using_3rd_party_libraries) and  [this](http://stackoverflow.com/a/10453895/94154).

## License

See LICENSE.txt