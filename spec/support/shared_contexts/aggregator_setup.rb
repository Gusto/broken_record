shared_context 'aggregator setup' do
  let(:object_result0) { BrokenRecord::JobResult.new(BrokenRecord::Job.new(klass: Object)) }
  let(:object_result1) { BrokenRecord::JobResult.new(BrokenRecord::Job.new(klass: Object)) }
  let(:string_result0) { BrokenRecord::JobResult.new(BrokenRecord::Job.new(klass: String)) }

  def error_message(id, model_klass)
    "invalid #{model_klass} model #{id}"
  end

  def create_invalid_model_error_stub(id, object_klass)
    message = "#{object_klass} #{id} is invalid"
    model_errors = double('ActiveModel::Errors', error_mappings: [[message, { context: 'calling_method', source: 'lib/calling_method.rb:55' }]]) # {base: [message]}

    stubbed_error = contract_double(BrokenRecord::ReportableError::InvalidModelError,
                                    id: id,
                                    message: error_message(id, object_klass),
                                    model_errors: model_errors,
                                    normalized_error: {
                                      id: id,
                                      message: error_message(id, object_klass),
                                      error_title: 'Invalid Record'
                                    })
  end

  def create_model_validation_exception_error(id, object_klass)
    stubbed_error = contract_double(BrokenRecord::ReportableError::ModelValidationExceptionError,
                                    id: id,
                                    message: error_message(id, object_klass),
                                    exception_context: ['file1:55', 'line2:105'],
                                    source: ['file1:55', 'line2:105'],
                                    exception_class: StandardError,
                                    normalized_error: {
                                      id: id,
                                      message: error_message(id, object_klass),
                                      error_title: 'Validation Exception'
                                    })
  end

  def create_validator_exception_error(id, object_klass)
    stubbed_error = contract_double(BrokenRecord::ReportableError::ValidatorExceptionError,
                                    id: id,
                                    message: error_message(id, object_klass),
                                    exception_context: ['file1:55', 'line2:105'],
                                    source: ['file1:55', 'line2:105'],
                                    exception_class: StandardError,
                                    normalized_error: {
                                      id: id,
                                      message: error_message(id, object_klass),
                                      error_title: 'Loading Error'
                                    })
  end

  def toggle_timers(object_result, duration)
    allow(Time).to receive(:now).and_return(Time.new(2017, 1, 1))
    object_result.start_timer
    allow(Time).to receive(:now).and_return(Time.new(2017, 1, 1) + duration)
    object_result.stop_timer
  end

  before(:each) do
    id = 0
    toggle_timers(object_result0, 25)
    stubbed_error = create_invalid_model_error_stub(id += 1, Object)
    object_result0.add_error(stubbed_error)

    toggle_timers(object_result1, 11)
    stubbed_error = create_invalid_model_error_stub(id += 1, Object)
    object_result1.add_error(stubbed_error)

    toggle_timers(string_result0, 0.234)

    stubbed_error = create_invalid_model_error_stub(id += 1, String)
    string_result0.add_error(stubbed_error)
    stubbed_error = create_model_validation_exception_error(id += 1, String)
    string_result0.add_error(stubbed_error)
    stubbed_error = create_validator_exception_error(id += 1, String)
    string_result0.add_error(stubbed_error)
    aggregator.add_result(object_result0)
    aggregator.add_result(object_result1)
    aggregator.add_result(string_result0)
  end
end
