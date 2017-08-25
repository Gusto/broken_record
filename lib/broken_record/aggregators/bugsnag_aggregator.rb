require 'bugsnag'

module BrokenRecord
  class InvalidRecordException < StandardError; end

  module Aggregators

    class BugsnagAggregator < ResultAggregator

      MAX_IDS = 500

      def report_job_start
        patch_active_record_errors!
        configure_bugsnag!
        notify_deploy
      end

      def report_results(klass)
        super(klass)

        klass_summary = {}

        @aggregated_results[klass].errors.each do |reportable_error|
          klass_summary[reportable_error.message] ||= {
            record_ids: [],
            context: reportable_error.error_context,
            stacktrace: reportable_error.stacktrace
          }

          klass_summary[reportable_error.message][:record_ids] << reportable_error.id
        end

        klass_summary.each do |error_message, error_data|
          ids = error_data[:record_ids]
          exception = InvalidRecordException.new("#{error_message} - #{ids.count} errors")
          exception.class.define_singleton_method(:name) { klass.name }
          exception.set_backtrace(error_data[:stacktrace])

          notify(
            exception,
            context: error_data[:context],
            grouping_hash: "#{klass.name}-#{error_data[:stacktrace]}",
            ids: ids.first(MAX_IDS).join(', '),
            error_count: ids.count,
            message: error_message,
            class: klass
          )
        end
      end

      private

      def notify(exception, options)
        Bugsnag.notify(exception, options)
      end

      def notify_deploy
        Bugsnag::Deploy.notify(
          repository: ENV['BROKEN_RECORD_REPOSITORY'],
          branch: ENV['BROKEN_RECORD_BRANCH']
        )
      end

      def configure_bugsnag!
        raise 'Bugsnag API Key must be set!' unless BrokenRecord::Config.bugsnag_api_key

        Bugsnag.configure do |c|
          c.notify_release_stages = ['production']
          c.release_stage = 'production'
          c.api_key = BrokenRecord::Config.bugsnag_api_key
          c.app_version = Date.today.to_s
          c.app_type = 'validation'
          c.delivery_method = :synchronous
        end
      end

      def patch_active_record_errors!
        require 'broken_record/patches/active_model_errors'
      end
    end
  end
end
