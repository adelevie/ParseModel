# About

ParseModel provides an Active Record pattern to your Parse models on RubyMotion.

I'm using ParseModel internally for a project, slowly but surely making it much, much better. When the project is near completion, I'm going to extract additional functionality into the gem.

Expect a much more Ruby-esque API that still leaves full access to all of the features in the Parse iOS SDK. I'm not trying to re-implement features from the Parse iOS SDK, I just want to make them easier to use. Moreover, you should be able to rely on [Parse's iOS docs](https://parse.com/docs/ios/api/) when using ParseModel.

If you have any questions or suggestions, email me.

## Usage

Create a model:

```ruby
class Post
  include ParseModel::Model

  fields :title, :body, :author
end
```

Create an instance:

```ruby
p = Post.new
p.title = "Why RubyMotion Is Better Than Objective-C"
p.author = "Josh Symonds"
p.body = "trololol"
```

`ParseModel::Model` objects will `respond_to?` to all methods available to [`PFObject`](https://parse.com/docs/ios/api/Classes/PFObject.html) in the Parse iOS SDK. You can also access the `PFObject` instance directly with, you guessed it, `ParseModel::Model#PFObject`.

### Saving objects

```ruby
p = Post.new
p.author = "Alan"

# save using main thread (blocking)
p.save

# save eventually (non-blocking)
p.saveEventually

# save in background with a block
p.saveInBackgroundWithBlock(lambda do |success, error|
  # do something...
end)

```

### New: Cloud Code functions

```ruby
# with block:
ParseModel::Cloud.callFunction("myFunction", {"myParam" => "myValue"}) do |result, error|
  # do something...
end

# without block:
ParseModel::Cloud.callFunction("myFunction", {"myParam" => "myValue"})
```

#### Cloud Code Examples
```javascript
Parse.Cloud.define('trivial', function(request, response) {
  response.success(request.params);
});
```

```ruby
ParseModel::Cloud.callFunction("trivial", {"foo" => "bar"})
#=> {"foo"=>"bar"}
```

```javascript
// implementation of random queries using Parse Cloud Code
// see https://parse.com/questions/random-search-its-possibile for setup details

Parse.Cloud.define('randomNouns', function(request, response) {
  var NounMaster = Parse.Object.extend("NounMaster");
  var maxQuery = new Parse.Query(NounMaster);
  maxQuery.first({
    success: function(object) {
      var max = object.get("nextWordIndex");
      var n = 10;
      if(request.params.count) { n = request.params.count; }
      var arr = [];
      while (arr.length < n) {
        arr.push(Math.ceil(Math.random() * max));
      }
      var indexes = arr;
      var Noun = Parse.Object.extend("Noun");
      var nounQuery = new Parse.Query(Noun);
      nounQuery.containedIn("index", indexes);
      nounQuery.find({
        success: function(results) { 
          response.success(results); 
        }
      });
    }
  });
});
```

```ruby
ParseModel::Cloud.callFunction("randomNouns", {"count" => 3})
#=> [#<PFObject:0x9620ee0>, #<PFObject:0x9629430>, #<PFObject:0x9629cd0>]
```

### Users

```ruby
class User
  include ParseModel::User
end

user = User.new
user.username = "adelevie"
user.email = "adelevie@gmail.com"
user.password = "foobar"
user.signUp

users = User.all # for more User query methods, see: https://parse.com/questions/why-does-querying-for-a-user-create-a-second-user-class 
users.map {|u| u.objectId}.include?(user.objectId) #=> true
```

`ParseModel::User` delegates to `PFUser` in a very similar fashion as `ParseModel::Model` delegates to `PFOBject`.

#### Current User

```ruby
if User.current_user
  @user = User.current_user
end
```

### Queries

Parse provides some great ways to query for objects: in the current blocking thread (`PFQuery#findObjects`, or in the background with a block (`PFQuery#findObjectsInBackGroundWithBlock()`).

These method names are a little long and verbose for my taste, so I added a little but of syntactic sugar:

```ruby
query = Post.query #=> <ParseModel::Query> ... this is a subclass of PFQuery
query.whereKey("author", equalTo:"Alan")
query.find # finds objects in the main thread, like PFQuery#findObjects

# Or run the query in a background thread

query.find do |objects, error|
  puts "You have #{objects.length} objects of class #{objects.first.class}."
end
```

By passing a two-argument block to `ParseModel::Query#find(&block)`, the query will automatically run in the background, with the code from the given block executing on completion.

Also note that `ParseModel::Query#find` and `ParseModel::Query#find(&block)` return `ParseModel::Model` objects, and not `PFObject`s.

Because I want Parse's documentation to be as relevant as possible, here's how I'm matching up `ParseModel::Query`'s convenience methods to `PFQuery`:

`ParseModel::Query` method | Equivalent `PFQuery` method
---------------------------|----------------------------|
`ParseModel::Query#find`| [`PFQuery#findObjects`][findObjects]
`ParseModel::Query#find(&block)`| [`PFQuery#findObjectsInBackgroundWithBlock`][findObjectsInBackgroundWithBlock]
`ParseModel::Query#getFirst`| [`PFQuery#getFirstObject`][getFirstObject]
`ParseModel::Query#get(id)`| [`PFQuery#getObjectWithId`][getObjectWithId]
`ParseModel::Query#get(id, &block)`| [`PFQuery#getObjectInBackgroundWithId:block:`][getObjectInBackgroundWithId]
`ParseModel::Query#count`| [`PFQuery#countObjects`][countObjects]
`ParseModel::Query#count(&block)`| [`PFQuery#countObjectsInBackgroundWithBlock`][countObjectsInBackgroundWithBlock]

[findObjects]: https://parse.com/docs/ios/api/Classes/PFQuery.html#//api/name/findObjects
[findObjectsInBackGroundWithBlock]: https://parse.com/docs/ios/api/Classes/PFQuery.html#//api/name/countObjectsInBackgroundWithBlock:
[getFirstObject]: https://parse.com/docs/ios/api/Classes/PFQuery.html#//api/name/getFirstObject
[getFirstObjectInBackgroundWithBlock]: https://parse.com/docs/ios/api/Classes/PFQuery.html#//api/name/getFirstObjectInBackgroundWithBlock:
[getObjectWithId]: https://parse.com/docs/ios/api/Classes/PFQuery.html#//api/name/getObjectWithId
[getObjectInBackgroundWithId]: https://parse.com/docs/ios/api/Classes/PFQuery.html#//api/name/getFirstObjectInBackgroundWithBlock:
[countObjects]: https://parse.com/docs/ios/api/Classes/PFQuery.html#//api/name/countObjects
[countObjectsInBackgroundWithBlock]: https://parse.com/docs/ios/api/Classes/PFQuery.html#//api/name/countObjectsInBackgroundWithBlock:


Essentially, I'm omitting the words "object" and "InBackgroundWithBlock" from `ParseModel`'s method signatures. I think it's a reasonable assumption that it can simply be implied that we're dealing with "objects." If I'm passing a block, it's repetitive to declare that I'm passing a block.

## Installation

Either `gem install ParseModel` then `require 'ParseModel'` in your `Rakefile`, OR
`gem "ParseModel"` in your Gemfile. ([Instructions for Bundler setup with Rubymotion)](http://thunderboltlabs.com/posts/using-bundler-with-rubymotion)

Somewhere in your code, such as `app/app_delegate.rb` set your API keys:

```ruby
Parse.setApplicationId("1234567890", clientKey:"abcdefghijk")
```

To install the Parse iOS SDK in your RubyMotion project, add the Parse iOS SDK to your `vendor` folder, then add the following to your `Rakefile`:

```ruby
  app.libs << '/usr/lib/libz.1.1.3.dylib'
  app.libs << '/usr/lib/libsqlite3.dylib'
  app.frameworks += [
    'AudioToolbox',
    'CFNetwork',
    'CoreGraphics',
    'CoreLocation',
    'MobileCoreServices',
    'QuartzCore',
    'Security',
    'StoreKit',
    'SystemConfiguration']

  # in case app.deployment_target < '6.0'
  app.weak_frameworks += [
    'Accounts',
    'AdSupport',
    'Social']

  app.vendor_project('vendor/Parse.framework', :static,
    :products => ['Parse'],
    :headers_dir => 'Headers')
```

More info on installation: [this](http://www.rubymotion.com/developer-center/guides/project-management/#_using_3rd_party_libraries) and  [this](http://stackoverflow.com/a/10453895/94154).

## License

See LICENSE.txt
