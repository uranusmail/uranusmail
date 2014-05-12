module Uranusmail
  class Folder

    attr_reader :name

    def initialize(name)
      @name = name
    end

    def count_messages
      return @count_messages if @count_messages

      query = Uranusmail.database.query("tag:#{name}")
      @count_messages = query.count_messages
      query.destroy!

      @count_messages
    end

    def count_threads
      return @count_threads if @count_threads

      query = Uranusmail.database.query("tag:#{name}")
      # TODO: Query should respond to :count_threads
      @count_threads = query.search_threads.count
      query.destroy!

      @count_threads
    end
  end
end
