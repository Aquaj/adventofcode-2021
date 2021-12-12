require_relative 'common'

require 'delegate'

class Day12 < AdventDay
  EXPECTED_RESULTS = { 1=> 10, 2 => 36 }.freeze

  class Paths
    START = 'start'
    EXIT = 'end'

    def initialize(edges)
      @edges = edges
    end

    def neighbors_of(value)
      @edges.
        select { |edge| edge.include? value }.
        map { |edge| (edge - [value]).unwrap }
    end

    def compute(to_visit=nil, current_path=[], allowed_more_visits = nil, max_visits: 1)
      limited_visits = (to_visit == to_visit.downcase)
      visit_count = current_path.count(to_visit)
      if limited_visits && visit_count >= 1
        return [] if allowed_more_visits              # Unique N-visit spot is already taken
        return [] if [START, EXIT].include? to_visit  # Can't loop on entrance or exit
        return [] if visit_count >= max_visits        # Doesn't matter if you can loop if you're already over max
        allowed_more_visits = to_visit                # Allowed to loop in this path (noone is + not special)
      end

      current_path = [*current_path, to_visit]
      return [current_path] if to_visit == EXIT

      self.neighbors_of(to_visit).flat_map do |neighbor|
        compute(neighbor, current_path, allowed_more_visits, max_visits: max_visits)
      end
    end
  end

  alias_method :paths, :input

  def first_part
    paths.compute('start').count
  end

  def second_part
    paths.compute(Paths::START, max_visits: 2).count
  end

  private

  def convert_data(data)
    edges = super.map { |line| line.split("-") }
    Paths.new(edges)
  end
end

Day12.solve
