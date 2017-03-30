require 'broken_record/slack_notifier'

module BrokenRecord
  class SlackAggregator < ResultAggregator
    def report_final_results
      notifier = SlackNotifier.new({
        icon_emoji: success? ? ':white_check_mark:' : ':x:',
        username: "#{app_name} ValidationMaster"
      })
      send_summary
      send_snippet
    end

    private

    def send_summary
      if success?
        notifier.send!("\nAll models validated successfully.")
      else
        notifier.send!("\n#{@total_errors} errors were found while running validations.")
      end
    end

    def send_snippet
      # For all validated classes, get all-errors on each class, and print all_errors
      require 'pry'; binding.pry
      @aggregated_results
      puts 'sending snippet'
    end
  end
end
