require_relative 'common'

class Day14 < AdventDay
  EXPECTED_RESULTS = { 1 => 1588, 2 => 2188189693529 }.freeze

  def first_part
    transformations = input[:transformations]
    new_polymer = 10.times.reduce(input[:base]) do |polymer, _|
      [
        # Careful about removing the nil valus when no transformation applicable
        *polymer.each_cons(2).flat_map { |pair| [pair.first, transformations[pair]] }.compact,
        polymer.last, # Readding last since we only cared about the first of each pair in loop
      ]
    end
    new_polymer.tally.then { |pol| pol.values.max - pol.values.min }
  end

  # Full list/string construction will kill us, performance-wise, so we switch approach
  def second_part
    pair_counts = input[:base].each_cons(2).tally.with_default(0)
    letter_counts = input[:base].tally.with_default(0)

    pair_counts = 40.times.reduce(pair_counts) do |counts, _|
      counts.each_with_object({}.with_default(0)) do |((a,b), pair_count), new_counts|
        to_insert = input[:transformations][[a,b]]

        letter_counts[to_insert]   += pair_count
        new_counts[[a, to_insert]] += pair_count
        new_counts[[to_insert, b]] += pair_count
      end
    end

    letter_counts.values.max - letter_counts.values.min
  end

  private

  def convert_data(data)
    base,transformations=data.split("\n\n")
    {
      base: base.chars,
      transformations: transformations.split("\n").map do |l|
        pair, insertion = l.split(' -> ')
        [pair.chars, insertion]
      end.to_h,
    }
  end
end

Day14.solve
