require "spec_helper"

module Uranusmail
  describe MailThread do
    before do
      @thread_db = Uranusmail.database.query("thread:0000000000000001").search_threads.first
      @thread = MailThread.new(@thread_db.thread_id)
    end

    it "should have an id" do
      @thread.id.should_not be_nil
    end

    context "#load" do
      it "should load the thread and yield it" do
        @thread.load do |thread|
          thread.tags.to_a.should_not be_nil
          thread.tags.to_a.should include("inbox")
        end
      end
    end

    context "#load_messages!" do
      it "should loads messages" do
        @thread.load_messages!
        @thread.messages.count.should == 7
      end
    end

    context "#archive!" do
      it "should remove the inbox from the thread" do
        @thread.archive!
        thread = Uranusmail.database.query("thread:0000000000000001").search_threads.first
        thread.tags.to_a.should_not include("inbox")
      end
    end

    context "#archive_and_read!" do
      it "should archive a thread and mark it as read" do
        @thread.archive_and_read!
        thread = Uranusmail.database.query("thread:0000000000000001").search_threads.first
        thread.tags.to_a.should_not include("inbox")
        thread.tags.to_a.should_not include("unread")
      end
    end
  end
end
