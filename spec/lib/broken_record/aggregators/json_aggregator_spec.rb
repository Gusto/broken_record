module BrokenRecord::Aggregators
  describe JsonAggregator do
    let(:json_aggregator) { JsonAggregator.new }

    describe '#report_final_results' do
      let(:aggregator) { json_aggregator }
      include_context 'aggregator setup'

      subject { json_aggregator.report_final_results }

      it 'creates a json file with formatted errors' do
        errors = {
          'Object'=> {
            duration: 25.0,
            invalid_records: [
              [
                {id: 1, message: 'invalid Object model 1', error_title: 'Invalid Record'}
              ],
              [
                {id: 2, message: 'invalid Object model 2', error_title: 'Invalid Record'}
              ]
            ]
          },
          'String'=> {
            duration: 0.234,
            invalid_records: [
              [
                {id: 3, message: 'invalid String model 3', error_title: 'Invalid Record'},
                {id: 4, message: 'invalid String model 4', error_title: 'Validation Exception'},
                {id: 5, message: 'invalid String model 5', error_title: 'Loading Error'}
              ],
            ]
          }
        }

        expect(json_aggregator).to receive(:write_json).with(errors)
        subject

      end
    end
  end
end
