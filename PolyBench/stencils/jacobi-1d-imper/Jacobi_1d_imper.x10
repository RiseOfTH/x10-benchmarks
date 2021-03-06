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
public class Jacobi_1d_imper {

  var _PB_TSTEPS : Long;
  var _PB_N : Long;

  def setPBs(tsteps : Long, n : Long) {
    _PB_TSTEPS = tsteps; 
    _PB_N = n; 
  }
  def init_array(n : Long,
  		 A : Rail[Double],
  		 B : Rail[Double])
  {
    for (var i : Long = 0; i < n; i++)
        {
  	A(i) = ((i as Double)+ 2) / n;
  	B(i) = ((i as Double)+ 3) / n;
        }
  }  /* DCE code. Must scan the entire live-out data.
     Can be used also to check the correctness of the output. */
  def print_array(n : Long,
  		 A : Rail[Double])
  
  {
    for (var i : Long = 0; i < n; i++)
      {
        Console.ERR.printf("%0.2lf", A(i));
        if (i % 20 == 0) Console.ERR.printf("\n");
      }
    Console.ERR.printf("\n");
  }  /* Main computational kernel. The whole function will be timed,
     including the call and return. */
  def kernel_jacobi_1d_imper(tsteps : Long,
  			    n : Long,
  			    A : Rail[Double],
  			    B : Rail[Double])
  {
  // #pragma scop
    for (var t : Long = 0; t < tsteps; t++)
      {
        for (var i : Long = 1; i < n - 1; i++)
  	B(i) = 0.33333 * (A(i-1) + A(i) + A(i + 1));
        for (var j : Long = 1; j < n - 1; j++)
  	A(j) = B(j);
      }
  // #pragma endscop
  
  }  public static def main(args : Rail[String])
  {
    var TSTEPS : Long = 0;
    var N : Long = 0;
    
    @Ifdef("EXTRALARGE_DATASET") {
        TSTEPS = 1000;
        N = 1000000;
    }
    @Ifdef("STANDARD_DATASET") {
        TSTEPS = 100;
        N = 10000;
    }
    @Ifdef("MINI_DATASET") {
        TSTEPS = 2;
        N = 500;
    }
    @Ifdef("SMALL_DATASET") {
        TSTEPS = 10;
        N = 1000;
    }
    @Ifdef("LARGE_DATASET") {
        TSTEPS = 10000;
        N = 100000;
    }
    
    val jacobi_1d_imper = new Jacobi_1d_imper();
    /* Retrieve problem size. */
    var n  : Long= N;
    var tsteps  : Long= TSTEPS;
  
    jacobi_1d_imper.setPBs(tsteps, n);
    /* Variable declaration/allocation. */
    val A = new Rail[Double](n);

    val B = new Rail[Double](n);  
    /* Initialize array(s). */
    jacobi_1d_imper.init_array (n, A, B);
  
    /* Start timer. */
    val t1 = System.currentTimeMillis();
  
    /* Run kernel. */
    jacobi_1d_imper.kernel_jacobi_1d_imper (tsteps, n, A, B);
  
    /* Stop and prvar timer : Long. */
    val t2 = System.currentTimeMillis();
    Console.OUT.printf("Elapsed time= " + (t2 - t1) + " (ms)");
    // jacobi_1d_imper.print_array(n, A);
  
    /* Prevent dead-code elimination. All live-out data must be printed
       by the function call in argument. */
  
    /* Be clean. */
  
  }
}
