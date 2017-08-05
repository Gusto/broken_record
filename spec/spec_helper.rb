require 'rspec'
require 'awesome_print'
require 'yaml'
require 'pry'

Dir['./lib/**/*.rb'].sort.each { |f| require f }

def contract_double(cls, attr_map = {})
  instance_double(cls, attr_map).tap do |dbl|
    allow(dbl).to receive(:is_a?).with(anything) { false }
    allow(dbl).to receive(:is_a?).with(cls) { true }
  end
end

RSpec.configure do |config|
  config.color = true
end
