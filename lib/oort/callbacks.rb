# frozen_string_literal: true

module Oort
  class Callbacks
    def self.call(association_class:, remove_from_method_name:, insert_method_name:, instance_name:, default:)
      new(
        association_class: association_class,
        remove_from_method_name: remove_from_method_name,
        insert_method_name: insert_method_name,
        instance_name: instance_name,
        default: default
      ).call
    end

    attr_reader :association_class, :remove_from_method_name, :insert_method_name, :instance_name, :default

    def initialize(association_class:, remove_from_method_name:, insert_method_name:, instance_name:, default:)
      @association_class = association_class
      @remove_from_method_name = remove_from_method_name
      @insert_method_name = insert_method_name
      @instance_name = instance_name
      @default = default
    end

    def call
      add_callbacks
      add_methods
    end

    private

    def add_callbacks
      association_class.class_eval do
        after_create_commit :initial_insert_at
        before_destroy :remove_from_reorderable
      end
    end

    def add_methods
      association_class.class_eval(
        # def insert_at(position = 0)
        #   public_send(:user)
        #     .public_send(:update_posts_ordering, insert: id, at: position)
        # end

        # def remove_from_reorderable
        #   public_send(:user).public_send(:remove_from_posts_ordering, id)
        # end
        <<-RUBY, __FILE__, __LINE__ + 1
          def insert_at(position = 0, initial: nil)
            public_send(#{instance_name.inspect})
              .public_send(#{insert_method_name.inspect}, insert: id, at: position, initial: initial)
          end

          def initial_insert_at
            insert_at(initial: #{default.inspect})
          end

          def remove_from_reorderable
            public_send(#{instance_name.inspect})
              .public_send(#{remove_from_method_name.inspect}, id)
          end
        RUBY
      )
    end
  end
end
