require_relative 'common'

class Day20 < AdventDay
  EXPECTED_RESULTS = { 1 => 35, 2 => 3351 }.freeze

  def first_part
    output = 2.times.reduce(input[:image]) { |image,_| enhance(image) }
    output.flatten.sum
  end

  def second_part
    output = 50.times.reduce(input[:image]) { |image,_| enhance(image) }
    output.flatten.sum
  end

  private

  def out_of_bounds
    # Everything more than one step out-of-bounds is going to have 0 neighbors at first
    # then switch according to the same rule as others — but stay in sync
    @oob_enum ||= Enumerator.produce(0) { |n| input[:algorithm][([n]*9).join.to_i(2)] }
  end

  def enhance(image)
    empty_grid = Array.new(image.height + 2) { Array.new(image.width + 2, 0) }
    new_grid = Grid.new(empty_grid)
    default = out_of_bounds.next
    new_grid.coords.each do |(x,y)|
      index = image.square_on(x-1,y-1).flatten.map { |n| n || default }.join.to_i(2)
      new_val = input[:algorithm][index]
      new_grid[x, y] = new_val
    end
    new_grid
  end

  def show_image(image)
    Grid.new(image.to_a.map { |r| r.join.tr('01', '.#').chars })
  end

  def convert_data(data)
    algorithm, image = data.tr('.#', '01').split("\n\n")
    algorithm = algorithm.chars.map(&:to_i)
    image = image.split("\n").map(&:chars).map { |r| r.map(&:to_i) }
    {
      algorithm: algorithm,
      image: Grid.new(image),
    }
  end
end

Day20.solve
