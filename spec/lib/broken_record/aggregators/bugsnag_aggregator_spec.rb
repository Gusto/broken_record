module BrokenRecord::Aggregators
  describe BugsnagAggregator do
    let(:bugsnag_aggregator) { BugsnagAggregator.new }
    let(:logger) { StringIO.new }

    let(:aggregator) { bugsnag_aggregator }

    describe '#report_results' do
      include_context 'aggregator setup'
      let(:klass) { String }
      subject { bugsnag_aggregator.report_results(klass) }
      it 'notifies Bugsnag with the correct data' do
        # Validate invalid record reporting
        expected_exception = kind_of(BrokenRecord::InvalidRecordException)
        expected_context = {
          context: 'calling_method',
          grouping_hash: 'String-calling_method',
          ids: '3',
          error_count: 1,
          message: 'calling_method',
          class: String
        }

        expect(bugsnag_aggregator).to receive(:notify).with(expected_exception, expected_context)

        # Validate exception reporting
        expected_exception = kind_of(BrokenRecord::InvalidRecordException)
        expected_context = {
          context: ['file1:55', 'line2:105'],
          grouping_hash: 'String-["file1:55", "line2:105"]',
          ids: '4, 5',
          error_count: 2,
          message: 'invalid String model 4',
          class: String,
          exception_class: StandardError
        }
        expect(bugsnag_aggregator).to receive(:notify).with(expected_exception, expected_context)

        subject
      end
    end
  end
end
