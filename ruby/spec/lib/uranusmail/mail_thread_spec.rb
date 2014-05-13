require "spec_helper"

module Uranusmail
  describe MailThread do
    before do
      @thread_id = "0000000000000001"
      @db_entry = Uranusmail.database.query("thread:#{@thread_id}").search_threads.first
      @mt = MailThread.new(thread_id: @thread_id)
    end

    context "#initialize" do
      it "should load the entry given the id" do
        @mt = MailThread.new(thread_id: @thread_id)
        @mt.db_entry.should be_instance_of Notmuch::Thread
      end

      it "should load the thread id given the db_entry" do
        @mt = MailThread.new(db_entry: @db_entry)
        @mt.thread_id.should == @thread_id
      end

      it "should raise an error if none given" do
        expect { MailThread.new }.to raise_error(ArgumentError)
      end
    end

    context "#load_messages!" do
      it "should loads messages" do
        @mt.load_messages!
        @mt.messages.count.should == 7
      end
    end

    context "#to_s" do
      it "should give us a string reprentation of a thread" do
        @mt.to_s.should =~
          /11-18-09.*7 Lars Kellogg-Stedman.*Working with Maildir.*\(inbox signed unread\)/
      end
    end

    context "#archive!" do
      it "should remove the inbox from the thread" do
        @mt.archive!
        thread = Uranusmail.database.query("thread:0000000000000001").search_threads.first
        thread.tags.to_a.should_not include("inbox")
      end
    end

    context "#archive_and_read!" do
      it "should archive a thread and mark it as read" do
        @mt.archive_and_read!
        thread = Uranusmail.database.query("thread:0000000000000001").search_threads.first
        thread.tags.to_a.should_not include("inbox")
        thread.tags.to_a.should_not include("unread")
      end
    end
  end
end
