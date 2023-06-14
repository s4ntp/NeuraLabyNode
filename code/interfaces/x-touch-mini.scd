/*
MKtl(\xtouch).gui.showLabels;
*/

MKtl.all[\xtouch].free;
MKtl(\xtouch, "*x-touch-mini");

// first encoder does less/more
MKtl(\xtouch).elAt(\A, \chan, 0, \enc, 0).action_({ |enc|
	var diff = (enc.deviceValue - enc.prevDeviceValue).clip2(5);
	q.stepDryWet(diff * 0.015);
}).elemDesc.label = "LessMore";

// last encoder does speaker/object balance
MKtl(\xtouch).elAt(\A, \chan, 7, \enc, 0).action_({ |enc|
	var currval = Ndef(\RawIns).getUni(\balance);
	var diff = (enc.deviceValue - enc.prevDeviceValue).clip2(5);
	Ndef(\RawIns).setUni(\balance, currval + (diff * 0.01));
}).elemDesc.label = "SpkObj";

// button xxx toggles autoMutate
MKtl(\xtouch).elAt(\A, \chan, 0, \bt, \B, \on).action = { |bt|
	if (bt.isOn) {
		if (Tdef('autoMutate').isPlaying.not) {
			"'autoMutate' plays".postln;
			Tdef('autoMutate').play
		} {
			"'autoMutate' stops".postln;
			Tdef('autoMutate').stop
		};
	};
};

// // use knobs for relative influence
MKtl(\xtouch).elAt(\A, \chan, (1..6), \enc, 0).do { |enc, i|
	enc.elemDesc.label = "nudge rd" + (i+1);
	enc.action = { |enc|
		var diff = (enc.deviceValue - enc.prevDeviceValue).clip2(5);
		var step = (diff * 0.02);
		q.nudge(step, q.myseeds[i]);
	}
};
