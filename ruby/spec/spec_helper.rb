lib = File.expand_path("../../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "erb"
require "support/vim"
require "support/config"

require "uranusmail"

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  config.order = "random"

  config.before do
    Uranusmail::Main.init(config_file: @config_file.path)
  end
end
