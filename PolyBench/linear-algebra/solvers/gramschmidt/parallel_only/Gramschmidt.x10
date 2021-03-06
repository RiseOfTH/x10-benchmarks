/*
 *  This file is part of the X10 project (http://x10-lang.org).
 *
 *  This file is licensed to You under the Eclipse Public License (EPL);
 *  You may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *      http://www.opensource.org/licenses/eclipse-1.0.php
 *
 *  (C) Copyright IBM Corporation 2015.
 * 
 *
 *  @author HUANG RUOCHEN (hrc706@gmail.com)
 */

import x10.compiler.Ifdef;
import x10.array.Array_2;
import x10.array.Array_3;
import x10.compiler.Foreach;
public class Gramschmidt {

  var _PB_NI : Long;
  var _PB_NJ : Long;

  def setPBs(ni : Long, nj : Long) {
    _PB_NI = ni; 
    _PB_NJ = nj; 
  }
  def init_array(ni : Long, nj : Long,
  		A : Array_2[Double],
  		R : Array_2[Double],
  		Q : Array_2[Double])
  {
    for (var i : Long = 0; i < ni; i++)
      for (var j : Long = 0; j < nj; j++) {
        A(i,j) = ((i as Double) *j) / ni;
        Q(i,j) = ((i as Double)*(j+1)) / nj;
      }
    for (var i : Long = 0; i < nj; i++)
      for (var j : Long = 0; j < nj; j++)
        R(i,j) = ((i as Double)*(j+2)) / nj;
  }  /* DCE code. Must scan the entire live-out data.
     Can be used also to check the correctness of the output. */
  def print_array(ni : Long, nj : Long,
  		 A : Array_2[Double],
  		 R : Array_2[Double],
  		 Q : Array_2[Double])
  {
    for (var i : Long = 0; i < ni; i++)
      for (var j : Long = 0; j < nj; j++) {
  	Console.ERR.printf("%0.2lf ", A(i,j));
  	if (i % 20 == 0) Console.ERR.printf("\n");
      }
    Console.ERR.printf("\n");
    for (var i : Long = 0; i < nj; i++)
      for (var j : Long = 0; j < nj; j++) {
  	Console.ERR.printf("%0.2lf ", R(i,j));
  	if (i % 20 == 0) Console.ERR.printf("\n");
      }
    Console.ERR.printf("\n");
    for (var i : Long = 0; i < ni; i++)
      for (var j : Long = 0; j < nj; j++) {
  	Console.ERR.printf("%0.2lf ", Q(i,j));
  	if (i % 20 == 0) Console.ERR.printf("\n");
      }
    Console.ERR.printf("\n");
  }  /* Main computational kernel. The whole function will be timed,
     including the call and return. */
    def kernel_gramschmidt(ni : long, nj : long, A : Array_2[double], R : Array_2[double], Q : Array_2[double])  {
        {
            var nrm : double;
            for (var k : long = 0L; k < nj; k++) {
                {
                    var c1 : long;
                    nrm = (0L) as double;
                    for (c1 = 0; (c1 <= (ni + -1)); c1++) {
                        nrm += A(c1,k) * A(c1,k);
                    }
                }
                R(k,k) = x10.lang.Math.sqrt(nrm);
                {
                    var c4 : long;
                    var c1 : long;
                    {
                        val k_0 = k;
                        Foreach.block(0,(k_0 < (ni + -1) ? (k_0) as long : ((ni + -1)) as long),(var c1 : long) => {
                            var c4 : long;
                            Q(c1,k_0) = A(c1,k_0) / R(k_0,k_0);
                        }
);
                    }
                    {
                        val k_0 = k;
                        Foreach.block((k_0 + 1),(-1 < (nj + -1) ? (-1) as long : ((nj + -1)) as long),(var c1 : long) => {
                            var c4 : long;
                            R(k_0,c1) = (0L) as double;
                        }
);
                    }
                    {
                        val k_0 = k;
                        Foreach.block((0 > (k_0 + 1) ? (0) as long : ((k_0 + 1)) as long),((ni + -1) < (nj + -1) ? ((ni + -1)) as long : ((nj + -1)) as long),(var c1 : long) => {
                            var c4 : long;
                            Q(c1,k_0) = A(c1,k_0) / R(k_0,k_0);
                            R(k_0,c1) = (0L) as double;
                        }
);
                    }
                    {
                        val k_0 = k;
                        Foreach.block(((0 > nj ? (0) as long : (nj) as long) > (k_0 + 1) ? ((0 > nj ? (0) as long : (nj) as long)) as long : ((k_0 + 1)) as long),(ni + -1),(var c1 : long) => {
                            var c4 : long;
                            Q(c1,k_0) = A(c1,k_0) / R(k_0,k_0);
                        }
);
                    }
                    {
                        val k_0 = k;
                        Foreach.block(((0 > ni ? (0) as long : (ni) as long) > (k_0 + 1) ? ((0 > ni ? (0) as long : (ni) as long)) as long : ((k_0 + 1)) as long),(nj + -1),(var c1 : long) => {
                            var c4 : long;
                            R(k_0,c1) = (0L) as double;
                        }
);
                    }
                    if ((ni >= 1)) {
                        {
                            val k_0 = k;
                            Foreach.block((k_0 + 1),(nj + -1),(var c1 : long) => {
                                var c4 : long;
                                for (c4 = 0; (c4 <= (ni + -1)); c4++) {
                                    R(k_0,c1) += Q(c4,k_0) * A(c4,c1);
                                }
                                for (c4 = 0; (c4 <= (ni + -1)); c4++) {
                                    A(c4,c1) = A(c4,c1) - Q(c4,k_0) * R(k_0,c1);
                                }
                            }
);
                        }
                    }
                }
            }
        }
    }  public static def main(args : Rail[String])
  {
    var NI : Long = 0;
    var NJ : Long = 0;
    
    @Ifdef("EXTRALARGE_DATASET") {
        NI = 4000;
        NJ = 4000;
    }
    @Ifdef("STANDARD_DATASET") {
        NI = 512;
        NJ = 512;
    }
    @Ifdef("MINI_DATASET") {
        NI = 32;
        NJ = 32;
    }
    @Ifdef("SMALL_DATASET") {
        NI = 128;
        NJ = 128;
    }
    @Ifdef("LARGE_DATASET") {
        NI = 2000;
        NJ = 2000;
    }
    
    val gramschmidt = new Gramschmidt();
    /* Retrieve problem size. */
    var ni  : Long= NI;
    var nj  : Long= NJ;
  
    gramschmidt.setPBs(ni, nj);
    /* Variable declaration/allocation. */
    val A = new Array_2[Double](ni,nj);

    val R = new Array_2[Double](nj,nj);

    val Q = new Array_2[Double](ni,nj);    /* Initialize array(s). */
    gramschmidt.init_array (ni, nj,
  	      A,
  	      R,
  	      Q);
  
    /* Start timer. */
    val t1 = System.currentTimeMillis();
  
    /* Run kernel. */
    gramschmidt.kernel_gramschmidt (ni, nj,
  		      A,
  		      R,
  		      Q);
  
    /* Stop and prvar timer : Long. */
    val t2 = System.currentTimeMillis();
    Console.OUT.printf("Elapsed time= " + (t2 - t1) + " (ms)");
    // gramschmidt.print_array(ni, nj, A, R, Q);
  
    /* Prevent dead-code elimination. All live-out data must be printed
       by the function call in argument. */
  
    /* Be clean. */
  
  }
}
