MKtl.all[\beatstep].free;
MKtl(\beatstep, "arturia-beatstep-rel-16").desc;

/*
MKtl(\beatstep).gui.showLabels;
MKtl(\beatstep).desc.openFile;
MKtl(\beatstep).gui.showLabels;
*/

// upper pads nudge up, lower pads nudge down
MKtl(\beatstep).elAt(0, \pad, nil, \on).do { |pad, i|
	var sign = if (i < 8, "+", "-");
	pad.label = "nudge % rd %".format(sign, i);
	pad.action = { |pad|
		var nudgesign = if (i < NeuLab.myseeds.size, -1, 1);
		var nudgeval = pad.value ** 3 * nudgesign * 0.25;
		var nudgeseed = NeuLab.myseeds.wrapAt(i);
		// [nudgeval, nudgeseed].round(0.001);
		// [pad.name, pad.value].postln;
		NeuLab.nudge(nudgeval, nudgeseed);
	};
};

MKtl(\beatstep).elAt(0, \pad, 0, \on)
.action_({ NeuLab.auto.autoOn })
.label_("auto ON");
MKtl(\beatstep).elAt(0, \pad, 8, \on)
.action_({ NeuLab.auto.autoOff })
.label_("auto OFF");


MKtl(\beatstep).elAt(0, \pad, 1, \on)
.action_({ NeuLab.preset.stepCurr(1) })
.label_("pre L +");
MKtl(\beatstep).elAt(0, \pad, 2, \on)
.action_({ NeuLab.preset.stepCurr(-1) })
.label_("pre L -");
MKtl(\beatstep).elAt(0, \pad, 3, \on)
.action_({ NeuLab.preset.stepCurr(NeuLab.preset.settings.size.rand) })
.label_("pre L ?");

MKtl(\beatstep).elAt(0, \pad, 9, \on)
.action_({ NeuLab.preset.stepTarg(1) })
.label_("pre R +");
MKtl(\beatstep).elAt(0, \pad, 10, \on)
.action_({ NeuLab.preset.stepTarg(-1) })
.label_("pre R -");
MKtl(\beatstep).elAt(1, \pad, 11, \on)
.action_({ NeuLab.preset.stepTarg(NeuLab.preset.settings.size.rand) })
.label_("pre R ?");

// all knobs except top and bottom first and bottom last
// nudge params relative up/down
MKtl(\beatstep).elAt(0, \kn).do { |knob, i|
	knob.deviceValue = 64;
	knob.label = "nudge rd" + (i+1);
	knob.action = { |knob|
		var nudgeval = knob.deviceValue.clip(55, 73) - 64 * 0.01;
		var nudgeseed = NeuLab.myseeds.wrapAt(i);
		// [knob.name, knob.deviceValue, nudgeval, nudgeseed].round(0.001).postln;
		defer ({ knob.deviceValue = 64 }, 0.02);
		NeuLab.nudge(nudgeval, nudgeseed);
	}
};

// first knob nudges less or more FX :
MKtl(\beatstep).elAt(0, \kn, 0).label = "Less More";
MKtl(\beatstep).elAt(0, \kn, 0).action = { |knob|
	var nudgeval = knob.deviceValue.clip(55, 73) - 64 * 0.01;
	NeuLab.stepDryWet(nudgeval);
	// "lessMore step %\n".postf(nudgeval);
	defer ({ knob.deviceValue = 64 }, 0.02);
};

// first knob bottom row nudges preset morph left/right:
MKtl(\beatstep).elAt(0, \kn, 8).label = "Left Right";
MKtl(\beatstep).elAt(0, \kn, 8).action = { |knob|
	var nudgeval = knob.deviceValue.clip(55, 73) - 64 * 0.01;
	NeuLab.preset.morphValStep(NeuLab.preset.morphVal + nudgeval);
	defer ({ knob.deviceValue = 64 }, 0.02);
};

// last knob bottom row tiltsspeaker/object balance:
MKtl(\beatstep).elAt(0, \kn, 15).label = "Spk Obj";
MKtl(\beatstep).elAt(0, \kn, 15).action = { |knob|
	var nudgeval = knob.deviceValue.clip(55, 73) - 64 * 0.01;
	NeuLab.stepSpkObj(nudgeval);
	defer ({ knob.deviceValue = 64 }, 0.02);
};


// weird, bigKnob makes different step sizes even when clicking stepwise?
// so not good to use for master volume.
// MKtl(\beatstep).elAt(0, \bigKnob).action = { |knob| knob.deviceValue.postln };