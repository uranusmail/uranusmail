require "spec_helper"

module Uranusmail
  describe Message do
    before do
      @message_db = Uranusmail.database.query("thread:0000000000000001").search_messages.first
      @message = Message.new(@message_db.filename)
    end

    context "#initalize" do
      it "should load the file in mail" do
        @message.mail.should be_instance_of(Mail::Message)
      end
    end

    it "should delegate all calls to the mail" do
      @message.from.should == ["cworth@cworth.org"]
    end

    context "#decode_body" do
      before do
        @plain_text_thread = MailThread.new(thread_id: "0000000000000017")
        @plain_text_thread.load_messages!

        @html_thread = MailThread.new(thread_id: "0000000000000019")
        @html_thread.load_messages!
      end

      it "should display the text part of the plain_text_thread" do
        m = @plain_text_thread.messages.first
        body = m.decoded_text_or_html_body
        body.should_not be_empty
        body.should_not =~ /text\/html/
      end

      it "should display the text part of the plain_text_thread" do
        m = @html_thread.messages.first
        m.text_part.stub(:decoded).and_return(nil)

        body = m.decoded_text_or_html_body
        body.should =~ /text\/html/
      end
    end
  end
end
