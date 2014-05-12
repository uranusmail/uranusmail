require "set"

module VIM
  class Buffer

    attr_accessor :query

    def init(name)
      @name = name
      @info = [nil] # VIM buffer index starts at 1
    end

    def line_info
      @info[line_number]
    end

    def insert(line, info = {})
      @info ||= []

      @info << info
      append(count, line)
    end

    def load_more?
      count - line_number <= $curwin.height
    end

    def destroy!
      query.destroy! if query
    end

    def toggle_select_thread
      @selected ||= {}

      thread_id = line_info[:thread_id]

      if @selected.keys.include?(thread_id)
        unselect_thread(thread_id: thread_id)
      else
        select_thread(thread_id: thread_id)
      end
    end

    def unselect_all
      return if @selected.empty?

      @selected.each do |_, line|
        unselect_thread(line: line)
      end
    end

    def render
      old_count = count

      yield self

      old_count.times do
        @info.delete 1
        delete 1
      end
    end

    def continous_render(items, &block)
      @block = block
      @items = items

      render { do_next }
    end

    def do_next
      items = @items.take($curwin.height + 2)
      return if items.empty?

      @block.call(self, items)
    end

    private

    def select_thread(options = {})
      line = options[:line] || line_number

      @selected[options[:thread_id]] = line

      self[line] = self[line].gsub(/^ /, ">")
    end

    def unselect_thread(options = {})
      line = options[:line] || line_number
      thread_id = options[:thread_id] || @selected.key(line)

      @selected.delete(thread_id)

      self[line] = self[line].gsub(/^>/, " ")
    end
  end
end
