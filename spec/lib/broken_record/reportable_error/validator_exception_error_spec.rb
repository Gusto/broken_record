describe BrokenRecord::ReportableError::ValidatorExceptionError do
  let(:validator_class) { double(to_s: 'DoubleValidator') }
  let(:exception) { StandardError.new }
  let(:validator_exception_error) { described_class.new(validator_class, exception, {}) }

  before do
    allow(exception).to receive(:backtrace).and_return(['file1:55', 'line2:105'])
  end

  subject { validator_exception_error }

  it { is_expected.to be_kind_of(BrokenRecord::ReportableError::Helpers::ExceptionHelper) }

  describe '#id' do
    subject { validator_exception_error.id }
    it { is_expected.to eq nil }
  end

  describe '#error_title' do
    subject { validator_exception_error.error_title }
    it { is_expected.to eq 'Validator Exception' }
  end

  describe '#exception' do
    subject { validator_exception_error.exception }
    it { is_expected.to eq exception }
  end

  describe '#message' do
    subject { validator_exception_error.message }
    it { is_expected.to eq "    Exception while trying to run validator DoubleValidator.- StandardError.\n        file1:55\n        line2:105" }
  end
end
