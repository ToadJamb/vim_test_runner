module TestRunner
  class YamlFile
    attr_reader :path

    def initialize(path)
      @path = path
    end

    def content
      @content ||= System.load_yaml(@path)
    end
  end

  class Yaml
    def initialize
      @yamls = []
    end

    def to_hash
      load_yamls
      return {} if @yamls.empty?
      merge_yamls @yamls
    end

    def master_yaml_path
      File.join System.home, default_yaml
    end

    def home_yaml_path
      File.join System.home, project_yaml
    end

    def project_yaml_path
      default_yaml
    end

    def merge_yamls(yamls)
      hash = {}

      puts '*' * 80
      message  = 'The yaml files are merged in the following order '
      message += '(bottom files take precedence):'
      puts message
      puts '-' * 80

      yamls.each do |yaml|
        puts yaml.path
        if hash == {}
          hash = yaml.content
        else
          hash.merge! yaml.content
        end
      end

      hash
    end

    private

    def load_yamls
      [
        master_yaml_path,
        project_yaml_path,
        home_yaml_path,
      ].each do |yaml_path|
        @yamls << YamlFile.new(yaml_path) if System.file?(yaml_path)
      end
    end

    def project_yaml
      ".#{System.root}#{default_yaml}"
    end

    def default_yaml
      '.test_runner.yaml'
    end
  end
end
