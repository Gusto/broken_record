module BrokenRecord
  #
  # All ReportableErrors inherit from this class
  #
  # TODO: Use several mixins instead
  # Error type constants mixin, config wrapper mixin to set options, and `normalized_error` could be ErrorHelper
  module ReportableError
    class BaseError
      attr_reader :options

      def compact_output
        options[:compact_output].nil? ? BrokenRecord::Config.compact_output : options[:compact_output]
      end

      def normalized_error
        {
          id: id,
          message: message,
          error_title: error_title
        }
      end
    end
  end
end
