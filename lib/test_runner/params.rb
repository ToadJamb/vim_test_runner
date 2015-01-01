module TestRunner
  class Params
    attr_reader :file, :line

    def initialize(arg)
      return unless arg

      @file, @line = arg.split
      @line = @line
    end

    def valid?
      return @valid if defined?(@valid) && !@valid.nil?
      @valid = !!file
    end
  end
end
