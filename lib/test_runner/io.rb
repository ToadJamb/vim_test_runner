class TestRunner::IO
  class << self
    def input
      @file ||= Kernel.open(File.join(home, '.triggertest'), 'r+')
    end

    def run(command, suppress_output = false)
      puts command unless suppress_output
      Kernel.system command
    end

    def read_yaml
      return @yaml if @yaml

      yaml_file = yaml_path

      if yaml_file
        @yaml = Psych.load_file(yaml_file)
      else
        @yaml = {}
      end
    end

    def file?(*args)
      File.file?(*args)
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

    def home
      File.expand_path '~'
    end

    def root
      File.basename Dir.getwd
    end
  end
end
