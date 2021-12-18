require_relative 'common'

class Day18 < AdventDay
  EXPECTED_RESULTS = { 1 => 4140, 2 => 3993 }.freeze

  def first_part
    input.reduce(&:+).magnitude
  end

  def second_part
    input.combination(2).flat_map do |(a,b)|
      forward = a.copy + b.copy
      backward = b.copy + a.copy
      [forward.magnitude, backward.magnitude]
    end.max
  end

  private

  require 'json'
  def convert_data(data)
    super.map do |number|
      number = JSON(number)
      Node.new(number)
    end
  end

  class Node
    def initialize(value)
      @type = value.is_a?(Integer) ? :value : :pair
      if value?
        @value = value
      else
        @value = value.map { |n| n.is_a?(Node) ? n : Node.new(n) }
      end
    end

    def replace(value)
      @type = value.is_a?(Integer) ? :value : :pair
      @value = value
    end

    attr_reader :value

    def value?; @type == :value; end
    def pair?; @type == :pair; end
    def inspect; @value.inspect; end

    def magnitude
      return @value if value?
      return @value.first.magnitude * 3 + value.last.magnitude * 2
    end

    def +(node)
      self.class.new([self, node]).reduce
    end

    def reduce
      loop do
        case
        when pair = leftmost_deep_nested_pair
          pair.explode(onto: neighbors_of(pair))
        when node = leftmost_high_node
          node.split
        else
          break self
        end
      end
    end

    def leftmost_deep_nested_pair(nesting: 0)
      return self if nesting == 4 && pair?
      @value.find do |part|
        next if part.value?
        pair = part.leftmost_deep_nested_pair(nesting: nesting + 1)
        break pair if pair
      end
    end

    def leftmost_high_node
      return self if value? && value >= 10
      return if value?
      @value.find do |part|
        too_high = part.leftmost_high_node
        break too_high if too_high
      end
    end

    def explode(onto:)
      elements = self.flatten.map(&:value)

      left, right = *onto
      left.replace(left.value + elements.first) if left
      right.replace(right.value + elements.last) if right

      self.replace(0)
    end

    def split
      self.replace [Node.new(value / 2), Node.new((value/2.0).ceil)]
    end

    def neighbors_of(element)
      elements = element.flatten

      tuple_and_neighbors = self.flatten.each_cons(elements.length+1)
      left = tuple_and_neighbors.find  { |n, *p| p == elements }&.first
      right = tuple_and_neighbors.find { |*p,n| p == elements }&.last

      [left, right]
    end

    def flatten
      return self if value?
      value.flat_map(&:flatten)
    end

    def copy
      return Node.new(self.value) if value?
      Node.new(@value.map { |part| part.copy })
    end
  end
end

Day18.solve
