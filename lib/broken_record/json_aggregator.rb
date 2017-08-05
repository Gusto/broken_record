require 'json'

module BrokenRecord
  class JsonAggregator < ResultAggregator

    FILENAME = 'broken_record_results.json'

    def report_final_results
      json = @aggregated_results.reduce({}) do |acc, (klass, job_results)|
        acc[klass.name] = {
          duration: duration(klass),
          invalid_records: job_results.map(&:all_errors).map{|errors| errors.map(&:normalized_error)}
        }
        acc
      end

      write_json(json)
    end

    def write_json(json)
      File.open(FILENAME, 'w') { |f| f.puts(JSON.generate(json)) }
    end
  end
end
