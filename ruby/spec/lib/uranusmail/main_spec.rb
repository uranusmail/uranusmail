require "spec_helper"

module Uranusmail
  describe Main do
    context "self.init" do
      it "should initialize the config" do
        Main.instance.config[:user][:primary_email].should ==
          "john.doe@example.com"
      end
    end

    context "#render_folder" do
      before do
        @folders = [
          [ 'new', 'tag:inbox and tag:unread' ],
          [ 'inbox', 'tag:inbox' ],
          [ 'unread', 'tag:unread' ],
        ]
      end

      it "should count the threads for inbox" do
        Main.instance.render_folders(@folders)
        $curbuf.content.should include("       24 inbox                (tag:inbox)")
      end

      it "should count the messages for inbox" do
        Main.instance.config[:uranusmail][:count_threads] = false

        Main.instance.render_folders(@folders)
        $curbuf.content.should include("       52 inbox                (tag:inbox)")
      end

      it "should register the info with each line" do
        Main.instance.render_folders(@folders)
        $curbuf.line_info[:search].should == @folders[0][1]
      end
    end

    context "#render_search" do
      it "should render in UTF-8" do
        Main.instance.render_search("tag:inbox")
        $curbuf.content[1].encoding.to_s.should == 'UTF-8'
      end

      it "should render the full search" do
        Main.instance.render_search("tag:inbox")
        $curbuf.content.size.should == $curwin.height + 2
      end

      it "should load more when we are on the 7th line" do
        Main.instance.render_search("tag:inbox")

        $curbuf.load_more?.should be_false

        $curbuf.line_number = 24 - ($curwin.height + 2)
        $curbuf.load_more?.should be_true
      end

      it "should load them all after invoking do_next" do
        Main.instance.render_search("tag:inbox")
        $curbuf.do_next
        $curbuf.content.size.should == 24
      end

      it "should be able to toggle select on threads" do
        Main.instance.render_search("tag:inbox")
        $curbuf.content[1].should =~ /^ .*/
        $curbuf.toggle_select_thread
        $curbuf.content[1].should =~ /^>.*/
      end

      it "should be able to unselect all threads" do
        Main.instance.render_search("tag:inbox")
        $curbuf.line_number = 2
        $curbuf.toggle_select_thread
        $curbuf.line_number = 1
        $curbuf.content[2].should =~ /^>.*/

        $curbuf.unselect_all
        $curbuf.content[2].should =~ /^ .*/
      end
    end

    context "#render_thread" do
      before do
        @thread_id = "0000000000000001"
      end

      it "should render all the messages" do
        Main.instance.render_thread(@thread_id)
        $curbuf.content.join("\n").should =~ /Resulted in 4604/
      end

      it "should set the thread into the buffer" do
        Main.instance.render_thread(@thread_id)
        @mt = MailThread.new(thread_id: @thread_id)

        $curbuf.thread = @mt.to_s
      end
    end

    context "#render_buffers_list" do
      before do
        @thread_id = "0000000000000001"
        VIM::Buffer.new(query: "tag:inbox").init("search")
        VIM::Buffer.new(thread_id: @thread_id).init("show")
        VIM::Buffer.new.init("buffers")
        VIM::Buffer.new.init("") # TODO: Figure out why I need this for the spec
      end

      it "should show the folders buffer" do
        Main.instance.render_buffers_list
        $curbuf.content[1].should == "1: folders"
      end

      it "should show the inbox buffer" do
        Main.instance.render_buffers_list
        $curbuf.content[2].should == "2: search (tag:inbox)"
      end

      it "should show the thread for the show" do
        Main.instance.render_buffers_list
        $curbuf.content[3].should ==
          "3: show 18.11.09 02:08:10   7 Lars Kellogg-Stedman | [notmuch] Working with Maildir storage? (inbox signed unread)"
      end

      it "should not list the buffers" do
        Main.instance.render_buffers_list
        $curbuf.content.join("\n").should_not =~ /buffers/
      end
    end
  end
end
