class TestRunner::IO
  PIPE_NAME = '.test_runner'
  HELP_MASK = "Please create a named pipe " +
    "at one of the following locations:\n" +
    "%s\n%s\n%s\n"

  class << self
    def input
      return @file if @file

      pipe = case true
        when file?(pipes[:project]) then pipes[:project]
        when file?(pipes[:local]) then pipes[:local]
        when file?(pipes[:global]) then pipes[:global]
        else
          puts HELP_MASK % pipes.values
          return
        end

      puts "Listening for input from #{pipe}"

      @file = Kernel.open(pipe, 'r+')
    end

    def run(command, suppress_output = false)
      puts command unless suppress_output
      Kernel.system command
    end

    def read_yaml
      return @yaml if @yaml

      yaml_file = yaml_path

      if yaml_file
        @yaml = load_yaml(yaml_file)
      else
        @yaml = {}
      end
    end

    def load_yaml(path)
      Psych.load_file path
    end

    def file?(*args)
      File.exists?(*args)
    end

    def home
      File.expand_path '~'
    end

    def pwd
      Dir.getwd
    end

    private

    def yaml_path
      default_yaml = '.test_runner.yaml'
      home_yaml = File.join(home, ".#{root}#{default_yaml}")

      if file?(default_yaml)
        default_yaml
      elsif file?(home_yaml)
        home_yaml
      end
    end

    def root
      File.basename pwd
    end

    def pipes
      {
        :global  => File.join(home, PIPE_NAME),
        :local   => File.join(pwd, PIPE_NAME),
        :project => File.join(home, ".#{root}#{PIPE_NAME}"),
      }
    end
  end
end
