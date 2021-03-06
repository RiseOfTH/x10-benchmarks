/*
 *
 * (C) Copyright IBM Corporation 2006
 *
 *  This file is part of X10 Test.
 *
 */
package series.parallel.series;

import jgfutil.*;;

//This is the Thread
public class SeriesRunner {

	var id: int;
	var testArray: Array[double];
	var array_rows: int;
	var nthreads: int;

	public def this(var id: int, var p: int, var rows: int, var a: Array[double]): SeriesRunner = {
		this.id = id;
		this.nthreads = p;
		this.testArray = a;
		this.array_rows = rows;
	}

	public def run(): void = {
		var omega: double;       // Fundamental frequency.
		var ilow: int;
		var iupper: int;
		var slice: int;

		//int array_rows = SeriesTest.array_rows;

		// Calculate the fourier series. Begin by calculating A[0].

		if (id == 0) {
			testArray(0, 0) = TrapezoidIntegrate(0.0 as double, //Lower bound.
					2.0 as double,            // Upper bound.
					1000,                    // # of steps.
					0.0 as double,            // No omega*n needed.
					0) / 2.0 as double;       // 0 = term A[0].
		}

		// Calculate the fundamental frequency.
		// (2 * pi) / period...and since the period
		// is 2, omega is simply pi.

		omega = 3.1415926535897932 as double;

		slice = (array_rows + nthreads-1)/nthreads;

		ilow = id*slice;
		if (id == 0) ilow = id*slice+1;
		iupper = (id+1)*slice;
		if (iupper > array_rows) iupper = array_rows;

		for (var i: int = ilow; i < iupper; i++)
		{
			// Calculate A[i] terms. Note, once again, that we
			// can ignore the 2/period term outside the integral
			// since the period is 2 and the term cancels itself
			// out.

			testArray(0, i) = TrapezoidIntegrate(0.0 as double,
					2.0 as double,
					1000,
					omega * i as double,
					1);                       // 1 = cosine term.

			// Calculate the B[i] terms.

			testArray(1, i) = TrapezoidIntegrate(0.0 as double,
					2.0 as double,
					1000,
					omega * i as double,
					2);                       // 2 = sine term.
		}
	}

	/**
	 * TrapezoidIntegrate.
	 *
	 * Perform a simple trapezoid integration on the function (x+1)**x.
	 * x0,x1 set the lower and upper bounds of the integration.
	 * nsteps indicates # of trapezoidal sections.
	 * omegan is the fundamental frequency times the series member #.
	 * select = 0 for the A[0] term, 1 for cosine terms, and 2 for
	 * sine terms. Returns the value.
	 */
	private def TrapezoidIntegrate(var x0: double, var x1: double, var nsteps: int, var omegan: double, var select: int): double = {
		var x: double;               // Independent variable.
		var dx: double;              // Step size.
		var rvalue: double;          // Return value.

		// Initialize independent variable.

		x = x0;

		// Calculate stepsize.

		dx = (x1 - x0) / nsteps as double;

		// Initialize the return value.

		rvalue = thefunction(x0, omegan, select) / 2.0 as double;

		// Compute the other terms of the integral.

		if (nsteps != 1)
		{
			--nsteps;               // Already done 1 step.
			while (--nsteps > 0)
			{
				x += dx;
				rvalue += thefunction(x, omegan, select);
			}
		}

		// Finish computation.

		rvalue = (rvalue + thefunction(x1, omegan, select) / 2.0) * dx;
		return (rvalue);
	}

	/**
	 * thefunction.
	 *
	 * This routine selects the function to be used in the Trapezoid
	 * integration. x is the independent variable, omegan is omega * n,
	 * and select chooses which of the sine/cosine functions
	 * are used. Note the special case for select = 0.
	 */
	private def thefunction(var x: double, var omegan: double, var select: int): double = {
		// Use select to pick which function we call.

		switch (select)
		{
			case 0: return (Math.pow(x+1.0 as double, x));
			case 1: return (Math.pow(x+1.0 as double, x) * Math.cos(omegan*x));
			case 2: return (Math.pow(x+1.0 as double, x) * Math.sin(omegan*x));
		}

		// We should never reach this point, but the following
		// keeps compilers from issuing a warning message.

		return (0.0);
	}
}
