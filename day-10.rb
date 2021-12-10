require_relative 'common'

require 'rltk'

class Day10 < AdventDay
  EXPECTED_RESULTS = { 1 => 26397, 2 => 288957 }

  SCORES = {
    :RPAREN => 3,
    :RBRACKET => 57,
    :RBRACE => 1197,
    :RARROW => 25137,
  }
  AUTOCOMPLETE_SCORES = {
    ?) => 1,
    ?] => 2,
    ?} => 3,
    ?> => 4,
  }


  class Lexer < RLTK::Lexer
    rule(/\(/) { :LPAREN }
    rule(/\)/) { :RPAREN }
    rule(/\{/) { :LBRACE }
    rule(/\}/) { :RBRACE }
    rule(/\[/) { :LBRACKET }
    rule(/\]/) { :RBRACKET }
    rule(/\</) { :LARROW }
    rule(/\>/) { :RARROW }
  end

  class Parser < RLTK::Parser
    default_arg_type :array
    production(:exp) do
      clause('exp exp') {|*|}
      clause('LPAREN exp? RPAREN') {|*|}
      clause('LBRACE exp? RBRACE') {|*|}
      clause('LBRACKET exp? RBRACKET') {|*|}
      clause('LARROW exp? RARROW') {|*|}
    end
    finalize
  end


  def first_part
    @lexer = Lexer.new
    @parser = Parser.new
    input.sum do |line|
      parse(line)
    rescue RLTK::NotInLanguage => e
      next 0 if e.current.type == :EOS
      SCORES[e.current.type]
    else
      0
    end
  end

  def second_part
    corrupted_lines = input.reject do |line|
      parse(line)
    rescue RLTK::NotInLanguage => e
      e.current.type != :EOS
    else
      false
    end

    autocompletes = corrupted_lines.map { |line| autocomplete(line) }

    scores = autocompletes.map do |completion|
      completion.reduce(0) { |score,char| (score * 5) + AUTOCOMPLETE_SCORES[char] }
    end
    scores.sort[scores.length / 2]
  end

  private

  def parse(line)
    @lexer ||= Lexer.new
    @parser ||= Parser.new

    tokens = @lexer.lex(line)
    @parser.parse(tokens)
  end

  def autocomplete(line)
    autocompletion = []
    lengths = [nil, nil]

    begin
      parse(line + autocompletion.join)
    rescue RLTK::NotInLanguage => e
      lengths[0],lengths[1] = lengths[1], e.seen.count
      improved = lengths[0] && lengths[1] > lengths[0]

      # If it works, move to next char else try other completion
      last_try = improved ? nil : autocompletion.pop

      last_try_pos = AUTOCOMPLETE_SCORES.keys.index(last_try) || -1
      new_try = AUTOCOMPLETE_SCORES.keys[last_try_pos + 1]
      autocompletion << new_try
      retry
    else
      autocompletion
    end
  end

  def convert_data(data)
    super
  end
end

Day10.solve
