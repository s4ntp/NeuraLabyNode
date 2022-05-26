(
// make a spectralyzer,
q.spectral = q.spectral ?? { Spectralyzer.new(10) };
q.spectral.listenTo({ SoundIn.ar(0) });	// listen to mic in
q.spectral.makeWindow; // start displaying
q.spectral.view.close; // and stop
q.spectral.dt = 0.05;
);

Tdef(\autoMutate).addSpec(\mutaMin, [0, 1]);
Tdef(\autoMutate).addSpec(\mutaMax, [0, 1]);
Tdef(\autoMutate).addSpec(\mutaScale, [0, 1]);
Tdef(\autoMutate).addSpec(\mutaSum, [0, 1]);
Tdef(\autoMutate).addSpec(\mutaProb, [0, 1]);

Tdef(\autoMutate).set(\mutaMin, 0.0);
Tdef(\autoMutate).set(\mutaSum, 0.0);
Tdef(\autoMutate).set(\mutaScale, 1);
Tdef(\autoMutate).set(\mutaMax, 0.0);
Tdef(\autoMutate).set(\mutaProb, 0);
Tdef(\autoMutate).addHalo(\orderedNames,
	[\mutaMin, \mutaSum, \mutaScale, \mutaMax, \mutaProb]);

q.mutaSum = 0;

(
Tdef(\autoMutate, { |env|
	q.spectral.start;
	q.dbvals = [];
	loop {
		var mutaProb;
		q.mutaSum = 0;
		q.ampvals = q.spectral.ampsPx.bus.getnSynchronous;
		q.dbvals = q.dbvals.addFirst(q.ampvals.ampdb);
		if (q.dbvals.size > 60) { q.dbvals = q.dbvals.keep(60) };
		q.lastAmps = q.dbvals.collect(_[0]);
		q.lastBandAmps = q.dbvals.collect(_.drop(1));
		MFdef(\mutaTest).value;
		env.mutaSum = q.mutaSum;
		mutaProb = max(env.mutaMin, q.mutaSum)
		* env.mutaScale;
		env.mutaProb = mutaProb;
		if (mutaProb.coin) {
			"*** mutate: %\n".postf(mutaProb.round(0.0001));
			q.nudge(mutaProb, q.myseeds.choose);
		};
		0.05.wait;
	};
});
);

// various funcs that run on
MFdef(\mutaTest).add(\post, {
	"amps: [%-%] mean: % dev: %\n".postf(
		*[q.lastAmps.minItem,
			q.lastAmps.maxItem,
			q.lastAmps.mean,
			q.lastAmps.stdDev].round(0.01)
	);
});
MFdef(\mutaTest).enable(\post);
MFdef(\mutaTest).disable(\post);

MFdef(\mutaTest).add(\tooSoft, {
	var add2muta = q.lastAmps.mean.abs.linlin(40, 60, 0, 0.1);
	q.mutaSum = q.mutaSum + add2muta;
	if (add2muta > 0.02 and: 0.1.coin) {
		"tooSoft: %\n".postf(add2muta.round(0.001))
	};
});

MFdef(\mutaTest).add(\tooLoud, {
	var add2muta = q.lastAmps.mean.linlin(-15, 0, 0, 0.1);
	q.mutaSum = q.mutaSum + add2muta;
	if (add2muta > 0.02 and: 0.1.coin) {
		"tooLoud: %\n".postf(add2muta.round(0.001))
	};
});

MFdef(\mutaTest).add(\tooEven, {
	var add2muta = q.lastAmps.stdDev.explin(0.2, 10, 0.1, 0);
	q.mutaSum = q.mutaSum + add2muta;
	if (add2muta > 0.02 and: 0.1.coin) {
		"tooEven: %\n".postf(add2muta.round(0.001))
	};
});

//
MFdef(\mutaTest).add(\tooShrill, {
	// var add2muta = q.lastAmps.stdDev.explin(0.2, 10, 0.1, 0);
	// q.mutaSum = q.mutaSum + add2muta;
	// if (add2muta > 0.02) {
	// 	"tooEven: %\n".postf(add2muta.round(0.001))
	// };
});
