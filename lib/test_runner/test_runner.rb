module TestRunner
  def self.run
    args = TestRunner::IO.input.gets
    params = Params.new(args)
    run_command = command(params)
    TestRunner::IO.run run_command.command if run_command
  end

  def self.command(params)
    TestRunner::Command.new(params) if params.valid?
  end
end
