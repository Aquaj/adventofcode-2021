require_relative 'common'

class Day9 < AdventDay
  EXPECTED_RESULTS = { 1 => 15, 2 => 1134 }.freeze

  def first_part
    input.coords.map do |x,y|
      n = input[x,y]
      n + 1 if input.neighbors_of(x,y).all? { |nx,ny| n < input[nx,ny] }
    end.compact.sum
  end

  def second_part
    basins = []
    input.coords.each{ |x,y| input[x,y] = nil if input[x,y] == 9 }

    until input.flatten.all?(&:nil?)
      remain_x, remain_y = *input.coords.find { |x,y| input[x,y] }

      basin = input.bfs_traverse([remain_x,remain_y])
      basin.each { |(x,y)| input[x,y] = nil }
      basins << basin
    end

    basins.map(&:size).sort.last(3).reduce(&:*)
  end

  def convert_data(data)
    Grid.new(super.map(&:chars).map { |r| r.map(&:to_i) })
  end
end

Day9.solve
