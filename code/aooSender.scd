(
~ips = (
	NLivm5: 171,
	NLawe3: 161,
	NLanon5: 172,
	NLmaya: 153,
	NLflower: 199,
	NLadc5a: 103,
);


~sinks = ~ips.collect {|ip| AooAddr("192.168.0.%".format(ip), 4000) };
~busses = ~ips.collect {|ip| Bus.audio(s, 1) };
);


(
~makeSenderCtl = {|to|
	SynthDef(to, {AooSend.ar(3000 + ~ips[to], 0, InFeedback.ar(~busses[to]))}).add;
	fork {
		var senderSynth, senderCtl;
		s.sync;
		senderSynth = Synth(to);
		s.sync;
		senderCtl = AooSendCtl(senderSynth);
		s.sync;
		senderCtl.addSink(~sinks[to]);
		s.sync;
		senderCtl.setFormat(AooFormatPCM(1, 256), { senderCtl.start });
	};
};
)

~ips.keys.do {|key| ~makeSenderCtl.(key) };

// if you play to any ~busses, it goes to that station
Ndef(\someSound, { Blip.ar(200, LFDNoise3.kr(1, 100, 20), 0.02) }).play(~busses[\NLflower]);

// stereo to two different stations:
Ndef(\someSounds, { Blip.ar(200, LFDNoise3.kr([1,1], 100, 20), 0.02) }).playN([~busses.choose.index, ~busses.choose.index]);

