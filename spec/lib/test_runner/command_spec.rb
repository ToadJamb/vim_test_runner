require 'spec_helper'

describe TestRunner::Command do
  let(:args) { "#{file} #{line}" }
  let(:file) { 'foo.rb' }
  let(:line) { 23 }

  describe '.new' do
    subject { described_class.new args }
    it 'returns a command object' do
      expect(subject).to be_a described_class
    end
  end

  describe '#command' do
    subject { described_class.new(args).command }

    context 'given a ruby file' do
      let(:command) { "bundle exec rspec #{file} -l #{line}" }

      before { expect(File.extname(file)).to eq '.rb' }

      it 'invokes rspec' do
        expect(subject).to eq command
      end

      context 'given the first line' do
        let(:line) { 1 }

        before { expect(line).to eq 1 }

        it 'does not include the line number' do
          expect(subject).to_not match(/-l #{line}/)
        end
      end
    end

    context 'given a feature file' do
      let(:command) { "bundle exec cucumber #{file} -l #{line} -r features" }
      let(:file)    { 'cucumber.feature' }

      before { expect(File.extname(file)).to eq '.feature' }

      it 'invokes cucumber' do
        expect(subject).to eq command
      end

      context 'given the first line' do
        let(:line) { 1 }

        before { expect(line).to eq 1 }

        it 'does not include the line number' do
          expect(subject).to_not match(/-l #{line}/)
        end
      end
    end

    context 'given a lua file' do
      let(:command) { "lspec #{file} -l #{line}" }
      let(:file)    { 'file_spec.lua' }

      before { expect(File.extname(file)).to eq '.lua' }

      it 'invokes lspec' do
        expect(subject).to eq command
      end

      context 'given the first line' do
        let(:line) { 1 }

        before { expect(line).to eq 1 }

        it 'does not include the line number' do
          expect(subject).to_not match(/-l #{line}/)
        end
      end
    end
  end
end
