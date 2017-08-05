module BrokenRecord
  class ResultAggregator
    def initialize
      @aggregated_results = {}
    end

    def add_result(result)
      job_class = result.job.klass
      @aggregated_results[job_class] ||= []
      @aggregated_results[job_class] << result
    end

    def report_job_start
      # No-op: Define in subclass
    end

    def report_results(klass)
      # No-op: Define in subclass
    end

    def report_final_results
      # No-op: Define in subclass
    end

    def success?
      total_error_count == 0
    end

    def count(klass)
      results_for_class(klass).count
    end

    private

    def total_error_count
      all_errors.count
    end

    def all_error_ids_for(klass)
      results_for_class(klass).flat_map(&:all_errors).map(&:id).compact
    end

    def invalid_model_errors_for(klass)
      results_for_class(klass).flat_map(&:invalid_model_errors)
    end

    def all_classes
      @aggregated_results.keys
    end

    def all_results
      @aggregated_results.values.flatten
    end

    def all_errors
      all_results.flat_map(&:all_errors)
    end

    def all_errors_for(klass)
      results_for_class(klass).flat_map(&:all_errors)
    end

    def duration(klass)
      start_time = results_for_class(klass).map(&:start_time).min
      end_time = results_for_class(klass).map(&:end_time).max
      (end_time - start_time).round(3)
    end

    def app_name
      Rails.application.class.parent_name
    end

    def results_for_class(klass)
      @aggregated_results[klass]
    end
  end
end
