require 'spec_helper'

describe TestRunner::System do
  shared_examples_for 'a delegate to' do |klass, method, delegate|
    let(:arg1) { 'abc' }
    let(:arg2) { 'def' }
    let(:arg3) { { :k1 => :v1 } }
    let(:arg4) { { :k2 => :v2 } }

    before { delegate ||= method }
    before { described_class.unstub delegate }

    context 'given no arguments are passed' do
      it "calls #{klass}.#{method} with no arguments" do
        klass.expects(method).with
        described_class.send delegate
      end
    end

    context 'given 1 argument is passed' do
      it "calls #{klass}.#{method} with 1 argument" do
        klass.expects(method).with arg1
        described_class.send delegate, arg1
      end
    end

    context 'given 3 arguments are passed' do
      it "calls #{klass}.#{method} with 3 arguments" do
        klass.expects(method).with arg1, arg2, arg3
        described_class.send delegate, arg1, arg2, arg3
      end
    end

    context 'given multiple arguments are passed, followed by a hash' do
      it "calls #{klass}.#{method} with all arguments" do
        klass.expects(method).with arg1, arg2, arg3, arg4
        described_class.send delegate, arg1, arg2, arg3, arg4
      end
    end
  end

  describe('.system')  { it_behaves_like 'a delegate to', Kernel, :system }
  describe('.file?')   { it_behaves_like 'a delegate to', File, :file? }
  describe('.exists?') { it_behaves_like 'a delegate to', File, :exists? }

  describe('.open_file') do
    it_behaves_like 'a delegate to', File, :open, :open_file
  end

  describe('.load_yaml') do
    it_behaves_like 'a delegate to', Psych, :load_file, :load_yaml
  end

  describe '.file_join' do
    it_behaves_like 'a delegate to', File, :join, :file_join
  end

  describe '.home' do
    subject { described_class.home }

    let(:home) { '/home/path' }

    before { described_class.unstub :home }
    before { described_class.instance_variable_set :@home, nil }

    context 'given the first call' do
      it 'uses File.expand_path to find the home path' do
        File.expects(:expand_path).with('~').returns home
        expect(subject).to eq home
      end
    end

    context 'given subsequent calls' do
      it_behaves_like 'a cached value for', File, :expand_path, :home
    end
  end

  describe '.pwd' do
    subject { described_class.pwd }

    let(:pwd) { '/current/path' }

    before { described_class.unstub :pwd }
    before { described_class.instance_variable_set :@pwd, nil }

    context 'given the first call' do
      it 'uses Dir.pwd to find the home path' do
        Dir.expects(:pwd).with.returns pwd
        expect(subject).to eq pwd
      end
    end

    context 'given subsequent calls' do
      it_behaves_like 'a cached value for', Dir, :pwd
    end
  end

  describe '.root' do
    subject { described_class.root }

    let(:root) { '/root/path' }
    let(:pwd)  { '/current/path' }

    before { described_class.unstub :root }
    before { described_class.stubs :pwd => pwd }
    before { described_class.instance_variable_set :@root, nil }

    context 'given the first call' do
      it 'returns the root path using system calls' do
        File.expects(:basename).with(pwd).returns root
        expect(subject).to eq root
      end
    end

    context 'given subsequent calls' do
      it_behaves_like 'a cached value for', File, :basename, :root
    end
  end
end
