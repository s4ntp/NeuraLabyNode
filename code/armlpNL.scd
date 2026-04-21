/*


First pass at Neural Synth for Neural Labyrinths:
use small ARMLP feedback chain, tweaked small enough
dimensions so it runs OK on Pi4 and Pi5.

patchbox 44100, hwbuf 512
keep
netSize 6, netWidth 2, netEpochs 1 : 40%

defer ({ WinBounds.showOrMake(\NeuralSynth) }, 1);

*/

(
WinBounds.addMake(\NeuralSynth, {
	var w = Window(\NeuralSynth).front;
	var l = w.addFlowLayout;
	var e = EnvirGui(Ndef(\armlpNL).getHalo.fixed, 2, w, 200@40);
	var frz = StaticText(w, 20@40).string_("11\n7");
	var b = Button(w, 60@40).states_([["RESTART"]]);
	var expBt = Button(w, 50@40).states_([["basic"], ["expert"]]);
	var g = NdefPresetGui(NdefPreset(\armlpNL), 19, w);
	b.action = {
		Ndef(\armlpNL).postln.rebuild.play;
	};
	expBt.action = { |bt|
		g.proxyGui.paramGui.paramViews.drop(10).drop(-1).do(_.visible_(bt.value > 0));
		w.bounds = w.bounds.flipY.height_([330, 470][bt.value]).flipY;
	};
	// remove drags, make labels bigger?
	// NdefGui(Ndef(\armlpNL)).paramGui.drags.do(_.visible_(false));

	expBt.valueAction_(0);

	Ndef(\armlpNL).addHalo(\netDisplay, frz);
	Ndef(\armlpNL).getHalo.store;

	g.proxyGui.addMeter;
	w;
});
);

Ndef(\armlpNL).clear;
Ndef(\armlpNL);


// make specs global for now:

Spec.add(\netEpochs, [1, 11, \lin, 1]);

['mic', 'feedback', 'learnRate1', 'learnRate2', 'ridge'].do { |name|
	Spec.add(name, [0, 1, \amp]);
};

Spec.add(\delayMax, [0.001, 1, \exp]);
Spec.add(\delayRate, [0.01, 10, \exp]);
Spec.add(\delayDepth, [0, 1]);

Spec.add(\act1, [0, 2]);
Spec.add(\act2, [0, 2]);
Spec.add(\sineFac, [1, 11]);
Spec.add(\momentum, [0, 0.999]);
Spec.add(\errorMode, [0, 2, \lin, 1]);
Spec.add(\gradNoise, [0, 0.05, \amp]);
Spec.add(\recurrent, \amp);
Spec.add(\maxWeight, [1, 25, \exp]);
Spec.add(\reset, [-1, 1]);




Ndef(\armlpNL).addHalo(\namesToStore, [
	'mic', 'feedback',
	'netEpochs', 'learnRate1', 'learnRate2', 'ridge',
	'delayMax', 'delayRate',
	'act1', 'act2', 'sineFac',
	'momentum', 'errorMode', 'gradNoise',
	'recurrent', 'maxWeight',
]);

// handle init-only params by storing when (re)building:
Spec.add(\netSize, [1, 11, \lin, 1]);
Spec.add(\netWidth, [1, 11, \lin, 1]);

Ndef(\armlpNL).addHalo(\fixed, (
	netSize: 11, netWidth: 4
));
Ndef(\armlpNL).addHalo(\store, { |halo|
	halo.stored = halo.fixed.copy.postcs;
	try { halo.netDisplay.string = "%\n%".format(
		halo.stored.netSize, halo.stored.netWidth)
	};
	halo.stored;
});

(
Ndef(\armlpNL, { |
	amp = 0.25,
	mic = 0.25, feedback=0.25,
	netEpochs = 4,learnRate1 = 0.8, learnRate2 = 0.8, ridge = 0.001,
	delayMax = 0.1, delayRate = 0.1, delayDepth = 0.5,
	// the new params in ARMLP, specialist mode:
	act1 = 0, act2 = 0, sineFac = 2,
	momentum = 0, errorMode = 0,
	gradNoise = 0,
	recurrent = 0, maxWeight = 10
	/*reset = 0*/
	|

	var size = 12, num = 3; // how many in feedback loop

	var in = (BrownNoise.ar(0.0001))
	+ (LocalIn.ar(1) * (feedback * 4).lag(1))
	+ SoundIn.ar(0) * (mic * 4).lag(1);

	var ridge2 = (ridge.squared * 0.01).max(0.00001);

	var stored = Ndef(\armlpNL).getHalo.store;

	var snd = in;
	var chans = num.collect { |i|
		var chan = ARMLP.ar(
			HPF.ar(snd,20).tanh,
			stored.netSize, stored.netWidth,
			netEpochs,
			learnRate1, learnRate2, ridge2,
			act1, act2, sineFac,
            momentum, errorMode, gradNoise,
            recurrent, maxWeight/*, reset*/
		).zap;

		// add drifting delay for each channel
		chan = DelayC.ar(chan, 1,
			LFDNoise3.kr(delayRate * rrand(0.8, 1.2))
			.exprange(1.01 - delayDepth, 1)
			* delayMax.lag(1)
		);
		snd = chan;
		chan;
	};
	LocalOut.ar(snd+(LPF.ar(snd, 20)));

	LPF.ar(HPF.ar(LeakDC.ar(Splay.ar(chans.scramble, 1, amp)), 20), 12000).zap.flat.tanh;
});
NdefPreset(\armlpNL);
);
