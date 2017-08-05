module BrokenRecord
  #
  # This is an error that comes when there are exceptions trying to run validations
  #
  module ReportableError
    class ValidatorExceptionError < BaseError
      include Helpers::ExceptionHelper

      def initialize(validator_class, exception, options)
        @options = options
        @exception = exception
        @validator_class = validator_class
      end

      #
      # Accessor methods
      #
      def id
        nil
      end

      def error_title
        'Validator Exception'
      end

      def message
        construct_message
      end

      attr_reader :exception

      private

      def construct_message
        message = "    Exception while trying to run validator #{@validator_class}."
        serialize_exception(message, compact_output)
      end
    end
  end
end
