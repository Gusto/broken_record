module BrokenRecord
  describe SlackAggregator do
    let(:slack_aggregator) { SlackAggregator.new }
    let(:logger) { StringIO.new }
    let(:slack_notifier) { instance_double(SlackNotifier, send!: nil, send_snippet!: nil) }
    let(:aggregator) { slack_aggregator }

    describe '#report_final_results' do
      subject { slack_aggregator.report_final_results(notifier: slack_notifier) }

      context 'no errors' do
        it 'outputs the correct validation data to the logger' do
          expect(slack_notifier).to receive(:send!).with("\nAll models validated successfully.")
          expect(slack_notifier).to_not receive(:send_snippet!)
          subject
        end
      end

      context 'errors' do
        include_context 'aggregator setup'
        it 'outputs the correct validation data to the logger' do
          expected_snippet = <<-eos
Running validations for Object...                                     [FAIL]  (25.0s)
2 errors were found while running validations for Object
Invalid ids: [1, 2]
Validation errors on first 5 invalid models
invalid Object model 1
invalid Object model 2
Running validations for String...                                     [FAIL]  (0.234s)
3 errors were found while running validations for String
Invalid ids: [3, 4, 5]
Validation errors on first 5 invalid models
invalid String model 3
invalid String model 4
invalid String model 5
eos
          expect(slack_notifier).to receive(:send!).with("\n5 errors were found while running validations.")
          expect(slack_notifier).to receive(:send_snippet!).with(expected_snippet, 'Model Validation Failures')
          subject
        end
      end
    end
  end
end
