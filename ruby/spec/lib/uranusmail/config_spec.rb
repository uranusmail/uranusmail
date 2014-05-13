require "spec_helper"

module Uranusmail
  describe Config do
    before do
      @contents = <<-EOF
# this is a comment
[string]
key=value

[array]
key=value1;value2
      EOF

      @config = Config.new(@contents)
    end

    it "should parse a simple config" do
      @config[:string][:key].should == "value"
    end

    it "should be able to parse an array" do
      @config[:array][:key].should == ["value1", "value2"]
    end

    it "should use some default config" do
      @config[:uranusmail][:count_threads].should ==
        Config::DEFAULT_CONFIG[:uranusmail][:count_threads]
      @config[:uranusmail][:date_format].should ==
        Config::DEFAULT_CONFIG[:uranusmail][:date_format]
    end
  end
end
