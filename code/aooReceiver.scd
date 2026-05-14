(
fork {
	~aooReceiverBus = ~aooReceiverBus ?? { Bus.audio(s, 1) };
	SynthDef(\aooReceiver, {|bus| Out.ar(bus, AooReceive.ar(4000, 0, 1)) }).add;

	s.sync;

	~receiverSynth = Synth(\aooReceiver, [\bus, ~aooReceiverBus]);

	~receiverCtl = AooReceiveCtl(~receiverSynth);

	~receiverCtl.addListener(\start, { |source, metadata|
		"New source...: ".post;
		source.postln;
		"  metadata: ".post;
		metadata.postln;
	});
	Ndef(\aooReceiver, {InFeedback.ar(~aooReceiverBus, 1)});
};
Spec.add(\aooAmp, \amp);
Ndef(\RawIns).put(20, { |aooAmp = 1| Ndef(\aooReceiver).ar(1) * aooAmp.lag(1) });
)