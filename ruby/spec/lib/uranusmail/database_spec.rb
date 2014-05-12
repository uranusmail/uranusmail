require "spec_helper"

module Uranusmail
  describe Database do
    before do
      @db = Main.instance.database
    end

    context "#initialize" do
      it "should initialize the database" do
        @db.notmuch_database.should be_instance_of Notmuch::Database
      end
    end

    context "#query" do
      it "should be able to query the database" do
        @db.query("tag:inbox").count_messages.should == 52
      end

      it "should be able to be used with a block" do
        query = @db.query("tag:inbox") do |q|
          q.count_messages.should == 52
        end.should be_nil
      end
    end

    context "#do_write" do
      it "should be able to open the database temporarly for writing mode" do
        @db.query("tag:inbox").count_messages.should == 52

        @db.do_write do |writable_db|
          query = writable_db.query("tag:inbox")
          query.search_messages.each do |m|
            m.freeze
            m.remove_tag("inbox")
            m.thaw
            m.tags_to_maildir_flags
          end
          query.destroy!
        end

        @db.query("tag:inbox").count_messages.should == 0
      end
    end
  end
end
