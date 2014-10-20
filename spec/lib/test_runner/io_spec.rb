require 'spec_helper'

describe TestRunner::IO do
  System = TestRunner::System

  let(:home)        { '/home/path' }
  let(:root)        { 'project_root' }
  let(:pipe_suffix) { '.test_runner' }
  let(:pwd)         { File.join '/path/to', root }

  let(:project_pipe) { File.join home, ".#{root}#{pipe_suffix}" }
  let(:global_pipe)  { File.join home, pipe_suffix }
  let(:local_pipe)   { File.join pwd, pipe_suffix }

  let(:pipes) { [project_pipe, global_pipe, local_pipe] }

  let(:pipe) { pipes.sample }

  let(:file_stream) { StringIO.new output }
  let(:output) { ['', 'foo-bar'].sample }

  let(:instance_vars) {[
    :@file,
    :@notified,
    :@pipe,
    :@is_pipe,
  ]}

  around do |example|
    @out = StringIO.new
    $stdout = @out
    example.run
    $stdout = STDOUT
  end

  before { System.stubs :home => home }
  before { System.stubs :pwd  => pwd }
  before { System.unstub :file_join }

  before { System.unstub :root }
  before { System.stubs :root => root }

  before { System.stubs :exists? => false }
  before { System.stubs(:exists?).with(pipe).returns true }

  before { System.stubs :pipe? => [true, false].sample }

  before { System.unstub :open_file }
  before { System.stubs(:open_file).with(pipe, 'r+').returns file_stream }

  before { System.unstub :read_file }
  before { System.stubs(:read_file).with(pipe).returns output }

  before { System.unstub :write_file }
  before { System.stubs(:write_file).with(pipe, '') }

  before do
    instance_vars.each do |var|
      described_class.instance_variable_set var, nil
    end
  end

  shared_examples_for 'a stringio' do
    it { expect(subject).to be_a StringIO }
  end

  describe '.input' do
    subject { described_class.input }

    context 'by default' do
      it_behaves_like 'a stringio'

      it 'notifies the user which file it is listening to' do
        expect(subject).to be_a StringIO
        expect(@out.string).to match(/listening/i)
        expect(@out.string).to match(/#{pipe}/)
      end

      context 'given subsequent calls' do
        before { described_class.input }

        it_behaves_like 'a stringio'

        it 'does not duplicate the notification' do
          subject
          expect(@out.string.scan(/listening/i).count).to eq 1
        end
      end
    end

    context 'given a named pipe' do
      before { System.stubs :pipe? => true }

      it_behaves_like 'a stringio'
      it_behaves_like 'a cached value for', System, :open_file, :input, :file

      it 'returns the stream from the named pipe' do
        System.expects(:open_file).with(pipe, 'r+').returns 'pipe-stream'
        expect(subject).to eq 'pipe-stream'
      end

      context 'given a second call' do
        before { @subject = subject }
        before { System.stubs :open_file => 'wrong-file' }
        let(:methods) {[
          :listening,
          :pipe?,
          :pipe_input,
          :file_input,
        ]}

        it_behaves_like 'a stringio'

        it 'does not call other methods' do
          methods.each do |method|
            described_class.expects(method).never
          end

          expect(described_class.input).to eq @subject
        end

        it 'returns the same pipe' do
          expect(described_class.input).to eq @subject
        end
      end
    end

    context 'given a file' do
      let(:output) { 'file-output' }

      before { System.stubs :pipe? => false }

      it_behaves_like 'a stringio'

      it 'returns the contents of the file' do
        expect(subject.gets).to eq 'file-output'
      end

      context 'given a second call' do
        before { expect(described_class.input.gets).to eq 'file-output' }
        before { System.stubs(:read_file).with(pipe).returns 'new-file' }

        it 'returns new contents' do
          subject.rewind
          expect(subject.gets).to eq 'new-file'
        end
      end
    end
  end

  describe '.run' do
    subject { described_class.run command }

    let(:command) { 'some_command' }

    before { described_class.unstub :run }

    it 'delegates to System' do
      System.expects(:system).with command
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

      before { System.stubs :root => root }

      before do
        System.stubs(:load_yaml).with(work_path).returns work_yaml
        System.stubs(:load_yaml).with(home_path).returns home_yaml
      end

      context 'given a yaml file in the working folder' do
        before { System.stubs(:file?).with(work_path).returns true }

        context 'given a yaml file in the home folder' do
          before do
            System.stubs(:file?).with(home_path).returns true
          end

          it 'loads the working folder yaml file' do
            expect(subject).to eq work_yaml
          end
        end

        context 'given no yaml file in the home folder' do
          before do
            System.stubs(:file?).with(home_path).returns false
          end

          it 'loads the working folder yaml file' do
            expect(subject).to eq work_yaml
          end
        end
      end

      context 'given no yaml file in the working folder' do
        before { System.stubs(:file?).with(work_path).returns false }

        context 'given a yaml file in the home folder' do
          before do
            System.stubs(:file?).with(home_path).returns true
          end

          it 'loads the home folder yaml file' do
            expect(subject).to eq home_yaml
          end
        end

        context 'given no yaml file in the home folder' do
          before do
            System.stubs(:file?).with(home_path).returns false
          end

          it 'returns an empty hash' do
            expect(subject).to eq({})
          end
        end
      end
    end

    context 'given it has been invoked previously' do
      it_behaves_like 'a cached value for',
        System, :load_yaml, :read_yaml, :yaml
    end
  end

  describe '.pipe' do
    subject { described_class.pipe }

    before { System.stubs :exists? => true }

    it_behaves_like 'a cached value for', System, :exists?, :pipe, :pipe

    context 'given a global pipe exists' do
      before { expect(System.exists?).to eq true }

      context 'given a local pipe exists' do
        before { expect(System.exists?(local_pipe)).to eq true }

        context 'given a project pipe exists' do
          before { expect(System.exists?(project_pipe)).to eq true }
          it 'returns the project pipe' do
            expect(subject).to eq project_pipe
          end
        end

        context 'given a project pipe does not exist' do
          before do
            System.stubs(:exists?).with(project_pipe).returns false
            expect(System.exists?(project_pipe)).to eq false
          end

          it 'returns the local pipe' do
            expect(subject).to eq local_pipe
          end
        end
      end

      context 'given a local pipe does not exist' do
        before { System.stubs(:exists?).with(local_pipe).returns false }
        before { expect(System.exists?(local_pipe)).to eq false }

        context 'given a project pipe exists' do
          before { expect(System.exists?(project_pipe)).to eq true }
          it 'returns the project pipe' do
            expect(subject).to eq project_pipe
          end
        end

        context 'given a project pipe does not exist' do
          before do
            System.stubs(:exists?).with(project_pipe).returns false
            expect(System.exists?(project_pipe)).to eq false
          end

          it 'returns the global pipe' do
            expect(subject).to eq global_pipe
          end
        end
      end
    end

    context 'given a global pipe does not exist' do
      before { System.stubs(:exists?).with(global_pipe).returns false }
      before { expect(System.exists?(global_pipe)).to eq false }

      context 'given a local pipe exists' do
        before { expect(System.exists?(local_pipe)).to eq true }

        context 'given a project pipe exists' do
          before { expect(System.exists?(project_pipe)).to eq true }
          it 'returns the project pipe' do
            expect(subject).to eq project_pipe
          end
        end

        context 'given a project pipe does not exist' do
          before do
            System.stubs(:exists?).with(project_pipe).returns false
            expect(System.exists?(project_pipe)).to eq false
          end

          it 'returns the local pipe' do
            expect(subject).to eq local_pipe
          end
        end
      end

      context 'given a local pipe does not exist' do
        before { System.stubs(:exists?).with(local_pipe).returns false }
        before { expect(System.exists?(local_pipe)).to eq false }

        context 'given a project pipe exists' do
          before { expect(System.exists?(project_pipe)).to eq true }
          it 'returns the project pipe' do
            expect(subject).to eq project_pipe
          end
        end

        context 'given a project pipe does not exist' do
          before do
            System.stubs(:exists?).with(project_pipe).returns false
            expect(System.exists?(project_pipe)).to eq false
          end

          it 'raises and shows the useful information about creating a pipe' do
            expect{ subject }
              .to raise_error TestRunner::NamedPipeNotFoundException
            expect(@out.string).to match('Please create a named pipe')
          end
        end
      end
    end
  end

  describe '.listening' do
    before { described_class.listening }

    it 'notifies the user that it is listening to the pipe' do
      expect(@out.string).to match(/listening/i)
      expect(@out.string).to match(/#{pipe}/)
    end

    context 'given a second call' do
      before { described_class.listening }

      it 'does not notify the user again' do
        notify_count = @out.string.scan(/listening/i).count
        expect(notify_count).to eq 1
      end
    end
  end

  describe '.pipe?' do
    subject { described_class.pipe? }

    it_behaves_like 'a cached value for', System, :pipe?, :pipe?, :is_pipe

    it 'return the value from System.pipe?' do
      System.stubs(:pipe?).with(pipe).returns 'foo-bar'
      expect(subject).to eq 'foo-bar'
    end

    context 'given a value of false and a second call would return true' do
      before { System.stubs :pipe? => false }
      before { described_class.pipe? }
      before { System.stubs :pipe? => true }

      it 'returns false' do
        expect(subject).to eq false
      end
    end
  end

  describe '.pipe_input' do
    subject { described_class.pipe_input }

    it_behaves_like 'a cached value for', System, :open_file, :pipe_input, :file

    it 'opens the file for continuous reading' do
      System.expects(:open_file).with(pipe, 'r+').returns 'open-pipe'
      expect(subject).to eq 'open-pipe'
    end
  end

  describe '.file_input' do
    subject { described_class.file_input }

    it_behaves_like 'a stringio'

    context 'given the file contains a non-empty string' do
      let(:output) { 'file-output' }

      it_behaves_like 'a stringio'

      it 'returns the string' do
        expect(subject.gets).to eq 'file-output'
      end

      it 'empties the file' do
        System.expects(:write_file).with(pipe, '')
        expect(subject.gets).to eq output
      end
    end

    context 'given the file is empty' do
      let(:output) { '' }

      it_behaves_like 'a stringio'

      it 'does not empty the file' do
        System.unstub :write_file
        System.expects(:write_file).never
        expect(subject.gets).to eq nil
      end
    end
  end
end
