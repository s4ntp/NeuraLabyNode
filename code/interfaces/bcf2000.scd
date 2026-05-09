/*
MKtl(\bcf2000).gui.showLabels;
*/

MKtl.all[\bcf2000].free;
MKtl(\bcf2000, "*bcf2000");

MKtl(\bcf2000).elAt(\tr, 0, 0)
.action_({ |bt| if (bt.isOn) { NeuLab.auto.autoOff }})
.label_("auto OFF");
MKtl(\bcf2000).elAt(\tr, 0, 1)
.action_({ |bt| if (bt.isOn) { NeuLab.auto.autoOn }})
.label_("auto ON");


MKtl(\bcf2000).elAt(\kn, 0, 0).action_({ |kn|
	var delta = (kn.value - kn.prevValue).clip2(0.07);
	NeuLab.stepDryWet(delta * 2);
}).label = "Less More";

// left lower knob is spkObj balance
MKtl(\bcf2000).elAt(\kn, 0, 7).action_({ |kn|
	var delta = (kn.value - kn.prevValue).clip2(0.07);
	NeuLab.stepSpkObj(delta * 2)
}).label = "Spk Obj";


MKtl(\bcf2000).elAt(\kn, 0, (1..6)).do { |kn, i|
	kn.label = "nudge rd %".format(i);
	kn.action = { |kn|
		var nudgeval = ((kn.deviceValue - kn.prevDeviceValue)).clip2(5);
		var stepval = nudgeval * 0.01;
		var nudgeseed = NeuLab.myseeds.wrapAt(i);
		// [kn.key, stepval, nudgeseed].postln;
		NeuLab.nudge(stepval, nudgeseed);
	}
};

MKtl(\bcf2000).elAt(\sl).do { |sl, i|
	sl.label = "nudge rd %".format(i);
	sl.action = { |sl|
		var nudgeval = ((sl.deviceValue - sl.prevDeviceValue)).clip2(5);
		var stepval = nudgeval * 0.01;
		var nudgeseed = NeuLab.myseeds.wrapAt(i + 8);
		// [sl.key, stepval, nudgeseed].postln;
		NeuLab.nudge(stepval, nudgeseed);
	}
};



