require 'broken_record/class_finder'
require 'broken_record/job'
require 'broken_record/schedulers/job_scheduler'
require 'broken_record/schedulers/parallel_job_scheduler'
require 'broken_record/schedulers/external_job_scheduler'
require 'broken_record/aggregators/result_aggregator'
require 'broken_record/aggregators/slack_aggregator'
require 'broken_record/aggregators/datadog_aggregator'
require 'broken_record/aggregators/console_aggregator'
require 'broken_record/aggregators/json_aggregator'
require 'broken_record/aggregators/multi_aggregator'
require 'broken_record/aggregators/bugsnag_aggregator'

module BrokenRecord
  class Scanner
    def run(class_names)
      BrokenRecord::Config.aggregator_class.constantize.new.tap do |aggregator|
        classes = classes_to_validate(class_names)

        BrokenRecord::Config.before_scan_callbacks.each { |callback| callback.call }

        scheduler_class = BrokenRecord::Config.job_scheduler_class.constantize
        raise "Invalid job scheduler" unless scheduler_class.ancestors.include?(BrokenRecord::Schedulers::JobScheduler)
        scheduler = scheduler_class.new(classes, aggregator, BrokenRecord::Config.job_scheduler_options)
        scheduler.run
      end
    end

    private

    def classes_to_validate(class_names)
      ClassFinder.new(class_names).classes_to_validate
    end
  end
end
