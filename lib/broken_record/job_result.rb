module BrokenRecord
  class JobResult
    attr_reader :start_time, :end_time, :errors, :job

    def initialize(job)
      @job = job
      @errors = []
    end

    def start_timer
      @start_time = Time.now
    end

    def stop_timer
      @end_time = Time.now
    end

    def add_error(error)
      @errors << "#{error.red}\n"
    end
  end
end