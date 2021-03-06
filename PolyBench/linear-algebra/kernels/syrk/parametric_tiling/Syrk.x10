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
public class Syrk {

  var _PB_NI : Long;
  var _PB_NJ : Long;  

  def setPBs(ni : Long, nj : Long) {
    _PB_NI = ni; 
    _PB_NJ = nj; 
  }
  def init_array(ni : Long,
  nj : Long,
  		alpha : Rail[Double],
  		beta : Rail[Double],
  		C : Array_2[Double],
  		A : Array_2[Double])
  {
    alpha(0) = 32412;
    beta(0) = 2123;
    for (var i : Long = 0; i < ni; i++)
      for (var j : Long = 0; j < nj; j++)
        A(i,j) = ((i as Double) *j) / ni;
    for (var i : Long = 0; i < ni; i++)
      for (var j : Long = 0; j < ni; j++)
        C(i,j) = ((i as Double) *j) / ni;
  }  /* DCE code. Must scan the entire live-out data.
     Can be used also to check the correctness of the output. */
  def print_array(ni : Long,
  		 C : Array_2[Double])
  {
    for (var i : Long = 0; i < ni; i++)
      for (var j : Long = 0; j < ni; j++) {
  	Console.ERR.printf("%0.2lf ", C(i,j));
  	if ((i * ni + j) % 20 == 0) Console.ERR.printf("\n");
      }
    Console.ERR.printf("\n");
  }  /* Main computational kernel. The whole function will be timed,
     including the call and return. */
    def kernel_syrk(ni : long, nj : long, alpha : double, beta : double, C : Array_2[double], A : Array_2[double])  {
        var ___pace_tile_sizes : Rail[long] = new Rail[Long](3L);
        Pace_tiling_api.PACETileSizeVectorInit(___pace_tile_sizes,3,2);
        var c1t1 : long;
        var T1c3 : float = (___pace_tile_sizes(0L)) as float;
        var c3t1 : long;
        var T1c2 : float = (___pace_tile_sizes(1L)) as float;
        var T1c1 : float = (___pace_tile_sizes(2L)) as float;
        var c2t1 : long;
        var c2 : long;
        var c3 : long;
        var c1 : long;
        if ((ni >= 1)) {
            {
                var tmpLb : long;
                var tmpUb : long;
                tmpLb = (Math.round(((-1 + (1 / T1c1))) as double)) as long;
                tmpUb = (Math.round((((ni * (1 / T1c1)) + ((1 / T1c1) * -1))) as double)) as long;
                {
                    val T1c1_3 = T1c1;
                    val T1c2_2 = T1c2;
                    val tmpUb_1 = tmpUb;
                    val tmpLb_0 = tmpLb;
                    Foreach.block(tmpLb_0,tmpUb_1,(var c1t1 : long) => {
                        var c2t1 : long;
                        var c2 : long;
                        var c1 : long;
                        for (c2t1 = (Math.round(((-1 + (1 / T1c2_2))) as double)) as long; (c2t1 <= (Math.round((((ni * (1 / T1c2_2)) + ((1 / T1c2_2) * -1))) as double)) as long); ++c2t1) {
                            for (c1 = ((c1t1 * T1c1_3) > 0 ? ((c1t1 * T1c1_3)) as long : (0) as long); (c1 <= (((c1t1 * T1c1_3) + (T1c1_3 + -1)) < (ni + -1) ? (((c1t1 * T1c1_3) + (T1c1_3 + -1))) as long : ((ni + -1)) as long)); c1++) {
                                for (c2 = ((c2t1 * T1c2_2) > 0 ? ((c2t1 * T1c2_2)) as long : (0) as long); (c2 <= (((c2t1 * T1c2_2) + (T1c2_2 + -1)) < (ni + -1) ? (((c2t1 * T1c2_2) + (T1c2_2 + -1))) as long : ((ni + -1)) as long)); c2++) {
                                    C(c1,c2) *= beta;
                                }
                            }
                        }
                    }
);
                }
            }
            if ((nj >= 1)) {
                {
                    var tmpLb : long;
                    var tmpUb : long;
                    tmpLb = (Math.round(((-1 + (1 / T1c1))) as double)) as long;
                    tmpUb = (Math.round((((ni * (1 / T1c1)) + ((1 / T1c1) * -1))) as double)) as long;
                    {
                        val T1c1_4 = T1c1;
                        val T1c3_3 = T1c3;
                        val T1c2_2 = T1c2;
                        val tmpUb_1 = tmpUb;
                        val tmpLb_0 = tmpLb;
                        Foreach.block(tmpLb_0,tmpUb_1,(var c1t1 : long) => {
                            var c3t1 : long;
                            var c2t1 : long;
                            var c2 : long;
                            var c3 : long;
                            var c1 : long;
                            for (c2t1 = (Math.round(((-1 + (1 / T1c2_2))) as double)) as long; (c2t1 <= (Math.round((((ni * (1 / T1c2_2)) + ((1 / T1c2_2) * -1))) as double)) as long); ++c2t1) {
                                for (c3t1 = (Math.round(((-1 + (1 / T1c3_3))) as double)) as long; (c3t1 <= (Math.round((((nj * (1 / T1c3_3)) + ((1 / T1c3_3) * -1))) as double)) as long); ++c3t1) {
                                    for (c1 = ((c1t1 * T1c1_4) > 0 ? ((c1t1 * T1c1_4)) as long : (0) as long); (c1 <= (((c1t1 * T1c1_4) + (T1c1_4 + -1)) < (ni + -1) ? (((c1t1 * T1c1_4) + (T1c1_4 + -1))) as long : ((ni + -1)) as long)); c1++) {
                                        for (c2 = ((c2t1 * T1c2_2) > 0 ? ((c2t1 * T1c2_2)) as long : (0) as long); (c2 <= (((c2t1 * T1c2_2) + (T1c2_2 + -1)) < (ni + -1) ? (((c2t1 * T1c2_2) + (T1c2_2 + -1))) as long : ((ni + -1)) as long)); c2++) {
                                            for (c3 = ((c3t1 * T1c3_3) > 0 ? ((c3t1 * T1c3_3)) as long : (0) as long); (c3 <= (((c3t1 * T1c3_3) + (T1c3_3 + -1)) < (nj + -1) ? (((c3t1 * T1c3_3) + (T1c3_3 + -1))) as long : ((nj + -1)) as long)); c3++) {
                                                C(c1,c2) += alpha * A(c1,c3) * A(c2,c3);
                                            }
                                        }
                                    }
                                }
                            }
                        }
);
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
        NI = 1024;
        NJ = 1024;
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
    
    val syrk = new Syrk();
    /* Retrieve problem size. */
    var ni  : Long= NI;
    var nj  : Long= NJ;
  
    syrk.setPBs(ni, nj);
    /* Variable declaration/allocation. */
    val alpha = new Rail[Double](1);
    val beta = new Rail[Double](1);
    val C = new Array_2[Double](ni,ni);

    val A = new Array_2[Double](ni,nj);    /* Initialize array(s). */
    syrk.init_array (ni, nj, alpha, beta, C, A);
  
    /* Start timer. */
    val t1 = System.currentTimeMillis();
  
    /* Run kernel. */
    syrk.kernel_syrk (ni, nj, alpha(0), beta(0), C, A);
  
    /* Stop and prvar timer : Long. */
    val t2 = System.currentTimeMillis();
    Console.OUT.printf("Elapsed time= " + (t2 - t1) + " (ms)");
    // syrk.print_array(ni, C);
  
    /* Prevent dead-code elimination. All live-out data must be printed
       by the function call in argument. */
  
    /* Be clean. */
  
  }
}
