module BrokenRecord
  class ConsoleAggregator < ResultAggregator
    def report_results(klass, logger: $stdout)
      super(klass)

      result_count = BrokenRecord::Config.default_result_count

      class_errors = all_errors_for(klass)
      all_error_ids_for = all_error_ids_for(klass)
      duration = duration(klass)

      formatted_errors = class_errors.map(&:message).map{ |message| message.red }.join("\n")

      logger.print "Running validations for #{klass}... ".ljust(70)
      if class_errors.empty?
        logger.print '[PASS]'.green
      else
        logger.print '[FAIL]'.red
      end
      logger.print "  (#{duration}s)\n"

      if class_errors.any?
        logger.puts "#{class_errors.length} errors were found while running validations for #{klass}\n"
        logger.puts "Invalid ids: #{all_error_ids_for.inspect}"
        logger.puts "Validation errors on first #{result_count} invalid models"
        logger.puts formatted_errors
      end
    end

    def report_final_results(logger: $stdout)
      if total_error_count == 0
        logger.puts "\nAll models validated successfully.".green
      else
        logger.puts "\n#{total_error_count} errors were found while running validations.".red
      end
    end
  end
end
