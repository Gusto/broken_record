describe BrokenRecord::ReportableError::Helpers::ExceptionHelper do
  let(:exception) { StandardError.new }
  let(:exception_helper) { Class.new.extend(described_class) }

  before do
    allow(exception).to receive(:backtrace).and_return(['file1:55', 'line2:105'])
    exception_helper.instance_variable_set(:@exception, exception)
  end

  describe '#serialize_exception' do
    subject { exception_helper.serialize_exception('', false) }
    it { is_expected.to eq "- StandardError.\n        file1:55\n        line2:105" }
  end

  describe '#source' do
    subject { exception_helper.source }
    it { is_expected.to eq ['file1:55', 'line2:105'] }
  end

  describe '#exception_context' do
    subject { exception_helper.exception_context }
    it { is_expected.to eq ['file1:55', 'line2:105'] }
  end

  describe '#exception_class' do
    subject { exception_helper.exception_class }
    it { is_expected.to eq StandardError }
  end
end
