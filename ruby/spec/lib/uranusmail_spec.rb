require "spec_helper"

describe "Uranusmail" do
  context "#puts" do
    it "should invoke VIM::command" do
      VIM.should_receive(:command).with("echo 'hello'").once
      Uranusmail.puts("hello")
    end
  end

  context "#p" do
    it "should invoke VIM::command" do
      VIM.should_receive(:command).with("echo '\"hello\"'").once
      Uranusmail.p("hello")
    end
  end
end
