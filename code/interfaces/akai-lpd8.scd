// four pads nudge up, four pads nudge down
/*
MKtl(\lpd8).gui.showLabels;
*/

MKtl.all[\lpd8].free;
MKtl(\lpd8, "akai-lpd8");

// left upper pad is autoON
MKtl(\lpd8).elAt(\pad, 0, \on)
.action_({ q.autoOn })
.elemDesc.label_("auto ON");
// left lower pad is autoOFF
MKtl(\lpd8).elAt(\pad, 4, \on)
.action_({ q.autoOff })
.elemDesc.label_("auto OFF");

// left upper knob is drywet balance
MKtl(\lpd8).elAt(\kn, 0).action_({ |kn|
	var delta = (kn.value - kn.prevValue).clip2(0.07);
	q.stepDryWet(delta * 2)
}).elemDesc.label = "Less More";

// left lower knob is spkObj balance
MKtl(\lpd8).elAt(\kn, 4).action_({ |kn|
	var delta = (kn.value - kn.prevValue).clip2(0.07);
	q.stepDryWet(delta * 2)
}).elemDesc.label = "Spk Obj";

// pads to nudge
MKtl(\lpd8).elAt(\kn, (1..3) ++ (5..7)).do { |kn, i|
	kn.elemDesc.label = "nudge rd %".format(i);
	kn.action = { |kn|
		var nudgeval = ((kn.deviceValue - kn.prevDeviceValue)).clip2(5);
		var stepval = nudgeval * 0.01;
		var nudgeseed = q.myseeds.wrapAt(i+8);
		// [kn.key, stepval, nudgeseed].postln;
		q.nudge(stepval, nudgeseed);
	}
};

MKtl(\lpd8).elAt(\pad, (1..3) ++ (5..7), \on).do { |pad, i|
	var sign = if (i < 3, "-", "+");
	pad.elemDesc.label = "nudge % rd %".format(sign, i % 3);
	pad.action = { |pad|
		var nudgesign = if (i < 4, -1, 1);
		var nudgeval = pad.value ** 3 * nudgesign * 0.25;
		var nudgeseed = q.myseeds.wrapAt(i);
		// [pad.name, pad.value].postln;
		q.nudge(nudgeval, nudgeseed);
	}
};
