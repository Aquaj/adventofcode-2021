require_relative 'common'

class Day21 < AdventDay
  EXPECTED_RESULTS = { 1 => 739785, 2 => 444356092776315 }.freeze

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
    @cache = {}
    game(input[0], input[1], 0, 0, 0, 0).max
  end

  private

  def game(pos_1, pos_2, score_1, score_2, dice_value, turn, wins_1=0, wins_2=0)
    universe_wins_1, universe_wins_2 = *@cache[[pos_1, pos_2, score_1, score_2, dice_value, turn]] ||= begin
      score_1 += (pos_1 = (pos_1 + dice_value - 1) % 10 + 1) if turn == 1
      return [wins_1+1, wins_2] if score_1 >= 21
      score_2 += (pos_2 = (pos_2 + dice_value - 1) % 10 + 1) if turn == 2
      return [wins_1, wins_2+1] if score_2 >= 21
      new_turn = turn % 2 + 1

      universe_wins_1 = universe_wins_2 = 0
      (1..3).product(1..3).product(1..3).each do |die_roll|
        w1, w2 = *game(pos_1, pos_2, score_1, score_2, die_roll.flatten.sum, new_turn, 0, 0)
        universe_wins_1 += w1
        universe_wins_2 += w2
      end
      [universe_wins_1, universe_wins_2]
    end

    [wins_1 + universe_wins_1, wins_2 + universe_wins_2]
  end

  def convert_data(data)
    super.map(&:last).map(&:to_i)
  end
end

Day21.solve
