module BrokenRecord
  class JobResult
    attr_reader :start_time, :end_time, :job, :normalized_errors, :original_errors, :exceptions

    def initialize(job)
      @job = job
      @normalized_errors = []
      @original_errors = []
      @exceptions = []
    end

    def start_timer
      @start_time = Time.now
    end

    def stop_timer
      @end_time = Time.now
    end

    def add_error(id: nil, error_type:, message:, errors: nil, exception: nil)
      @normalized_errors << { id: id, message: message, error_type: error_type }
      @original_errors << [id, errors] if errors
      @exceptions << [id, exception] if exception
    end

    def errors
      @normalized_errors.map do |error|
        "#{error[:message].red}\n"
      end
    end

    def error_ids
      @normalized_errors.map do |error|
        error[:id]
      end.compact
    end
  end
end
