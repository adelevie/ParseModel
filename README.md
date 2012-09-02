# About

ParseModel provides an Active Record pattern to your Parse models on RubyMotion.

I'm using ParseModel internally for a project, slowly but surely making it much, much better. When the project is near completion, I'm going to extract additional functionality into the gem.

Expect a much more Ruby-esque API that still leaves full access to all of the features in the Parse iOS SDK. I'm not trying to re-implement featurs from the Parse iOS SDK, I just want to make them easier to use. Moreover, you should be able to rely on [Parse's iOS docs](https://parse.com/docs/ios/api/) when using ParseModel.

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
p.saveEventually
```

`ParseModel::Model` objects will `respond_to?` to all methods available to [`PFObject`](https://parse.com/docs/ios/api/Classes/PFObject.html) in the Parse iOS SDK. You can also access the `PFObject` instance directly with, you guessed it, `ParseModel::Model#PFObject`.

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

<table>
	<tr>
		<th>`ParseModel::Query` method</th>
		<th>Equivalent `PFQuery` method</th>
		<th>Parse Documentation</th>
	</tr>
	<tr>
		<td>`ParseModel::Query#find`</td>
		<td>`PFQuery#findObjects`</td>
		<td><a href='https://parse.com/docs/ios/api/Classes/PFQuery.html#//api/name/findObjects'>here</a></td>
	</tr>
	<tr>
		<td>`ParseModel::Query#find(&block)`</td>
		<td>`PFQuery#findObjectsInBackgroundWithBlock`</td>
		<td><a href='https://parse.com/docs/ios/api/Classes/PFQuery.html#//api/name/countObjectsInBackgroundWithBlock:'>here</a></td>
	</tr>
	<tr>
		<td>`ParseModel::Query#getFirst` (not yet implemented)</td>
		<td>`PFQuery#getFirstObject`</td>
		<td><a href='https://parse.com/docs/ios/api/Classes/PFQuery.html#//api/name/getFirstObject'>here</a></td>
	</tr>
	<tr>
		<td>`ParseModel::Query#getFirst(&block)` (not yet implemented)</td>
		<td>`PFQuery#getFirstObjectInBackgroundWithBlock`</td>
		<td><a href='https://parse.com/docs/ios/api/Classes/PFQuery.html#//api/name/getFirstObjectInBackgroundWithBlock:'>here</a></td>
	</tr>
	<tr>
		<td>`ParseModel::Query#get(id)` (not yet implemented)</td>
		<td>`PFQuery#getObjectWithId`</td>
		<td><a href='https://parse.com/docs/ios/api/Classes/PFQuery.html#//api/name/getFirstObject'>here</a></td>
	</tr>
	<tr>
		<td>`ParseModel::Query#get(id, &block)` (not yet implemented)/td>
		<td>`PFQuery#getObjectInBackgroundWithId:block:`</td>
		<td><a href='https://parse.com/docs/ios/api/Classes/PFQuery.html#//api/name/getFirstObjectInBackgroundWithBlock:'>here</a></td>
	</tr>
	<tr>
		<td>`ParseModel::Query#count` (not yet implemented)</td>
		<td>`PFQuery#countObjects`</td>
		<td><a href='https://parse.com/docs/ios/api/Classes/PFQuery.html#//api/name/countObjects'>here</a></td>
	</tr>
	<tr>
		<td>`ParseModel::Query#count(&block)`</td>
		<td>`PFQuery#countObjectsInBackgroundWithBlock`</td>
		<td><a href='https://parse.com/docs/ios/api/Classes/PFQuery.html#//api/name/countObjectsInBackgroundWithBlock:'>here</a></td>
	</tr>
</table>

Essentially, I'm omitting the words "object" and "InBackgroundWithBlock" from `ParseModel`'s method signatures. I think it's a reasonable assumption that it can simply be implied that we're dealing with "objects." If I'm passing a block, it's repetitive to declare that I'm passing a block.

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