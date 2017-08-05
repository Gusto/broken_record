describe BrokenRecord::ReportableError::BaseError do
  let(:base_error) { described_class.new }

  describe '#compact_output' do
    before { base_error.instance_variable_set(:@options, {}) }

    subject { base_error.compact_output }

    context 'instance variable set to false' do
      before { base_error.instance_variable_set(:@options, compact_output: false) }
      it { is_expected.to eq false }
    end

    context 'instance variable set to true' do
      before { base_error.instance_variable_set(:@options, compact_output: true) }
      it { is_expected.to eq true }
    end

    context 'instance variable not set' do
      it 'uses the broken record config' do
        expect(BrokenRecord::Config).to receive(:compact_output).and_return(true)
        expect(subject).to eq true
      end
    end
  end

  describe '#normalized_error' do
    subject { base_error.normalized_error }
    it 'delegates to subclass methods' do
      expect(base_error).to receive(:id).and_return(1)
      expect(base_error).to receive(:message).and_return('model is invalid')
      expect(base_error).to receive(:error_title).and_return('Invalid Record')
      expect(subject).to eq(id: 1,
                            message: 'model is invalid',
                            error_title: 'Invalid Record')
    end
  end
end
