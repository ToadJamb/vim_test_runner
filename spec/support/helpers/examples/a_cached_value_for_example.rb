shared_examples_for 'a cached value for' do |klass, method, delegate, var|
  subject { described_class.send delegate }

  let(:cache) { 'cached-value' }

  before { delegate ||= method }
  before { var      ||= delegate }
  before { described_class.instance_variable_set "@#{var}".to_sym, cache }

  it "#{klass}.#{method}" do
    klass.expects(method).never
    expect(subject).to eq cache
  end
end
