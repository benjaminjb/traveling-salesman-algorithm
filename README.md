### Traveling Salesman Algorithm, Branch-and-Bound Method

For the Eff Errands project (our first group hackathon), I attempted to write an algorithm that would find the shortest overall route for the errands. 

After some preliminary research into methods for solving the traveling salesman problem, I settled on the branch-and-bound method, which creates a tree-like decision structure that considers the shortest route with some path included vs. the shortest route with the same path excluded.

For instance, if the A-B distance is low, it might seem like a good route to take; a "greedy" algorithm that merely takes the shortest available path might take it. But using the A-B path (or edge if you prefer graph theory) might result in a sub-optimal choice for the overall route: A-B might be low, but the overall path might be higher if you include it. Branch-and-bound is meant to avoid the problem of greedy algorithms leading to suboptimal outcomes, while also operating slightly faster than a method that needs to check all of the edges between all of the nodes.

The algorithm proved a little too time-consuming in the time available for the hackathon, so we ended up using Google Maps API, which includes a solution for the Traveling Salesman Problem.

For more on the branch-and-bound method, these were the resources I found most helpful:

1) [Optimal Solution for TSP using Branch and Bound](http://lcm.csa.iisc.ernet.in/dsa/node187)
2) [The Traveling Salesman Problem](www.csd.uoc.gr/~hy583/papers/ch11.pdf)
3) [Branch and Bound Implementations for the Traveling Salesperson Problem](www.jot.fm/issues/issue_2003_03/column7.pdf) Note: contains Java implementation for the problem (if you're interested in seeing how you might solve the problem in another language).