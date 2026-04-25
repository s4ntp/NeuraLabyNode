/*
MKtl(\xtouch).gui.showLabels;
*/

MKtl.all[\xtouch].free;
MKtl(\xtouch, "*x-touch-mini");

// first encoder does less/more
MKtl(\xtouch).elAt(\A, \chan, 0, \enc, 0).action_({ |enc|
	var diff = (enc.deviceValue - enc.prevDeviceValue).clip2(5);
	NeuLab.stepDryWet(diff * 0.015);
}).label = "LessMore";

// last encoder does speaker/object balance
MKtl(\xtouch).elAt(\A, \chan, 7, \enc, 0).action_({ |enc|
	var currval = Ndef(\RawIns).getUni(\balance);
	var diff = (enc.deviceValue - enc.prevDeviceValue).clip2(5);
	Ndef(\RawIns).setUni(\balance, currval + (diff * 0.01));
}).label = "SpkObj";

// button xxx toggles autoMutate
MKtl(\xtouch).elAt(\A, \chan, 0, \bt, \A, \on)
.action_({ NeuLab.auto.autoOn })
.label_("auto ON");
MKtl(\xtouch).elAt(\A, \chan, 0, \bt, \B, \on)
.action_({ NeuLab.auto.autoOff })
.label_("auto OFF");

// // use knobs for relative influence
MKtl(\xtouch).elAt(\A, \chan, (1..6), \enc, 0).do { |enc, i|
	enc.label = "nudge rd" + (i+1);
	enc.action = { |enc|
		var diff = (enc.deviceValue - enc.prevDeviceValue).clip2(5);
		var step = (diff * 0.02);
		NeuLab.nudge(step, NeuLab.myseeds[i]);
	}
};

// MKtl(\xtouch).elAt(\A, \chan, 0)
// .action_({ NeuLab.preset.stepCurr(1) })
// .label_("pre L +");
// MKtl(\xtouch).elAt(\pgSl1, \bt, 5, 0)
// .action_({ NeuLab.preset.stepCurr(-1) })
// .label_("pre L -");
//
// MKtl(\xtouch).elAt(\pgSl1, \bt, 6, 0)
// .action_({ NeuLab.preset.stepTarg(1) })
// .label_("pre R +");
// MKtl(\xtouch).elAt(\pgSl1, \bt, 7, 0)
// .action_({ NeuLab.preset.stepTarg(-1) })
// .label_("pre R -");

