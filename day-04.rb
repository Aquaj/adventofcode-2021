require_relative 'common'

class Day4 < AdventDay
  class Board
    def initialize(board)
      @board = board
      @drawn = Set.new
    end

    def mark(num)
      @drawn << num
    end

    def winning?
      @board.any? { |row| row.all? { |n| @drawn.include? n } } ||
        @board.transpose.any? { |col| col.all? { |n| @drawn.include? n } }
    end

    def remaining_numbers
      @board.flatten - @drawn.to_a
    end
  end

  def first_part
    last_num, board = winning_board
    last_num * board.remaining_numbers.sum
  end

  def second_part
    last_num, board = losing_board
    last_num * board.remaining_numbers.sum
  end

  private

  alias_method :game, :input

  def winning_board
    game[:draw].each do |num|
      game[:boards].each do |board|
        board.mark(num)
        return [num, board] if board.winning?
      end
    end
  end

  def losing_board
    game[:draw].each do |num|
      game[:boards].reject! do |board|
        board.mark(num)
        return [num, board] if game[:boards].one? && board.winning?
        board.winning?
      end
    end
  end

  def convert_data(data)
    input = data.split("\n\n")
    draw = input[0].split(',').map(&:to_i)
    boards = input[1..].map { |b| Board.new(b.split("\n").map(&:split).map { |r| r.map(&:to_i) }) }
    {
      draw: draw,
      boards: boards,
    }
  end
end

Day4.solve
