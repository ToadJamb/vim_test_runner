RSpec.configure do |config|
  # Disable all 'dangerous' actions.
  config.before do
    io_methods = TestRunner::IO.methods - TestRunner::IO.superclass.methods
    io_methods.each do |method|
      TestRunner::IO.stubs(method).raises NotImplementedError,
        "#{TestRunner::IO}.#{method} has been stubbed as not implemented."
    end

    system_methods = TestRunner::System.methods
    system_methods -= TestRunner::System.superclass.methods

    system_methods.each do |method|
      TestRunner::System.stubs(method).raises NotImplementedError,
        "#{TestRunner::System}.#{method} has been stubbed as not implemented."
    end
  end
end
