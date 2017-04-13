require 'broken_record/patches/active_model_errors'

module BrokenRecord
  class InvalidRecordException < StandardError; end

  class BugsnagAggregator < ResultAggregator

    MAX_IDS = 500

    def report_job_start
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

      @aggregated_results[klass].flat_map(&:exceptions).each do |record_id, exception_hash|
        summary[record_id] = exception_hash
      end

      report = {}
      summary.each do |record_id, exception_mapping|
        kontext = exception_mapping[:context]
        report[kontext] ||= {
          record_ids: [],
          source: exception_mapping[:source],
          message: exception_mapping[:message],
          exception_class: exception_mapping[:exception_class]
        }
        report[kontext][:record_ids] << record_id
      end

      report.each do |kontext, hash|
        ids = hash[:record_ids]
        source = hash[:source]
        message = hash[:message]
        exception_class = hash[:exception_class]
        exception = InvalidRecordException.new("#{exception_class} - #{message} - #{ids.count} errors")
        exception.class.define_singleton_method(:name) { klass.name }
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

      @aggregated_results[klass].flat_map(&:original_errors).each do |record_id, errors|
        summary[record_id] = errors.error_mappings
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
      Bugsnag.notify(exception, default_bugsnag_options.merge(options))
    end

    def notify_deploy
      Bugsnag::Deploy.notify(
        default_bugsnag_options.merge(
          repository: ENV['BROKEN_RECORD_REPOSITORY'],
          branch: ENV['BROKEN_RECORD_BRANCH']
        )
      )
    end

    def default_bugsnag_options
      @opts ||= begin
        raise 'Bugsnag API Key must be set!' unless BrokenRecord::Config.bugsnag_api_key
        
        {
          api_key: BrokenRecord::Config.bugsnag_api_key,
          notify_release_stages: ['development'],
          app_version: Date.today.to_s,
          app_type: 'validation'
        }
      end
    end
  end
end
