Spec.add(\gain, [0, 4, \amp]);
Spec.add(\bass, [-24, 24]);
Spec.add(\treble, [-24, 24]);
Spec.add(\midFreq, [100, 10000, \exp]);
Spec.add(\midWidth, [0.1, 10, \exp]);
Spec.add(\midGain, [-24, 24]);

~numIns = ~numIns ? 2;
// max input names
~inNames = [\inMic, \inPiezo, \line1, \line2, \nodeX, \nodeY];

// keep all 6 for large audio interface, or just 4,
// or just 2 for audio mixer as 2 chan interface
~inNames = ~inNames.keep(~numIns);
~inNames.do (Spec.add(_, \gain));

~inNdefs = ~inNames.collect { |name, index|
	Ndef(name, {
		var snd = SoundIn.ar(index);
		var amp = \gain.kr(1, 0.5);
		var pan = \pan.kr([-1, 1].wrapAt(index) * rrand(0.4, 1.0), 0.5);
		snd = BHiShelf.ar(snd, 5000, 1, \treble.kr(-6, 0.5));
		snd = BLowShelf.ar(snd, 200, 1, \bass.kr(6, 0.5));
		snd = BPeakEQ.ar(snd,
			\midFreq.kr(1000, 0.5),
			\midWidth.kr(1, 0.5),
			\midGain.kr(0, 0.5));
		snd = Pan2.ar(snd, pan, amp);
	});
};

Ndef(\RawIns, {
	~inNdefs.sum { |ndef|
		 ndef.ar * ndef.key.kr(0.5, 0.5)
	}
});
