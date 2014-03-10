module TestRunner
  class IO
    PIPE_NAME = '.test_runner'
    HELP_MASK = "Please create a named pipe " +
      "at one of the following locations:\n\n" +
      "%s\n%s\n%s\n\n" +
      "see https://www.bitbucket.org/toadjamb/vim_test_runner " +
      "for additional information\n\n"

    class << self
      def input
        return @file if @file

        pipe = case true
          when System.exists?(pipes[:project]) then pipes[:project]
          when System.exists?(pipes[:local]) then pipes[:local]
          when System.exists?(pipes[:global]) then pipes[:global]
          else
            puts HELP_MASK % pipes.values
            raise NamedPipeNotFoundException
          end

        puts "Listening for input from #{pipe}"

        @file = System.open_file(pipe, 'r+')
      end

      def run(command)
        puts '*' * 80
        puts command
        System.system command
      end

      def read_yaml
        return @yaml if @yaml

        yaml_file = yaml_path

        if yaml_file
          @yaml = System.load_yaml(yaml_file)
        else
          @yaml = {}
        end
      end

      private

      def yaml_path
        default_yaml = '.test_runner.yaml'
        home_yaml = System.file_join(
          System.home, ".#{System.root}#{default_yaml}")

        if System.file?(default_yaml)
          default_yaml
        elsif System.file?(home_yaml)
          home_yaml
        end
      end

      def pipes
        {
          :global  => File.join(System.home, PIPE_NAME),
          :local   => File.join(System.pwd, PIPE_NAME),
          :project => File.join(System.home, ".#{System.root}#{PIPE_NAME}"),
        }
      end
    end
  end
end
