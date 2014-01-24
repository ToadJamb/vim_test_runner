require 'spec_helper'

describe TestRunner do
  let(:valid_args) { "#{file} #{line}\n" }
  let(:args)       { valid_args }
  let(:file)       { "#{path}/file.rb" }
  let(:line)       { rand(999) + 2 }
  let(:path)       { ['spec', 'test', 'features'].sample }

  before { TestRunner::IO.stubs :read_yaml => {} }

  describe '.run' do
    let(:mock_input) { mock 'IO.input' }
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
      let(:args) { "\n" }

      before { expect(args).to eq "\n" }

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

  describe '.command' do
    subject { described_class.command args }

    context 'given the first call' do
      before { TestRunner.instance_variable_set :@command, nil }

      context 'given valid arguments' do
        before { expect(args).to_not be_empty }
        it 'returns a command object' do
          expect(subject).to be_a TestRunner::Command
        end
      end

      context 'given invalid arguments' do
        let(:args) { '' }
        before { expect(args).to be_empty }
        it 'returns nil' do
          expect(subject).to eq nil
        end
      end
    end

    context 'given a previous call' do
      let(:command_object) { TestRunner::Command.new valid_args }

      before { TestRunner.instance_variable_set :@command, command_object }

      context 'given valid arguments' do
        before { expect(args).to_not be_empty }
        it 'returns a new command object' do
          expect(subject).to be_a TestRunner::Command
          expect(subject).to_not eq command_object
        end
      end

      context 'given invalid arguments' do
        let(:args) { '' }
        before { expect(args).to be_empty }
        it 'returns the previous command object' do
          expect(subject).to eq command_object
        end
      end
    end
  end

  describe '.valid_args?' do
    subject { described_class.valid_args? args }

    context 'given args' do
      let(:args) { 'foo' }
      it('returns true') { expect(subject).to eq true }
    end

    context 'given no args' do
      let(:args) { '' }
      it('returns false') { expect(subject).to eq false }
    end
  end
end
