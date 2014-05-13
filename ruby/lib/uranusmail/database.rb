module Uranusmail
  class Database

    attr_reader :notmuch_database, :path

    def initialize(path)
      @path = path

      open_or_reopen
    end

    def do_write(&block)
      begin
        Notmuch::Database.open(@path, mode: Notmuch::MODE_READ_WRITE, &block)
      ensure
        open_or_reopen
      end
    end

    def query(terms, options = {})
      query = super(terms)

      if options[:omit_excluded_tags]
        Main.instance.config[:search][:exclude_tags].each do |tag|
          query.add_tag_exclude(tag)
        end
      end

      # Prior to Notmuch 0.19, query.count_threads did not exist
      # and we need to load all of the threads to count them
      unless query.respond_to?(:count_threads)
        def query.count_threads
          search_threads.count
        end
      end

      if block_given?
        yield query
        query.destroy!
      else
        query
      end
    end

    def open_or_reopen
      @notmuch_database.close if @notmuch_database
      @notmuch_database = Notmuch::Database.new(path)
    end

    private

    def method_missing(method, *args, &block)
      if @notmuch_database.respond_to?(method)
        @notmuch_database.send(method, *args, &block)
      else
        super
      end
    end
  end
end
