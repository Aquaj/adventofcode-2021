require_relative 'common'

class Day8 < AdventDay
  EXPECTED_RESULTS = { 1 => 26, 2 => 61229 }
  SEGMENTS = {
    0 => Set.new(%w[a b c e f g]),
    1 => Set.new(%w[c f]),
    2 => Set.new(%w[a c d e g]),
    3 => Set.new(%w[a c d f g]),
    4 => Set.new(%w[b c d f]),
    5 => Set.new(%w[a b d f g]),
    6 => Set.new(%w[a b d e f g]),
    7 => Set.new(%w[a c f]),
    8 => Set.new(%w[a b c d e f g]),
    9 => Set.new(%w[a b c d f g]),
  }.freeze
  DIGITS = SEGMENTS.reverse.freeze

  INITIAL_CANDIDATES = (?a..?g).map { |segment| [segment, Set.new((?a..?g).to_a)] }.to_h.freeze


  def first_part
    input.sum { |d| d[:outputs].count { |signal| [2, 4, 3, 7].include? signal.length } }
  end

  def second_part
    input.sum do |line|
      sorted = line[:patterns].sort_by(&:length).reverse
      candidates = sorted.each_with_object(INITIAL_CANDIDATES.dup) do |signal, candidates|
        matching = SEGMENTS.to_a.select { |(_,segments)| segments.count == signal.length }
        signal.chars.each { |s| candidates[s] &= matching.map(&:last).reduce(&:|) }
      end

      candidates = candidates.sort_by { |(_,candidates)| candidates.length }
      mappings = build_possible_mappings(candidates)

      # Output translation will either be right for all digits, or nil on at least one
      # so finding the first mapping that can translate all digits is enough
      mappings.each do |mapping|
        outputs = line[:outputs].map { |output| translate(output, mapping) }
        break outputs.join.to_i if outputs.none?(&:nil?)
      end
    end
  end

  private

  def build_possible_mappings(uncertain_mapping, matches = {})
    return [matches] if uncertain_mapping.empty?
    uncertain_mapping = uncertain_mapping.deep_copy
    segment, candidates = uncertain_mapping.shift
    candidates -= matches.values

    candidates.flat_map do |candidate|
      build_possible_mappings(uncertain_mapping, matches.merge(segment => candidate))
    end
  end

  def translate(value, mapping)
    translated = value.tr(mapping.keys.join, mapping.values.join)
    DIGITS[Set.new(translated.chars)]
  end
  alias_method :translateable?, :translate

  def convert_data(data)
    super.map { |l| l.split('|').map(&:strip).map(&:split) }.map { |d|
    {
      patterns: d.first,
      outputs: d.last,
    } }
  end
end

Day8.solve
