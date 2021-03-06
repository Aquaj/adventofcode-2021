require 'delegate'
require_relative '../patches'

# Wraps a 2D array
class Grid < SimpleDelegator
  attr_reader :width, :height

  EMPTY = nil

  def initialize(twod_array, fast_access: false)
    super(twod_array)
    @height = twod_array.length
    @width = twod_array.first.length
    @fast_access = fast_access
    build_access_cache if fast_access
  end

  def inspect
    (0...@height).map do |row_i|
      self[row_i].map { |e| e || ' ' }.join
    end.join("\n")
  end

  def coords
    (0...@width).product(0...@height)
  end

  def neighbors_of(*coords, diagonals: false, extended: false)
    offsets = [[1,0],[0,1],[-1,0],[0,-1]]
    offsets += [[1,1],[-1,1],[1,-1],[-1,-1]] if diagonals
    new_offsets = offsets.map { |(x,y)| [coords.first+x, coords.last+y] }
    extended ? new_offsets : new_offsets.reject { |(x,y)| out_of_bounds?(x,y) }
  end
  alias_method :neighbors, :neighbors_of

  def square_on(x,y)
    Grid.new([
      [self[x-1, y-1], self[x, y-1], self[x+1, y-1]],
      [self[x-1,   y], self[x,   y], self[x+1,   y]],
      [self[x-1, y+1], self[x, y+1], self[x+1, y+1]],
    ])
  end

  def flatten
    if fast_access?
      @access_cache.values
    else
      __getobj__.flatten
    end
  end

  def out_of_bounds?(x,y)
    x < 0 || x >= @width ||
      y < 0 || y >= @height
  end

  def [](*coords, cache: fast_access?)
    return super(coords.first) if coords.one?
    return @access_cache[coords] if cache
    x,y = *coords
    return nil if out_of_bounds?(x,y)
    __getobj__[y][x]
  end

  def []=(*coords, value)
    return super(coords.unwrap, value) if coords.one?
    x,y = *coords
    raise ArgumentError, "#{coords.inspect} is not in grid" if out_of_bounds?(x,y)
    if fast_access?
      @access_cache[[x,y]] = value
    else
      __getobj__[y][x] = value
    end
  end

  def access_cache=(cache)
    @access_cache = cache
  end
  protected :access_cache=

  def fast_access?
    @fast_access
  end

  def build_access_cache
    @access_cache ||= coords.map { |(x,y)| [[x,y], self[x,y, cache: false]] }.to_h
  end

  def apply_cache
    @access_cache.each do |(x,y), value|
      __getobj__[y][x] = value
    end
    self
  end

  def deep_copy
    new_grid = self.class.new(__getobj__.deep_copy, fast_access: @fast_access)
    new_grid.access_cache = @access_cache.deep_copy if fast_access?
    new_grid
  end

  def concat_h(grid_or_array)
    Grid.new self.to_a.concat_h(grid_or_array.to_a)
  end

  def concat_v(grid_or_array)
    Grid.new self.to_a.concat_v(grid_or_array.to_a)
  end

  def bfs_traverse(to_visit=nil, queue=[], discovered=[to_visit], &block)
    return discovered unless to_visit

    yield self[*to_visit], to_visit if block_given?

    neighbors_of(*to_visit).each do |neighbor|
        next if !traversable?(*neighbor) || discovered.include?(neighbor)
        discovered << neighbor
        queue << neighbor
      end
    bfs_traverse(queue.shift, queue, discovered, &block)
  end

  def traversable?(*coord)
    self[*coord] != EMPTY
  end

  def dfs_traverse(to_visit=[0,0], discovered=[], &block)
    discovered << to_visit

    yield self[*to_visit], to_visit if block_given?

    neighbors_of(*to_visit).each do |neighbor|
      next if !traversable?(*neighbor) || discovered.include?(neighbor)
      dfs_traverse(neighbor, discovered, &block)
    end

    discovered
  end

  module GraphMethods
    def nodes
      @nodes ||= coords.to_a
    end

    def edges
      @edges ||= coords.flat_map { |s| neighbors_of(*s).map { |t| [s, t] } }
    end

    def edge_cost(_source, target)
      self[*target]
    end

    def neighbors(node)
      super(*node, diagonals: diagonals?)
    end
  end

  def to_graph(diagonals: false)
    graph = Grid.new self.to_a
    graph.extend(GraphMethods)
    graph.define_singleton_method(:diagonals?) {  diagonals }
    graph
  end
end
