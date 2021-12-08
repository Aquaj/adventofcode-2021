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
  }
  DIGITS = SEGMENTS.map(&:reverse).to_h

  def first_part
    input.sum { |d| d[:outputs].count { |signal| [2, 4, 3, 7].include? signal.length } }
  end

  def second_part
    input.sum do |line|
      segment_decoder = (?a..?g).zip([Set.new((?a..?g).to_a)] * 7).to_h
      (line[:patterns] + line[:outputs]).sort_by(&:length).reverse.each do |signal|
        matching = SEGMENTS.to_a.select { |(_,segments)| segments.count == signal.length }
        signal.chars.each { |s| segment_decoder[s] &= matching.map(&:last).reduce(&:|) }
      end

      segment_decoder = segment_decoder.sort_by { |(_,candidates)| candidates.length }
      possibilities = build_possibilities(segment_decoder)

      # Output translation will either be right for all digits, or nil on at least one
      # so finding the first possibility that matches is enough
      possibilities.each do |possibility|
        outputs = line[:outputs].map { |output| translate(output, possibility) }
        break outputs.join.to_i if outputs.none?(&:nil?)
      end
    end
  end

  private

  def build_possibilities(decoder, matches = {})
    return [matches] if decoder.empty?
    decoder = decoder.deep_copy
    char, candidates = decoder.shift
    candidates -= matches.values
    candidates.map { |candidate| build_possibilities(decoder, matches.merge(char => candidate)) }.flatten(1)
  end

  def translate(value, decoder)
    translated = value.tr(decoder.keys.join, decoder.values.join)
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
