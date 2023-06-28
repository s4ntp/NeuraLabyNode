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
MKtl(\xtouch).elAt(\A, \chan, 0, \bt, \A, \on)
.action_({ q.autoOn })
.elemDesc.label_("auto ON");
MKtl(\xtouch).elAt(\A, \chan, 0, \bt, \B, \on)
.action_({ q.autoOff })
.elemDesc.label_("auto OFF");

// // use knobs for relative influence
MKtl(\xtouch).elAt(\A, \chan, (1..6), \enc, 0).do { |enc, i|
	enc.elemDesc.label = "nudge rd" + (i+1);
	enc.action = { |enc|
		var diff = (enc.deviceValue - enc.prevDeviceValue).clip2(5);
		var step = (diff * 0.02);
		q.nudge(step, q.myseeds[i]);
	}
};

// MKtl(\xtouch).elAt(\A, \chan, 0)
// .action_({ q.preset.stepCurr(1) })
// .elemDesc.label_("pre L +");
// MKtl(\xtouch).elAt(\pgSl1, \bt, 5, 0)
// .action_({ q.preset.stepCurr(-1) })
// .elemDesc.label_("pre L -");
//
// MKtl(\xtouch).elAt(\pgSl1, \bt, 6, 0)
// .action_({ q.preset.stepTarg(1) })
// .elemDesc.label_("pre R +");
// MKtl(\xtouch).elAt(\pgSl1, \bt, 7, 0)
// .action_({ q.preset.stepTarg(-1) })
// .elemDesc.label_("pre R -");

