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
public class Covariance {

  var _PB_M : Long;
  var _PB_N : Long;  

  def setPBs(m : Long, n : Long) {
    _PB_M = m; 
    _PB_N = n; 
  }
  def init_array(m : Long,
  n : Long,
  		 float_n : Rail[Double],
  		 data : Array_2[Double])
  {
  
    float_n(0) = 1.2;
  
    for (var i : Long = 0; i < m; i++)
      for (var j : Long = 0; j < n; j++)
        data(i,j) = ((i as Double) *j) / m;
  }  /* DCE code. Must scan the entire live-out data.
     Can be used also to check the correctness of the output. */
  def print_array(m : Long,
  		 symmat : Array_2[Double])
  
  {
    for (var i : Long = 0; i < m; i++)
      for (var j : Long = 0; j < m; j++) {
        Console.ERR.printf("%0.2lf ", symmat(i,j));
        if ((i * m + j) % 20 == 0) Console.ERR.printf("\n");
      }
    Console.ERR.printf("\n");
  }  /* Main computational kernel. The whole function will be timed,
     including the call and return. */
    def kernel_covariance(m : long, n : long, float_n : double, data : Array_2[double], symmat : Array_2[double], mean : Rail[double])  {
      {
            var i : long;
            var j : long;
            var j1 : long;
            var j2 : long;
            {
                var c3 : long;
                var c1 : long;
                var c2 : long;
                if ((m >= 1)) {
                    {
                        Foreach.block(0,(m + -1),(var c1 : long) => {
                            var c3 : long;
                            var c2 : long;
                            for (c2 = c1; (c2 <= (m + -1)); c2++) {
                                symmat(c1,c2) = 0.0;
                            }
                        }
);
                    }
                    {
                        Foreach.block(0,(m + -1),(var c1 : long) => {
                            var c3 : long;
                            var c2 : long;
                            mean(c1) = 0.0;
                        }
);
                    }
                    if ((n >= 1)) {
                        {
                            Foreach.block(0,(m + -1),(var c1 : long) => {
                                var c3 : long;
                                var c2 : long;
                                for (c2 = 0; (c2 <= (n + -1)); c2++) {
                                    mean(c1) += data(c2,c1);
                                }
                            }
);
                        }
                    }
                    {
                        Foreach.block(0,(m + -1),(var c1 : long) => {
                            var c3 : long;
                            var c2 : long;
                            mean(c1) /= float_n;
                        }
);
                    }
                    {
                        Foreach.block(0,(n + -1),(var c1 : long) => {
                            var c3 : long;
                            var c2 : long;
                            for (c2 = 0; (c2 <= (m + -1)); c2++) {
                                data(c1,c2) -= mean(c2);
                            }
                        }
);
                    }
                    if ((n >= 1)) {
                        {
                            Foreach.block(0,(m + -1),(var c1 : long) => {
                                var c3 : long;
                                var c2 : long;
                                for (c2 = c1; (c2 <= (m + -1)); c2++) {
                                    for (c3 = 0; (c3 <= (n + -1)); c3++) {
                                        symmat(c1,c2) += data(c3,c1) * data(c3,c2);
                                    }
                                }
                            }
);
                        }
                    }
                    {
                        Foreach.block(0,(m + -1),(var c1 : long) => {
                            var c3 : long;
                            var c2 : long;
                            for (c2 = c1; (c2 <= (m + -1)); c2++) {
                                symmat(c2,c1) = symmat(c1,c2);
                            }
                        }
);
                    }
                }
            }
        }
    }  

  public static def main(args : Rail[String])
  {
    var M : Long = 0;
    var N : Long = 0;
    
    @Ifdef("EXTRALARGE_DATASET") {
        M = 4000;
        N = 4000;
    }
    @Ifdef("STANDARD_DATASET") {
        M = 1000;
        N = 1000;
    }
    @Ifdef("MINI_DATASET") {
        M = 32;
        N = 32;
    }
    @Ifdef("SMALL_DATASET") {
        M = 500;
        N = 500;
    }
    @Ifdef("LARGE_DATASET") {
        M = 4000;
        N = 4000;
    }
    
    val covariance = new Covariance();
    /* Retrieve problem size. */
    var n  : Long= N;
    var m  : Long= M;
  
    covariance.setPBs(m, n);
    /* Variable declaration/allocation. */
    val float_n = new Rail[Double](1);
    val data = new Array_2[Double](m,n);

    val symmat = new Array_2[Double](m,m);

    val mean = new Rail[Double](m);  
    /* Initialize array(s). */
    covariance.init_array (m, n, float_n, data);
  
    /* Start timer. */
    val t1 = System.currentTimeMillis();
  
    /* Run kernel. */
    covariance.kernel_covariance (m, n, float_n(0),
  		     data,
  		     symmat,
  		     mean);
  
    /* Stop and prvar timer : Long. */
    val t2 = System.currentTimeMillis();
    Console.OUT.printf("Elapsed time= " + (t2 - t1) + " (ms)");
    // covariance.print_array(m, symmat);
  
    /* Prevent dead-code elimination. All live-out data must be printed
       by the function call in argument. */
  
    /* Be clean. */
  
  }
}
