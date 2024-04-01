# frozen_string_literal: true

require "test_helper"

class Post < ActiveRecord::Base
  include Oort::Scopes
  belongs_to :user
end

class User < ActiveRecord::Base
  include Oort::Ordered
  handles_ordering_of :posts

  has_many :posts
end

class TestOort < Minitest::Test
  def setup
    ActiveRecord::Base.connection.create_table :users do |t|
      t.column(
        :posts_ordering,
        :integer,
        array: true,
        default: [],
        using: "ARRAY[benefit_type]::INTEGER[]"
      )

      t.check_constraint "(array_position(posts_ordering, null) is null)", name: "posts_ordering"
    end

    ActiveRecord::Base.connection.create_table :posts do |t|
      t.column :user_id, :bigint
    end

    @user = User.create
  end

  def teardown
    teardown_db
  end

  def test_that_it_has_a_version_number
    refute_nil ::Oort::VERSION
  end

  def test_responds_to_insert_methods
    assert @user.respond_to? :update_posts_ordering
  end

  def test_responds_to_removes_methods
    assert @user.respond_to? :remove_from_posts_ordering
  end

  def test_remove_method_handles_missing_id
    assert_nothing_raised do
      @user.remove_from_posts_ordering(0)
    end
  end

  def test_scope
    @post1 = Post.create(user_id: @user.id)
    @post2 = Post.create(user_id: @user.id)

    assert_equal @user.posts.ordered_with(@user.posts_ordering).pluck(:id), [@post1.id, @post2.id]
  end

  def test_after_create
    @post1 = Post.create(user_id: @user.id)
    @post2 = Post.create(user_id: @user.id)

    assert_equal @user.reload.posts_ordering, [@post2.id, @post1.id]
  end

  def test_after_destroy
    @post1 = Post.create(user_id: @user.id)
    @post2 = Post.create(user_id: @user.id)

    @post1.destroy

    assert_equal @user.reload.posts_ordering, [@post2.id]
  end

  def test_post_responds_to_insert_methods
    @post1 = Post.create(user_id: @user.id)

    assert @post1.respond_to? :insert_at
  end

  def test_post_responds_to_remove_methods
    @post1 = Post.create(user_id: @user.id)

    assert @post1.respond_to? :remove_from_reorderable
  end

  def test_default_top
    User.handles_ordering_of(:posts, default: :top)

    @post1 = Post.create(user_id: @user.id)
    @post2 = Post.create(user_id: @user.id)

    User.handles_ordering_of(:posts)

    assert_equal @user.posts.ordered_with(@user.posts_ordering).pluck(:id), [@post1.id, @post2.id]
  end

  def test_default_bottom
    User.handles_ordering_of(:posts, default: :bottom)

    @post1 = Post.create(user_id: @user.id)
    @post2 = Post.create(user_id: @user.id)

    User.handles_ordering_of(:posts)

    assert_equal @user.posts.ordered_with(@user.posts_ordering).pluck(:id), [@post1.id, @post2.id]
  end
end
