module BrokenRecord
  #
  # This is an error that is a result of a model validation throwing an error
  #
  module ReportableError
    class ModelValidationExceptionError < BaseError
      include Helpers::ExceptionHelper

      def initialize(model, exception, options)
        @options = options
        @exception = exception
        @model = model
      end

      #
      # Accessor methods
      #
      def id
        @model.id
      end

      def error_title
        'Validation Exception'
      end

      def message
        construct_message
      end

      attr_reader :exception

      private

      def construct_message
        message = "    Exception while trying to load models for #{@model.class}."
        serialize_exception(message, compact_output)
      end
    end
  end
end
