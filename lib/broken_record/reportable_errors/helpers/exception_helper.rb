module BrokenRecord
  #
  # Helper to wrap common operations around exceptions.
  # Can be included in any ReportableError that is initialized with an @exception instance variable
  #
  module ReportableError
    module Helpers
      module ExceptionHelper
        def serialize_exception(message, compact_output)
          message << "- #{@exception}.\n" << source.map { |line| "        #{line}" }.join("\n") unless compact_output
          message
        end

        def source
          @exception.backtrace
        end

        def exception_context
          if defined? Rails
            source.grep(Regexp.new(Rails.root.to_s))[0].gsub("#{Rails.root}/", '')
          else
            source
          end
        end

        def exception_class
          @exception.is_a?(Class) ? @exception : @exception.class
        end
      end
    end
  end
end
