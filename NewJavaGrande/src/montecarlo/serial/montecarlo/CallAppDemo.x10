/*
 *
 * (C) Copyright IBM Corporation 2006
 *
 *  This file is part of X10 Test.
 *
 */
package montecarlo.serial.montecarlo;

/**
 * X10 port of montecarlo benchmark from Section 2 of Java Grande Forum Benchmark Suite (Version 2.0)
 *
 * @author Vivek Sarkar (vsarkar@us.ibm.com)
 *
 * Porting issues identified:
 *
 * 1) Add nullable type constructor to declaration of ap.
 *    Note that no non-nullable conversion is needed prior to method invocation on ap.
 */
public class CallAppDemo {
	protected var size: int;
	// protected int[] datasizes = { 10000, 60000 };
	protected var datasizes: Array[int] = [ 1000, 60000 ];
	var input: Array[int] = new Array[int](2);
	var ap: AppDemo = null;

	public def initialise(): void {
		input(0) = 1000;
		input(1) = datasizes(size);

		var dirName: String = "Data";
		var filename: String = "hitData";
		ap = new AppDemo(dirName, filename, (input(0)), (input(1)));
		ap.initSerial();
	}

	public def runiters(): void {
		ap.runSerial();
	}

	public def presults(): void {
		ap.processSerial();
	}
}
