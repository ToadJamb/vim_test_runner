require 'spec_helper'

RSpec.describe TestRunner::Yaml do
  context '.merge_yamls' do
    subject { described_class.new.merge_yamls yamls }

    let(:yamls) {[
      TestRunner::YamlFile.new('/path/file-1'),
      TestRunner::YamlFile.new('/path/file-2'),
      TestRunner::YamlFile.new('/path/file-3'),
    ]}

    around do |example|
      @out = StringIO.new
      $stdout = @out
      example.run
      $stdout = STDOUT
    end

    before do
      yamls[0].stubs :content => {
        1 => yamls[0].path,
        :foo => 1,
        :bar => 1,
        :baz => 1,
      }
      yamls[1].stubs :content => {
        2 => yamls[1].path,
        :foo => 2,
        :bar => 2,
        :fizz => 2,
      }
      yamls[2].stubs :content => {
        3 => yamls[2].path,
        :foo => 3,
        :baz => 3,
        :fizz => 3,
      }
    end

    it 'merges hashes correctly' do
      expect(subject).to eq({
        1 => yamls[0].path,
        2 => yamls[1].path,
        3 => yamls[2].path,
        :foo => 3,
        :bar => 2,
        :baz => 3,
        :fizz => 3,
      })
    end
  end

  context 'yaml paths' do
    let(:sys)          { TestRunner::System }
    let(:base_file)    { '.test_runner.yaml' }
    let(:project_file) { ".#{root}#{base_file}" }
    let(:root)         { 'my_project_root' }
    let(:home)         { '/home/path' }

    let(:master_yaml_path) { File.join home, base_file }
    let(:home_yaml_path)   { File.join home, project_file }

    describe '#master_yaml_path' do
      subject { described_class.new.master_yaml_path }

      before { sys.stubs :home => home }

      it 'returns the master yaml path' do
        expect(subject).to eq master_yaml_path
      end
    end

    describe '#home_yaml_path' do
      subject { described_class.new.home_yaml_path }

      before { sys.stubs :home => home }
      before { sys.stubs :root => root }

      it 'returns the home yaml path' do
        expect(subject).to eq home_yaml_path
      end
    end

    describe '#project_yaml_path' do
      subject { described_class.new.project_yaml_path }

      it 'returns the project yaml path' do
        expect(subject).to eq base_file
      end
    end
  end
end
