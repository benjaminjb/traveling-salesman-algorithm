module BranchBoundTSP
  def self.solver=(x)
    @solver = x
  end

  def self.solver
    @solver
  end
end

module BranchBoundTSP
  class Solver
    # attr_accessor :matrix, :nodelist, :optimal_path
    
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
          name = "#{key}--#{dest[0]}" #.downcase
          holding_hash[name] = dest[1]
        end
        @matrix << holding_hash
      end
    end

    def build_tree()
      infinitize
      while @included.length < @matrix.length
        @matrix.each do |row|
          row.each do |key,value|
            node_vs_node(included: @included, excluded: @excluded, path: {key => value})
          end
        end
      end
      build_result
    end

    def node_vs_node(included: included, excluded: excluded, path: path)
      # path must be hash, with key of path name, value of distance
      least_edges_all_with = least_edges_all(included: included.merge(path), excluded: excluded).map {|x| x.values }.flatten.inject(:+)
      least_edges_all_without = least_edges_all(included: included, excluded: excluded.merge(path)).map {|x| x.values }.flatten.inject(:+)

      if least_edges_all_with > least_edges_all_without
        @included = @included.merge(path)
        return true
      else
        @excluded = @excluded.merge(path)
        return false
      end
    end

    def least_edges(included: {}, excluded: {}, hash: hash)
      # included and excluded will be hashes; the hash is trip-name:=>distance, empty hashes cool
      least = included
      hashwork = hash
      copy = hashwork.delete_if {|key, value| excluded.has_key?(key) }.sort_by {|_,v| v}
      i = 0
      until (least.length == 2)
        binding.pry
        least[copy[i][0]] = copy[i][1]
        i += 1
      end
      return least
      # will return a hash of the 2 lowest distances, minus any excluded
    end

    def least_edges_all(included: {}, excluded: {})
      # included and excluded will be hashes; the hash is trip-name:=>distance, empty hashes cool
      least_all = []
      @matrix.each do |hash|
        least_all << least_edges(included: included, excluded: excluded, hash: hash)
      end
      return least_all
      # an array of hashes from each level of the matrix
    end

    def build_result
      solution_array = []
      home = @included.delete_if {|k,v| k.include?(@home) }
      holder = home.pop
      find = holder.keys.split('-')[1]
      solution_array << holder
      until @included.length == 0
        holder = @included.delete_if {|k,v| k.include?(find) }
        find = holder.keys.split('-')[1]
        solution_array << holder
      end
      solution_array << home.pop
      solution_array = test.map(&:to_a).flatten(1)
      solution = {}
      solution_array.each_index do |index|
        solution[index] = solution_array[index]
      end
      return solution
    end

    def infinitize()
      # a method for making 0 distances into infinity (so they don't get picked up as lowest distances)
      # @matrix.each do |array|
      #   hash.each do |k,_| 
      #     hash[k] = Float::INFINITY if hash[k]==0
      #   end
      # end

      # a method for removing any key with a distance of zero
      @matrix.each do |hash|
        hash.each do |k,v| 
          hash.delete(k) if v == 0
        end
      end      
    end


  end
end





# module BranchBoundTSP
#   class BBNode
#     attr_accessor :least, :parent, :left_child, :right_child 
#     def initialize(name: name, least: nil, parent: nil, left_child: nil, right_child: nil)
#       @name = name
#       @least = least
#       @parent = parent
#       @left_child = left_child
#       @right_child = right_child
#       BranchBoundTSP.solver.nodelist << self
#     end
#   end
# end