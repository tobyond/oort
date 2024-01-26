# frozen_string_literal: true

module Oort
  class Callbacks
    def self.call(association_class:, remove_from_method_name:, insert_method_name:, instance_name:)
      new(
        association_class: association_class,
        remove_from_method_name: remove_from_method_name,
        insert_method_name: insert_method_name,
        instance_name: instance_name
      ).call
    end

    attr_reader :association_class, :remove_from_method_name, :insert_method_name, :instance_name

    def initialize(association_class:, remove_from_method_name:, insert_method_name:, instance_name:)
      @association_class = association_class
      @remove_from_method_name = remove_from_method_name
      @insert_method_name = insert_method_name
      @instance_name = instance_name
    end

    def call
      add_callbacks
      add_methods
    end

    private

    def add_callbacks
      association_class.class_eval do
        after_create_commit :insert_at
        after_destroy :remove_from_reorderable
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
          def insert_at(position = 0)
            public_send(#{instance_name.inspect})
              .public_send(#{insert_method_name.inspect}, insert: id, at: position)
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
