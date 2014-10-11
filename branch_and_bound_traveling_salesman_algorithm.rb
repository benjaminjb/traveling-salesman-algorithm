


class BranchBound
  def initialize(raw_matrix)
    @home = raw_matrix[0].keys[0]
    @matrix = []
    @included = {}
    @excluded = {}
    build_matrix(raw_matrix)
  end

  def build_matrix(raw_matrix)
    raw_matrix.each do |origin|
      holding_hash = {}
      key = origin.keys[0]
      origin.values.flatten(1).each do |dest|
        name = ["#{key}"] 
        name << "#{dest[0]}"
        name.sort!
        name = "#{name[0]}--#{name[1]}" #.downcase
        holding_hash[name] = dest[1]
      end
      @matrix << holding_hash
    end
  end

  def build_tree()
    infinitize
    @matrix.each do |row|
      row.each do |key,value|
        node_vs_node(included: @included, excluded: @excluded, path: {key => value})
      end
    end
    build_result
  end

  def node_vs_node(included: included, excluded: excluded, path: path)
    # path must be hash, with key of path name, value of distance
    # return
    # STAR # top level comment

    least_edges_all_with, least_edges_all_without = nil
    # Least edges with 
    holding_with = least_edges_all(included: included.merge(path), excluded: excluded)
    # Check to see if nil because
    if (!holding_with.nil?)
      least_edges_all_with = holding_with
    else
      @excluded = @excluded.merge(path)
    end

    # STAR # detail comment
    holding_without = least_edges_all(included: included, excluded: excluded.merge(path))
    if (!holding_without.nil?)
      least_edges_all_without = holding_without
    else
      @included = @included.merge(path)
    end

    if !least_edges_all_with.nil? && !least_edges_all_without.nil? && least_edges_all_with <= least_edges_all_without
      @included = @included.merge(path)
    elsif !least_edges_all_with.nil? && !least_edges_all_without.nil? && least_edges_all_with > least_edges_all_without
      @excluded = @excluded.merge(path)
    end
  end

  def least_edges_all(included: {}, excluded: {})
    # included and excluded will be hashes; the hash is trip-name:=>distance, empty hashes cool

    least_all = Array.new
    counter = 0
    @matrix.each_index do |hash_index|
      holder = least_edges(included: included, excluded: excluded, hash: @matrix[hash_index])
      if holder
        least_all.insert(hash_index,holder)
        counter += 1
      end
    end

    if counter == @matrix.length
      return least_all.inject(:+)
    else
      return nil
    end
    # an array of hashes from each level of the matrix
  end

  def least_edges(included: {}, excluded: {}, hash: hash)
    # included and excluded will be hashes; the hash is trip-name:=>distance, empty hashes cool

    keeper_array = included.keys & hash.keys    
    least = Hash[included.find_all {|k,_| keeper_array.include?(k) }]    
    step1 = hash.find_all {|key, value| !excluded.has_key?(key) }.find_all {|x| !least.has_key?(x[0])}
    step2 = step1.sort_by {|x| x[1]}
    i = 0
    until (least.length > 1)
      if (step2[i].nil?)
        return false
      else
        least[step2[i][0]] = step2[i][1]
        i += 1
      end
    end
    return least.values.inject(:+)
    # will return a hash of the 2 lowest distances, minus any excluded
  end

  def build_result
    solution_array = []
    home_holder = []
    other_holder = []
    @included.each do |k,v|
      home_holder << [k,v] if k.include?(@home)
      other_holder << [k,v] if !k.include?(@home)
    end
    holder = home_holder.shift
    find = holder[0].split('--')[1]
    solution_array << holder
    until other_holder.length == 0
      holder = other_holder.find {|destination_distance_pair| destination_distance_pair[0].include?(find) }
      other_holder.delete_at (other_holder.index(holder))
      find = holder[0].split('--')[1]
      solution_array << holder
    end
    solution_array << home_holder.pop
    solution = Hash[solution_array]
    return solution
  end

  # a method for removing any key with a distance of zero
  def infinitize()
    @matrix.each do |hash|
      hash.each do |k,v| 
        hash.delete(k) if v == 0
      end
    end      
  end

  # a method for removing doubled edges from the hash
  # def remove_doubles()
  #   eliminator = @matrix[0].keys
  #   @matrix[1..-1].each do |hash|
  #     hash.delete_if {|k,_| eliminator.include?(k) }
  #     eliminator |= hash.keys
  #   end
  # end

end

test = BranchBound.new(
  [{"A"=>
        [
        ["B", 10], 
        ["C", 100], 
        ["D", 1000],
        ["E", 10000],
        ["A", 0]]}, 
      {"B"=>
        [
        ["B", 0], 
        ["C", 20], 
        ["D", 200],
        ["E", 2000],
        ["A", 10]]}, 
      {"C"=>
        [
        ["B", 20], 
        ["C", 0], 
        ["D", 30],
        ["E", 300],
        ["A", 100]]},
      {"D"=>
        [
        ["B", 200], 
        ["C", 30], 
        ["D", 0],
        ["E", 40],
        ["A", 10000]]},
      {"E"=>
        [
        ["B", 2000], 
        ["C", 300], 
        ["D", 40],
        ["E", 0],
        ["A", 10000]]}])
test.build_tree


