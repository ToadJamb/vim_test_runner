require 'spec_helper'

describe TestRunner::IO do
  let(:home)        { '/home/path' }
  let(:root)        { 'project_root' }
  let(:pipe_suffix) { '.test_runner' }

  before { TestRunner::IO.stubs :home => home }

  describe '.input' do
    subject { described_class.input }

    let(:pwd)          { "/root/path/to/#{root}" }
    let(:global_pipe)  { File.join home, pipe_suffix }
    let(:local_pipe)   { File.join pwd, pipe_suffix }
    let(:project_pipe) { File.join home, ".#{root}#{pipe_suffix}" }

    let(:local_file)   { "#{local_pipe}-file-handle" }
    let(:global_file)  { "#{global_pipe}-file-handle" }
    let(:project_file) { "#{project_pipe}-file-handle" }

    before { described_class.unstub :input, :file? }

    before { TestRunner::IO.stubs :pwd => pwd }
    before { TestRunner::IO.stubs :file? => true }

    before { described_class.instance_variable_set :@file, nil }

    around do |example|
      @out = StringIO.new
      $stdout = @out
      example.run
      $stdout = STDOUT
    end

    context 'given the first call' do
      before { described_class.instance_variable_set :@file, nil }

      it 'delegates to open' do
        Kernel.expects(:open)
          .with(project_pipe, 'r+')
          .returns project_file

        expect(subject).to eq project_file
      end
    end

    context 'given the second call' do
      before { described_class.instance_variable_set :@file, 'cached-file' }

      it 'returns the previous file handle' do
        Kernel.expects(:open).never
        expect(subject).to eq 'cached-file'
      end
    end

    shared_examples_for 'an open pipe for' do |type|
      let(:pipe)      { send "#{type}_pipe" }
      let(:pipe_file) { send "#{type}_file" }

      before { TestRunner::IO.stubs(:file?).with(pipe).returns true }
      before { expect(TestRunner::IO.file?(pipe)).to eq true }

      it "a #{type} pipe" do
        Kernel.expects(:open).with(pipe, 'r+').returns pipe_file
        expect(subject).to eq pipe_file
      end
    end

    context 'given a global pipe exists' do
      before { expect(TestRunner::IO.file?(global_pipe)).to eq true }

      context 'given a local pipe exists' do
        before { expect(TestRunner::IO.file?(local_pipe)).to eq true }

        context 'given a project pipe exists' do
          before { expect(TestRunner::IO.file?(project_pipe)).to eq true }
          it_behaves_like 'an open pipe for', :project
        end

        context 'given a project pipe does not exist' do
          before do
            TestRunner::IO.stubs(:file?).with(project_pipe).returns false
            expect(TestRunner::IO.file?(project_pipe)).to eq false
          end

          it_behaves_like 'an open pipe for', :local
        end
      end

      context 'given a local pipe does not exist' do
        before { TestRunner::IO.stubs(:file?).with(local_pipe).returns false }
        before { expect(TestRunner::IO.file?(local_pipe)).to eq false }

        context 'given a project pipe exists' do
          before { expect(TestRunner::IO.file?(project_pipe)).to eq true }
          it_behaves_like 'an open pipe for', :project
        end

        context 'given a project pipe does not exist' do
          before do
            TestRunner::IO.stubs(:file?).with(project_pipe).returns false
            expect(TestRunner::IO.file?(project_pipe)).to eq false
          end

          it_behaves_like 'an open pipe for', :global
        end
      end
    end

    context 'given a global pipe does not exist' do
      before { TestRunner::IO.stubs(:file?).with(global_pipe).returns false }
      before { expect(TestRunner::IO.file?(global_pipe)).to eq false }

      context 'given a local pipe exists' do
        before { expect(TestRunner::IO.file?(local_pipe)).to eq true }

        context 'given a project pipe exists' do
          before { expect(TestRunner::IO.file?(project_pipe)).to eq true }
          it_behaves_like 'an open pipe for', :project
        end

        context 'given a project pipe does not exist' do
          before do
            TestRunner::IO.stubs(:file?).with(project_pipe).returns false
            expect(TestRunner::IO.file?(project_pipe)).to eq false
          end

          it_behaves_like 'an open pipe for', :local
        end
      end

      context 'given a local pipe does not exist' do
        before { TestRunner::IO.stubs(:file?).with(local_pipe).returns false }
        before { expect(TestRunner::IO.file?(local_pipe)).to eq false }

        context 'given a project pipe exists' do
          before { expect(TestRunner::IO.file?(project_pipe)).to eq true }
          it_behaves_like 'an open pipe for', :project
        end

        context 'given a project pipe does not exist' do
          before do
            TestRunner::IO.stubs(:file?).with(project_pipe).returns false
            expect(TestRunner::IO.file?(project_pipe)).to eq false
          end

          it 'shows the user some useful information about creating a pipe' do
            subject
            expect(@out.string).to match('Please create a named pipe')
          end
        end
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

    before { described_class.instance_variable_set :@yaml, nil }

    before { described_class.unstub :read_yaml }

    context 'given the first invocation' do
      let(:work_path) { '.test_runner.yaml' }
      let(:home_path) { File.join home, ".#{root}.test_runner.yaml" }
      let(:work_yaml) {{ :work => true }}
      let(:home_yaml) {{ :home => true }}

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
