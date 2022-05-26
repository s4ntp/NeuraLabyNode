MKtl.all[\beatstep].free;
MKtl(\beatstep, "arturia-beatstep-rel-16").desc;

/*
MKtl(\beatstep).desc.openFile;
MKtl(\beatstep).gui.showLabels;
*/

// upper pads nudge up, lower pads nudge down
MKtl(\beatstep).elAt(0, \pad, nil, \on).do { |pad, i|
	var sign = if (i < 8, "+", "-");
	pad.elemDesc.label = "nudge % rd %".format(sign, i);
	pad.action = { |pad|
		var nudgesign = if (i < q.myseeds.size, -1, 1);
		var nudgeval = pad.value ** 3 * nudgesign * 0.25;
		var nudgeseed = q.myseeds.wrapAt(i);
		// [nudgeval, nudgeseed].round(0.001);
		// [pad.name, pad.value].postln;
		q.nudge(nudgeval, nudgeseed);
	};
};

MKtl(\beatstep).elAt(0, \pad, 0, \on)
.action_({ q.preset.stepCurr(1) })
.elemDesc.label_("pre L +");
MKtl(\beatstep).elAt(0, \pad, 8, \on)
.action_({ q.preset.stepCurr(-1) })
.elemDesc.label_("pre L -");
MKtl(\beatstep).elAt(0, \pad, 1, \on)
.action_({ q.preset.stepCurr(q.preset.settings.size.rand) })
.elemDesc.label_("pre L ?");

MKtl(\beatstep).elAt(0, \pad, 2, \on)
.action_({ q.preset.stepTarg(1) })
.elemDesc.label_("pre R +");
MKtl(\beatstep).elAt(0, \pad, 10, \on)
.action_({ q.preset.stepTarg(-1) })
.elemDesc.label_("pre R -");
MKtl(\beatstep).elAt(0, \pad, 9, \on)
.action_({ q.preset.stepTarg(q.preset.settings.size.rand) })
.elemDesc.label_("pre R ?");



// all knobs except top and bottom first nudge params relative up/down
MKtl(\beatstep).elAt(0, \kn).do { |knob, i|
	knob.deviceValue = 64;
	knob.elemDesc.label = "nudge rd" + (i+1);
	knob.action = { |knob|
		var nudgeval = knob.deviceValue.clip(55, 73) - 64 * 0.01;
		var nudgeseed = q.myseeds.wrapAt(i);
		// [knob.name, knob.deviceValue, nudgeval, nudgeseed].round(0.001).postln;
		defer ({ knob.deviceValue = 64 }, 0.02);
		q.nudge(nudgeval, nudgeseed);
	}
};

// first knob nudges less or more FX :
MKtl(\beatstep).elAt(0, \kn, 0).elemDesc.label = "Less More";
MKtl(\beatstep).elAt(0, \kn, 0).action = { |knob|
	knob.action = { |knob|
		var nudgeval = knob.deviceValue.clip(55, 73) - 64 * 0.01;
		q.stepDryWet(nudgeval);
		// "lessMore step %\n".postf(nudgeval);
		defer ({ knob.deviceValue = 64 }, 0.02);
	};
};

// first knob bottom row nudges preset morph left/right:
MKtl(\beatstep).elAt(0, \kn, 8).elemDesc.label = "Left Right";
MKtl(\beatstep).elAt(0, \kn, 8).action = { |knob|
	knob.action = { |knob|
		var nudgeval = knob.deviceValue.clip(55, 73) - 64 * 0.01;
		q.preset.morphValStep(q.preset.morphVal + nudgeval);
		defer ({ knob.deviceValue = 64 }, 0.02);
	};
};


// weird, bigKnob makes different step sizes even when clicking stepwise?
// so not good to use for master volume.
// MKtl(\beatstep).elAt(0, \bigKnob).action = { |knob| knob.deviceValue.postln };