# Couldn't get this to work by including a module.
class Mocha::Mockery
  alias_method :orig_satisfied_expectations, :satisfied_expectations
  def satisfied_expectations(*args)
    satisfied = orig_satisfied_expectations(*args)
    satisfied.reject do |e|
      e.mocha_inspect.match(/allowed any number of times, not yet invoked/)
    end
  end
end
