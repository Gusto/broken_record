require 'rake'

namespace :broken_record do
  desc 'Scans models for validation errors'
  task :scan, [:class_name] => :environment do |t, args|
    scanner = BrokenRecord::Scanner.new
    class_names = args[:class_name] ? [args[:class_name]] : []
    class_names += args.extras
    aggregator = scanner.run(class_names)
    aggregator.report_final_results

    exit 1 unless aggregator.success?
  end

  desc 'Start a server to host the classes to process'
  task :server, [:class_name] => :environment do |t, args|
    class_names = args[:class_name] ? [args[:class_name]] : []
    class_names += args.extras
    server = BrokenRecord::Server.new(class_names)
    server.start
  end

  desc 'Start a slave to process work from a master'
  task :worker do |t, args|
    # Assign the queue scheduler
    BrokenRecord::Config.job_scheduler_class = 'BrokenRecord::QueueScheduler'
    Rake::Task['broken_record:scan'].invoke
  end
end
