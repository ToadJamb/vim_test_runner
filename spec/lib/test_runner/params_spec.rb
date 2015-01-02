require 'spec_helper'

RSpec.describe TestRunner::Params do
  subject { instance }

  let(:instance) { described_class.new arg }

  let(:arg) { [file, line].join(' ') + "\n" }
  let(:file) { '/path/to/file_spec.rb' }
  let(:line) { rand(999) + 1 }

  context '.valid?' do
    subject { instance.valid? }

    context 'given a non-empty string' do
      it { expect(subject).to eq true }

      context 'given additional checks' do
        before { instance.valid? }
        it { expect(subject).to eq true }
      end
    end

    context 'given an empty string' do
      let(:arg) { '' }
      it { expect(subject).to eq false }
    end

    context 'given nil' do
      let(:arg) { nil }
      it { expect(subject).to eq false }
    end

    context 'given a blank string' do
      let(:arg) { [' ', "\n"].sample }
      it { expect(subject).to eq false }
    end
  end

  context '.file' do
    subject { instance.file }

    context 'given a file' do
      before { expect(arg).to_not be_empty }
      it 'returns the file' do
        expect(subject).to eq file
      end
    end
  end

  context '.line' do
    subject { instance.line }

    context 'given a file and a line' do
      before { expect(arg).to match(/\S+ \d+/) }
      it 'returns the file' do
        expect(subject).to eq line.to_s
      end
    end

    context 'given only a file' do
      let(:line) { nil }
      before { expect(arg).to match(/\D/) }
      it 'returns nil' do
        expect(subject).to eq nil
      end
    end
  end
end
