require_relative 'common'

require 'algorithms'

class Day23 < AdventDay
  EXPECTED_RESULTS = { 1 => 12521, 2 => 44169 }.freeze

  class Amphipod
    attr_reader :type, :grid, :x, :y
    ENERGY_COST = {
      'A' => 1,
      'B' => 10,
      'C' => 100,
      'D' => 1000,
    }.freeze

    def initialize(x,y, type, grid)
      @x = x
      @y = y
      @type = type
      @grid = grid
      @moved_to_hall = false
      grid.amphipods << self
      grid[x,y] = self
    end

    def copy_to(grid)
      new_amphipod = Amphipod.new(@x,@y, @type, grid)
      new_amphipod.moved! if moved_to_hall?
      new_amphipod
    end

    def move_to(x,y)
      cost = cost(x,y)
      grid[@x,@y] = grid.class::EMPTY
      @x,@y = x,y
      moved!
      grid[x,y] = self
      cost
    end

    def cost(*move)
      x,y = *move
      distance = @y + y + (@x - x).abs
      distance * energy_cost
    end

    def energy_cost
      ENERGY_COST[self.type]
    end

    def possible_moves
      room = grid.room(self)
      return [] if [@x,@y] == [room, 2]
      possible_spots = grid.accessible_spots(self) - [[@x,@y]]
      possible_spots.reject! { |(x,y)| y == 0 } if moved_to_hall?
      possible_spots.reject! { |(x,y)| grid.class::ROOMS.values.include?(x) && y == 0 }
      possible_spots.reject! { |(x,y)| x == @x }
      possible_spots.reject! { |(x,y)| x != room && y > 0 }

      # Going to available room spot is always the best move
      room_spots = possible_spots & [[room, 1], [room, 2], [room, 3], [room, 4]]
      possible_spots = [room_spots.max_by(&:last)] if room_spots.any?

      possible_spots
    end

    def moved!
      @moved_to_hall = true
    end

    def moved_to_hall?
      @moved_to_hall
    end

    def to_s
      @type
    end

    def inspect
      "<#{type}: #{x},#{y}>"
    end
  end

  class Hallway < Grid
    include Containers

    EMPTY = nil
    WALL = '#'
    ROOMS = {
      'A' => 2,
      'B' => 4,
      'C' => 6,
      'D' => 8,
    }.freeze

    attr_reader :amphipods
    def initialize(*args, **kwargs)
      super(*args, **kwargs)
      @amphipods = []
      @current_cost = 0
    end

    def room(amphipod)
      ROOMS[amphipod.type]
    end

    Cache = {}
    # What cost to solve
    def solve
      key = Set.new(self.amphipods.map{|a| [a.type, a.x,a.y, a.moved_to_hall?]})
      @current_cost + self.class::Cache[key.hash] ||= begin
        to_try = possible_moves.each_with_object(PriorityQueue.new) do |(amphipod, move), queue|
          cost = amphipod.cost(*move)
          queue.push [cost, amphipod, move], -cost
        end

        min_solution = successful? ? 0 : Float::INFINITY
        loop do
          break if to_try.empty?
          cost, amphipod, move = to_try.pop
          break if cost >= min_solution # Ordered so all following solutions will cost more than current best

          hall = self.deep_copy
          copies = self.amphipods.map { |a| [a, a.copy_to(hall)] }.to_h

          hall.move(copies[amphipod], move)

          solution_cost = hall.solve
          min_solution = solution_cost if solution_cost < min_solution
        end
        min_solution
      end
    end

    def successful?
      amphipods.all? { |amphipod| amphipod.x == room(amphipod) }
    end

    def move(amphipod, move)
      cost = amphipod.move_to(*move)
      @current_cost += cost
    end

    def possible_moves
      return [] if successful?
      @possible_moves ||= @amphipods.flat_map do |amphipod|
        room = room(amphipod)
        occupants = [self[room, 1], self[room, 2], self[room, 3], self[room, 4]] - [EMPTY, WALL]
        next [] if occupants.all? { |a| a.type == amphipod.type } && occupants.include?(amphipod)
        moves = amphipod.possible_moves.map { |move| [amphipod, move] }
      end
    end

    def accessible_spots(amphipod)
      bfs_traverse([amphipod.x, amphipod.y])
    end

    def traversable?(*coord)
      self[*coord] == EMPTY
    end
  end

  def first_part
    Hallway::Cache.clear
    input.solve
  end

  def second_part
    Hallway::Cache.clear
    @unfolded = true
    input.solve
  end

  private

  def convert_data(data)
    hallway = Hallway.new Array.new(5) { Array.new(11, Hallway::WALL) }
    (0...11).each { |i| hallway[i,0] = Hallway::EMPTY }
    (0...3).each { |c| [2,4,6,8].each { |room| hallway[room, c] = Hallway::EMPTY } }
    if @unfolded
      super[2].tr(' #', '').chars.each_with_index { |c,i| Amphipod.new(2+i*2, 1, c, hallway) }
      ['D','C','B','A'].each_with_index { |c,i| Amphipod.new(2+i*2, 2, c, hallway) }
      ['D','B','A','C'].each_with_index { |c,i| Amphipod.new(2+i*2, 3, c, hallway) }
      super[3].tr(' #', '').chars.each_with_index { |c,i| Amphipod.new(2+i*2, 4, c, hallway) }
    else
      super[2].tr(' #', '').chars.each_with_index { |c,i| Amphipod.new(2+i*2, 1, c, hallway) }
      super[3].tr(' #', '').chars.each_with_index { |c,i| Amphipod.new(2+i*2, 2, c, hallway) }
    end
    hallway
  end
end

Day23.solve
