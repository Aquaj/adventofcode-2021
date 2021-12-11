require_relative 'common'

class Day11 < AdventDay
  EXPECTED_RESULTS = { 1 => 1656, 2 => 195 }.freeze

  def first_part
    100.times.sum do |_|
      flashed = evaluate_flashes
      flashed.count
    end
  end

  def second_part
    (1..).find do
      flashed = evaluate_flashes
      flashed.count == input.coords.count
    end
  end

  private

  def evaluate_flashes
    flashed = []
    traversed = []
    input.coords.each do |octopus|
      input[*octopus] += 1
    end
    input.coords.each do |octopus|
      evaluate_flash(octopus, flashed)
    end
    flashed.each { |octopus| input[*octopus] = 0 }
    flashed
  end

  def evaluate_flash(octopus, flashed = [])
    return if flashed.include? octopus
    if input[*octopus] > 9
      flashed << octopus
      input.neighbors_of(*octopus, diagonals: true).each do |neighbor|
        input[*neighbor] += 1
      end
      input.neighbors_of(*octopus, diagonals: true).each do |neighbor|
        evaluate_flash(neighbor, flashed)
      end
    end
  end

  def convert_data(data)
    Grid.new(super.map { |row| row.chars.map(&:to_i) })
  end
end

Day11.solve
