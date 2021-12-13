require_relative 'common'

require 'matrix'

class Day13 < AdventDay
  EMPTY = '.'
  EXPECTED_RESULTS = { 1 => 17 }.freeze

  def first_part
    folded = fold(input[:grid], folds: [input[:folds].first])
    folded.to_a.flatten.count(&:nonzero?)
  end

  def second_part
    folded = fold(input[:grid], folds: input[:folds])
    folded.coords.each { |square| folded[*square] = (folded[*square].zero? ? nil : '#') }
    display folded.inspect
  end

  private

  def fold(grid, folds:)
    folds.reduce(grid) do |grid_to_fold, (fx,fy)|
      Grid.new case
               when fx
                 fold_vertically(grid_to_fold.to_a, at: fx)
               when fy
                 fold_horizontally(grid_to_fold.to_a, at: fy)
               end
    end
  end

  def fold_vertically(array, at:)
    panes = array.map { |row| [row[...at], row[(at+1)..].reverse] }
    panes.transpose.map { |pane| Matrix.columns(pane) }.reduce(&:+).to_a.transpose
  end

  def fold_horizontally(array, at:)
    fold_vertically(array.transpose, at: at).transpose
  end

  def setup_grid(coords)
    height = coords.transpose.last.max+1
    width = coords.transpose.first.max+1

    grid = Grid.new(height.times.map { width.times.map { 0 } })
    coords.each { |coord| grid[*coord] = 1 }

    grid
  end

  def convert_data(data)
    coords, folds = data.split("\n\n")
    coords = coords.split("\n").map { |coord| coord.split(',').map(&:to_i) }
    folds = folds.split("\n").map do |fold|
      match = fold.match /fold along (?:x=(.*))?(?:y=(.*))?/
      [match[1]&.to_i, match[2]&.to_i]
    end
    {
      coords: coords,
      folds: folds,
      grid: setup_grid(coords),
    }
  end
end

Day13.solve
