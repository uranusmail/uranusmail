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
        threads.each do |thread|
          authors = thread.authors.force_encoding("utf-8").split(/[,|]/).map do |a|
            a.strip!
            a.gsub!(/[\.@].*/, "")
            a.gsub!(/^ext /, "")
            a.gsub!(/ \(.*\)/, "")
            a
          end.join(",")

          date = Time.at(thread.newest_date).strftime(config[:uranusmail][:date_format])
          subject = thread.messages.first['subject']
          subject = Mail::Field.new("Subject: " + subject).to_s

          tags = thread.tags.map(&:to_s).join(" ")

          line = " %-12s %3s %-20.20s | %s (%s)" % [date, thread.matched_messages,
                                                    authors, subject, tags]
          buffer.insert line, {thread_id: thread.thread_id}
        end
      end
    end

    def render_thread(thread_id, options = {})
      thread = MailThread.new(thread_id)
      thread.load_messages!

      tags = ""
      thread.load { |t| tags = t.tags.map(&:to_s).join(" ") }

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

    private

    def count_threads?
      config[:uranusmail][:count_threads] == "true"
    end
  end
end
