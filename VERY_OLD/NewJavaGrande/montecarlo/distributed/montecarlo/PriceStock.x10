/*
 *
 * (C) Copyright IBM Corporation 2006
 *
 *  This file is part of X10 Test.
 *
 */
package montecarlo.distributed.montecarlo;

/**
 * X10 port of montecarlo benchmark from Section 2 of Java Grande Forum Benchmark Suite (Version 2.0).
 *
 * @author Vivek Sarkar (vsarkar@us.ibm.com)
 *
 * Porting issues identified:
 */
public class PriceStock extends Universal {

	//------------------------------------------------------------------------
	// Class variables.
	//------------------------------------------------------------------------

	/**
	 * Class variable for determining whether to switch on debug output or
	 * not.
	 */
	public static val DEBUG: boolean = true;

	/**
	 * Class variable for defining the debug message prompt.
	 */
	protected static val prompt: String = "PriceStock> ";

	//------------------------------------------------------------------------
	// Instance variables.
	//------------------------------------------------------------------------

	/**
	 * The Monte Carlo path to be generated.
	 */
	private var mcPath: MonteCarloPath;

	/**
	 * String identifier for a given task.
	 */
	private var taskHeader: String;

	/**
	 * Random seed from which the Monte Carlo sequence is started.
	 */
	private var randomSeed: long = -1;

	/**
	 * Initial stock price value.
	 */
	private var pathStartValue: double = Double.NaN;

	/**
	 * Object which represents the results from a given computation task.
	 */
	private var result: ToResult;
	private var expectedReturnRate: double = Double.NaN;
	private var volatility: double = Double.NaN;
	private var volatility2: double = Double.NaN;
	private var finalStockPrice: double = Double.NaN;
	private var pathValue: Array[double];

	//------------------------------------------------------------------------
	// Constructors.
	//------------------------------------------------------------------------

	/**
	 * Default constructor.
	 */
	public def this(): PriceStock = {
		super();
		mcPath = new MonteCarloPath();
		set_prompt(prompt);
		set_DEBUG(DEBUG);
	}

	//------------------------------------------------------------------------
	// Methods.
	//------------------------------------------------------------------------
	//------------------------------------------------------------------------
	// Methods which implement the Slaveable interface.
	//------------------------------------------------------------------------

	/**
	 * Method which is passed in the initialisation data common to all tasks,
	 * and then unpacks them for use by this object.
	 *
	 * @param obj Object representing data which are common to all tasks.
	 */
	public def setInitAllTasks(var obj: ToInitAllTasks): void = {
		val initAllTasks: ToInitAllTasks = obj as ToInitAllTasks;
		finish async at (mcPath) {
			mcPath.set_name(initAllTasks.get_name());
			mcPath.set_startDate(initAllTasks.get_startDate());
			mcPath.set_endDate(initAllTasks.get_endDate());
			mcPath.set_dTime(initAllTasks.get_dTime());
			mcPath.set_returnDefinition(initAllTasks.get_returnDefinition());
			mcPath.set_expectedReturnRate(initAllTasks.get_expectedReturnRate());
			mcPath.set_volatility(initAllTasks.get_volatility());
			var nTimeSteps: int = initAllTasks.get_nTimeSteps();
			mcPath.set_nTimeSteps(nTimeSteps);
			this.pathStartValue = initAllTasks.get_pathStartValue();
			mcPath.set_pathStartValue(pathStartValue);
			mcPath.set_pathValue(new Array[double](nTimeSteps));
			mcPath.set_fluctuations(new Array[double](nTimeSteps));
		}
	}

	/**
	 * Method which is passed in the data representing each task, which then
	 * unpacks it for use by this object.
	 *
	 * @param obj Object representing the data which defines a given task.
	 */
	public def setTask(var obj: x10.lang.Object): void = {
		var task: ToTask = obj as ToTask;
		this.taskHeader     = task.get_header();
		this.randomSeed     = task.get_randomSeed();
	}

	/**
	 * The business end.  Invokes the necessary computation routine, for a
	 * a given task.
	 */
	public def run(): void = {
		try {
			mcPath.computeFluctuationsGaussian(randomSeed);
			mcPath.computePathValue(pathStartValue);
			var rateP: RatePath = new RatePath(mcPath);
			var returnP: ReturnPath = rateP.getReturnCompounded();
			returnP.estimatePath();
			expectedReturnRate = returnP.get_expectedReturnRate();
			volatility = returnP.get_volatility();
			volatility2 = returnP.get_volatility2();
			finalStockPrice = rateP.getEndPathValue();
			pathValue = mcPath.get_pathValue();
		} catch (var demoEx: DemoException) {
			errPrintln(demoEx.toString());
		}
	}

	/**
	 * Method which returns the results of a computation back to the caller.
	 * @return An object representing the computed results.
	 */
	public def getResult(): x10.lang.Object = {
		var resultHeader: String = "Result of task with Header = "+taskHeader+": randomSeed = "+randomSeed+": pathStartValue = "+pathStartValue;
		var res: ToResult = new ToResult(resultHeader,expectedReturnRate,volatility,
									volatility2,finalStockPrice,pathValue);
		return res;
	}
}
