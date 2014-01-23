require 'spec_helper'

describe TestRunner do
  let(:valid_args) { "#{file} #{line}\n" }
  let(:args)       { valid_args }
  let(:file)       { "#{path}/file.rb" }
  let(:line)       { 23 }
  let(:path)       { ['spec', 'test', 'features'].sample }

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

    context 'given a file in an unsupported location' do
      let(:file) { 'foo/bar.rb' }

      before { expect(args).to_not match(/^(spec|test|features)\//) }

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

    before { TestRunner.instance_variable_set :@command, nil }

    context 'given valid arguments' do
      before { expect(args).to match(/^(spec|test|features)\//) }
      it 'returns a command object' do
        expect(subject).to be_a TestRunner::Command
      end
    end

    context 'given a valid root path' do
      before { expect(args).to match(/^(spec|test|features)\//) }
      context 'given invalid sub-path' do
        let(:path) {[
          'spec/support',
          'test/support',
          'features/step_definitions',
          'features/support',
        ].sample}

        before { expect(args).to match(/^#{path}/) }

        it 'returns a command object' do
          expect(subject).to eq nil
        end
      end
    end
  end

  describe '.valid_args?' do
    subject { described_class.valid_args? args }

    context 'given a file in the spec folder' do
      let(:path) { 'spec' }

      before { expect(args).to match(/^spec\//) }

      context 'by default' do
        before { expect(args).to_not match(/^spec\/support\//) }
        it('returns true') { expect(subject).to eq true }
      end

      context 'given a file in the support subfolder' do
        let(:path) { 'spec/support' }
        before { expect(args).to match(/^spec\/support\//) }
        it('returns false') { expect(subject).to eq false }
      end
    end

    context 'given a file in the test folder' do
      let(:path) { 'test' }

      before { expect(args).to match(/^test\//) }

      context 'by default' do
        before { expect(args).to_not match(/^test\/support\//) }
        it('returns true') { expect(subject).to eq true }
      end

      context 'given a file in the support subfolder' do
        let(:path) { 'test/support' }
        before { expect(args).to match(/^test\/support\//) }
        it('returns false') { expect(subject).to eq false }
      end
    end

    context 'given a file in the features folder' do
      let(:path) { 'features' }

      before { expect(args).to match(/^features\//) }

      context 'by default' do
        before { expect(args).to_not match(/^features\/support\//) }
        before { expect(args).to_not match(/^features\/step_definitions\//) }
        it('returns true') { expect(subject).to eq true }
      end

      context 'given a file in the support subfolder' do
        let(:path) { 'features/support' }
        before { expect(args).to match(/^features\/support\//) }
        it('returns false') { expect(subject).to eq false }
      end

      context 'given a file in the step_definitions subfolder' do
        let(:path) { 'features/step_definitions' }
        before { expect(args).to match(/^features\/step_definitions\//) }
        it('returns false') { expect(subject).to eq false }
      end
    end
  end
end
