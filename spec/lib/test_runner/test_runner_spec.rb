require 'spec_helper'

RSpec.describe TestRunner do
  let(:params)     { TestRunner::Params.new args }
  let(:valid_args) { "#{file} #{line}\n" }
  let(:args)       { valid_args }
  let(:file)       { "#{path}/file.rb" }
  let(:line)       { rand(999) + 2 }
  let(:path)       { ['spec', 'test', 'features'].sample }

  before { TestRunner::IO.stubs :read_yaml => {} }

  describe '.run' do
    let(:mock_input) { mock 'IO.input' }
    let(:command)    { "bundle exec rspec #{file}:#{line}" }

    before { mock_input.expects :gets => args }
    before { TestRunner::IO.expects :input => mock_input }

    context 'given valid arguments' do
      before { expect(params.valid?).to eq true }
      it 'runs the command' do
        TestRunner::IO.expects(:run).with command
        described_class.run
      end
    end

    context 'given no arguments' do
      let(:args) { "\n" }

      before { expect(args).to eq "\n" }

      before { TestRunner.instance_variable_set :@command, nil }
      before { TestRunner::IO.unstub :run }
      before { TestRunner::IO.expects(:run).never }

      it 'does not invoke run' do
        described_class.run
      end
    end
  end

  describe '.command' do
    subject { described_class.command params }

    context 'given valid arguments' do
      before { expect(params.valid?).to eq true }
      it 'returns a command object' do
        expect(subject).to be_a TestRunner::Command
      end
    end

    context 'given invalid arguments' do
      let(:args) { '' }

      before { expect(params.valid?).to eq false }

      it 'returns nil' do
        expect(subject).to eq nil
      end
    end
  end
end
