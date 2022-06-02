/*
PMC:
Pepsi Modifier Board Channel,
or Proxy MultiFX Chain system

Wishlist :
x Preset for chain as Ndef with all nudgeable controls

For testing and performing :
- 1 drop sink for soundfile, reuse pepsi tape (tape player)
- make a tapes/soundfiles folder locally,
- with subfolders to load array of files at once

*/
(
q = q ? ();

q.lag = Ndef('lag', { |lag=3| lag });

Spec.add(\amp4, [0, 4, \amp]);
Spec.add(\drive, [0, 10, 4.4]);
Spec.add(\lag, [0, 11, 1.9616]);
// [0, 11, 1.9616].asSpec.map(0.5); // 3

(
// was: \mix -> { ... }
// changed to {} to save one mix line in gui
ProxyChain.add3(\ins, {
	var snd = Ndef(\RawIns).ar;
	snd = LeakDC.ar(snd, 0.999);
	snd;
}, 1)
);

///// global lag param present in all controls,
///// but not stored along in preset.

///// Mumma1: freq shift mod, with envelope following
(
ProxyChain.add3(\freqMod, \filter -> { |in, carrFreq=5000, filtRatio=1, freqShift=30|
	var snd, freq2;
	carrFreq = carrFreq.lag(Ndef(\lag));
	freqShift = freqShift.lag(Ndef(\lag));
	freq2 = carrFreq + freqShift;

	snd = in.asArray.mean * SinOsc.ar(carrFreq, [0, pi/2]);
	snd = LPF.ar(snd,
		(carrFreq * filtRatio.lag(Ndef(\lag)))
		.clip(20, (s.sampleRate * 0.45) - carrFreq)
	);
	snd = snd * SinOsc.ar(freq2, [0, pi/2]);
	snd.sum;
}, 1, (
	carrFreq: [200, 6000, \exp],
	filtRatio: [1, 10, \exp],
	freqShift: [-1000, 1000]
)
)
);


// // Mumma2: amplitude modulation with envelope following
(
ProxyChain.add3(\ampMod, \filter -> { |in, amFreq = 16, amWidth = 0.5, amRateMod = 0.5|
	var snd = in;
	var envel = Amplitude.kr(snd, 0.01, 0.5);
	var envmod = (48 * envel * amRateMod.lag(Ndef(\lag))).midiratio;
	var modOsc = SinOsc.ar(amFreq.lag(Ndef(\lag)) * envmod)
	.range(1, 1-amWidth.lag(Ndef(\lag)));

	///// comment this line out for ring mod,
	//// comment in to create shorter pulses:
	modOsc = modOsc.clip(0, 1);
	snd * modOsc;

}, 1, (
	// specs go here:
	\amFreq: [0.1, 1000, \exp, 0.1],
	\amWidth: [0, 4, \amp],
	\amRateMod: [-1, 1],
)
)
);

(
ProxyChain.add3(\hiPass, \filter -> { |in,
	hpFreq = 200, hpWidth = 0.5, hpRate = 3, hpRateMod = 0.5|

	var envel = Amplitude.kr(in, 0.01, 0.5);
	var envmod = (48 * envel * hpRateMod.lag(Ndef(\lag))).midiratio; // +- 4 octaves max
	var modOsc = SinOsc.ar(hpRate.lag(Ndef(\lag)) * envmod) * hpWidth.lag(Ndef(\lag));
	var filtfreq = (hpFreq.lag(Ndef(\lag)) * (16 ** modOsc)).clip(20, 20000);
	HPF.ar(in, filtfreq);
}, 1, (
	// specs go here:
	\hpFreq: [20, 2000, \exp, 0.1],
	\hpWidth: [0, 1],
	\hpRate: [0.1,2000, \exp],
	hpRateMod: [-1, 1],
)
)
);

ProxyChain.add3(\gapz, \filter -> { |in,
	probkeep = 0.5, mindur = 0.02|

	var trig = Trig1.ar(in.sign, mindur.lag(Ndef(\lag)).clip(0, 1));
	var passamp = Latch.ar(CoinGate.ar(probkeep.lag(Ndef(\lag)), trig), trig);
	in * passamp;
}, 0.5, (
	\probkeep: [0, 1 ],
	\mindur: [0, 0.5, 2.77 ]
));

(
ProxyChain.add3(\tanh, \filter -> { |in| (in * 2).tanh })
);

(
ProxyChain.add3(\limiter, \filter -> { |in,
	drive = 3, maxLevel = 0.2|
	Limiter.ar(in.tanh * drive.lag(Ndef(\lag)), maxLevel.lag(Ndef(\lag)));
}, 1, (
	// specs go here:
	drive: [ 0, 10, 4.4],
	maxLevel: [0.1, 1.0, \exp, 0.001, 0.6],
)
)
);



// making
///// tanh moved into limiter to save one GUI line

q.pcSlots = [\ins, \freqMod, \ampMod, \hiPass, \gapz, \limiter ];

q.pchain.free;
q.pchain = ProxyChain.from(Ndef(\NeuraLaby), q.pcSlots).play;

Ndef(\NeuraLaby).fadeTime = 10;


// better use linear mappings for drywet FX controls:
Ndef(\NeuraLaby).addSpec(\wet20, [0, 1, 0]);
Ndef(\NeuraLaby).addSpec(\wet30, [0, 1, 0]);
Ndef(\NeuraLaby).addSpec(\wet40, [0, 1, 0]);
Ndef(\NeuraLaby).addSpec(\wet50, [0, 1, 0]);


// turn on the FX that can be nudged
q.pchain.do { |pc, i|
	pc.add(\freqMod, 1);
	pc.add(\ampMod, 1);
	pc.add(\hiPass, 1);
	pc.add(\gapz, 1);
};

// grab the parameters to nudge
q.params = q.pchain.proxy.getKeysValues.flop[0].reject(_ == \lag);
"**** q.params for preset: ".postln;
q.params.printcsAll;

q.preset = NdefPreset(Ndef(\NeuraLaby), q.params);
q.preset.loadSettings;

"left, right, center settings:".postln;
q.prekeys = q.preset.settings.collect(_.key).drop(1);
q.preset.setCurr(q.prekeys.take(q.prekeys.choose).postln, false);
q.preset.setTarg(q.prekeys.take(q.prekeys.choose).postln, false);
q.preset.setProxy(q.prekeys.take(q.prekeys.choose).postln);
q.preset.morphVal_(0.5);

q.nudge = { |q, step = 0.1, seed = 4711|
	fork {
		thisThread.randSeed_(seed);
		q.params.do { |param|
			var proxy = q.pchain.proxy;
			var val = proxy.getUni(param);
			proxy.setUni(param, (val + step.rand2));
		}
	}
};

q.myseeds = 16.collect { 1000.rand };

/*
q.nudge(0.1, 123);
q.nudge(-0.1, 123);
*/
Ndef(\NeuraLaby).getUnis('wet20', 'wet30', 'wet40', 'wet50');

// Ndef(\NeuraLaby).getKeysValues.flop[0].sort.cs;
q.stepDryWet = { |q, step = 0.1|
	var ndef = Ndef(\NeuraLaby);
	var paramKeys = ['wet20', 'wet30', 'wet40', 'wet50'];
	var settings = ndef.getKeysValues(paramKeys);
	var newSettings = settings.collect { |pair|
		var paramKey = pair[0], val = pair[1];
		var spec = ndef.getSpec(paramKey);
		var normval = spec.unmap(val);
		var outnormval = (normval + step).clip(0, 1);
		var outval = spec.map(outnormval);
		[ paramKey, outval];
	};
	ndef.set(*newSettings.flat);
};
/*
q.stepDryWet(0.1);
q.stepDryWet(-0.1);
*/

fork ({
	0.5.wait;
	q.pchain.remove(\freqMod);
	0.5.wait;
	// turn on input and limiter after gui is made
	// to force gui update / wet labels.
	q.pchain.add(\freqMod, 1);
	q.pchain.add(\ins, 1);
	q.pchain.add(\limiter, 1);

});
);