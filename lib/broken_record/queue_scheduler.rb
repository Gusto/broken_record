require 'drb'
require 'benchmark'

module BrokenRecord
  class QueueScheduler < JobScheduler
    class DRbQueueWrapper
      def initialize(queue)
        @queue = queue
      end

      def num_waiting
        @queue.num_waiting
      end

      def pop(*args)
        @queue.pop(*args)
      rescue DRb::DRbConnError
        nil
      end
    end

    def run
      result_aggregator.report_job_start

      while klass = queue.pop
        puts "Processing #{klass}"
        bm = Benchmark.measure do
          result = Job.new(klass: klass).perform
          if result.is_a? BrokenRecord::JobResult
            puts "Sending #{result.job.klass} results to Bugsnag"
            result_aggregator.add_result(result)
            result_aggregator.report_results(result.job.klass)
          end
        end
        puts "Finished processing #{klass} in #{bm.real.round(2)}"
      end
    end

    private
    def queue
      @queue ||= begin
        host = BrokenRecord::Config.server_host
        port = BrokenRecord::Config.server_port

        uri = "druby://#{host}:#{port}"
        queue = DRbObject.new_with_uri(uri).tap { |queue| drb_retry(queue) }
        DRbQueueWrapper.new(queue)
      end
    end

    MAX_RETRY = 100
    def drb_retry(obj)
      retry_count = 0

      begin
        !obj.empty?
      rescue DRb::DRbConnError
        retry_count += 1
        raise if retry_count > MAX_RETRY

        puts "DRb server not available yet, retrying in 5s"
        sleep 5
        retry
      end
    end

  end
end
