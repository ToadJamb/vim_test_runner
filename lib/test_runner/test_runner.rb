module TestRunner
  def self.run
    args = TestRunner::Input.read.gets

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
