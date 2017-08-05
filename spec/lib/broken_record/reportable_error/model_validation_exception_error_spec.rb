describe BrokenRecord::ReportableError::ModelValidationExceptionError do
  let(:model_errors) { { base: ['Stuff is broken'] } }
  let(:invalid_model) { double(id: 1, errors: model_errors, class: Object) }
  let(:exception) { StandardError.new }
  let(:model_validation_exception_error) { described_class.new(invalid_model, exception, {}) }

  before do
    allow(exception).to receive(:backtrace).and_return(['file1:55', 'line2:105'])
  end

  subject { model_validation_exception_error }

  it { is_expected.to be_kind_of(BrokenRecord::ReportableError::Helpers::ExceptionHelper) }

  describe '#id' do
    subject { model_validation_exception_error.id }
    it { is_expected.to eq 1 }
  end

  describe '#error_title' do
    subject { model_validation_exception_error.error_title }
    it { is_expected.to eq 'Validation Exception' }
  end

  describe '#exception' do
    subject { model_validation_exception_error.exception }
    it { is_expected.to eq exception }
  end

  describe '#message' do
    subject { model_validation_exception_error.message }
    it { is_expected.to eq "    Exception while trying to load models for Object.- StandardError.\n        file1:55\n        line2:105" }
  end
end
