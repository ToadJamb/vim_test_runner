class TestRunner::Input
  class << self
    def read
      @file ||= open(File.expand_path('~/.triggertest'), 'r+')
    end
  end
end
