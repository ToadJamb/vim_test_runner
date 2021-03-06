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

        listening

        if pipe?
          pipe_input
        else
          file_input
        end
      end

      def run(command)
        puts '*' * 80
        puts command
        puts '*' * 80
        System.system command
      end

      def read_yaml
        Yaml.new.to_hash
      end

      # These are thought of as private, but tested directly.
      # Perhaps move them to a different interface?

      def pipe
        @pipe ||= case true
          when System.exists?(pipes[:project]) then pipes[:project]
          when System.exists?(pipes[:local]) then pipes[:local]
          when System.exists?(pipes[:global]) then pipes[:global]
          else
            puts HELP_MASK % pipes.values
            raise NamedPipeNotFoundException
          end
      end

      def listening
        return if @notified
        puts "Listening for input from #{pipe}"
        @notified = true
      end

      def pipe?
        return @is_pipe unless @is_pipe.nil?
        @is_pipe = System.pipe?(pipe)
      end

      def pipe_input
        @file ||= System.open_file(pipe, 'r+')
      end

      def file_input
        out = System.read_file(pipe)
        System.write_file(pipe, '') unless out.empty?
        StringIO.new out
      end

      private

      def pipes
        {
          :global  => System.file_join(System.home, PIPE_NAME),
          :local   => System.file_join(System.pwd, PIPE_NAME),
          :project => System.file_join(
            System.home,
            ".#{System.root}#{PIPE_NAME}"
          ),
        }
      end
    end
  end
end
