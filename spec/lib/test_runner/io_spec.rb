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

  describe '.read_yaml' do
    subject { described_class.read_yaml }

    before { described_class.unstub :read_yaml }

    context 'given the first invocation' do
      let(:work_path) { '.test_runner.yaml' }
      let(:home_path) { File.expand_path "~/.#{root}.test_runner.yaml" }
      let(:root)      { 'project_name' }
      let(:work_yaml) {{ :work => true }}
      let(:home_yaml) {{ :home => true }}

      before { described_class.instance_variable_set :@yaml, nil }
      before { described_class.unstub :load_yaml }
      before { described_class.unstub :file? }
      before { described_class.stubs :root => root }

      before do
        described_class.stubs(:load_yaml).with(work_path).returns work_yaml
        described_class.stubs(:load_yaml).with(home_path).returns home_yaml
      end

      context 'given a yaml file in the working folder' do
        before { described_class.stubs(:file?).with(work_path).returns true }

        context 'given a yaml file in the home folder' do
          before do
            described_class.stubs(:file?).with(home_path).returns true
          end

          it 'loads the working folder yaml file' do
            expect(subject).to eq work_yaml
          end
        end

        context 'given no yaml file in the home folder' do
          before do
            described_class.stubs(:file?).with(home_path).returns false
          end

          it 'loads the working folder yaml file' do
            expect(subject).to eq work_yaml
          end
        end
      end

      context 'given no yaml file in the working folder' do
        before { described_class.stubs(:file?).with(work_path).returns false }

        context 'given a yaml file in the home folder' do
          before do
            described_class.stubs(:file?).with(home_path).returns true
          end

          it 'loads the home folder yaml file' do
            expect(subject).to eq home_yaml
          end
        end

        context 'given no yaml file in the home folder' do
          before do
            described_class.stubs(:file?).with(home_path).returns false
          end

          it 'returns an empty hash' do
            expect(subject).to eq({})
          end
        end
      end
    end

    context 'given it has been invoked previously' do
      let(:hash) {{:round2 => true}}
      before { described_class.instance_variable_set :@yaml, hash }
      it 'returns the previous value' do
        expect(subject).to eq hash
      end
    end
  end

  describe '.load_yaml' do
    subject { described_class.load_yaml yaml_path }
    let(:yaml_path) { '/root/path' }
    before { described_class.unstub :load_yaml }
    it "calls #{Psych}.load_file" do
      Psych.expects(:load_file).with(yaml_path).returns({:foo => :bar})
      expect(subject).to eq({:foo => :bar})
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
