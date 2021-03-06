/**************************************************************************
*                                                                         *
*             Java Grande Forum Benchmark Suite - MPJ Version 1.0         *
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
*                  Original version of this code by                       *
*                         Dieter Heermann                                 *
*                       converted to Java by                              *
*                Lorna Smith  (l.smith@epcc.ed.ac.uk)                     *
*                   (see copyright notice below)                          *
*                                                                         *
*      This version copyright (c) The University of Edinburgh, 2001.      *
*                         All rights reserved.                            *
*                                                                         *
**************************************************************************/
package moldyn.serial.moldyn;


/**
 * Moldyn ported to x10. Sequential version.
 *
 * @author kemal 3/2005
 */
public class md {

	public static val ITERS: int = 100; // 100
	public static val LENGTH: double = 50e-10;
	public static val m: double = 4.0026;
	public static val mu: double = 1.66056e-27;
	public static val kb: double = 1.38066e-23;
	public static val TSIM: double = 50;
	public static val deltat: double = 5e-16;
	public var one: Array[Particle] = new Array[Particle](0);
	public var epot: double = 0.0;
	public var vir: double = 0.0;
	public var count: double = 0.0;
	var size: int;
	var datasizes: Array[int] = [ 4, 13 ];
	// int datasizes[] = { 2, 13 };
	public var interactions: int = 0;

	var i: int;var j: int;var k: int;var lg: int;var mdsize: int;var move: int;var mm: int;

	var l: double;var rcoff: double;var rcoffs: double;var side: double;var sideh: double;var hsq: double;var hsq2: double;var vel: double;
	var a: double;var r: double;var sum: double;var tscale: double;var sc: double;var ekin: double;var ek: double;var ts: double;var sp: double;
	var den: double = 0.83134;
	var tref: double = 0.722;
	var h: double = 0.064;
	var vaver: double;var vaverh: double;var rand: double;
	var etot: double;var temp: double;var pres: double;var rp: double;
	var u1: double;var u2: double;var v1: double;var v2: double;var s: double;

	var ijk: int;var npartm: int;var partsize: int;var iseed: int;var tint: int;
	var irep: int = 10;
	var istop: int = 19;
	var iprint: int = 10;
	var movemx: int = 50;

	var randnum: Random;

	public def initialise(): void {
		/* Parameter determination */
		mm = datasizes(size);
		partsize = mm*mm*mm*4;
		mdsize = partsize;
		one = new Array[Particle](mdsize);
		l = LENGTH;

		side = Math.pow((mdsize/den), 0.3333333);
		rcoff = mm/4.0;

		a = side/mm;
		sideh = side*0.5;
		hsq = h*h;
		hsq2 = hsq*0.5;
		npartm = mdsize - 1;
		rcoffs = rcoff * rcoff;
		tscale = 16.0 / (1.0 * mdsize - 1.0);
		vaver = 1.13 * Math.sqrt(tref / 24.0);
		vaverh = vaver * h;

		/* Particle Generation */
		ijk = 0;
		for (lg = 0; lg <= 1; lg++) {
			for (i = 0; i<mm; i++) {
				for (j = 0; j<mm; j++) {
					for (k = 0; k<mm; k++) {
						one(ijk) = new Particle((i*a+lg*a*0.5), (j*a+lg*a*0.5), (k*a),
								0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
						ijk = ijk + 1;
					}
				}
			}
		}
		for (lg = 1; lg <= 2; lg++) {
			for (i = 0; i<mm; i++) {
				for (j = 0; j<mm; j++) {
					for (k = 0; k<mm; k++) {
						one(ijk) = new Particle((i*a+(2-lg)*a*0.5), (j*a+(lg-1)*a*0.5),
								(k*a+a*0.5), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
						ijk = ijk + 1;
					}
				}
			}
		}

		/* Initialise velocities */
		iseed = 0;
		v1 = 0.0;
		v2 = 0.0;

		randnum = new Random(iseed, v1, v2);

		for (i = 0; i<mdsize; i += 2) {
			r  = randnum.seed();
			one(i).xvelocity = r*randnum.v1;
			one(i+1).xvelocity  = r*randnum.v2;
		}

		for (i = 0; i<mdsize; i += 2) {
			r  = randnum.seed();
			one(i).yvelocity = r*randnum.v1;
			one(i+1).yvelocity  = r*randnum.v2;
		}

		for (i = 0; i<mdsize; i += 2) {
			r  = randnum.seed();
			one(i).zvelocity = r*randnum.v1;
			one(i+1).zvelocity  = r*randnum.v2;
		}

		/* velocity scaling */
		ekin = 0.0;
		sp = 0.0;

		for (i = 0; i<mdsize; i++) {
			sp = sp + one(i).xvelocity;
		}
		sp = sp / mdsize;

		for (i = 0; i<mdsize; i++) {
			one(i).xvelocity = one(i).xvelocity - sp;
			ekin = ekin + one(i).xvelocity*one(i).xvelocity;
		}

		sp = 0.0;
		for (i = 0; i<mdsize; i++) {
			sp = sp + one(i).yvelocity;
		}
		sp = sp / mdsize;

		for (i = 0; i<mdsize; i++) {
			one(i).yvelocity = one(i).yvelocity - sp;
			ekin = ekin + one(i).yvelocity*one(i).yvelocity;
		}

		sp = 0.0;
		for (i = 0; i<mdsize; i++) {
			sp = sp + one(i).zvelocity;
		}
		sp = sp / mdsize;

		for (i = 0; i<mdsize; i++) {
			one(i).zvelocity = one(i).zvelocity - sp;
			ekin = ekin + one(i).zvelocity*one(i).zvelocity;
		}

		ts = tscale * ekin;
		sc = h * Math.sqrt(tref/ts);

		for (i = 0; i<mdsize; i++) {

			one(i).xvelocity = one(i).xvelocity * sc;
			one(i).yvelocity = one(i).yvelocity * sc;
			one(i).zvelocity = one(i).zvelocity * sc;
		}

		/* MD simulation */
	}

	public def runiters(): void {
		var n: int = 0;
		move = 0;
		for (move = 0; move<movemx; move++) {

			for (i = 0; i<mdsize; i++) {
				one(i).domove(side);        /* move the particles and update velocities */
			}

			epot = 0.0;
			vir = 0.0;

			for (i = 0; i<mdsize; i++) {
				one(i).force(side, rcoff, mdsize, i, this);  /* compute forces */
			}

			sum = 0.0;

			for (i = 0; i<mdsize; i++) {
				sum = sum + one(i).mkekin(hsq2);    /*scale forces, update velocities */
			}

			ekin = sum/hsq;

			vel = 0.0;
			count = 0.0;

			for (i = 0; i<mdsize; i++) {
				vel = vel + one(i).velavg(vaverh, h, this); /* average velocity */
			}

			vel = vel / h;

			/* tmeperature scale if required */
			if ((move < istop) && (((move+1) % irep) == 0)) {
				sc = Math.sqrt(tref / (tscale*ekin));
				for (i = 0; i<mdsize; i++) {
					one(i).dscal(sc, 1);
				}
				ekin = tref / tscale;
			}

			/* sum to get full potential energy and virial */
			if (((move+1) % iprint) == 0) {
				ek = 24.0*ekin;
				epot = 4.0*epot;
				etot = ek + epot;
				temp = tscale * ekin;
				pres = den * 16.0 * (ekin - vir) / mdsize;
				vel = vel / mdsize;
				rp = (count / mdsize) * 100.0;
			}
		}
	}
}
