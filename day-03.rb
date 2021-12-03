require_relative 'common'

class Day3 < AdventDay
  def first_part
    bits_per_col = input.transpose
    gamma = bits_per_col.map { |col| most_common_in(col) }.join.to_i(2)
    epsilon = bits_per_col.map { |col| least_common_in(col) }.join.to_i(2)
    gamma * epsilon
  end

  def second_part
    bits_length = input.first.length

    o2 = bits_length.times.each_with_object(input.dup) do |pos, remaining_choices|
      bit_criteria = most_common_in(remaining_choices.transpose[pos], default: ?1)

      remaining_choices.select! { |e| e[pos] == bit_criteria }
      break remaining_choices if remaining_choices.one?
    end.unwrap.join.to_i(2)

    co2 = bits_length.times.each_with_object(input.dup) do |pos, remaining_choices|
      bit_criteria = least_common_in(remaining_choices.transpose[pos], default: ?0)

      remaining_choices.select! { |e| e[pos] == bit_criteria }
      break remaining_choices if remaining_choices.one?
    end.unwrap.join.to_i(2)

    o2 * co2
  end

  private

  def most_common_in(bits, default: ?0)
    case bits.count(?0) <=> bits.count(?1)
    when -1 then ?1
    when 0 then default
    when 1 then ?0
    end
  end

  def least_common_in(bits, default: ?0)
    case bits.count(?0) <=> bits.count(?1)
    when -1 then ?0
    when 0 then default
    when 1 then ?1
    end
  end

  def convert_data(data)
    super.map(&:chars)
  end
end

Day3.solve
