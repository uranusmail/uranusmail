module Uranusmail
  class Config < Hash

    attr_reader :contents

    def initialize(contents)
      @contents = contents

      parse_config
    end

    private

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
