module BrokenRecord
  #
  # This is an error that can be attributed to a single model instance
  #
  module ReportableError
    class InvalidModelError < BaseError
      def initialize(invalid_model, options)
        @options = options
        @invalid_model = invalid_model
      end

      #
      # Accessor methods
      #
      def id
        @invalid_model.id
      end

      def error_title
        'Invalid Record'
      end

      def message
        construct_message
      end

      def model_errors
        @invalid_model.errors
      end

      private

      def construct_message
        id = @invalid_model.id
        message = "    Invalid record in #{@invalid_model.class} id=#{id}."
        @invalid_model.errors.each { |attr, msg| message << "\n        #{attr} - #{msg}" } unless compact_output
        message
      end
    end
  end
end
