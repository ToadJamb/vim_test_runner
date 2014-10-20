class TestRunner::System
  class << self
    def open_file(*args)
      File.open(*args)
    end

    def system(*args)
      Kernel.system(*args)
    end

    def load_yaml(*args)
      Psych.load_file(*args)
    end

    def file?(*args)
      File.file?(*args)
    end

    def exists?(*args)
      File.exists?(*args)
    end

    def file_join(*args)
      File.join(*args)
    end

    def pipe?(*args)
      File.pipe?(*args)
    end

    def read_file(*args)
      File.read(*args)
    end

    def write_file(*args)
      File.write(*args)
    end

    def home
      @home ||= File.expand_path('~')
    end

    def pwd
      @pwd ||= Dir.pwd
    end

    def root
      @root ||= File.basename(pwd)
    end
  end
end
