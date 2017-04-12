module NotAHack
  def add(attribute, message = :invalid, options = {})
    # Track the source location
    @error_mapping ||= {}

    caller_location = caller_locations(1,1)[0]
    calling_method = caller_location.label

    _message = normalize_message(attribute, message, options)
    if calling_method == 'validate_each'
      @error_mapping[_message] = {
        context:  _message,
        source: "#{$:.grep(/broken_record/).first}/broken_record/best_practices.md:1"
      }
    else
      @error_mapping[_message] = {
        context:  calling_method,
        source: "#{caller_location.path}:#{caller_location.lineno}"
      }
    end

    super(attribute, message, options)
  end

  def error_mappings
    values.flatten.map { |error_message| @error_mapping[error_message] }
  end
end


module ActiveModel
  class Errors
    prepend NotAHack
  end
end

module BrokenRecord
  class InvalidRecordException < StandardError; end

  class BugsnagAggregator < ResultAggregator

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
        report[kontext] ||= { record_ids: [], source: exception_mapping[:source], message: exception_mapping[:message]}
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

        client.notify(exception,
          context: kontext,
          ids: ids,
          message: message,
          class: klass,
          exception_class: exception_class)
      end
    end

    def report_errors(klass)
      summary = {}

      @aggregated_results[klass].flat_map(&:original_errors).each do |record_id, errors|
        summary[record_id] = errors.error_mappings
      end

      report = {}
      summary.each do |record_id, error_mappings|
        error_mappings.each do |error_mapping|
          mapped_error = error_mapping[:context]
          report[mapped_error] ||= { record_ids: [], source: error_mapping[:source] }
          report[mapped_error][:record_ids] << record_id
        end
      end

      report.each do |message, hash|
        ids = hash[:record_ids]
        source = hash[:source]
        exception = InvalidRecordException.new("#{message} - #{ids.count} errors")
        exception.class.define_singleton_method(:name) { klass.name }
        exception.set_backtrace([source])

        client.notify(exception,
          context: message,
          ids: ids,
          message: message,
          class: klass)
      end
    end

    def client
      @client ||= begin
        require 'bugsnag'

        Bugsnag.configure do |config|
          config.api_key = '9c6fe81732e5f7f1039a40abc5130583'
          config.notify_release_stages = ['development']
          config.app_version = Date.today.to_s
          config.app_type = 'validation'
        end

        Bugsnag
      end
    end
  end
end
