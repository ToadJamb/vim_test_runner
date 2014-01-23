require 'spec_helper'

describe TestRunner do
  describe '.run' do
    let(:mock_input) { mock 'IO.input' }
    let(:args)       { "file.rb 23\n" }

    before { mock_input.expects :gets => args }
    before { TestRunner::IO.expects :input => mock_input }

    it 'runs the command' do
      TestRunner::IO.expects(:run).with 'bundle exec rspec file.rb -l 23'
      described_class.run
    end
  end
end
