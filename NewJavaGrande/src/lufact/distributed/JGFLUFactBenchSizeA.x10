/**************************************************************************
*                                                                         *
*             Java Grande Forum Benchmark Suite - Version 2.0             *
*                                                                         *
*                            produced by                                  *
*                                                                         *
*                  Java Grande Benchmarking Project                       *
*                                                                         *
*                                at                                       *
*                                                                         *
*                Edinburgh Parallel Computing Centre                      *
*                                                                         *
*                email: epcc-javagrande@epcc.ed.ac.uk                     *
*                                                                         *
*                                                                         *
*      This version copyright (c) The University of Edinburgh, 1999.      *
*                         All rights reserved.                            *
*                                                                         *
**************************************************************************/
package lufact.distributed;

import lufact.distributed.lufact.*;
import jgfutil.*;
import harness.x10Test;;

public class JGFLUFactBenchSizeA extends x10Test {

	public def run(): boolean {
		JGFInstrumentor.printHeader(2, 0);
		var lub: JGFLUFactBench = new JGFLUFactBench();
		lub.JGFrun(0);
		return true;
	}

	public static def main(var args: Rail[String]): void {
		new JGFLUFactBenchSizeA().execute();
	}
}
