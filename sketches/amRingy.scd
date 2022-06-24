// sketches for better ampMod and filter functions
// ampMod up is full ring modulation,
// down is positive only, creates pulsing

ProxyChain.add3(
	\amRing,
	\filter -> { |in, mod=0, modfreq=30|
	var modRing = mod.clip(0, 1) * -2 + 1;
	var modAM = (mod.clip(-1, 0) * 3 + 1) ** 2;
	var modOsc = SinOsc.ar(modfreq);
	var ringSnd = in * modOsc.range(modRing, 1);
	var amSnd = in * (modOsc * modAM).clip(0, 1);
	ringSnd * modOsc.range(modAM, 1).max(0);
}, 1, (
		\modfreq:
		mod: \pan
	)
);

Ndef(\amRing).clear;

Ndef(\amRing).addSpec(\sawfreq, \freq);
Ndef(\amRing).addSpec(\modfreq, \widefreq);
Ndef(\amRing).addSpec(\mod, \pan);

Ndef(\amRing, { |mod=0, sawfreq = 150, modfreq=30|
	var in = RLPF.ar(SinOsc.ar(sawfreq) * 0.2, sawfreq * 3);
	var modRing = mod.clip(0, 1) * -2 + 1;
	var modAM = (mod.clip(-1, 0) * 3 + 1) ** 2;
	var modOsc = SinOsc.ar(modfreq);
	var ringSnd = in * modOsc.range(modRing, 1);
	var amSnd = in * (modOsc * modAM).clip(0, 1);
	ringSnd * modOsc.range(modAM, 1).max(0);
}).play.scope;

Ndef(\amRing).gui;

FreqScope();

// filta : mid is full range,
// to left is LPF, to right is HPF, both with resonance

Ndef(\filta).addSpec(\bal, \pan);
Ndef(\filta).addSpec(\exp, [0.25, 4, \exp]);
Ndef(\filta).addSpec(\reso, [1, 4, \exp]);

Ndef(\filta, { |bal=0, exp = 1, reso = 1|
	var in = PinkNoise.ar;
	var rq = (1/reso).clip(0.05, 1);
	var lpfreq = (bal ** exp).linexp(-1, 0, 100, 20000);
	var hpfreq = (bal ** exp).linexp(0, 1, 20, 4000);
	RHPF.ar(RLPF.ar(in, lpfreq, rq), hpfreq, rq);
}).scope;

Ndef(\filta).gui;
