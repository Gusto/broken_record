require 'drb'
require 'broken_record/class_finder'

module BrokenRecord
  class Server

    def initialize(class_names)
      @queue = Queue.new
      @class_names = class_names
    end

    def start
      populate_queue!
      puts "Starting DRb server on #{drb_uri}"
      DRb.start_service(drb_uri, @queue)

      sleep 5 until @queue.empty?
      puts 'Queue depleted, exiting...'
    end

    private
    def populate_queue!
      ClassFinder.new(@class_names).classes_to_validate.each do |klass|
        @queue << klass
      end
    end

    def drb_uri
      "druby://0.0.0.0:#{BrokenRecord::Config.server_port}"
    end

  end
end
