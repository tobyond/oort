# frozen_string_literal: true

module Oort
  module Scopes
    def self.included(base)
      # user = User.find(909)
      # user.posts.ordered_with(user.posts_ordered)
      # by default this will use posts.id::INTEGER
      # but you can pass in something else if you have joins and items
      # stored in another table
      base.scope :ordered_with, lambda { |ids, type = "#{table_name}.id::INTEGER"|
                                  if ids.blank?
                                    order(:id)
                                  else
                                    order(Arel.sql("array_position(ARRAY[#{ids.join(", ")}], #{type})"))
                                  end
                                }
    end
  end
end
