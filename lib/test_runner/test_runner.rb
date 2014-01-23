module TestRunner
  def self.run
    args = TestRunner::IO.input.gets.strip
    run_command = command(args)
    TestRunner::IO.run run_command.command if run_command
  end

  def self.command(args)
    if args == ''
      @command
    else
      @command = TestRunner::Command.new(args)
    end
  end
end
