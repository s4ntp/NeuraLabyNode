(
NeuLab.auto = NeuLab.auto ? ();
// make a spectralyzer,
NeuLab.auto.spectral = NeuLab.auto.spectral ?? { Spectralyzer.new(10) };
NeuLab.auto.spectral.listenTo({ SoundIn.ar(0) });	// listen to mic in
NeuLab.auto.spectral.makeWindow; // start displaying
NeuLab.auto.spectral.view.close; // and stop
NeuLab.auto.spectral.dt = 0.05;
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

NeuLab.auto.mutaSum = 0;

// for the interfaces:
NeuLab.auto.autoOn = { "autoMutate ON".postln; Tdef(\autoMutate).play };
NeuLab.auto.autoOff = { "autoMutate OFF".postln; Tdef(\autoMutate).stop };
NeuLab.auto.autoToggle = {
	var t = Tdef(\autoMutate);
	if (t.isPlaying) { NeuLab.auto.autoOff } { NeuLab.auto.autoOn }
};

(
Tdef(\autoMutate, { |env|
	var mutaProb = 0;
	var dt;
	NeuLab.auto.spectral.start;
	NeuLab.auto.dbvals = [];
	loop {
		NeuLab.auto.mutaSum = 0;
		NeuLab.auto.ampvals = NeuLab.auto.spectral.ampsPx.bus.getnSynchronous.max(0.001);
		NeuLab.auto.dbvals = NeuLab.auto.dbvals.addFirst(NeuLab.auto.ampvals.ampdb);
		if (NeuLab.auto.dbvals.size > 60) { NeuLab.auto.dbvals = NeuLab.auto.dbvals.keep(60) };
		NeuLab.auto.lastAmps = NeuLab.auto.dbvals.collect(_[0]);
		NeuLab.auto.lastBandAmps = NeuLab.auto.dbvals.collect(_.drop(1));
		MFdef(\mutaTest).value;
		env.mutaSum = NeuLab.auto.mutaSum;
		mutaProb = max(env.mutaMin, NeuLab.auto.mutaSum)
		* env.mutaScale;
		env.mutaProb = mutaProb;
		if (mutaProb.coin) {
			"*** mutate: %\n".postf(mutaProb.round(0.0001));
			NeuLab.auto.nudge(mutaProb, NeuLab.myseeds.choose);
			//
			if (0.1.coin) {
				"delay: ".post;
				Ndef(\RawIns).setUni(\delay,
					(Ndef(\RawIns).getUni(\delay) + 0.04.bilinrand).fold(0, 1).postln
				);
			};
		};
		0.05.wait;
	};
});
);

// various funcs that run on
MFdef(\mutaTest).add(\post, {
	"amps: [%-%] mean: % dev: %\n".postf(
		*[NeuLab.auto.lastAmps.minItem,
			NeuLab.auto.lastAmps.maxItem,
			NeuLab.auto.lastAmps.mean,
			NeuLab.auto.lastAmps.stdDev].round(0.01)
	);
});
MFdef(\mutaTest).enable(\post);
MFdef(\mutaTest).disable(\post);

MFdef(\mutaTest).add(\tooSoft, {
	var add2muta = NeuLab.auto.lastAmps.mean.abs.linlin(40, 60, 0, 0.1);
	NeuLab.auto.mutaSum = NeuLab.auto.mutaSum + add2muta;
	if (add2muta > 0.02 and: 0.1.coin) {
		"tooSoft: %\n".postf(add2muta.round(0.001))
	};
});

MFdef(\mutaTest).add(\tooLoud, {
	var add2muta = NeuLab.auto.lastAmps.mean.linlin(-15, 0, 0, 0.1);
	NeuLab.auto.mutaSum = NeuLab.auto.mutaSum + add2muta;
	if (add2muta > 0.02 and: 0.1.coin) {
		"tooLoud: %\n".postf(add2muta.round(0.001))
	};
});

MFdef(\mutaTest).add(\tooEven, {
	var add2muta = NeuLab.auto.lastAmps.stdDev.explin(0.2, 6, 0.1, 0);
	NeuLab.auto.mutaSum = NeuLab.auto.mutaSum + add2muta;
	if (add2muta > 0.02 and: 0.1.coin) {
		"tooEven: %\n".postf(add2muta.round(0.001))
	};
});

//
MFdef(\mutaTest).add(\tooShrill, {
	// var add2muta = NeuLab.auto.lastAmps.stdDev.explin(0.2, 10, 0.1, 0);
	// NeuLab.auto.mutaSum = NeuLab.auto.mutaSum + add2muta;
	// if (add2muta > 0.02) {
	// 	"tooEven: %\n".postf(add2muta.round(0.001))
	// };
});
