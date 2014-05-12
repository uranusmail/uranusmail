module Uranusmail
  def self.puts(s)
    VIM::command("echo '#{s.to_s}'")
  end

  def self.p(s)
    VIM::command("echo '#{s.inspect}'")
  end

  def self.main
    Main.instance
  end

  def self.database
    main.database
  end
end

require "notmuch"
require "uranusmail/version"
require "uranusmail/config"
require "uranusmail/database"
require "uranusmail/mail_thread"
require "uranusmail/message"
require "uranusmail/main"
require "uranusmail/folder"
require "uranusmail/extensions/vim/buffer"
