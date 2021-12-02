require_relative 'common'

class Day2 < AdventDay
  def first_part
    input.reduce({x:0, d:0}) do |coords, (instruction, n)|
      case instruction
      when 'forward'
        coords[:x] += n
      when 'down'
        coords[:d] += n
      when 'up'
        coords[:d] -= n
      end
      coords
    end.then { |coords| coords[:x] * coords[:d] }
  end

  def second_part
    input.reduce({x:0, d:0, aim:0}) do |coords, (instruction, n)|
      case instruction
      when 'forward'
        coords[:x] += n
        coords[:d] += n*coords[:aim]
      when 'down'
        coords[:aim] += n
      when 'up'
        coords[:aim] -= n
      end
      coords
    end.then { |coords| coords[:x] * coords[:d] }
  end

  private

  def convert_data(data)
    super.map(&:split).map { |(i,n)| [i, n.to_i] }
  end
end

Day2.solve
