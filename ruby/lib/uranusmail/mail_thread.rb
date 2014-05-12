module Uranusmail
  class MailThread

    attr_reader :id, :messages

    def initialize(id)
      @id = id
      @messages = []
    end

    def load(&block)
      Uranusmail.database.query("thread:#{id}") do |query|
        db_entry = query.search_threads.first
        yield db_entry
      end
    end

    def load_messages!
      Uranusmail.database.query("thread:#{id}") do |query|
        query.sort = Notmuch::SORT_OLDEST_FIRST
        query.search_messages.each do |msg|
          messages << Message.new(msg.filename)
        end
      end
    end

    def archive!
      Uranusmail.database.do_write do |db|
        db.query("thread:#{id}").search_messages.each do |msg|
          msg.freeze
          msg.remove_tag "inbox"
          msg.thaw
          msg.tags_to_maildir_flags
        end
      end
    end

    def archive_and_read!
      Uranusmail.database.do_write do |db|
        db.query("thread:#{id}").search_messages.each do |msg|
          msg.freeze
          msg.remove_tag "inbox"
          msg.remove_tag "unread"
          msg.thaw
          msg.tags_to_maildir_flags
        end
      end
    end
  end
end
