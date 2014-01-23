RSpec.configure do |config|
  # Disable all 'dangerous' actions.
  config.before do
    save_util_methods = TestRunner::IO.methods - TestRunner::IO.superclass.methods
    save_util_methods.each do |method|
      TestRunner::IO.stubs(method).raises NotImplementedError,
        "#{TestRunner::IO}.#{method} has been stubbed as not implemented."
    end
  end
end
