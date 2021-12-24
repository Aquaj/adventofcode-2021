require_relative 'common'

require 'z3'

class Day24 < AdventDay
  EXPECTED_RESULTS = { 1 => 99429795993929, 2 => 18113181571611 }.freeze

  def first_part
    resolve_constraints_opt(:maximize)
  end

  def second_part
    resolve_constraints_opt(:minimize)
  end

  private

  def optimized_computing
    segments = input.chunk { |op,*_| op == 'inp' }.map(&:last).each_slice(2).to_a.map { |ops| ops.flatten(1) }
    @precomputed = Hash.new { |h,k| h[k] = Hash.new { { 'w' => 0, 'x' => 0, 'y' => 0, 'z' => 0 } } }
    catch :stop_early do
      precompute_and_run [], segments.dup, 0
    end
    #TODO: Find biggest value in @precomputed hash[14]
  end

  def precompute_and_run(args, remaining_segments, depth = 0)
    return unless remaining_segments.any?
    segment = remaining_segments.shift
    (9.towards 1).each do |n|
      puts n if depth == 4
      full_args = [*args, n]
      @precomputed[depth][full_args.dup] = registers = run_program segment, [n], @precomputed[depth - 1][args].dup
      throw :stop_early if registers['z'].zero? && remaining_segments.none?
      precompute_and_run(full_args, remaining_segments.dup, depth+1)
    end
  end

  def run_program(program, queue, registers={ 'w' => 0, 'x' => 0, 'y' => 0, 'z' => 0 })
    program.each do |op, *args|
      case op
      when 'inp'
        registers[args.first] = queue.shift
      when 'add'
        a,b = *args
        registers[a] = registers[a] + value_of(b, registers)
      when 'mul'
        a,b = *args
        registers[a] = registers[a] * value_of(b, registers)
      when 'div'
        a,b = *args
        raise if value_of(b, registers) == 0
        registers[a] = registers[a] / value_of(b, registers)
      when 'mod'
        a,b = *args
        raise if registers[a] < 0
        raise if value_of(b, registers) <= 0
        registers[a] = registers[a] % value_of(b, registers)
      when 'eql'
        a,b = *args
        registers[a] = registers[a] == value_of(b, registers) ? 1 : 0
      end
    end
    registers
  end

  def value_of(v, registers)
    registers[v] || v.to_i
  end

  def resolve_constraints(program)
    solver = Z3::Optimize.new

    digits = Array.new(14) { |n| Z3.Int("digit-#{n.to_s.rjust(2, '0')}") }
    digits.each do |digit|
      solver.assert digit >= 1
      solver.assert digit <= 9
    end
    input_arg = Z3.Int('arg')
    solver.assert input_arg == digits.reverse.each_with_index.map { |n,i| n*(10**i) }.reduce(&:+)
    solver.maximize input_arg

    registers = { 'w' => [Z3.Int("w0")], 'x' => [Z3.Int("x0")], 'y' => [Z3.Int("y0")], 'z' => [Z3.Int("z0")] }
    solver.assert registers['w'][0] == 0
    solver.assert registers['x'][0] == 0
    solver.assert registers['y'][0] == 0
    solver.assert registers['z'][0] == 0

    digit = 0
    program.each do |op, *args|
      case op
      when 'inp'
        a, _ = *args
        registers[a] << new_a = Z3.Int("#{a}#{registers[a].length.to_s.rjust(2, '0')}")
        solver.assert new_a == digits[digit]
        digit += 1
      when 'add'
        a,b = *args
        curr_a = registers[a].last
        curr_b = registers[b]&.last || b.to_i
        registers[a] << new_a = Z3.Int("#{a}#{registers[a].length.to_s.rjust(2, '0')}")
        solver.assert new_a == curr_a + curr_b
      when 'mul'
        a,b = *args
        curr_a = registers[a].last
        curr_b = registers[b]&.last || b.to_i
        registers[a] << new_a = Z3.Int("#{a}#{registers[a].length.to_s.rjust(2, '0')}")
        solver.assert new_a == curr_a * curr_b
      when 'div'
        a,b = *args
        curr_a = registers[a].last
        curr_b = registers[b]&.last || b.to_i
        solver.assert curr_b != 0 if b.is_a? Z3::Expr
        registers[a] << new_a = Z3.Int("#{a}#{registers[a].length.to_s.rjust(2, '0')}")
        solver.assert new_a == curr_a / curr_b
      when 'mod'
        a,b = *args
        curr_a = registers[a].last
        curr_b = registers[b]&.last || b.to_i
        solver.assert curr_a >= 0
        solver.assert curr_b > 0 if b.is_a? Z3::Expr
        registers[a] << new_a = Z3.Int("#{a}#{registers[a].length.to_s.rjust(2, '0')}")
        solver.assert new_a == curr_a.mod(curr_b)
      when 'eql'
        a,b = *args
        curr_a = registers[a].last
        curr_b = registers[b]&.last || b.to_i
        registers[a] << new_a = Z3.Int("#{a}#{registers[a].length.to_s.rjust(2, '0')}")
        solver.assert new_a == Z3.IfThenElse(curr_a == curr_b, 1, 0)
      end
    end
    solver.assert registers['z'].last == 0

    solver.satisfiable?
    solver.model.model_eval(input_arg).to_i
  end

  # All blocks are identical save for parameter changes, let's use that to cut down constraint number
  def resolve_constraints_opt(goal)
    segments = input.chunk { |op,*_| op == 'inp' }.map(&:last).each_slice(2).to_a.map { |ops| ops.flatten(1) }
    parameters = segments.map { |segment| [segment[4][2], segment[5][2], segment[15][2]].map(&:to_i) }

    solver = Z3::Optimize.new

    digits = Array.new(14) { |n| Z3.Int("digit-#{n.to_s.rjust(2, '0')}") }
    digits.each { |digit| solver.assert (digit >= 1).& (digit <= 9) }
    input_arg = digits.reverse.each_with_index.map { |n,i| n*(10**i) }.reduce(&:+)
    solver.send goal, input_arg

    z = Z3.Int('z0')
    solver.assert z == 0
    parameters.each_with_index do |(q,r,n), i|
      w = digits[i]
      condition = z.mod(26) + r == w

      z = Z3::IfThenElse(z.mod(26) + r == w, z / q, z * 26 / q + w + n)
    end

    solver.assert z == 0

    solver.satisfiable?
    solver.model.model_eval(input_arg).to_i
  end

  def convert_data(data)
    super.map do |ins|
      ins.split
    end
  end
end

Day24.solve
