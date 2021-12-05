require_relative 'common'

class Day5 < AdventDay
  EXPECTED_RESULTS = { 1 => 5, 2 => 12 }

  def first_part
    @vents = {}
    input.each do |(x1,y1),(x2,y2)|
      next unless x1 == x2 || y1 == y2
      enum_x = x1.towards(x2)
      enum_y = y1.towards(y2)
      enum_x.product(enum_y).each { |x,y| mark_vent(x,y) }
    end
    vent_counts.count { |v| v >= 2 }
  end

  def second_part
    @vents = {}
    input.each do |(x1,y1),(x2,y2)|
      enum_x = x1.towards(x2)
      enum_y = y1.towards(y2)

      if x1 == x2 || y1 == y2 # Straight lines
        coll = enum_x.product enum_y
        coll.each { |(x,y)| mark_vent(x,y) }
      else # *Square* diagonals
        coll = enum_x.zip enum_y
        (coll).each { |(x,y)| mark_vent(x,y) }
      end
    end
    vent_counts.count { |v| v >= 2 }
  end

  private

  def vent_counts
    @vents.values.map(&:values).flatten
  end

  def mark_vent(x,y)
    @vents[x] ||= {}
    @vents[x][y] ||= 0
    @vents[x][y] += 1
  end

  def convert_data(data)
    super.map do |desc|
      desc.split(' -> ').map do |point|
        point.split(',').map(&:to_i)
      end
    end
  end
end

Day5.solve
