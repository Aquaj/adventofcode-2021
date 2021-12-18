require_relative 'common'

class Day17 < AdventDay
  EXPECTED_RESULTS = { 1 => 45, 2 => 112 }.freeze

  def first_part
    trajectories.
      select { |(vx,vy),pos| pos.any? { |coords| in_target?(*coords) } }.
      map { |*_,pos| pos.map(&:last).max }.
      max
  end

  def second_part
    trajectories.
      select { |(vx,vy),pos| pos.any? { |coords| in_target?(*coords) } }.
      count
  end

  private

  def in_target?(x,y)
    xmin,xmax,ymax,ymin = input
    xmin.towards(xmax).include?(x) && ymin.towards(ymax).include?(y)
  end

  def after_target?(x,y)
    outer_x,outer_y = outer_coords

    sign_y = outer_y / outer_y.abs
    x.abs > outer_x.abs || ((y-outer_y)*sign_y).positive?
  end

  def outer_coords
    return @outer if defined? @outer
    xmin,xmax,ymax,ymin = input
    outer_x = [xmin,xmax].max_by(&:abs)
    outer_y = [ymin,ymax].max_by(&:abs)
    @outer = [outer_x, outer_y]
  end

  def trajectories
    xmin,xmax,ymax,ymin = input
    outer_x,outer_y = outer_coords

    y_range = outer_y.positive? ? 0.towards(2*outer_y) : (-1*outer_y).towards(outer_y)
    vels = y_range.flat_map do |vel_y|
      0.towards(outer_x).map do |vel_x|
        positions = []
        new_x = 0
        new_y = 0
        (0...).each do |n|
          break if after_target?(new_x, new_y)
          sign_x = vel_x.zero? ? 0 : vel_x / vel_x.abs
          abs_pos_x = [vel_x.abs * (n+1) - (0..[n,vel_x].min).sum, (0..vel_x.abs).sum].min
          new_x = sign_x * abs_pos_x
          new_y = vel_y*(n+1) - (0..n).sum
          positions << [new_x, new_y]
        end
        [[vel_x, vel_y], positions]
      end
    end
  end

  def convert_data(data)
    super.first.match(/target area: x=(-?\d+)..(-?\d+), y=(-?\d+)..(-?\d+)/).captures.map(&:to_i)
  end
end

Day17.solve
