require "spec_helper"

module Uranusmail
  describe Folder do
    before do
      @folder = Folder.new("inbox")
    end

    it "should know the number of messages" do
      @folder.count_messages.should == 52
    end

    it "should know the number of threads" do
      @folder.count_threads.should == 24
    end
  end
end
