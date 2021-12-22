require_relative 'common'

class Day22 < AdventDay
  EXPECTED_RESULTS = { 1 => 474140, 2 => 2758514936282235 }.freeze

  class PointGrid
    attr_reader :actives

    def initialize(actives = Set.new)
      @actives = actives
    end

    def turn_cube(x_range, y_range, z_range, status:)
      (x_range).product(y_range).product(z_range).each do |(x,y), z|
        if status
          add_active x,y,z
        else
          remove_active x,y,z
        end
      end
    end

    def add_active(*coords)
      @actives << coords
    end

    def remove_active(*coords)
      @actives.delete(coords)
    end
  end

  class RangeGrid
    attr_reader :cubes

    def initialize(cubes = Set.new)
      @cubes = Set.new
    end

    class Cube < Struct.new(:min_x, :max_x, :min_y, :max_y, :min_z, :max_z)
      def empty?
        min_x >= max_x || min_y >= max_y || min_z >= max_z
      end

      def volume
       empty? ? 0 : (max_x-min_x)*(max_y-min_y)*(max_z-min_z)
      end
    end

    def turn_cube(nx_min,nx_max, ny_min, ny_max, nz_min, nz_max, status:)
      new_cube = Cube.new nx_min,nx_max, ny_min, ny_max, nz_min, nz_max
      new_cubes = @cubes.dup
      @cubes.each do |cube|
        intersection = compute_intersection(cube,new_cube)
        next if intersection.empty?
        compute_slices(cube, new_cube).each { |slice| new_cubes << slice }
        new_cubes.delete(cube)
      end
      new_cubes << new_cube if status
      @cubes = new_cubes
    end

    def compute_slices(cube, new_cube)
      grid = [cube.min_x, cube.max_x, new_cube.min_x, new_cube.max_x].sort.each_cons(2).product(
        [cube.min_y, cube.max_y, new_cube.min_y, new_cube.max_y].sort.each_cons(2)).product(
        [cube.min_z, cube.max_z, new_cube.min_z, new_cube.max_z].sort.each_cons(2))

      cubes = grid.map { |((x1,x2),(y1,y2)),(z1,z2)| Cube.new x1,x2, y1,y2, z1,z2 }
      cubes.reject(&:empty?).select do |subcube|
        compute_intersection(subcube, new_cube).empty? &&
          !(compute_intersection(subcube, cube).empty?)
      end
    end

    def compute_intersection(cube, new_cube)
      min_x = [cube.min_x, new_cube.min_x].max
      max_x = [cube.max_x, new_cube.max_x].min
      min_y = [cube.min_y, new_cube.min_y].max
      max_y = [cube.max_y, new_cube.max_y].min
      min_z = [cube.min_z, new_cube.min_z].max
      max_z = [cube.max_z, new_cube.max_z].min
      Cube.new min_x, max_x, min_y, max_y, min_z, max_z
    end
  end

  def first_part
    grid = PointGrid.new
    input.each do |(status, x_min, x_max, y_min, y_max, z_min, z_max)|
      x_min = [x_min, -50].max
      x_max = [x_max,  50].min
      y_min = [y_min, -50].max
      y_max = [y_max,  50].min
      z_min = [z_min, -50].max
      z_max = [z_max,  50].min
      grid.turn_cube(x_min..x_max, y_min..y_max, z_min..z_max, status: status)
    end
    grid.actives.count
  end

  def second_part
    grid = RangeGrid.new
    input.each do |(status, x_min, x_max, y_min, y_max, z_min, z_max)|
      # Incrementing maxes since we're not using inclusive ranges this time
      grid.turn_cube(x_min,x_max+1, y_min,y_max+1, z_min,z_max+1, status: status)
    end
    grid.cubes.sum(&:volume)
  end

  private

  INPUT_REGEX = /(on|off) x=(-?\d+)\.\.(-?\d+),y=(-?\d+)\.\.(-?\d+),z=(-?\d+)\.\.(-?\d+)/
  def convert_data(data)
    super.map do |line|
      (status, x_min, x_max, y_min, y_max, z_min, z_max) = line.match(INPUT_REGEX).captures
      [status == 'on', x_min.to_i, x_max.to_i, y_min.to_i, y_max.to_i, z_min.to_i, z_max.to_i]
    end
  end
end

Day22.solve
