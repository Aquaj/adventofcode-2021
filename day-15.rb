require_relative 'common'
require 'algorithms'

class Day15 < AdventDay
  EXPECTED_RESULTS = { 1 => 40, 2 => 315 }.freeze

  def first_part
    bellman_ford_solution input.to_graph
  end

  def second_part
    bellman_ford_solution larger_input.to_graph
  end

  private

  # Literally never better than dijkstra in our case
  def bellman_ford_solution(graph)
    goal = goal(graph)
    solution = Algorithms::bellman_ford([0,0], graph)
    solution[:distances][goal]
  end

  def dijkstra_solution(graph)
    goal = goal(graph)
    solution = Algorithms::dijkstra [0,0], graph, goal
    solution[:distances][goal]
  end

  def goal(graph)
    [graph.width-1, graph.height-1]
  end

  def larger_input
    input_shifts_cache = {}
    big_grid = 5.times.flat_map do |y_offset|
      5.times.reduce([[]] * input.height) do |big_row, x_offset|
        inc = y_offset+x_offset
        new_grid = input_shifts_cache[inc%9] ||= input.map { |row| row.map { |risk| (1..9).cycle.nth(risk+inc) } }
        big_row.concat_h(new_grid)
      end
    end
    Grid.new big_grid
  end

  def convert_data(data)
    Grid.new(super.map(&:chars).map { |r| r.map(&:to_i) })
  end
end

Day15.solve
