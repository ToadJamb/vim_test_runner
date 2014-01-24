module TestRunner
  def self.run
    args = TestRunner::IO.input.gets.strip
    run_command = command(args)
    TestRunner::IO.run run_command.command if run_command
  end

  def self.command(args)
    if valid_args?(args)
      @command = TestRunner::Command.new(args)
    else
      @command
    end
  end

  def self.valid_args?(args)
    !args.empty?
  end
end
