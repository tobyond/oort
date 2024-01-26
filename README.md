# Oort

#### Rails sorting and ordering without deadlocks.

*Rails and PostgreSQL only (for now).*

Typically, ordering involves adding a position column to records and rearranging the entire collection when altering the sort order. However, this approach is prone to deadlocks and places a heavy load on the database, especially when modifying multiple records simultaneously.

Oort provides an alternative solution by allowing the order to be stored in an array column on the parent object. Any changes to the sort order become a simple modification to a single column.


## Instructions

Let's begin with a basic schema involving a User and a Post. You can substitute these entities as needed; just ensure that handles_ordering_of has a corresponding has_many association. (Replace instances of post with your own association in the following examples.)

### Migration

Firstly, you will also need the following migration to users (postgresql only for now):

```
  def change
    add_column(:users, :posts_ordering, :integer, array: true, default: [], using: 'ARRAY[benefit_type]::INTEGER[]')

    add_check_constraint :users, '(array_position(posts_ordering, null) is null)', name: 'posts_ordering'
  end
```

This will store the ids of posts in an array on the user, and will only accept integers to prevent any nasty surprises.

### Model

Include the `Oort::Ordered` module in the parent object:

```
class User < ActiveRecord::Base
  include Oort::Ordered
  handles_ordering_of :posts

  has_many :posts
end

class Post < ActiveRecord::Base
  belongs_to :user
end

```

This inclusion adds `update_posts_ordering` to the user model and `insert_at` to the posts model. It also introduces removal methods: `remove_from_posts_ordering` for the user model and `remove_from_reorderable` for the posts model.


### Callbacks

The following callbacks are also added to post:

```
after_create_commit :insert_at
after_destroy :remove_from_reorderable
```

These callbacks automatically insert a new post at the first position and remove a destroyed post from the user's list.

### Usage
To change to order of a post, simply call `post.insert_at(12)`
To remove a post, simply call `post.remove_from_reorderable`

### Scope
The `ordered_with` scope is also added to the post model. This allows a `user` object to have the following query:

```
user.posts.ordered_with(user.posts_ordering)

# or

Post.where(user_id: user.id).ordered_with(user.posts_ordering)
```


## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add oort

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install oort


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tobyond/oort.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
