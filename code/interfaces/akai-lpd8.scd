// four pads nudge up, four pads nudge down
/*
MKtl(\lpd8).gui.showLabels;
*/

MKtl.all[\lpd8].free;
MKtl(\lpd8, "akai-lpd8").desc;

MKtl(\lpd8).elAt(\kn, 0).action_({ |kn|
	var delta = (kn.value - kn.prevValue).clip2(0.07);
	q.stepDryWet(delta * 2)
}).elemDesc.label = "Less More";


MKtl(\lpd8).elAt(\kn, (1..7)).do { |kn, i|
	kn.elemDesc.label = "nudge rd %".format(i);
	kn.action = { |kn|
		var nudgeval = ((kn.deviceValue - kn.prevDeviceValue)).clip2(5);
		var stepval = nudgeval * 0.01;
		var nudgeseed = q.myseeds.wrapAt(i+8);
		// [kn.key, stepval, nudgeseed].postln;
		q.nudge(stepval, nudgeseed);
	}
};

MKtl(\lpd8).elAt(\pad, nil, \on).do { |pad, i|
	var sign = if (i < 4, "-", "+");
	pad.elemDesc.label = "nudge % rd %".format(sign, i % 4);
	pad.action = { |pad|
		var nudgesign = if (i < 4, -1, 1);
		var nudgeval = pad.value ** 3 * nudgesign * 0.25;
		var nudgeseed = q.myseeds.wrapAt(i);
		[nudgeval, nudgeseed].round(0.001);
		// [pad.name, pad.value].postln;
		q.nudge(nudgeval, nudgeseed);
	}
};


