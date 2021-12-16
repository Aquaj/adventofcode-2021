require_relative 'common'

class Day16 < AdventDay
  EXPECTED_RESULTS = { 1 => 31, 2 => 54 }.freeze

  def first_part
    bits = input
    sum_version [parse_packet(bits.dup)]
  end

  def second_part
    bits = input
    compute_packet parse_packet(bits.dup)
  end

  private

  def parse_packet(bits)
    version = bits.shift(3).join.to_i(2)
    type_id = bits.shift(3).join.to_i(2)
    remaining = bits
    case type_id
    when 4
      value = parse_value_packet(remaining)
      [version, type_id, value]
    else
      _length_type, subpackets = *parse_operator_packet(remaining)
      [version, type_id, subpackets]
    end
  end

  def parse_value_packet(bits)
    groups = []
    loop do
      prefix = bits.shift
      groups << bits.shift(4)
      break if prefix == 0
    end
    groups.join.to_i(2)
  end

  def parse_operator_packet(bits)
    sub_packets = []
    length_type = bits.shift
    case length_type
    when 0
      length = bits.shift(15).join.to_i(2)
      body = bits.shift(length)
      sub_packets << parse_packet(body) until body.all?(&:zero?)
    when 1
      length = bits.shift(11).join.to_i(2)
      body = bits
      length.times { sub_packets << parse_packet(body) }
    end
    [length_type, sub_packets]
  end

  def compute_packet(packet)
    _version, type_id, data = packet
    case type_id
    when 0 then data.map { |pack| compute_packet(pack) }.reduce(&:+)
    when 1 then data.map { |pack| compute_packet(pack) }.reduce(&:*)
    when 2 then data.map { |pack| compute_packet(pack) }.min
    when 3 then data.map { |pack| compute_packet(pack) }.max
    when 4 then data
    when 5 then compute_packet(data[0]) >  compute_packet(data[1]) ? 1 : 0
    when 6 then compute_packet(data[0]) <  compute_packet(data[1]) ? 1 : 0
    when 7 then compute_packet(data[0]) == compute_packet(data[1]) ? 1 : 0
    end
  end

  def sum_version(packets)
    packets.sum do |packet|
      packet.last.is_a?(Array) ? packet.first + sum_version(packet.last) : packet.first
    end
  end

  def convert_data(data)
    data.chars.map { |c| c.to_i(16).to_s(2).rjust(4,'0').chars.map(&:to_i) }.flatten
  end
end

Day16.solve
