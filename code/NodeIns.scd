Spec.add(\gain, [0, 4, \amp]);
Spec.add(\bass, [-24, 24]);
Spec.add(\treble, [-24, 24]);
Spec.add(\midFreq, [100, 10000, \exp]);
Spec.add(\midWidth, [0.1, 10, \exp]);
Spec.add(\midGain, [-24, 24]);

q.laby.numIns = q.laby.numIns ? 2;
// max input names
q.laby.inNames = [\inMic, \inPiezo, \line1, \line2, \nodeX, \nodeY];

// keep all 6 for large audio interface, or just 4,
// or just 2 for audio mixer as 2 chan interface
q.laby.inNames = q.laby.inNames.keep(q.laby.numIns);
q.laby.inNames.do (Spec.add(_, \gain));
q.laby.panNames = q.laby.inNames.collect { |name| (name ++ "Pan").asSymbol };
q.laby.panNames.do (Spec.add(_, \pan));


q.laby.inNdefs = q.laby.inNames.collect { |name, index|
	Ndef(name, {
		var snd = SoundIn.ar(index);
		var amp = \gain.kr(1, 0.5);
		snd = BHiShelf.ar(snd, 5000, 1, \treble.kr(0, 0.5));
		snd = BLowShelf.ar(snd, 200, 1, \bass.kr(0, 0.5));
		snd = BPeakEQ.ar(snd,
			\midFreq.kr(1000, 0.5),
			\midWidth.kr(1, 0.5),
			\midGain.kr(0, 0.5));
	});
};

Spec.add(\balance, \pan);
Spec.add(\delay, [0, 5, 3]);

q.stepSpkObj = { |q, step = 0.0|
	var ins = Ndef(\RawIns);
	var curr = ins.getUni(\balance);
	ins.setUni(\balance, curr + step);
};

Ndef(\RawIns, { |balance = 0, delay = 0|
	var lag = Ndef('lag').kr[0];
	var mix = q.laby.inNdefs.collect { |ndef, i|
		var ampname =  q.laby.inNames[i];
		var amp = ampname.kr(1, lag);
		var panname = q.laby.panNames[i];
		var pan = panname.kr([-1, 1][i], lag);

		Pan2.ar(ndef.ar(1), pan, amp);
	}.sum.postln;

	mix = DelayN.ar(mix, 5, delay.lag(lag));

	Balance2.ar(mix[0], mix[1], balance.lag(lag));
});

Ndef(\pinkTest, { PinkNoise.ar }).vol_(0.25);

Ndef(\sineTest, { SinOsc.ar(LFSaw.kr(0.1).exprange(20, 20000)) }).vol_(0.25);
