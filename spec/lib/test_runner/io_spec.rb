require 'spec_helper'

describe TestRunner::IO do
  describe '.input' do
    subject { described_class.input }

    let(:mock_input) { mock 'TestRunner::IO.input' }

    before { described_class.unstub :input }

    context 'given the first call' do
      before { described_class.instance_variable_set :@file, nil }

      it 'delegates to open' do
        Kernel.expects(:open)
          .with(File.expand_path('~/.triggertest'), 'r+')
          .returns mock_input

        expect(subject).to eq mock_input
      end
    end

    context 'given the second call' do
      before { described_class.instance_variable_set :@file, mock_input }

      it 'returns the previous file handle' do
        Kernel.expects(:open).never
        expect(subject).to eq mock_input
      end
    end
  end

  describe '.run' do
    subject { described_class.run command, true }

    let(:command) { 'some_command' }

    before { described_class.unstub :run }

    it 'delegates to system' do
      Kernel.expects(:system).with command
      subject
    end
  end

  describe '.file?' do
    subject { described_class.file?(*args) }

    let(:args) {[
      [],
      ['1'],
      ['1', '2'],
      ['1', '2', '3'],
      ['1', '2', '3', '4'],
    ].sample}

    it "delegates to #{File}.file?" do
      described_class.expects(:file?).with(*args).returns 'woot'
      expect(subject).to eq 'woot'
    end
  end
end
