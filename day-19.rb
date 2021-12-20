require_relative 'common'

require 'matrix'

class Day19 < AdventDay
  EXPECTED_RESULTS = { 1 => 79, 2 => 3621 }

  CACHE = {} # Class-level cache since we have per-instance solving

  def first_part
    absolute_positions = CACHE[input] ||= compute_absolute_positions

    absolute_beacons = input.map.with_index do |beacons, i|
      beacons.map { |beacon| add(orient(beacon, absolute_positions[i].first), absolute_positions[i].last) }
    end
    absolute_beacons.flatten(1).uniq.count
  end

  def second_part
    absolute_positions = CACHE[input] ||= compute_absolute_positions

    absolute_positions.map(&:last).combination(2).map { |s1,s2| diff(s1,s2).map(&:abs).sum }.max
  end

  private

  def compute_absolute_positions
    precompute_orientations(input)

    indices = (0...input.length).to_a
    matching_pairs = indices.product(indices).map.with_index do |(base_index, beacon_vectors_index), i|
      _, base = get_orientation(base_index).find { |orientation, _v| orientation == Matrix.identity(3) }
      get_orientation(beacon_vectors_index).find do |(ref, orientation)|
        in_common = base.keys & orientation.keys
        next unless in_common.count >= (12*11/2) # V = ∑(0->n)
        break [[[base_index, beacon_vectors_index], ref], in_common.map { |vector| [base[vector], orientation[vector]] }]
      end
    end.compact
    matches = matching_pairs.map do |metadata, pairs|
      [metadata, pairs.
        flat_map { |(p1a,p1b),p2| [[p1a, [p2]], [p1b, [p2]]].to_h }.
        reduce { |a,e| a.merge(e) { |k,v1,v2| v1 + v2 } }.
        map { |s,possible_ts| [s, possible_ts.reduce(&:&).unwrap] }]
    end
    relative_positions = matches.flat_map do |((i0,i1),orientation),pairs|
      relative_pos = pairs.map { |(p1,p2)| diff(p1, p2) }.uniq.unwrap

      [
        [[[i0, i1], orientation], relative_pos],
      ]
    end.to_h

    (0...input.length).map { |scanner| compute_absolute_position(0, scanner, relative_positions) }
  end

  def compute_vector(beacon_1, beacon_2)
    diff(beacon_1, beacon_2)
  end

  def compute_absolute_position(root, scanner, relpos)
    return [Matrix.identity(3), [0,0,0]] if root == scanner
    existing_pos = relpos.find { |((from,to),_),_| from == root && to == scanner }
    return [existing_pos.first.last, existing_pos.last] if existing_pos

    relpos.select { |((from,to),_),_| from == root }.map do |((_,new_from),local_orientation), new_pos|
      pertinent_pos = relpos.reject { |((from, to),_),_| from == root || to == root }
      global_orientation, local_pos = compute_absolute_position(new_from, scanner, pertinent_pos)
      next unless local_pos
      nonlocal_pos = orient(local_pos, local_orientation)
      [local_orientation*global_orientation, add(new_pos, nonlocal_pos)]
    end.compact.first
  end

  def precompute_orientations(scans)
    return @orientations if defined? @orientations
    @orientations ||= {}
    scans.each_with_index do |vectors, i|
      @orientations[i] = begin
        oriented = possible_orientations(vectors)

        vectors = oriented.map do |orientation, beacons|
          [
            orientation,
            beacons.product(beacons).map do |b1, b2|
              next if b1 == b2
              [compute_vector(b1, b2), [b1,b2]]
            end.compact.to_h
          ]
        end
      end
    end
  end

  def get_orientation(index)
    @orientations[index]
  end

  def diff(v1,v2)
   v1.zip(v2).map { |cb1, cb2| cb1 - cb2 }
  end

  def add(v1,v2)
   v1.zip(v2).map { |cb1, cb2| cb1 + cb2 }
  end

  ROTATIONS_X = (1..4).map { |n| ([Matrix.rows([[1,0,0],[0,0,1],[0,-1,0]])]*n).reduce(&:*) }
  ROTATIONS_Y = (1..4).map { |n| ([Matrix.rows([[0,0,1],[0,1,0],[-1,0,0]])]*n).reduce(&:*) }
  ROTATIONS_Z = (1..4).map { |n| ([Matrix.rows([[0,-1,0],[1,0,0],[0,0,1]])]*n).reduce(&:*) }
  ORIENTATIONS = ROTATIONS_X.product(ROTATIONS_Y).product(ROTATIONS_Z).map { |(a,b),c| a*b*c }.uniq

  def possible_orientations(vectors)
    ORIENTATIONS.map do |orientation|
      [
        orientation,
        vectors.map { |vector| orient(vector, orientation) },
      ]
    end
  end

  def orient(vector, orientation)
    matrix = Matrix.columns([vector])
    (orientation * matrix).transpose.to_a.unwrap.map(&:to_i)
  end

  def convert_data(data)
    data.split("\n\n").map do |scanner|
      scanner.split("\n")[1..].map do |beacon|
        beacon.split(',').map(&:to_i)
      end
    end
  end
end

Day19.solve
