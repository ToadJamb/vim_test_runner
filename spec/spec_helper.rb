#RSpec.configuration.seed = 1234
srand RSpec.configuration.seed

require 'benchmark'
benchmark_format = "%n\t#{Benchmark::FORMAT}"

puts Benchmark.measure('app') {
  require_relative File.join('..', 'lib', 'test_runner')
}.format(benchmark_format)

puts Benchmark.measure('specs') {
  Dir['spec/support/**/*.rb'].each do |support_file|
    require_relative File.join('..', support_file)
  end

  RSpec.configure do |config|
    config.mock_with :mocha
    config.order = :random
  end
}.format(benchmark_format)
