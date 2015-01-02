require 'spec_helper'

RSpec.describe TestRunner::Command do
  let(:params) { TestRunner::Params.new args }
  let(:args) { "#{file} #{line}" }
  let(:file) { 'foo.rb' }
  let(:line) { 23 }

  describe '.new' do
    subject { described_class.new params }
    before { TestRunner::IO.stubs :read_yaml => {} }
    it 'returns a command object' do
      expect(subject).to be_a described_class
    end
  end

  describe '#command' do
    subject { described_class.new(params).command }

    before { TestRunner::IO.stubs :read_yaml => {} }

    context 'given a ruby file' do
      let(:command) { "bundle exec rspec #{file}:#{line}" }

      before { expect(File.extname(file)).to eq '.rb' }

      it 'invokes rspec' do
        expect(subject).to eq command
      end

      context 'given the first line' do
        let(:line) { 1 }

        before { expect(line).to eq 1 }

        it 'does not include the line number' do
          expect(subject).to_not match(/:#{line}/)
        end
      end

      context 'given a .testrunner.yaml file' do
        let(:yaml) {{
          'rb' => 'bundle exec test %f %l',
        }}

        before { TestRunner::IO.stubs :read_yaml => yaml }

        it 'uses the yaml settings' do
          expect(subject).to eq "bundle exec test #{file} #{line}"
        end
      end
    end

    context 'given a feature file' do
      let(:command) { "bundle exec cucumber #{file}:#{line} -r features" }
      let(:file)    { 'cucumber.feature' }

      before { expect(File.extname(file)).to eq '.feature' }

      it 'invokes cucumber' do
        expect(subject).to eq command
      end

      context 'given the first line' do
        let(:line) { 1 }

        before { expect(line).to eq 1 }

        it 'does not include the line number' do
          expect(subject).to_not match(/:#{line}/)
        end
      end

      context 'given a .testrunner.yaml file' do
        let(:yaml) {{
          'feature' => 'bundle exec feature %f',
        }}

        before { TestRunner::IO.stubs :read_yaml => yaml }

        it 'uses the yaml settings' do
          expect(subject).to eq "bundle exec feature #{file}"
        end
      end
    end

    context 'given a lua file' do
      let(:command) { "lspec #{file}:#{line}" }
      let(:file)    { 'file_spec.lua' }

      before { expect(File.extname(file)).to eq '.lua' }

      it 'invokes lspec' do
        expect(subject).to eq command
      end

      context 'given the first line' do
        let(:line) { 1 }

        before { expect(line).to eq 1 }

        it 'does not include the line number' do
          expect(subject).to_not match(/:#{line}/)
        end
      end

      context 'given a .testrunner.yaml file' do
        let(:yaml) {{
          'lua' => ['lspec test %f %l', '-n %l']
        }}

        before { TestRunner::IO.stubs :read_yaml => yaml }

        it 'uses the yaml settings' do
          expect(subject).to eq "lspec test #{file} -n #{line}"
        end
      end
    end
  end
end
