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

## Installation

For now, just copy `parse_model.rb` into your `app` folder. Gemification [coming soon](http://twitter.com/#!/lrz/status/198781031619379202).

Somewhere in your code, such as `app/app_delegate.rb` set your API keys:

```ruby
Parse.setApplicationId("1234567890", clientKey:"abcdefghijk")
```

To install the Parse iOS SDK in your RubyMotion project, read [this](http://www.rubymotion.com/developer-center/guides/project-management/#_using_3rd_party_libraries) and  [this](http://stackoverflow.com/a/10453895/94154).
