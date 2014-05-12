module VIM
  class << self
    def evaluate(*args); end
    def command(*args); end
  end

  class Buffer
    attr_accessor :line_number
    attr_reader :content, :info

    @@buffers = []

    def initialize(options = {})
      @@buffers << self

      @content = [nil] # VIM buffer index starts at 1
      @line_number = 1
      @query = options[:query]
    end

    def self.count
      (@@buffers.size || 0)
    end

    def self.[](index)
      @@buffers[index]
    end

    def self.clear
      @@buffers = []
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
    $curbuf = VIM::Buffer.new.init("folders")
    $curwin = VIM::Window.new
  end

  config.after do
    VIM::Buffer.clear
  end
end
