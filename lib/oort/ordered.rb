# frozen_string_literal: true

module Oort
  # Oort.configure do |config|
  #   config.option = 'this'
  # end
  module Ordered
    def self.included(base)
      base.extend ClassMethods
      # base.include InstanceMethods

      base.class_eval do
      end
    end

    module ClassMethods
      def handles_ordering_of(association)
        args = {
          stored_in: :"#{association}_ordering",
          insert_method_name: :"update_#{association}_ordering",
          remove_from_method_name: :"remove_from_#{association}_ordering",
          association_class: association.to_s.classify.constantize,
          instance_name: :"#{name.downcase}",
          class_name: name.classify.constantize
        }

        Inserts.call(**args.slice(:stored_in, :insert_method_name, :class_name))
        Removes.call(**args.slice(:stored_in, :remove_from_method_name, :class_name))
        Scopes.call(**args.slice(:association_class))
        Callbacks.call(**args.slice(:association_class, :remove_from_method_name, :insert_method_name, :instance_name))
      end
    end
  end
end
