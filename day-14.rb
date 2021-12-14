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

  def second_part
    # Full list/string construction will kill us, performance-wise
    pair_counts = 40.times.reduce(input[:base].each_cons(2).tally.with_default(0)) do |counts, _|
      input[:transformations].each_with_object({}.with_default(0)) do |((a,b), to_insert), new_counts|
        pair_count = counts[[a,b]]
        new_counts[[a, to_insert]] += pair_count
        new_counts[[to_insert, b]] += pair_count
      end
    end

    letter_counts = pair_counts_to_letters_count(pair_counts)
    letter_counts.values.max - letter_counts.values.min
  end

  private

  def pair_counts_to_letters_count(pair_counts)
    # To avoid counting each letter twice we only take the first letter into account
    letter_counts = pair_counts.each_with_object({}.with_default(0)) do |((a,_b), count), counts|
      counts[a] += count
    end
    # And then we add the missing last letter on the last pair
    *,last = *input[:base]
    letter_counts[last] += 1

    letter_counts
  end

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
