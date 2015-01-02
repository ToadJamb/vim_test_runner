require 'benchmark'
benchmark_format = "%n\t#{Benchmark::FORMAT}"

puts Benchmark.measure('app') {
  require_relative File.join('..', 'lib', 'test_runner')
}.format(benchmark_format)

puts Benchmark.measure('specs') {
  RSpec.configure do |config|
    config.mock_with :mocha

    # rspec-expectations config goes here. You can use an alternate
    # assertion/expectation library such as wrong or the stdlib/minitest
    # assertions if you prefer.
    config.expect_with :rspec do |expectations|
      # This option will default to `true` in RSpec 4.
      # It makes the `description`and `failure_message`
      # of custom matchers include text for helper methods
      # defined using `chain`, e.g.:
      # be_bigger_than(2).and_smaller_than(4).description
      #   # => "be bigger than 2 and smaller than 4"
      # ...rather than:
      #   # => "be bigger than 2"
      expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    end

    # Limits the available syntax to the non-monkey patched syntax
    # that is recommended.
    # For more details, see:
    #   - http://myronmars.to/n/dev-blog/2012/06/rspecs-new-expectation-syntax
    config.disable_monkey_patching!

    # This setting enables warnings. It's recommended, but in some cases may
    # be too noisy due to issues in dependencies.
    config.warnings = true

    # Run specs in random order to surface order dependencies. If you find an
    # order dependency and want to debug it, you can fix the order by providing
    # the seed, which is printed after each run.
    #     --seed 1234
    config.order = :random

    # Seed global randomization in this process using the `--seed` CLI option.
    # Setting this allows you to use `--seed` to deterministically reproduce
    # test failures related to randomization by passing the same `--seed` value
    # as the one that triggered the failure.
    #config.seed = 1234
    Kernel.srand config.seed
  end

  Dir['spec/support/**/*.rb'].each do |support_file|
    require_relative File.join('..', support_file)
  end
}.format(benchmark_format)
