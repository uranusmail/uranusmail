require "mail"

module Uranusmail
  class Message

    attr_reader :mail, :formatted_from

    def initialize(filename)
      @mail = Mail.read(filename)
      @formatted_from = Mail::FromField.new(@mail.header[:from])
    end

    def decoded_text_or_html_body
      if multipart?
        text_part.decoded || decode_html
      else
        decoded
      end
    end

    private

    def decode_html
      IO.popen("elinks --dump", "w+") do |p|
        p.write(html_part)
        p.close_write
        p.read
      end
    end

    def method_missing(method, *args, &block)
      mail.send(method, *args, &block)
    end
  end
end
