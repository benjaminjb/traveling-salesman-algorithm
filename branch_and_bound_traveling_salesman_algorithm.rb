# In the original implementation of Eff Errands, the front-end team got addresses from users.
# These addresses were then sent to Google Maps API, which returned a JSON object.
# The JSON object was then parsed and passed to this algorithm.
# The input data came in as an array of hashes; 
# the keys of those hashes were the origin locations;
# the values of those hashes were arrays of arrays, containing the destination and the distances.

class BranchBound
  def initialize(raw_matrix)
    # raw_matrix: an array of hashes with origin as the keys 
    # and [destination,distance] as the values

    # @home records the starting/ending point
    @home = raw_matrix[0].keys[0]

    # The middle matrix form that the algorithm uses
    @matrix = []

    # @included and @excluded are hashes recording the edges to be used / avoided in the solution
    @included = {}
    @excluded = {}

    # Call to function to construct the instance variable @matrix, with no output
    build_matrix(raw_matrix)
  end

  def build_matrix(raw_matrix)
    # To build the matrix, we want to make sure that every comparable edge is consistent,
    # i.e., A-B == B-A,
    # so our build_matrix function has to normalize the edge names

    raw_matrix.each do |origin_destination|
      # Create a temporary holding hash
      origin_destination_distance_hash = {}

      # Get the origin name
      origin_name = origin_destination.keys[0]

      # For each array of [destinations,distance] (flattened because it's passed within a larger array due to .values)
      origin_destination[origin_name].each do |destination_distance_array|
      
      # To get the names of the edges, add the origin name to the destination name,
      # sort the names, then join them with a symbol unlikely to be found in the original name
        edge_name = ["#{origin_name}", "#{destination_distance_array[0]}"].sort.join("--")

      # Now add the distance to the hash with the origin--destination key
        origin_destination_distance_hash[edge_name] = destination_distance_array[1]
      end

      # Add each origin_destination_distance_hash-- 
      # i.e., {"A--B"=>10, "A--C"=>100, "A--D"=>1000, "A--E"=>10000, "A--A"=>0}
      # --to the @matrix instance variable array
      @matrix << origin_destination_distance_hash

    end
    # Now the @matrix is complete, call the function that begins the actual solution
    build_tree
  end

  def build_tree()
    
    # Call to helper function that removes any self-move, i.e., A--A.
    infinitize

    # For each location-bound row in the array, i.e., ALL the possible moves from A
    @matrix.each do |origin_to_all_destinations|
      
      # For EACH individual possible move from A
      origin_to_all_destinations.each do |edge,distance|

        # If the particular edge is not already included in the @included or @excluded hashes
        if @included[edge].nil? && @excluded[edge].nil?

          # Call the helper function that compares the cost between including and excluding the path
          # Note: with_or_without_decider takes in the @included and @excluded hashes,
          # which is necessary to remember what edges the program has already decided to include or exclude for the decision
          with_or_without_decider(included: @included, excluded: @excluded, path: {edge => distance})
        end
      end
    end

    # Now the @included and @excluded info is complete, so send to helper function to prepare the output
    build_result
  end

  def infinitize()
    # A method for removing any key with a distance of zero from the @matrix

    # For each section of the @matrix
    @matrix.each do |section|

      # For each origin--destination => distance hash
      section.each do |k,v| 

        # Delete from the section (and thus the @matrix) if the distance == 0
        section.delete(k) if v == 0
      end
    end      
  end

  def with_or_without_decider(included: included, excluded: excluded, path: path)
    # included: the hash of paths the program has already decided to include
    # excluded: the hash of paths the program has already decided to exclude
    # path: the particular edge between two nodes that is being tested, in hash form, with key of path name and value of distance, i.e., {"A--B"=>10}

    # In order to compare the lower bound WITH a path vs. the lower bound WITHOUT a path, I get the lowest outcomes, first for the total distance WITH that path (forced into included)
    least_distance_with = least_overall_distance(included: included.merge(path), excluded: excluded)

    # And then for the total distance WITHOUT that particular path (forced into excluded)
    least_distance_without = least_overall_distance(included: included, excluded: excluded.merge(path))

    # Some path produce no solution if included so the result may be nil
    # If so, the path should be added to @excluded and the test return
    if least_distance_with.nil?
      @excluded = @excluded.merge(path)
      return
    elsif least_distance_without.nil?
    # Some path produce no solution if excluded so the result may be nil
    # If so, the path should be added to @included
      @included = @included.merge(path)
      return
    end

    # If the path is not automatically included or excluded, then we move on to comparison
    # If the distance WITH the path is less
    if least_distance_with <= least_distance_without
      # Then we add the path to the @included hash
      @included = @included.merge(path)
    else 
      # Otherwise, we add that path to the @excluded hash
      @excluded = @excluded.merge(path)
    end

    # Method has no return; the method's side effect is to put the tested path into either the @included or @excluded hash for use during build_result
  end

  def least_overall_distance(included: {}, excluded: {})
    # Inputs are hashes in the form {trip-name=>distance}
    
    # The least possible distance
    lowest_distance = 0

    # A counter set to find the shortest paths from each location
    # If this counter ends up failing to count up to the number of paths needed,
    # then we know this path is not valid
    counter = 0

    # For each section of the matrix--
    # i.e., {"A--B"=>10, "A--C"=>100, "A--D"=>1000, "A--E"=>10000, "A--A"=>0}
    @matrix.each_index do |origin_to_all_destinations|

      # Find the lowest possible distance for each location
      shortest_distance_for_single_location = shortest_distance_for_single_location_method(included: included, excluded: excluded, origin_section_to_go_through: @matrix[origin_to_all_destinations])

      # If there is a shortest distance for that location available
      if shortest_distance_for_single_location

        # Then add that distance to the lowest possible distance result
        lowest_distance += shortest_distance_for_single_location

        # And increment the counter
        counter += 1
      end
    end

    # If the counter equals the @matrix.length--
    # i.e., if we have found a number of paths that equals the number of locations to visit
    # --then return the distance for comparison
    if counter == @matrix.length
      return lowest_distance
    else

    # If the counter doesn't equal the @matrix.length, then we haven't found as many paths as we need
    # So return nil to indicate that this tested path is not valid
      return nil
    end
  end

  def shortest_distance_for_single_location_method(included: {}, excluded: {}, origin_section_to_go_through: origin_section_to_go_through)
    # Inputs are hashes in the form {trip-name=>distance}

    # least_overall_distance find the lower bound for the entire trip;
    # shortest_distance_for_single_location_method finds the lower bound for each individual location
    # The lower bound for any location includes two paths--one coming from and one going to the location
    
    # Create a array of paths from the intersection of the included parameter and the section parameter but excluding the excluded parameter
    # I.e., if we're looking at all paths from D, then we don't need to consider A--B, even if it is included
    # And if we're looking at all paths from D but we already know that A--D is excluded, we can't check it
    # These are the paths already included from that location

    array_of_paths_already_included = included.find_all { |k,_| origin_section_to_go_through.has_key?(k) && !excluded.has_key?(k) }

    # Find the distance for the paths that are already included
    result_number = 0
    array_of_paths_already_included.each {|path_distance| result_number += path_distance[1]}

    # Set a counter of how many elements we need
    counter = 2 - array_of_paths_already_included.length

    # If we don't need any elements, return the result
    if counter < 0
      return result_number
    end

    # Create a array of paths from the section parameter that are not excluded OR either already included in the above array
    # Sort that array by the distance so that we can easily pull the lowest distance answers

    array_of_paths_to_check = origin_section_to_go_through.find_all {|k, _| !excluded.has_key?(k)}.sort_by {|path_distance| path_distance[1] } - array_of_paths_already_included

    # Check that there are enough paths to take from that array
    if counter > array_of_paths_to_check.length
      # Return false if there aren't enough paths from this location
      return false
    end

    # Add the distances from the additional paths to the already computed result
    array_of_paths_to_check.take(counter).each {|path_distance| result_number += path_distance[1]}

    # Return the total length of that possible path to and from the location
    return result_number
  end

  def build_result

    # Set three arrays for help in organizing the solution:
    # An array of the solution to be used later
    solution_array = []

    # An array for those paths including @home
    paths_including_home = []

    # An array for those paths that don't touch @home
    paths_without_home_location = []

    # Divide the paths among those two arrays
    @included.each do |k,v|
      paths_including_home << [k,v] if k.include?(@home)
      paths_without_home_location << [k,v] if !k.include?(@home)
    end

    # To organize the solution, we'll need to take one of the home-touching paths
    # and find the other location that home leads to
    # and so on--always finding the second location given in a path
    # i.e., if @home is "A" and we have "A--B", then we will next look for a path including "B"

    first_home_location = paths_including_home.shift

    # Taken the home location, split it, and take the non-@home element
    location_array = first_home_location[0].split('--')
    location_array[0] == @home ? next_location_to_find = location_array[1] : next_location_to_find = location_array[0]

    # Regardless of previous action, put this home-touching path into the solution array
    solution_array << first_home_location

    # Until paths_without_home_location is empty, we have paths that don't return home to deal with
    until paths_without_home_location.length == 0

      # We have to find a path that includes our other location
      # I.e., if we went from A--B, our next path has to involve B
      next_path = paths_without_home_location.find {|destination_distance_pair| destination_distance_pair[0].include?(next_location_to_find) }

      # We can put that into our solution array
      solution_array << next_path

      # But we also have to take it out of our paths_without_home_location array
      paths_without_home_location.delete(next_path)

      # And we also have to make sure we're ready to find our next location
      # First by splitting the origin--destination name
      location_array = next_path[0].split('--')

      # Then by assigning the appropriate destination to next_location_to_find
      location_array[0] == next_location_to_find ? next_location_to_find = location_array[1] : next_location_to_find = location_array[0]

    end

    # With all of the paths that don't touch home being sorted, we need to finish the solution
    # by adding the last path, the one that returns home
    solution_array << paths_including_home.pop

    # Because my team asked me to return the answers inthe form of an array, I do
    solution = Hash[solution_array]
    puts solution
  end

end

# For testing purposes
# test = BranchBound.new(
#   [{"A"=>
#         [
#         ["B", 10], 
#         ["C", 100], 
#         ["D", 1000],
#         ["E", 10000],
#         ["A", 0]]}, 
#       {"B"=>
#         [
#         ["B", 0], 
#         ["C", 20], 
#         ["D", 200],
#         ["E", 2000],
#         ["A", 10]]}, 
#       {"C"=>
#         [
#         ["B", 20], 
#         ["C", 0], 
#         ["D", 30],
#         ["E", 300],
#         ["A", 100]]},
#       {"D"=>
#         [
#         ["B", 200], 
#         ["C", 30], 
#         ["D", 0],
#         ["E", 40],
#         ["A", 10000]]},
#       {"E"=>
#         [
#         ["B", 2000], 
#         ["C", 300], 
#         ["D", 40],
#         ["E", 0],
#         ["A", 10000]]}])