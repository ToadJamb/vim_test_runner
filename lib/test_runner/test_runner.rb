module TestRunner
  def self.run
    args = TestRunner::IO.input.gets.strip
    run_command = command(args).command
    TestRunner::IO.run run_command
  end

  def self.command(args)
    if args == ''
      @command
    else
      @command = TestRunner::Command.new(args)
    end
  end

  def self.run_archive
    args = TestRunner::IO.input.gets

    if args.strip == ''
      args = @previous
    else
      @previous = args
    end

    commands = { 'spec' => 'rspec', 'features' => 'cucumber' }

    matched = args.match /^(spec|features)\//
    if matched
      unless args =~ /step_definitions/
        fname, linenum = args.split
        command = commands[matched[1]]
      end
    end

    if fname
      cmd = "bundle exec #{command} #{fname} -l #{linenum}"
      puts cmd
      system cmd
    end
  end
end
