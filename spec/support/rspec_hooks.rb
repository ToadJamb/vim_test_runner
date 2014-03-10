RSpec.configure do |config|
  config.before do
    system_methods = TestRunner::System.methods
    system_methods -= TestRunner::System.superclass.methods

    system_methods.each do |method|
      TestRunner::System.stubs(method).raises NotImplementedError,
        "#{TestRunner::System}.#{method} has been stubbed as not implemented."
    end
  end
end
