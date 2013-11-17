package bc.lib;

import x10.compiler.*;
import x10.util.Option;
import x10.util.OptionsParser;
import x10.util.Random;

import bc.Rmat;
import glb.GLB;

public final class BCG {
    public static def main(args:Rail[String]):void {
        val cmdLineParams = new OptionsParser(args, new Rail[Option](0L), [
                                                                           Option("s", "", "Seed for the random number"),
                                                                           Option("n", "", "Number of vertices = 2^n"),
                                                                           Option("a", "", "Probability a"),
                                                                           Option("b", "", "Probability b"),
                                                                           Option("c", "", "Probability c"),
                                                                           Option("d", "", "Probability d"),
                                                                           Option("p", "", "Permutation"),
                                                                           Option("g", "", "Number of nodes to process before probing. Default 200."),
                                                                           Option("w", "", "Number of thieves to send out. Default 1."),
                                                                           Option("l", "", "Base of the lifeline"),
                                                                           Option("m", "", "Max potential victims"),
                                                                           Option("v", "", "Verbose")]);

        val seed:Long = cmdLineParams("-s", 2);
        val n:Int = cmdLineParams("-n", 2n);
        val a:Double = cmdLineParams("-a", 0.55);
        val b:Double = cmdLineParams("-b", 0.1);
        val c:Double = cmdLineParams("-c", 0.1);
        val d:Double = cmdLineParams("-d", 0.25);
        val permute:Int = cmdLineParams("-p", 1n); // on by default
        val verbose:Int = cmdLineParams("-v", 0n); // off by default

        val g = cmdLineParams("-g", 511n);
        val l = cmdLineParams("-l", 32n);
        val m = cmdLineParams("-m", 1024n);

        val P = Place.MAX_PLACES;

        var z0:Int = 1n;
        var zz:Int = l;
        while (zz < P) {
            z0++;
            zz *= l;
        }
        val z = z0;

        val w = cmdLineParams("-w", z);

        Console.OUT.println("places=" + P +
                "   w=" + w +
                        "   g=" + g +
                                "   l=" + l + 
                                        "   m=" + m + 
                                                "   z=" + z);

        Console.OUT.println("Running BC with the following parameters:");
        Console.OUT.println("seed = " + seed);
        Console.OUT.println("N = " + (1<<n));
        Console.OUT.println("a = " + a);
        Console.OUT.println("b = " + b);
        Console.OUT.println("c = " + c);
        Console.OUT.println("d = " + d);
        Console.OUT.println("places = " + P);

        var time:Long = System.nanoTime();
        val init = ()=>{ return new Queue(Rmat(seed, n, a, b, c, d), permute); };
        val glb = new GLB[Queue](init, g, w, l, z, m, false);
        val setupTime = (System.nanoTime()-time)/1e9;

        
        Console.OUT.println("Starting...");
        time = System.nanoTime();
        glb.runParallel();
        val procTime = (System.nanoTime()-time)/1e9;
        Console.OUT.println("Finished.");

        PlaceGroup.WORLD.broadcastFlat(()=>{
            (glb.taskQueue()).allreduce();
        });
        
        if(verbose > 0) {
            PlaceGroup.WORLD.broadcastFlat(()=>{
                Console.OUT.println("[" + here.id + "]"
                        + " Time = " + (glb.taskQueue()).accTime
                        + " Count = " + (glb.taskQueue()).count);
            });
        }

        if(verbose > 2) (glb.taskQueue()).printBetweennessMap();

        val bc = glb.taskQueue();

        glb.stats(verbose > 1);

        Console.OUT.println("Places: " + P + " N: " + bc.N + "  Setup: " + setupTime + "s  Processing: " + procTime + "s");
    }
}