require "singleton"
require "mail"

module Uranusmail
  class Main
    include Singleton

    attr_reader :config, :database

    def self.init(options = {})
      instance.parse_config(options[:config_file])
      instance.init_database

      instance
    end

    def parse_config(file)
      contents = File.read(file)

      @config = Config.new(contents)
    end

    def init_database
      @database = Database.new(@config[:database][:path])
    end

    def render_folders(folders, options = {})
      $curbuf.render do |buffer|
        folders.each do |name, search|
          Uranusmail.database.query(search) do |query|
            if count_threads?
              count = query.count_threads
            else
              count = query.count_messages
            end

            line = "%9d %-20s (%s)" % [count, name, search]
            buffer.insert line, {search: search}
          end
        end
      end
    end

    def render_search(search, options = {})
      $curbuf.query ||= Uranusmail.database.query(search)
      threads = $curbuf.query.search_threads

      $curbuf.continous_render(threads) do |buffer, threads|
        threads.each do |db_entry|
          thread = MailThread.new(db_entry: db_entry)
          line = " #{thread}"
          buffer.insert line, {thread_id: thread.thread_id}
        end
      end
    end

    def render_thread(thread_id, options = {})
      thread = MailThread.new(thread_id: thread_id)
      thread.load_messages!

      tags = thread.db_entry.tags.map(&:to_s).join(" ")
      $curbuf.thread = thread.to_s

      $curbuf.render do |buffer|
        thread.messages.each do |msg|
          date = msg.date.strftime(config[:uranusmail][:date_format])

          buffer.insert("%s %s (%s)" % [msg.from, date, tags])
          buffer.insert("Subject: %s" % [msg.subject])
          buffer.insert("To: %s" % msg.to)
          buffer.insert("Cc: %s" % msg.cc)
          buffer.insert("Date: %s" % msg.date)

          msg.decoded_text_or_html_body.each_line do |line|
            buffer.insert(line.chomp)
          end
        end
      end
    end

    def render_buffers_list
      $curbuf.render do |curbuf|
        (0...VIM::Buffer.count).each do |buffer_index|
          buffer = VIM::Buffer[buffer_index]
          if buffer && buffer.uranusmail_buffer? && buffer.type != "buffers"
            line = "%d: %s" % [buffer_index + 1, buffer.type]

            line << " (#{buffer.query})" if buffer.query
            line << " #{buffer.thread}"  if buffer.thread

            curbuf.insert(line, buffer_id: buffer_index + 1)
          end
        end
      end
    end

    private

    def count_threads?
      config[:uranusmail][:count_threads] == "true"
    end
  end
end
