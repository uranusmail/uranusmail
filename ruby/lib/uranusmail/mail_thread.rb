module Uranusmail
  class MailThread

    attr_reader :thread_id, :messages, :db_entry

    def initialize(options = {})
      unless options[:thread_id] || options[:db_entry]
        raise ArgumentError.new("You need to specify a thread_id or a db_entry")
      end

      @thread_id = options[:thread_id]
      @db_entry = options[:db_entry]

      load_thread_id! unless @thread_id
      load_db_entry! unless @db_entry
      # TODO: Raise error here if both are still nil
    end

    def load_messages!
      Uranusmail.database.query("thread:#{thread_id}") do |query|
        query.sort = Notmuch::SORT_OLDEST_FIRST
        query.search_messages.each do |msg|
          @messages ||= []
          messages << Message.new(msg.filename)
        end
      end
    end

    def archive!
      Uranusmail.database.do_write do |db|
        db.query("thread:#{thread_id}").search_messages.each do |msg|
          msg.freeze
          msg.remove_tag "inbox"
          msg.thaw
          msg.tags_to_maildir_flags
        end
      end

      load_db_entry!
    end

    def archive_and_read!
      Uranusmail.database.do_write do |db|
        db.query("thread:#{thread_id}").search_messages.each do |msg|
          msg.freeze
          msg.remove_tag "inbox"
          msg.remove_tag "unread"
          msg.thaw
          msg.tags_to_maildir_flags
        end
      end

      load_db_entry!
    end

    def to_s
      authors = db_entry.authors.force_encoding("utf-8").split(/[,|]/).map do |a|
        a.strip!
        a.gsub!(/[\.@].*/, "")
        a.gsub!(/^ext /, "")
        a.gsub!(/ \(.*\)/, "")
        a
      end.join(",")

      date = Time.at(db_entry.newest_date).strftime(Main.instance.config[:uranusmail][:date_format])
      subject = db_entry.messages.first['subject']
      subject = Mail::Field.new("Subject: " + subject).to_s

      tags = db_entry.tags.map(&:to_s).join(" ")

      "%-12s %3s %-20.20s | %s (%s)" % [date, db_entry.matched_messages,
                                         authors, subject, tags]
    end

    private

    def load_db_entry!
      @db_entry_query = Uranusmail.database.query("thread:#{thread_id}")
      @db_entry = @db_entry_query.search_threads.first
    end

    def load_thread_id!
      @thread_id = @db_entry.thread_id
    end

  end
end
