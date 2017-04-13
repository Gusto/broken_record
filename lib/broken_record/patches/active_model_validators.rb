module BrokenRecord
  module Patches
    module ValidatorTracker
      attr_reader :allocation_caller_locations

      def initialize(*args)
        @allocation_caller_locations = caller_locations
        super(*args)
      end
    end
  end
end

ActiveModel::Validator.send(:prepend, BrokenRecord::Patches::ValidatorTracker)
