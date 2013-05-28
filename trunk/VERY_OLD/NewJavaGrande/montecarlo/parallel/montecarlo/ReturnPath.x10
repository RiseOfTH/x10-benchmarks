/*
 *
 * (C) Copyright IBM Corporation 2006
 *
 *  This file is part of X10 Test.
 *
 */
package montecarlo.parallel.montecarlo;

/**
 * X10 port of montecarlo benchmark from Section 2 of Java Grande Forum Benchmark Suite (Version 2.0).
 *
 * @author Vivek Sarkar (vsarkar@us.ibm.com)
 *
 * Porting issues identified:
 * 1) Variables/fields starting with an upper case letter have to be renamed if not final (debug)
 * 2) Remove Java package structure
 * 3) Comment out call to "super.dbgDumpFields()" which was being translated to "PathId.super.dbgdumpFields()"
 * 4) Add import x10.lang.* (may not be necessary for this class)
 * 5) No need to extend x10.lang.Object because PathId already does that.
 */
public class ReturnPath extends PathId {

	//------------------------------------------------------------------------
	// Class variables.
	//------------------------------------------------------------------------

	/**
	 * A class variable, for setting whether to print debug messages or not.
	 */
	public static val debug: boolean = true;

	/**
	 * Class variable, for defining the prompt to print in front of debug
	 * messages.
	 */
	protected static val prompt: String = "ReturnPath> ";

	/**
	 * Flag for indicating one of the return definitions, via:
	 *       u_i = \ln { \frac { S_i } { S_ { i-1 } } }
	 * corresponding to the instantaneous compounded return.
	 */
	public static val COMPOUNDED: int = 1;

	/**
	 * Flag for indicating one of the return definitions, via:
	 *       u_i = \frac { S_i - S_ { i-1 } } { S_i }
	 * corresponding to the instantaneous non-compounded return.
	 */
	public static val NONCOMPOUNDED: int = 2;

	//------------------------------------------------------------------------
	// Instance variables.
	//------------------------------------------------------------------------

	/**
	 * An instance variable, for storing the return values.
	 */
	private var pathValue: Array[double];

	/**
	 * The number of accepted values in the rate path.
	 */
	private var nPathValue: int = 0;

	/**
	 * Integer flag for indicating how the return was calculated.
	 */
	private var returnDefinition: int = 0;

	/**
	 * Value for the expected return rate.
	 */
	private var expectedReturnRate: double = Double.NaN;

	/**
	 * Value for the volatility, calculated from the return data.
	 */
	private var volatility: double = Double.NaN;

	/**
	 * Value for the volatility-squared, a more natural quantity
	 * to use for many of the calculations.
	 */
	private var volatility2: double = Double.NaN;

	/**
	 * Value for the mean of this return.
	 */
	private var mean: double = Double.NaN;

	/**
	 * Value for the variance of this return.
	 */
	private var variance: double = Double.NaN;

	//------------------------------------------------------------------------
	// Constructors.
	//------------------------------------------------------------------------

	/**
	 * Default constructor.
	 */
	public def this(): ReturnPath = {
		super();
		set_prompt(prompt);
		set_DEBUG(debug);
	}

	/**
	 * Another constructor.
	 *
	 * @param pathValue for creating a return path with a precomputed path
	 *                  value.  Indexed from 1 to <code>nPathArray-1</code>.
	 * @param nPathValue the number of accepted data points in the array.
	 * @param returnDefinition to tell this class how the return path values
	 *                         were computed.
	 */
	public def this(var pathValue: Array[double], var nPathValue: int, var returnDefinition: int): ReturnPath = {
		set_prompt(prompt);
		set_DEBUG(debug);
		this.pathValue = pathValue;
		this.nPathValue = nPathValue;
		this.returnDefinition = returnDefinition;
	}

	//------------------------------------------------------------------------
	// Methods.
	//------------------------------------------------------------------------
	//------------------------------------------------------------------------
	// Accessor methods for class ReturnPath.
	// Generated by 'makeJavaAccessor.pl' script.  HWY.  20th January 1999.
	//------------------------------------------------------------------------

	/**
	 * Accessor method for private instance variable <code>pathValue</code>.
	 * @return Value of instance variable <code>pathValue</code>.
	 * @exception DemoException thrown if instance variable <code>pathValue</code> is undefined.
	 */
	public def get_pathValue(): Array[double] = {
		// (VIVEK) The following test is no longer necessary because pathValue is not nullable
		// if (this.pathValue == null)
		// throw new DemoException("Variable pathValue is undefined!");
		return (this.pathValue);
	}

	/**
	 * Set method for private instance variable <code>pathValue</code>.
	 * @param pathValue the value to set for the instance variable <code>pathValue</code>.
	 */
	public def set_pathValue(var pathValue: Array[double]): void = {
		this.pathValue = pathValue;
	}

	/**
	 * Accessor method for private instance variable <code>nPathValue</code>.
	 * @return Value of instance variable <code>nPathValue</code>.
	 * @exception DemoException thrown if instance variable <code>nPathValue</code> is undefined.
	 */
	public def get_nPathValue(): int = {
		if (this.nPathValue == 0)
			throw new DemoException("Variable nPathValue is undefined!");
		return (this.nPathValue);
	}

	/**
	 * Set method for private instance variable <code>nPathValue</code>.
	 * @param nPathValue the value to set for the instance variable <code>nPathValue</code>.
	 */
	public def set_nPathValue(var nPathValue: int): void = {
		this.nPathValue = nPathValue;
	}

	/**
	 * Accessor method for private instance variable <code>returnDefinition</code>.
	 * @return Value of instance variable <code>returnDefinition</code>.
	 * @exception DemoException thrown if instance variable <code>returnDefinition</code> is undefined.
	 */
	public def get_returnDefinition(): int = {
		if (this.returnDefinition == 0)
			throw new DemoException("Variable returnDefinition is undefined!");
		return (this.returnDefinition);
	}

	/**
	 * Set method for private instance variable <code>returnDefinition</code>.
	 * @param returnDefinition the value to set for the instance variable <code>returnDefinition</code>.
	 */
	public def set_returnDefinition(var returnDefinition: int): void = {
		this.returnDefinition = returnDefinition;
	}

	/**
	 * Accessor method for private instance variable <code>expectedReturnRate</code>.
	 * @return Value of instance variable <code>expectedReturnRate</code>.
	 * @exception DemoException thrown if instance variable <code>expectedReturnRate</code> is undefined.
	 */
	public def get_expectedReturnRate(): double = {
		if (this.expectedReturnRate == Double.NaN)
			throw new DemoException("Variable expectedReturnRate is undefined!");
		return (this.expectedReturnRate);
	}

	/**
	 * Set method for private instance variable <code>expectedReturnRate</code>.
	 * @param expectedReturnRate the value to set for the instance variable <code>expectedReturnRate</code>.
	 */
	public def set_expectedReturnRate(var expectedReturnRate: double): void = {
		this.expectedReturnRate = expectedReturnRate;
	}

	/**
	 * Accessor method for private instance variable <code>volatility</code>.
	 * @return Value of instance variable <code>volatility</code>.
	 * @exception DemoException thrown if instance variable <code>volatility</code> is undefined.
	 */
	public def get_volatility(): double = {
		if (this.volatility == Double.NaN)
			throw new DemoException("Variable volatility is undefined!");
		return (this.volatility);
	}

	/**
	 * Set method for private instance variable <code>volatility</code>.
	 * @param volatility the value to set for the instance variable <code>volatility</code>.
	 */
	public def set_volatility(var volatility: double): void = {
		this.volatility = volatility;
	}

	/**
	 * Accessor method for private instance variable <code>volatility2</code>.
	 * @return Value of instance variable <code>volatility2</code>.
	 * @exception DemoException thrown if instance variable <code>volatility2</code> is undefined.
	 */
	public def get_volatility2(): double = {
		if (this.volatility2 == Double.NaN)
			throw new DemoException("Variable volatility2 is undefined!");
		return (this.volatility2);
	}

	/**
	 * Set method for private instance variable <code>volatility2</code>.
	 * @param volatility2 the value to set for the instance variable <code>volatility2</code>.
	 */
	public def set_volatility2(var volatility2: double): void = {
		this.volatility2 = volatility2;
	}

	/**
	 * Accessor method for private instance variable <code>mean</code>.
	 * @return Value of instance variable <code>mean</code>.
	 * @exception DemoException thrown if instance variable <code>mean</code> is undefined.
	 */
	public def get_mean(): double = {
		if (this.mean == Double.NaN)
			throw new DemoException("Variable mean is undefined!");
		return (this.mean);
	}

	/**
	 * Set method for private instance variable <code>mean</code>.
	 * @param mean the value to set for the instance variable <code>mean</code>.
	 */
	public def set_mean(var mean: double): void = {
		this.mean = mean;
	}

	/**
	 * Accessor method for private instance variable <code>variance</code>.
	 * @return Value of instance variable <code>variance</code>.
	 * @exception DemoException thrown if instance variable <code>variance</code> is undefined.
	 */
	public def get_variance(): double = {
		if (this.variance == Double.NaN)
			throw new DemoException("Variable variance is undefined!");
		return (this.variance);
	}

	/**
	 * Set method for private instance variable <code>variance</code>.
	 * @param variance the value to set for the instance variable <code>variance</code>.
	 */
	public def set_variance(var variance: double): void = {
		this.variance = variance;
	}

	//------------------------------------------------------------------------

	/**
	 * Method to calculate the expected return rate from the return data,
	 * using the relationship:
	 *    \mu = \frac { \bar { u } } { \Delta t } + \frac { \sigma^2 } { 2 }
	 *
	 * @exception DemoException thrown one tries to obtain an undefined variable.
	 */
	public def computeExpectedReturnRate(): void = {
		this.expectedReturnRate = mean/get_dTime() + 0.5*volatility2;
	}

	/**
	 * Method to calculate <code>volatility</code> and <code>volatility2</code>
	 * from the return path data, using the relationship, based on the
	 * precomputed <code>variance</code>.
	 *   \sigma^2 = s^2\Delta t
	 *
	 * @exception DemoException thrown if one of the quantites in the
	 *                          computation are undefined.
	 */
	public def computeVolatility(): void = {
		if (this.variance == Double.NaN)
			throw new DemoException("Variable variance is not defined!");
		this.volatility2 = variance / get_dTime();
		this.volatility  = Math.sqrt(volatility2);
	}

	/**
	 * Method to calculate the mean of the return, for use by other
	 * calculations.
	 *
	 * @exception DemoException thrown if <code>nPathValue</code> is
	 *            undefined.
	 */
	public def computeMean(): void = {
		if (this.nPathValue == 0)
			throw new DemoException("Variable nPathValue is undefined!");
		this.mean = 0.0;
		for (var i: int = 1; i < nPathValue; i++) {
			mean += pathValue(i);
		}
		this.mean /= ((nPathValue - 1.0) as double);
	}

	/**
	 * Method to calculate the variance of the retrun, for use by other
	 * calculations.
	 *
	 * @exception DemoException thrown if the <code>mean</code> or
	 *            <code>nPathValue</code> values are undefined.
	 */
	public def computeVariance(): void = {
		if (this.mean == Double.NaN || this.nPathValue == 0)
			throw new DemoException("Variable mean and/or nPathValue are undefined!");
		this.variance = 0.0;
		for (var i: int = 1; i < nPathValue; i++) {
			variance += (pathValue(i) - mean)*(pathValue(i) - mean);
		}
		this.variance /= ((nPathValue - 1.0) as double);
	}

	/**
	 * A single method for invoking all the necessary methods which
	 * estimate the parameters.
	 *
	 * @exception DemoException thrown if there is a problem reading any
	 *            variables.
	 */
	public def estimatePath(): void = {
		computeMean();
		computeVariance();
		computeExpectedReturnRate();
		computeVolatility();
	}

	/**
	 * Dumps the contents of the fields, to standard-out, for debugging.
	 */
	public def dbgDumpFields(): void = {
		//super.dbgDumpFields();
		//dbgPrintln("nPathValue = "        +this.nPathValue);
		//dbgPrintln("expectedReturnRate = "+this.expectedReturnRate);
		//dbgPrintln("volatility = "        +this.volatility);
		//dbgPrintln("volatility2 = "       +this.volatility2);
		//dbgPrintln("mean = "              +this.mean);
		//dbgPrintln("variance = "          +this.variance);
	}
}
