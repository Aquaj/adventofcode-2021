require_relative 'common'

class Day21 < AdventDay
  EXPECTED_RESULTS = { 1 => 739785, 2 => 444356092776315 }.freeze

  UNIVERSE_FREQUENCIES = (1..3).product(1..3).product(1..3).map(&:flatten).tally

  def first_part
    dice = (1..100).cycle.each_slice(3)

    board_1 = (1..10).cycle
    board_1.nth(input[0]) # Setting initial pos

    board_2 = (1..10).cycle
    board_2.nth(input[1]) # Setting initial pos

    score_1 = score_2 = 0

    (0..).each do |n|
      score_1 += board_1.nth(dice.next.sum)
      break [3*(n*2+1), score_2] if score_1 >= 1000
      score_2 += board_2.nth(dice.next.sum)
      break [3*(n*2+2), score_1] if score_2 >= 1000
    end.reduce(&:*)
  end

  def second_part
    @cache = Hash.new
    GC.disable # Slight perf boost sicne we're going to create a bunch of objects
    scores = cached_game(input[0], input[1], 0, 0, 0, 0)
    GC.enable
    scores.max
  end

  private

  def game(pos_1, pos_2, score_1, score_2, dice_value, turn)
    score_1 += (pos_1 = (pos_1 + dice_value - 1) % 10 + 1) if turn == 1
    return [1, 0] if score_1 >= 21
    score_2 += (pos_2 = (pos_2 + dice_value - 1) % 10 + 1) if turn == 2
    return [0, 1] if score_2 >= 21
    new_turn = turn % 2 + 1

    universe_wins_1 = universe_wins_2 = 0
    UNIVERSE_FREQUENCIES.each do |(a,b,c), frequency|
      w1, w2 = *cached_game(pos_1, pos_2, score_1, score_2, a+b+c, new_turn)
      universe_wins_1 += w1 * frequency
      universe_wins_2 += w2 * frequency
    end
    [universe_wins_1, universe_wins_2]
  end

  def cached_game(*game_configuration)
    cache_key = game_configuration.hash # Pre-hashing so Array#eql? isn't called on cache lookup
    @cache[cache_key] ||= game(*game_configuration)
  end

  def convert_data(data)
    super.map(&:last).map(&:to_i)
  end
end

Day21.solve
