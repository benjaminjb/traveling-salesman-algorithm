## Traveling Salesman Algorithm
#### A Branch-and-Bound Solution in Ruby

For the [Eff Errands project](https://github.com/kizzle102/EffErrands) (our first group hackathon), I attempted to write an algorithm that would find the shortest overall route for the errands. 
___

### The Problem

A simple solution to the Traveling Salesman Problem would be to always take the shortest route from any point. But this "greedy" algorithm can quickly lead to suboptimal solutions: a short trip from A to B can lead to a longer trip overall.

On the other end, checking every possible route from every point to every other point can lead to a bloated run-time.

So, given that we had two days for our hackathon, how could I write a solution to the TSP?

___
### The Solution

The branch-and-bound solution to the TSP avoids the problem of greedy algorithms leading to suboptimal outcomes, while also operating slightly faster than a method that needs to check all of the routes between all of the points.

It works by creating a tree-like decision structure that considers **the shortest route with some path included** vs. **the shortest route with the same path excluded**.

The algorithm proved a little too time-consuming in the time available for the hackathon, so we ended up using Google Maps API, which includes a solution for the Traveling Salesman Problem.

___
### Resources
For more on the branch-and-bound method, these were the resources I found most helpful:

1. [Optimal Solution for TSP using Branch and Bound](http://lcm.csa.iisc.ernet.in/dsa/node187)
2. [The Traveling Salesman Problem](www.csd.uoc.gr/~hy583/papers/ch11.pdf)
3. [Branch and Bound Implementations for the Traveling Salesperson Problem](www.jot.fm/issues/issue_2003_03/column7.pdf) Note: contains Java implementation for the problem (if you're interested in seeing how you might solve the problem in another language).
