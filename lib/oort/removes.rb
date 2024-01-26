# frozen_string_literal: true

module Oort
  # Oort.configure do |config|
  #   config.option = 'this'
  # end
  class Removes
    def self.call(stored_in:, remove_from_method_name:, class_name:)
      new(stored_in: stored_in, remove_from_method_name: remove_from_method_name, class_name: class_name).call
    end

    attr_reader :stored_in, :remove_from_method_name, :class_name

    def initialize(stored_in:, remove_from_method_name:, class_name:)
      @stored_in = stored_in
      @remove_from_method_name = remove_from_method_name
      @class_name = class_name
    end

    def call
      class_name.class_eval(
        # def remove_from_posts_ordering(id)
        #   with_lock do
        #     current_values = public_send(stored_in.inspect)
        #     current_index = current_values.find_index(id)
        #     current_values.delete_at(current_index)
        #     update(stored_in.inspect => current_values)
        #   end
        # end
        <<-RUBY, __FILE__, __LINE__ + 1
          def #{remove_from_method_name}(id)
            with_lock do
              current_values = public_send(#{stored_in.inspect})
              current_index = current_values.find_index(id)
              return if current_index.blank?

              current_values.delete_at(current_index)
              update(#{stored_in.inspect} => current_values)
            end
          end
        RUBY
      )
    end
  end
end
