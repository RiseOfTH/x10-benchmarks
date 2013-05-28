/*
 *
 * (C) Copyright IBM Corporation 2006
 *
 *  This file is part of X10 Test.
 *
 */
package montecarlo.serial.montecarlo;
import x10.compiler.*;

/**
  * X10 port of montecarlo benchmark from Section 2 of Java Grande Forum Benchmark Suite (Version 2.0).
  *
  * @author Vivek Sarkar (vsarkar@us.ibm.com)
  */
public class Universal {

	//------------------------------------------------------------------------
	// Class variables.
	//------------------------------------------------------------------------

	/**
	 * Class variable, for whether to print debug messages.  This one is
	 * unique to this class, and can hence be set in the one place.
	 */
	private static val universal_debug: Boolean = true;
	//------------------------------------------------------------------------
	// Instance variables.
	//------------------------------------------------------------------------

	/**
	 * Variable, for whether to print debug messages.  This one can
	 * be set by subsequent child classes.
	 */
	private var debug: boolean;

	/**
	 * The prompt to write before any debug messages.
	 */
	private var prompt: String;

	//------------------------------------------------------------------------
	// Constructors.
	//------------------------------------------------------------------------

	/**
	 * Default constructor.
	 */
	public def this(): Universal = {
		super();
		this.debug = true;
		this.prompt = "Universal> ";
	}

	//------------------------------------------------------------------------
	// Methods.
	//------------------------------------------------------------------------
	//------------------------------------------------------------------------
	// Accessor methods for class AppDemo/Universal.
	// Generated by 'makeJavaAccessor.pl' script.  HWY.  20th January 1999.
	//------------------------------------------------------------------------

	/**
	 * Accessor method for private instance variable <code>debug</code>.
	 * @return Value of instance variable <code>debug</code>.
	 */
	public def get_DEBUG(): boolean = {
		return (this.debug);
	}

	/**
	 * set method for private instance variable <code>DEBUG</code>.
	 * @param DEBUG the value to set for the instance variable <code>DEBUG</code>.
	 */
	@NonEscaping final public def set_DEBUG(var debug: boolean): void = {
		this.debug = debug;
	}

	/**
	 * Accessor method for private instance variable <code>UNIVERSAL_DEBUG</code>.
	 * @return Value of instance variable <code>UNIVERSAL_DEBUG</code>.
	 */
	public def get_UNIVERSAL_DEBUG(): boolean = {
		return (this.universal_debug);
	}

	/**
	 * Set method for private instance variable <code>DEBUG</code>.
	 * @param UNIVERSAL_DEBUG the value to set for the instance
	 *        variable <code>UNIVERSAL_DEBUG</code>.
	 */
	public def set_UNIVERSAL_DEBUG(var UNIVERSAL_DEBUG: boolean): void = {
		this.universal_debug = UNIVERSAL_DEBUG;
	}

	/**
	 * Accessor method for private instance variable <code>prompt</code>.
	 * @return Value of instance variable <code>prompt</code>.
	 */
	public def get_prompt(): String = {
		return (this.prompt);
	}

	/**
	 * Set method for private instance variable <code>prompt</code>.
	 * @param prompt the value to set for the instance variable <code>prompt</code>.
	 */
	@NonEscaping final public def set_prompt(var prompt: String): void = {
		this.prompt = prompt;
	}

	//------------------------------------------------------------------------

	/**
	 * Used to print debug messages.
	 *
	 * @param s The debug message to print out, to PrintStream "out".
	 */
	public def dbgPrintln(var s: String): void = {
		if (debug || universal_debug) {
			Console.OUT.println("DBG "+prompt+s);
		}
	}

	/**
	 * Used to print debug messages.
	 *
	 * @param s The debug message to print out, to PrintStream "out".
	 */
	public def dbgPrint(var s: String): void = {
		if (debug || universal_debug) {
			Console.OUT.print("DBG "+prompt+s);
		}
	}

	/**
	 * Used to print error messages.
	 *
	 * @param s The error message to print out, to PrintStream "err".
	 */
	public def errPrintln(var s: String): void = {
		Console.ERR.println(prompt+s);
	}

	/**
	 * Used to print error messages.
	 *
	 * @param s The error message to print out, to PrintStream "err".
	 */
	public def errPrint(var s: String): void = {
		Console.ERR.print(prompt+s);
	}
}
