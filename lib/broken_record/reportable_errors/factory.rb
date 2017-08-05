module BrokenRecord
  module ReportableError
    class Factory
      def from_model(invalid_model, options = {})
        InvalidModelError.new(invalid_model, options)
      end

      def from_model_exception(model, exception, options = {})
        ModelValidationExceptionError.new(model, exception, options)
      end

      def from_validator_exception(validator_class, exception, options = {})
        ValidatorExceptionError.new(validator_class, exception, options)
      end
    end
  end
end
