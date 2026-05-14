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
	Ndef(\aooReceiver, {InFeedback.ar(~aooReceiverBus, 1)}).play;
}
)
