require 'spec_helper'

describe TestRunner do
  describe '.run' do
    let(:mock_input) { mock 'IO.input' }
    let(:valid_args) { "#{file} #{line}\n" }
    let(:args)       { valid_args }
    let(:file)       { 'file.rb' }
    let(:line)       { 23 }
    let(:command)    { "bundle exec rspec #{file} -l #{line}" }

    before { mock_input.expects :gets => args }
    before { TestRunner::IO.expects :input => mock_input }

    context 'given valid arguments' do
      before { expect(args).to_not be_empty }
      it 'runs the command' do
        TestRunner::IO.expects(:run).with command
        described_class.run
      end
    end

    context 'given no arguments' do
      let(:args) { '' }

      before { expect(args).to be_empty }

      context 'given it is the first run' do
        before { TestRunner.instance_variable_set :@command, nil }
        before { TestRunner::IO.unstub :run }
        before { TestRunner::IO.expects(:run).never }

        it 'does not invoke run' do
          described_class.run
        end
      end

      context 'given a previous run with valid arguments' do
        let(:command_object) { TestRunner::Command.new valid_args }

        before { TestRunner.instance_variable_set :@command, command_object }

        it 'runs the previous command' do
          TestRunner::IO.expects(:run).with command
          described_class.run
        end
      end
    end
  end
end
