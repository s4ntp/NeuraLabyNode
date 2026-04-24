(
// make a spectralyzer,
NeuLab.spectral = NeuLab.spectral ?? { Spectralyzer.new(10) };
NeuLab.spectral.listenTo({ SoundIn.ar(0) });	// listen to mic in
NeuLab.spectral.makeWindow; // start displaying
NeuLab.spectral.view.close; // and stop
NeuLab.spectral.dt = 0.05;
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

NeuLab.mutaSum = 0;

// for the interfaces:
NeuLab.autoOn = { "autoMutate ON".postln; Tdef(\autoMutate).play };
NeuLab.autoOff = { "autoMutate OFF".postln; Tdef(\autoMutate).stop };
NeuLab.autoToggle = {
	var t = Tdef(\autoMutate);
	if (t.isPlaying) { NeuLab.autoOff } { NeuLab.autoOn }
};

(
Tdef(\autoMutate, { |env|
	var mutaProb = 0;
	var dt;
	NeuLab.spectral.start;
	NeuLab.dbvals = [];
	loop {
		NeuLab.mutaSum = 0;
		NeuLab.ampvals = NeuLab.spectral.ampsPx.bus.getnSynchronous.max(0.001);
		NeuLab.dbvals = NeuLab.dbvals.addFirst(NeuLab.ampvals.ampdb);
		if (NeuLab.dbvals.size > 60) { NeuLab.dbvals = NeuLab.dbvals.keep(60) };
		NeuLab.lastAmps = NeuLab.dbvals.collect(_[0]);
		NeuLab.lastBandAmps = NeuLab.dbvals.collect(_.drop(1));
		MFdef(\mutaTest).value;
		env.mutaSum = NeuLab.mutaSum;
		mutaProb = max(env.mutaMin, NeuLab.mutaSum)
		* env.mutaScale;
		env.mutaProb = mutaProb;
		if (mutaProb.coin) {
			"*** mutate: %\n".postf(mutaProb.round(0.0001));
			NeuLab.nudge(mutaProb, NeuLab.myseeds.choose);
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
		*[NeuLab.lastAmps.minItem,
			NeuLab.lastAmps.maxItem,
			NeuLab.lastAmps.mean,
			NeuLab.lastAmps.stdDev].round(0.01)
	);
});
MFdef(\mutaTest).enable(\post);
MFdef(\mutaTest).disable(\post);

MFdef(\mutaTest).add(\tooSoft, {
	var add2muta = NeuLab.lastAmps.mean.abs.linlin(40, 60, 0, 0.1);
	NeuLab.mutaSum = NeuLab.mutaSum + add2muta;
	if (add2muta > 0.02 and: 0.1.coin) {
		"tooSoft: %\n".postf(add2muta.round(0.001))
	};
});

MFdef(\mutaTest).add(\tooLoud, {
	var add2muta = NeuLab.lastAmps.mean.linlin(-15, 0, 0, 0.1);
	NeuLab.mutaSum = NeuLab.mutaSum + add2muta;
	if (add2muta > 0.02 and: 0.1.coin) {
		"tooLoud: %\n".postf(add2muta.round(0.001))
	};
});

MFdef(\mutaTest).add(\tooEven, {
	var add2muta = NeuLab.lastAmps.stdDev.explin(0.2, 6, 0.1, 0);
	NeuLab.mutaSum = NeuLab.mutaSum + add2muta;
	if (add2muta > 0.02 and: 0.1.coin) {
		"tooEven: %\n".postf(add2muta.round(0.001))
	};
});

//
MFdef(\mutaTest).add(\tooShrill, {
	// var add2muta = NeuLab.lastAmps.stdDev.explin(0.2, 10, 0.1, 0);
	// NeuLab.mutaSum = NeuLab.mutaSum + add2muta;
	// if (add2muta > 0.02) {
	// 	"tooEven: %\n".postf(add2muta.round(0.001))
	// };
});
