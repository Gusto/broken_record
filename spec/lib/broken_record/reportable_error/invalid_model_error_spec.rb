describe BrokenRecord::ReportableError::InvalidModelError do
  let(:model_errors) { { base: ['Stuff is broken'] } }
  let(:invalid_model) { double(id: 1, errors: model_errors) }
  let(:invalid_model_error) { described_class.new(invalid_model, {}) }

  describe '#id' do
    subject { invalid_model_error.id }
    it { is_expected.to eq 1 }
  end

  describe '#error_title' do
    subject { invalid_model_error.error_title }
    it { is_expected.to eq 'Invalid Record' }
  end

  describe '#model_errors' do
    subject { invalid_model_error.model_errors }
    it { is_expected.to eq model_errors }
  end

  describe '#message' do
    subject { invalid_model_error.message }
    it { is_expected.to eq "    Invalid record in RSpec::Mocks::Double id=1.\n        base - [\"Stuff is broken\"]" }
  end
end
