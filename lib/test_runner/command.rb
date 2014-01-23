class TestRunner::Command
  def initialize(args)
    @file, @line = args.split
    @mask = masks[File.extname(@file)[1..-1]]
    @mask = [@mask] unless @mask.is_a?(Array)
    set_line
  end

  def command
    @mask[0].gsub(/%f/, @file).gsub(/%l/, @line) if @mask
  end

  private

  def masks
    {
      'rb'      => ['bundle exec rspec %f %l', '-l %l'],
      'feature' => ['bundle exec cucumber %f %l -r features', '-l %l'],
      'lua'     => ['lspec %f %l', '-l %l'],
    }.merge TestRunner::IO.read_yaml
  end

  def set_line
    if @line == '1'
      @line = ''
    elsif @mask[1]
      @line = @mask[1].gsub(/%l/, @line)
    end
  end
end
