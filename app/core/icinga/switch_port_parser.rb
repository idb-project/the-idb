module Icinga
  class SwitchPortParser
    ParserError = Class.new(StandardError)

    attr_reader :fqdn, :mac

    def initialize(input)
      @input = input.downcase

      parse!
    end

    def port
      @port.to_i
    end

    def to_switch_port
      nic = Nic.where(mac: mac).first

      return unless nic

      SwitchPort.where(number: port, nic: nic).first || SwitchPort.new(number: port, nic: nic)
    end

    private

    def parse!
      if @input =~ SwitchPort::ICINGA_REGEX
        @port, @fqdn, @mac = $1, $2, $3
      end

      if !@port || !@fqdn || !mac
        raise ParserError, "Unable to parse input: #{@input.inspect}"
      end
    end
  end
end
