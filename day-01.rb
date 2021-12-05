require_relative 'common'

class Day1 < AdventDay
  EXPECTED_RESULTS = { 1 => 7, 2 => 5 }

  def first_part
    input.each_cons(2).count { |a,b| b > a }
  end

  def second_part
    input.each_cons(3).each_cons(2).count { |a,b| b.sum > a.sum }
  end

  private

  def convert_data(data)
    super.map(&:to_i)
  end
end

Day1.solve
