# frozen_string_literal: true

module Oort
  class Inserts
    def self.call(stored_in:, insert_method_name:, class_name:)
      new(stored_in: stored_in, insert_method_name: insert_method_name, class_name: class_name).call
    end

    attr_reader :stored_in, :insert_method_name, :class_name

    def initialize(stored_in:, insert_method_name:, class_name:)
      @stored_in = stored_in
      @insert_method_name = insert_method_name
      @class_name = class_name
    end

    def call
      class_name.class_eval(
        # def update_posts_ordering(insert:, at: 0)
        #   with_lock do
        #     current_values = public_send(stored_in.inspect)
        #     current_index = current_values.find_index(insert)
        #     insertable = current_index.blank? ? insert : current_values.delete_at(current_index)
        #     current_values.insert(at, insertable)
        #     update(stored_in.inspect => current_values)
        #   end
        # end
        <<-RUBY, __FILE__, __LINE__ + 1
          def #{insert_method_name}(insert:, at: 0, initial: nil)
            with_lock do
              current_values = public_send(#{stored_in.inspect})

              if initial == :top
                current_values.unshift(insert)
                save
              elsif initial == :bottom
                current_values << insert
                save
              else
                current_index = current_values.find_index(insert)
                insertable = current_index.blank? ? insert : current_values.delete_at(current_index)
                current_values.insert(at, insertable)
                update(#{stored_in.inspect} => current_values)
              end
            end
          end
        RUBY
      )
    end
  end
end
