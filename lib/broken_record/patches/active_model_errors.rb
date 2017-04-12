module BrokenRecord
  module Patches
    module ErrorTracker
      BUILT_IN_VALIDATION_METHOD = 'validate_each'

      def add(attribute, message = :invalid, options = {})
        # Track the source location
        @error_mapping ||= {}

        caller_location = caller_locations(1,1)[0]
        calling_method = caller_location.base_label

        _message = normalize_message(attribute, message, options)
        if calling_method == BUILT_IN_VALIDATION_METHOD
          @error_mapping[_message] = {
            context:  _message,
            source: "#{$:.grep(/broken_record/).first}/broken_record/best_practices.md:1"
          }
        else
          @error_mapping[_message] = {
            context: "##{calling_method}",
            source: "#{caller_location.path}:#{caller_location.lineno}"
          }
        end

        super(attribute, message, options)
      end

      def error_mappings
        values.flatten.map { |error_message| [error_message, @error_mapping[error_message]] }
      end
    end
  end
end

ActiveModel::Errors.send(:prepend, BrokenRecord::Patches::ErrorTracker)
