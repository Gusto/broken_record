module BrokenRecord
  describe JobResult do
    let(:time) { Time.new 2015/01/01 }
    let(:job) { Job.new(klass:Object) }
    let(:job_result) { JobResult.new(job) }

    describe '#start_timer' do
      before { allow(Time).to receive(:now).and_return(time) }
      subject { job_result.start_timer }
      it { is_expected.to eq time }
    end

    describe '#stop_timer' do
      before { allow(Time).to receive(:now).and_return(time) }
      subject { job_result.stop_timer }
      it { is_expected.to eq time }
    end

    describe '#add_error' do
      let(:error) { contract_double(error_class) }
      subject { job_result.add_error(error) }
      context 'error is InvalidModelError' do
        let(:error_class) { BrokenRecord::ReportableError::InvalidModelError }
        it 'modifies errors correctly' do
          subject
          expect(job_result.instance_variable_get(:@invalid_model_errors)).to eq [error]
          expect(job_result.instance_variable_get(:@all_errors)).to eq [error]
          expect(job_result.instance_variable_get(:@exception_errors)).to eq []
        end
      end

      context 'error is ValidatorExceptionError' do
        let(:error_class) { BrokenRecord::ReportableError::ValidatorExceptionError }
        it 'modifies errors correctly' do
          subject
          expect(job_result.instance_variable_get(:@invalid_model_errors)).to eq []
          expect(job_result.instance_variable_get(:@all_errors)).to eq [error]
          expect(job_result.instance_variable_get(:@exception_errors)).to eq [error]
        end
      end

      context 'error is ModelValidationExceptionError' do
        let(:error_class) { BrokenRecord::ReportableError::ModelValidationExceptionError }
        it 'modifies errors correctly' do
          subject
          expect(job_result.instance_variable_get(:@invalid_model_errors)).to eq []
          expect(job_result.instance_variable_get(:@all_errors)).to eq [error]
          expect(job_result.instance_variable_get(:@exception_errors)).to eq [error]
        end
      end
    end
  end
end
