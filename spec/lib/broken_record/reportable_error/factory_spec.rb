describe BrokenRecord::ReportableError::Factory do
  let(:factory) { described_class.new }

  describe '#from_model' do
    let(:model) { double }
    let(:options) { double }
    subject { factory.from_model(model, options) }
    it 'creates a new InvalidModelError' do
      expect(BrokenRecord::ReportableError::InvalidModelError).to receive(:new).with(model, options)
      subject
    end
  end

  describe '#from_model_exception' do
    let(:model) { double }
    let(:exception) { double }
    let(:options) { double }
    subject { factory.from_model_exception(model, exception, options) }
    it 'creates a new ModelValidationExceptionError' do
      expect(BrokenRecord::ReportableError::ModelValidationExceptionError).to receive(:new).with(model, exception, options)
      subject
    end
  end

  describe '#from_model' do
    let(:validator_class) { double }
    let(:exception) { double }
    let(:options) { double }
    subject { factory.from_validator_exception(validator_class, exception, options) }
    it 'creates a new ValidatorExceptionError' do
      expect(BrokenRecord::ReportableError::ValidatorExceptionError).to receive(:new).with(validator_class, exception, options)
      subject
    end
  end
end
