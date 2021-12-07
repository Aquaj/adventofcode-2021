require_relative 'common'

class Day7 < AdventDay
  EXPECTED_RESULTS = { 1 => 37, 2 => 168 }

  def first_part
    median = input.median.to_i
    input.sum { |e| (e - median).abs }
  end

  def second_part
    (1..input.max).map do |n|
      input.sum { |n2| (1..(n - n2).abs).sum }
    end.min
  end

  private

  def convert_data(data)
    super.first.split(',').map(&:to_i)
  end
end

Day7.solve
