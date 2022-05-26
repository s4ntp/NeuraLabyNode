/*
MKtl(\nanokontrol2).gui.showLabels;
*/

MKtl.all[\nanokontrol2].free;
MKtl(\nanokontrol2, "*trol2");


q = q ? ();
q.knobseeds = 8.collect { 1000.rand }.postln;
q.slseeds = 8.collect { 1000.rand }.postln;

MKtl(\nanokontrol2).elAt(\kn, 0).action_({ |kn|
	var delta = (kn.value - kn.prevValue).clip2(0.07);
	q.stepDryWet(delta * 2);
}).elemDesc.label = "Less More";

MKtl(\nanokontrol2).elAt(\kn, (1..7)).do { |kn, i|
	kn.elemDesc.label = "nudge rd %".format(i);
	kn.action = { |kn|
		var nudgeval = ((kn.deviceValue - kn.prevDeviceValue)).clip2(5);
		var stepval = nudgeval * 0.01;
		var nudgeseed = q.knobseeds[i];
		// [kn.key, stepval, nudgeseed].postln;
		q.nudge(stepval, nudgeseed);
	}
};

MKtl(\nanokontrol2).elAt(\sl).do { |sl, i|
	sl.elemDesc.label = "nudge rd %".format(i);
	sl.action = { |sl|
		var nudgeval = ((sl.deviceValue - sl.prevDeviceValue)).clip2(5);
		var stepval = nudgeval * 0.01;
		var nudgeseed = q.slseeds[i];
		// [sl.key, stepval, nudgeseed].postln;
		q.nudge(stepval, nudgeseed);
	}
};



