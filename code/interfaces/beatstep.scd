MKtl.all[\beatstep].free;
MKtl(\beatstep, "arturia-beatstep-rel-16").desc;


/*
MKtl(\beatstep).desc.openFile;
MKtl(\beatstep).gui.showLabels;
*/


q = q ? ();
q.padseeds = 8.collect { 1000.rand }.postln;
q.knobseeds = 16.collect { 1000.rand }.postln;

// upper pads nudge up, lower pads nudge down
MKtl(\beatstep).elAt(0, \pad, nil, \on).do { |pad, i|
	var sign = if (i < 8, "+", "-");
	pad.elemDesc.label = "nudge % rd %".format(sign, i);
	pad.action = { |pad|
		var nudgesign = if (i < q.padseeds.size, -1, 1);
		var nudgeval = pad.value ** 3 * nudgesign * 0.25;
		var nudgeseed = q.padseeds.wrapAt(i);
		// [nudgeval, nudgeseed].round(0.001);
		// [pad.name, pad.value].postln;
		q.nudge(nudgeval, nudgeseed);
	};
};

// all knobs except first nudge params relative up/down
MKtl(\beatstep).elAt(0, \kn, (1..15)).do { |knob, i|
	knob.deviceValue = 64;
	knob.elemDesc.label = "nudge rd" + (i+1);
	knob.action = { |knob|
		var nudgeval = knob.deviceValue.clip(55, 73) - 64 * 0.01;
		var nudgeseed = q.knobseeds.wrapAt(i);
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


// weird, bigKnob makes different step sizes even when clicking stepwise?
// so not good to use for master volume.
// MKtl(\beatstep).elAt(0, \bigKnob).action = { |knob| knob.deviceValue.postln };