require_relative 'common'

class Day25 < AdventDay
  EXPECTED_RESULTS = { 1 => 58, 2 => nil }.freeze

  class SeaFloor
    attr_reader :height, :width
    def initialize(east_herd, south_herd, height,width)
      @east_herd = east_herd
      @south_herd = south_herd
      @height = height
      @width = width
      @static = false
    end

    def next!
      next_east = @east_herd.each_with_object(Set.new) do |cucumber, next_herd|
        x,y = *cucumber
        new_x = (x+1) % width
        next next_herd << [x,y] if @east_herd.include?([new_x,y]) || @south_herd.include?([new_x, y])
        next_herd << [new_x,y]
      end
      next_south = @south_herd.each_with_object(Set.new) do |cucumber, next_herd|
        x,y = *cucumber
        new_y = (y+1) % height
        next next_herd << [x,y] if @south_herd.include?([x,new_y]) || next_east.include?([x,new_y])
        next_herd << [x,new_y]
      end
      @static = @east_herd == next_east && @south_herd == next_south
      @east_herd = next_east
      @south_herd = next_south
      @static
    end
  end

  def first_part
    (1...).find { |n| input.next! }
  end

  def second_part
    display "Nothing to do 🎉"
  end

  private

  def convert_data(data)
    east = Set.new
    south = Set.new
    height = super.length
    width = super.first.length
    super.each_with_index do |row, y|
      row.chars.each_with_index do |cucumber, x|
        case cucumber
        when 'v'
          south << [x,y]
        when '>'
          east << [x,y]
        end
      end
    end
    SeaFloor.new(east,south, height,width)
  end
end

Day25.solve
