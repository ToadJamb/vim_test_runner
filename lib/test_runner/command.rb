class TestRunner::Command
  def initialize(args)
    @file, @line = args.split
    set_line
  end

  def command
    mask = masks[File.extname(@file)[1..-1].to_sym]
    mask.gsub(/%f/, @file).gsub(/%l/, @line) if mask
  end

  private

  def masks
    {
      :rb      => 'bundle exec rspec %f %l',
      :feature => 'bundle exec cucumber %f %l -r features',
      :lua     => 'lspec %f %l',
    }
  end

  def set_line
    if @line == '1'
      @line = ''
    else
      @line = "-l #{@line}"
    end
  end
end
