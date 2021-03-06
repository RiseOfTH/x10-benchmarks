/*
 *
 * (C) Copyright IBM Corporation 2006
 *
 *  This file is part of X10 Test.
 *
 */
package montecarlo.parallel;

import montecarlo.parallel.montecarlo.*;
import jgfutil.*;
import harness.x10Test;

/**
 * X10 port of montecarlo benchmark from Section 2 of Java Grande Forum Benchmark Suite (Version 2.0).
 *
 * Single-place, multi-threaded version.
 * @author vj
 */
public class JGFMonteCarloBenchSizeA extends x10Test {

	public def run(): boolean {
		JGFInstrumentor.printHeader(3, 0);
		var mc: JGFMonteCarloBench = new JGFMonteCarloBench();
		mc.JGFrun(0);
		return true;
	}

	public static def main(var args: Rail[String]): void {
		new JGFMonteCarloBenchSizeA().execute();
	}
}
