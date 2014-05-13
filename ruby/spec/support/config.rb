require "tempfile"

def generate_mail_and_database
  database_file = File.expand_path("../../files/database-v1.tar.xz", __FILE__)
  database_dir = Dir.mktmpdir
  system "tar xf #{database_file} -C #{database_dir}"

  database_dir
end

def generate_config_file(database_path)
  raw_contents = File.read(File.expand_path("../../files/notmuch-config.erb", __FILE__))

  contents = ERB.new(raw_contents).result(binding)

  config_file = Tempfile.new("notmuch-config")
  config_file.write contents
  config_file.flush
  config_file.close

  config_file
end

RSpec.configure do |config|
  config.before do
    @database_tmp_location = generate_mail_and_database
    @config_file = generate_config_file("#{@database_tmp_location}/database-v1")
  end

  config.after do
    FileUtils.remove_entry @database_tmp_location
    @config_file.close!
  end
end
