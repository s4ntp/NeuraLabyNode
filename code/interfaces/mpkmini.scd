/*
MKtl(\mpkmini).gui.showLabels;
*/

MKtl.all[\mpkmini].free;
MKtl(\mpkmini, "*mpkmini");

MKtl(\mpkmini).elAt(\bt)
.action_({ |bt| if (bt.isOn) { NeuLab.auto.autoToggle }})
.label_("auto TOGGLE");


MKtl(\mpkmini).elAt(\kn, 0).action_({ |kn|
	var delta = (kn.value - kn.prevValue).clip2(0.07);
	NeuLab.stepDryWet(delta * 2);
}).label = "Less More";

// left lower knob is spkObj balance
MKtl(\mpkmini).elAt(\kn, 7).action_({ |kn|
	var delta = (kn.value - kn.prevValue).clip2(0.07);
	NeuLab.stepSpkObj(delta * 2)
}).label = "Spk Obj";


MKtl(\mpkmini).elAt(\kn, (1..6)).do { |kn, i|
	kn.label = "nudge rd %".format(i);
	kn.action = { |kn|
		var nudgeval = ((kn.deviceValue - kn.prevDeviceValue)).clip2(5);
		var stepval = nudgeval * 0.01;
		var nudgeseed = NeuLab.myseeds.wrapAt(i);
		// [kn.key, stepval, nudgeseed].postln;
		NeuLab.nudge(stepval, nudgeseed);
	}
};

MKtl(\mpkmini).elAt(\pad, 1).do { |pad, i|
	pad.label = "nudge rd %".format(i).postln;
	[\on, \off].do {|onoff|
		pad.elAt(onoff).action = {
			var stepval, nudgeseed;
			stepval = pad.elAt(\on).deviceValue * 0.01;
			if (onoff == \off) { stepval = stepval.neg };
			nudgeseed = NeuLab.myseeds.wrapAt(i + 8);
			NeuLab.nudge(stepval.postln, nudgeseed);
		};
	};
};