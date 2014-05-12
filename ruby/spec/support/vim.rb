module VIM
  class << self
    def evaluate(*args); end
    def command(*args); end
  end

  class Buffer
    attr_accessor :line_number
    attr_reader :content, :info

    def initialize
      @content = [nil] # VIM buffer index starts at 1
      @line_number = 1

      init("")
    end

    def append(_, line)
      @content << line
    end

    def delete(_)
      @content.pop
    end

    def count
      @content.size
    end

    def line
      @content[@line_number]
    end

    def line=(string)
      @content[@line_number] = string
    end

    def [](key)
      @content[key]
    end

    def []=(key, value)
      @content[key] = value
    end
  end

  class Window

    def height
      15
    end
  end
end

RSpec.configure do |config|
  config.before do
    $curbuf = VIM::Buffer.new
    $curwin = VIM::Window.new
  end
end
