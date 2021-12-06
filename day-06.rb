require_relative 'common'

class Day6 < AdventDay
  EXPECTED_RESULTS = { 1 => 5934, 2 => 26984457539 }

  def first_part
    80.times.reduce(input) do |fishes, _|
      to_add = fishes.count(0)
      fishes = fishes.map { |n| n == 0 ? 6 : n-1 }
      fishes += [8] * to_add
      fishes
    end.count
  end

  def second_part
    initial_fish_counts = (0..8).to_a.product([0]).to_h
    fish_counts = initial_fish_counts.merge input.tally
    256.times.reduce(fish_counts) do |new_fish_counts, _|
      to_add = new_fish_counts[0]
      for_6 = new_fish_counts[0] + new_fish_counts[7] # Both aging and re-starting fishes
      new_fish_counts = new_fish_counts.map { |n, count| [(n == 0 ? 6 : n-1), count] }.to_h
      new_fish_counts[6] = for_6
      new_fish_counts[8] = to_add
      new_fish_counts
    end.values.sum
  end

  private

  def convert_data(data)
    data.split(',').map(&:to_i)
  end
end

Day6.solve
