module Uranusmail
  class Config < Hash

    DEFAULT_CONFIG = {
      uranusmail: {
        date_format: "%m-%d-%y %H:%M:%S",
        count_threads: false,
      },

      search: {
        exclude_tags: [
          "deleted",
          "spam",
          "killed"
        ],
      }
    }

    attr_reader :contents

    def initialize(contents)
      @contents = contents

      set_defaults
      parse_config
    end

    private

    def set_defaults
      DEFAULT_CONFIG.each do |group, keys|
        keys.each do |key, value|
          self[group] ||= {}
          self[group][key] = value
        end
      end
    end

    def parse_config
      group = nil

      contents.split("\n").each do |line|
        line.chomp!
        case line
        when /^\[(.*)\]$/
          group = $1.to_sym
          self[group] ||= {}
        when ''
        when /^(.*)=(.*)$/
          self[group][$1.to_sym] = parse_value($2)
        end
      end
    end

    def parse_value(value)
      case value
      when /.*;.*/
        value.split(/;/)
      else
        value
      end
    end
  end
end
