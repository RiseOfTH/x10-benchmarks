import x10.lang.Math;
import x10.lang.Int;
import x10.util.Random;

/**
 * A class that can generate a variety of lifeline structures based on what 
 * is requested. For example, it can currently generate a ring structure, and
 * a directed hypercube structure. All methods in this class are static.
 *
 * The output of this class is a ValRail[ValRail[Int]] -- essentially, one 
 * array for each node, indicating the neighbors that each node can 
 * communicate with.
 */
final class NetworkGenerator {
  public static val INVALID_EDGE:Int = -1;

  private static def countValidEdges (edgeList:ValRail[Int]) {
    var numValidEdges:Int = 0;
    for (var i:Int=0; i<edgeList.length(); ++i) 
      if (INVALID_EDGE != edgeList(i)) ++numValidEdges;
    return numValidEdges;
  }

  /**
   * Method to generate a directed hypercube structure.
   */
  public static def generateHyperCube (nplaces:Int) {
    // First, create a hypercube along with an overlay of a ring structure.
    // The ring structure is needed to ensure that there is always a linear
    // lifeline available to the system -- in case all else fails.
    val mutableNetwork:ValRail[Rail[Int]] = 
      ValRail.make[Rail[Int]] (nplaces, 
        (i:Int) => Rail.make[Int](x10.lang.Math.log2(nplaces)+1,
                              (j:Int) => 
          (0==j)?(i+1)%nplaces : 
                 (((i+1)%nplaces)==((1<<(j-1))^i) || 
                  ((1<<(j-1))^i)==((i==0)?(nplaces-1):(i-1)))?
                                                   -1:((1<<(j-1))^i)));

    // Now, make this hypercube directed by pruning away the 2-cycles 
    // randomly. Bsaically, we flip a coin and keep one of the 2 edges.
    val rng:Random = new Random();
    if (2 < nplaces) {
      for (var i:Int=0; i<mutableNetwork.length(); ++i) {
        for (var j:Int=1; j<mutableNetwork(i).length(); ++j) {
          // check if the cycle has already been broken
          if (mutableNetwork(i)(j) > i) {
            // break the cycle by flipping a coin 
            if (rng.nextBoolean()) {
              // go to the other entry and make it -1 
              val index:Int = mutableNetwork(i)(j);
              for (var k:Int=1; k<mutableNetwork(index).length(); ++k) {
                if (mutableNetwork(index)(k) == j) {
                  mutableNetwork(index)(k) = -1;
                  break;
                }
              }
            } else {
              mutableNetwork(i)(j) = -1;
            }
          }
        }
      }
    }

    // Finally, create a new thingy based on what we just created.
    val network:ValRail[ValRail[Int]] = ValRail.make[ValRail[Int]] 
        (nplaces, (i:Int) => ValRail.make[Int] 
          (mutableNetwork(i).length, (j:Int) => mutableNetwork(i)(j)));

    // Return what we just created.
    return network;
  }

  /**
   * Method to generate a directed hypercube structure.
   */
  public static def generateRing (nplaces:Int) {
    val network:ValRail[ValRail[Int]] = ValRail.make[ValRail[Int]] 
      (nplaces, (i:Int) => ValRail.make[Int] (1, (j:Int) => (i+1)%nplaces));

    return network;
  }

  /*
   * Given a bucket-list, a particular place, and the dimension, figure out
   * which is the neighbor in this dimension. Since there is a chance that 
   * not all buckets are of the same size, the neighbor *might* be -1!
   */
  private static def getNeighbor (buckets:ValRail[Int],
                                  place:Int,
                                  dimension:Int) {

    // Figure out which bucket this place belongs to
    var bucketNumber:Int=-1;
    val nDimensions:Int = buckets.length();
    for (var i:Int=0; i<nDimensions; ++i) {
      if (place >= buckets(i) && place < buckets(i+1)) {
        bucketNumber = i;
        break;
      }
    }

    // If the place is in the same dimension, the neighbor is +1 mod nbuckets
    // If the place is in a different dimension, then simply shift right.
    if (dimension==bucketNumber) {
      return (buckets(1+bucketNumber)==(1+place)) ?
                buckets (bucketNumber) : (1+place);
    } else {
      // Get the displacement of the place in the bucket
      val displacement:Int = place - buckets(bucketNumber);
      val numElementsInDimension:Int = 
                      buckets(1+dimension) - buckets(dimension); 

      return (displacement >= numElementsInDimension) ? 
                  -1 : (buckets(dimension) + displacement);
    }
  }

  /**
   * Method to generate the sparse hyper-cube structure that Vijay suggested.
   * The mappings are generated as follows:
   * Let P be the total number of places.
   * Let k be the dimensionality required.
   * We first create k buckets (as equally split as possible).
   * Next, for each bucket, we create an injective mapping to every other 
   * bucket including itself.
   */
   public static def generateSparseHyperCube (nplaces:Int, 
                                              nDimensions:Int) {
     // Figure out how many elements are in each bucket
     val quotient:Int = nplaces/nDimensions;
     var remainder:Int = nplaces%nDimensions;
     var firstCutBuckets:Rail[Int] = Rail.make[Int] 
                                (nDimensions+1, (i:Int) => i*quotient);

     // Adjust for the remainder
     var extraElementRecepient:Int = 1;
     while (0 != remainder) { 
       for (var i:Int=extraElementRecepient; i<firstCutBuckets.length(); ++i) {
        ++firstCutBuckets(i);
       }
       ++extraElementRecepient;
       --remainder; 
     }
     val buckets:ValRail[Int] = firstCutBuckets;

     // Now generate network. Basically, for each i, we determine which 
     // bucket it belongs to. Then, it is pretty simple to calculate 
     // which element it is mapped to.
     val network:ValRail[ValRail[Int]] = ValRail.make[ValRail[Int]]
       (nplaces, (i:Int) => ValRail.make[Int] 
         (nDimensions, (j:Int) => getNeighbor (buckets, i, j)));

     return network;
   }

  
  /**
   * Verify that there are no cycles of length 2
   */
  public static def has2cycles (nplaces:Int, 
                                network:ValRail[ValRail[Int]]) {
    if (2 < nplaces) {
      for (var i:Int=0; i<network.length(); ++i) {
        for (var j:Int=1; j<network(i).length(); ++j) {
          val lifeLine = network(i)(j);
          if (-1 != lifeLine) {
            for (var k:Int=0; k<network(lifeLine).length; ++k) {
              if (i == network(lifeLine)(k)) {
                return false;
              }
            }
          }
        }
      }
    }
    return true;
  }

  /** 
   * Print out the network.
   */
  public static def printNetwork (network:ValRail[ValRail[Int]]) {
    for (var i:Int=0; i<network.length(); ++i) {
      Console.OUT.print(i + " =>");
      for (var j:Int=0; j<network(i).length(); ++j) 
        if (-1 != network(i)(j)) Console.OUT.print(" " + network(i)(j));
      Console.OUT.println();
    }
  }
}
