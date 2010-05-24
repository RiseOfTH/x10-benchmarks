import x10.compiler.*;
import x10.util.OptionsParser;
import x10.util.Option;
import x10.lang.Math;
import x10.util.Random;
import x10.util.Stack;

public class UTS {

	static type PLH = PlaceLocalHandle[BinomialState];
	private static val NORMALIZER = 2147483648.0; // does not depend on input parameters

	@NativeRep ("c++", "UTS__SHA1Rand", "UTS__SHA1Rand", null)
	@NativeCPPCompilationUnit ("sha1.c")
	@NativeCPPCompilationUnit ("UTS__SHA1Rand.cc")
	public static struct SHA1Rand {
		public def this (seed:Int) { }
		public def this (parent:SHA1Rand, spawn_number:Int) { }
		@Native ("c++", "UTS__SHA1Rand_methods::apply(#0)")
		public def apply () : Int = 0;
	}

	static class SeqBinomialState {
		// params that define the tree
		val q:Long, m:Int;

		var nodesCounter:UInt = 0;
		public def this (q:Long, m:Int) {
			this.q = q; this.m = m; 
		}

		public final def processSubtree (rng:SHA1Rand) {
			processSubtree(rng, (rng() < q) ? m : 0);
		}
		public final def processSubtree (rng:SHA1Rand, numChildren:Int) {
			nodesCounter++;
			/* Iterate over all the children and push on stack. */
			for (var i:Int=0 ; i<numChildren ; ++i) 
				processSubtree(SHA1Rand(rng, i));
		}

		public final def main (b0:Int, rng:SHA1Rand) {
			processSubtree(rng, b0);
			Console.OUT.println(nodesCounter+" nodes. ");
			return nodesCounter;
		}
	}
	/*
	static class ImplicitStealBinomialState {
		// params that define the tree
		val q:Long, m:Int, k:Int;

		var nodesCounter:UInt = 0;
		public def this (q:Long, m:Int, k:Int) {
			this.q = q; this.m = m; this.k=k;
		}

		public final def processSubtree (st:PLH, rng:SHA1Rand) {
			processSubtree(rng, (rng() < q) ? m : 0);
		}
		public final def processSubtree (st: PLH, rng:SHA1Rand, numChildren:Int) {
			offer 1; 
			// Iterate over all the children and push on stack. 
			for (var i:Int=0 ; i<numChildren ; ++i) 
				@global async 
				   st().processSubtree(st, SHA1Rand(rng, i));
		}

		public final def main (st: PLH, b0:Int, rng:SHA1Rand) {
			val count = finish(Int.+) { processSubtree(st, rng, b0) };
			Console.OUT.println(nodesCounter+" nodes. ");
			return nodesCounter;
		}
	}
	*/
	static final class BinomialState {

		const STATE_PLACE_ZERO = 0; // the first place does not use a state machine, use this value as placeholder
		const STATE_STEALING = 1; // actively stealing work from other places
		const STATE_ARRESTED = 2; // no-longer stealing but still alive and could potentially steal again
		const STATE_DEATH_ROW = 3; // will soon be dead, will never steal again

		// places > 0 start off life stealing
		var state:Int = here == Place.FIRST_PLACE ? STATE_PLACE_ZERO : STATE_STEALING;

		val stack = new Stack[SHA1Rand]();

		// params that define the tree
		val q:Long, m:Int, k:Int;
		var nodesCounter:UInt = 0;
		var stealsAttempted:UInt = 0;
		var stealsPerpetrated:UInt = 0;
		var stealsReceived:UInt = 0;
		var stealsSuffered:UInt = 0;
		var nodesGiven:UInt = 0;
		var nodesReceived:UInt = 0;
		val myRandom = new Random();
		public def this (q:Long, m:Int, k:Int) {
			this.q = q; this.m = m; this.k=k;
		}

		def processSubtree (rng:SHA1Rand) {
			processSubtree(rng, (rng() < q) ? m : 0);
		}
		def processSubtree (rng:SHA1Rand, numChildren:Int) {
			nodesCounter++;
			/* Iterate over all the children and push on stack. */
			for (var i:Int=0 ; i<numChildren ; ++i) 
				stack.push(SHA1Rand(rng, i));
		}

	    def processStack() {
		var count:Int=0;
		while (stack.size() > 0) {
		    processSubtree(stack.pop());
		    if (count++ % 200 == 0) 
			Runtime.probe();
		}
	    }
		
	    def pop(k:Int) = ValRail.make[SHA1Rand](k, (int)=> stack.pop());

	    def trySteal () : ValRail[SHA1Rand] {
		stealsReceived++;
		val length = stack.size();
		val numSteals = 
		    (k > 0 ? (k < length ?  k : (k/2 < length ? k/2 :0))
		     : length/2);
		if (length <= 2 || numSteals==0) {
		    return null;
		}
		stealsSuffered++;
		nodesGiven += numSteals;
		return pop(numSteals);
	    }
		
	    def attemptSteal(st:PLH) {
		val P = Place.MAX_PLACES;
		val start = myRandom.nextInt(P);
		for (var pi:Int=0 ; pi <P ; ++pi) {
		    val p = Place((start+pi)%P);
		    if (p==here) continue;
		    stealsAttempted++;
		    val steal_result = at (p) st().trySteal();
		    if (steal_result!=null) {
			stealsPerpetrated++;
			nodesReceived += steal_result.length();
			for (r in steal_result) {
			    processSubtree(r);
			}
			return true;
		    }
		}
		return false;
	    }

	    def nonHomeMain (st:PLH) {
		while (state != STATE_DEATH_ROW) {
		    while (state == STATE_STEALING) {
			attemptSteal(st);
			Runtime.probe(); // have to check that we've not been arrested
			processStack();
		    }
		    // We are not in STATE_STEALING.
		    // So we must have processed a message that forced us into 
		    // STATE_ARRESTED. Keep processing messages until you you 
		    // get the killer message or a re-awakening message.
		    Runtime.probe(); // check that we've not been put on death row
		}
		// place > 0 now exits
	    }	
	    
	    def main (st:PLH, b0:Int, rng:SHA1Rand) {
		val P=Place.MAX_PLACES;
		finish {
		    for (var pi:Int=1 ; pi<P ; ++pi) 
			async (Place(pi)) 
			    st().nonHomeMain(st);

		    // Initialize the work.
		    processSubtree(rng, b0);

		    STEAL_LOOP:
		    while (true) {
			processStack();
			// Place 0 ran out of work *BUT* there may be work elsewhere that was stolen, 
			// so try to steal some back
			if (attemptSteal(st)) 
			    continue STEAL_LOOP;

			// no work, suspect global quiescence
			// the rest of this loop body is relatively slow
			// but should be executed rarely.
			// ask everyone to stop stealing (synchronous)
			for (var pi:Int=1 ; pi<P ; ++pi) {
			    at (Place(pi)) {
				val this_ = st();
				assert this_.state==STATE_STEALING;
				//  if (!this_.working)
				this_.state = STATE_ARRESTED;
			    }
			}
			// check noone has any work (synchronous)
			for (var pi:Int=1 ; pi<P ; ++pi) {
			    val p = Place(pi);
			    if (at (p) st().state != STATE_ARRESTED) {
				// Discovered work. Restart everyone.
				for (var pi2:Int=1 ; pi2<P ; ++pi2) {
				    val p2 = Place(pi2);
				    at (p2) {
					st().state = STATE_STEALING;
				    }
				}
				continue STEAL_LOOP;
			    }
			}
			for (var pi:Int=1 ; pi<P ; ++pi) {
			    val p = Place(pi);
			    at (p) {
				val this_ = st();
				assert this_.state == STATE_ARRESTED;
				this_.state = STATE_DEATH_ROW;
			    }
			}
			break;
		    } // STEAL_LOOP
		} // finish
	    }
	}

    static def stats(st:PlaceLocalHandle[BinomialState], time:Long, verbose:Boolean) {
	val P = Place.MAX_PLACES;
	var nodeSum_:Int=0;
	var stolenSum_:Int=0;
	var steals_:Int=0;
	for ((i) in 0..P-1) {
	    nodeSum_ += at (Place(i)) st().nodesCounter;
	    stolenSum_ += at (Place(i)) st().nodesReceived;
	    steals_ += at (Place(i)) st().stealsPerpetrated;
	}
	val nodeSum = nodeSum_;
	val stolenSum = stolenSum_;
	val steals = steals_;
	val idealRatio = 1.0/P;
	if (verbose)
	for ((i) in 0..P-1) at (Place(i)) {
	    val there = here;
	    val nodes = st().nodesCounter;
	    val sa = st().stealsAttempted;
	    val ss = st().stealsSuffered;
	    val sr = st().stealsReceived;
	    val sp = st().stealsPerpetrated;
	    val pc = sa==0U ? "NaN" : "" + ((100U*sp)/sa);
	    val pr = sr==0U ? "NaN" : "" + ((100U*ss)/sr);
	    val nr = st().nodesReceived;
	    val ns = st().nodesGiven;
	    Console.OUT.println(there+": processed " + nodes + " nodes.");
	    val ratio = (1.0*nodes)/nodeSum;
	    val ratioS = (""+ratio).substring(0,6);
	    val imbalance = (100.0*(ratio-idealRatio))/idealRatio;
	    val imbalanceS = (""+ imbalance).substring(0,6);
	    Console.OUT.println("\t " + ratioS + " ratio, "  
				+ imbalanceS + "% balance.");
	    Console.OUT.println("\t" + sp+"/"+sa+"="
				+ pc +"% successful steals, received " 
				+ nr + " nodes.");
	    Console.OUT.println("\t" + ss+"/"+sr+"="
				+ pr + "% suffered, gave " 
				+ ns + " nodes.");
	}
	Console.OUT.println("Overhead = " + stolenSum + " nodes stolen."); 
	Console.OUT.println("\t" + ((stolenSum*1.0)/steals) + " nodes stolen per attempt"); 
	Console.OUT.println("Performance = "+nodeSum+"/"+(time/1E9)+"="+ (nodeSum/(time/1E3)) + "M nodes/s");

    }
	
    public static def main (args : Rail[String]!) {
	try {
	    val opts = 
		new OptionsParser(args, 
				  null,
				  [Option("t", "", "Tree type 0: BIN, 1: GEO, 2: HYBRID"),
				   
				   Option("b", "", "Root branching factor"),
				   Option("r", "", "Root seed (0 <= r <= 2^31"),
				   
				   Option("a", "", "Tree shape function"),
				   Option("d", "", "Tree depth"),
				   Option("s", "", "Sequential"),
				   Option("q", "", "BIN: probability of a non-leaf node"),
				   Option("m", "", "BIN: number of children for non-leaf node"),
				   
				   Option("f", "", "Hybrid switch-over depth "),
				   
				   Option("k", "", "Number of items to steal; default 0. If 0, steal half. "),
				   Option("v", "", "Verbose, default 0 (no)."),
				   
				   Option("D", "", "Depth (performance tweak, default 5)")]);
	    
	    val tree_type:Int = opts ("-t", 0);
	    
	    val b0 = opts ("-b", 4);
	    val seq = opts("-s", 0);
	    val r:Int = opts ("-r", 0);
	    val verbose = opts("-v",0)==1;

	    // geometric options
	    val geo_tree_shape_fn:Int = opts ("-a", 0);
	    val geo_tree_depth:Int = opts ("-d", 6);

	    // binomial options
	    val q:Double = opts ("-q", 15.0/64.0);
	    val mf:Int = opts ("-m", 4);
	    val k:Int = opts ("-k", 0);

	    // hybrid options
	    val geo_to_bin_shift_depth_ratio:Double = opts ("-f", 0.5);

	    Console.OUT.println("--------");
	    Console.OUT.println("Places="+Place.MAX_PLACES);
	    Console.OUT.println("b0=" + b0 +
				"   r=" + r +
				"   m=" + mf +
				"   s=" + seq +
				"   q=" + q);

	    val qq = (q*NORMALIZER) as Long;

	    if (seq != 0) {
		var time:Long = System.nanoTime();
		val nodes = new SeqBinomialState(qq, mf).main(b0, SHA1Rand(r));
		time = System.nanoTime() - time;
		Console.OUT.println("Performance = "+nodes+"/"+(time/1E9)+"="+ (nodes/(time/1E3)) + "M nodes/s");
	    } else {
		val st = PlaceLocalHandle.make[BinomialState](Dist.makeUnique(), 
							      ()=>new BinomialState(qq, mf,k));
		var time:Long = System.nanoTime();
		st().main(st, b0, SHA1Rand(r));
		time = System.nanoTime() - time;
		stats(st, time, verbose);
	    }
	    Console.OUT.println("--------");
	    
	} catch (e:Throwable) {
	    e.printStackTrace(Console.ERR);
	}
    }
}

// vim: ts=2:sw=2:et
