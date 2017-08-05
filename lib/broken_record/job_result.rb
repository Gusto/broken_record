module BrokenRecord
  class JobResult
    attr_reader :start_time, :end_time, :job, :all_errors, :exception_errors, :invalid_model_errors

    def initialize(job)
      @job = job
      @all_errors = []
      @original_errors = []
      @exception_errors = []
      @invalid_model_errors = []
    end

    def start_timer
      @start_time = Time.now
    end

    def stop_timer
      @end_time = Time.now
    end

    def add_error(error)
      @all_errors << error
      if error.is_a? BrokenRecord::ReportableError::InvalidModelError
        @invalid_model_errors << error
      elsif error.is_a? BrokenRecord::ReportableError::ModelValidationExceptionError
        @exception_errors << error
      elsif error.is_a? BrokenRecord::ReportableError::ValidatorExceptionError
        @exception_errors << error
      else
        raise "Job result does not support error: #{error.class.to_s}"
      end
    end
  end
end
