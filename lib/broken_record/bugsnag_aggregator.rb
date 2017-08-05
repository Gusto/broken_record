module BrokenRecord
  require 'bugsnag'

  class InvalidRecordException < StandardError; end

  class BugsnagAggregator < ResultAggregator

    MAX_IDS = 500

    def report_job_start
      patch_active_record_errors!
      configure_bugsnag!
      notify_deploy
    end

    def report_results(klass)
      super(klass)
      report_errors(klass)
      report_exceptions(klass)
    end

    private

    def report_exceptions(klass)
      summary = {}
      @aggregated_results[klass].flat_map(&:exception_errors).each do |exception_error|
        summary[exception_error.id] = exception_error
      end

      report = {}
      summary.each do |record_id, exception_error|
        kontext = exception_error.exception_context
        report[kontext] ||= {
          record_ids: [],
          source: exception_error.source,
          message: exception_error.message,
          exception_class: exception_error.exception_class
        }
        report[kontext][:record_ids] << record_id
      end

      report.each do |kontext, hash|
        ids = hash[:record_ids]
        source = hash[:source]
        message = hash[:message]
        exception_class = hash[:exception_class]
        exception = InvalidRecordException.new("#{exception_class} - #{message} - #{ids.count} errors")
        exception.class.define_singleton_method(:name) { exception_class.name }
        exception.set_backtrace(source)

        notify(
          exception,
          context: kontext,
          grouping_hash: "#{klass.name}-#{kontext}",
          ids: ids.first(MAX_IDS).join(', '),
          error_count: ids.count,
          message: message,
          class: klass,
          exception_class: exception_class
        )
      end
    end

    def report_errors(klass)
      summary = {}

      invalid_model_errors_for(klass).each do |invalid_model_error|
        summary[invalid_model_error.id] = invalid_model_error.model_errors.error_mappings
      end

      report = {}
      summary.each do |record_id, error_mappings|
        error_mappings.each do |error_message, error_mapping|
          mapped_error = error_mapping[:context]
          report[mapped_error] ||= { record_ids: [], source: error_mapping[:source], error_message: error_message }
          report[mapped_error][:record_ids] << record_id
        end
      end

      report.each do |kontext, hash|
        ids = hash[:record_ids]
        source = hash[:source]
        exception = InvalidRecordException.new("#{hash[:error_message]} - #{ids.count} errors")
        exception.class.define_singleton_method(:name) { klass.name }
        exception.set_backtrace([source])

        notify(
          exception,
          context: kontext,
          grouping_hash: "#{klass.name}-#{kontext}",
          ids: ids.first(MAX_IDS).join(', '),
          error_count: ids.count,
          message: kontext,
          class: klass
        )
      end
    end

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
