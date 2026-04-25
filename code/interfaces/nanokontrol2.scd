/*
MKtl(\nanokontrol2).gui.showLabels;
*/

MKtl.all[\nanokontrol2].free;
MKtl(\nanokontrol2, "*trol2");

MKtl(\nanokontrol2).elAt(\tr, \stop)
.action_({ |bt| if (bt.isOn) { NeuLab.auto.autoOff }})
.label_("auto OFF");
MKtl(\nanokontrol2).elAt(\tr, \play)
.action_({ |bt| if (bt.isOn) { NeuLab.auto.autoOn }})
.label_("auto ON");


MKtl(\nanokontrol2).elAt(\kn, 0).action_({ |kn|
	var delta = (kn.value - kn.prevValue).clip2(0.07);
	NeuLab.stepDryWet(delta * 2);
}).label = "Less More";

// left lower knob is spkObj balance
MKtl(\nanokontrol2).elAt(\kn, 7).action_({ |kn|
	var delta = (kn.value - kn.prevValue).clip2(0.07);
	NeuLab.stepSpkObj(delta * 2)
}).label = "Spk Obj";


MKtl(\nanokontrol2).elAt(\kn, (1..6)).do { |kn, i|
	kn.label = "nudge rd %".format(i);
	kn.action = { |kn|
		var nudgeval = ((kn.deviceValue - kn.prevDeviceValue)).clip2(5);
		var stepval = nudgeval * 0.01;
		var nudgeseed = NeuLab.myseeds.wrapAt(i);
		// [kn.key, stepval, nudgeseed].postln;
		NeuLab.nudge(stepval, nudgeseed);
	}
};

MKtl(\nanokontrol2).elAt(\sl).do { |sl, i|
	sl.label = "nudge rd %".format(i);
	sl.action = { |sl|
		var nudgeval = ((sl.deviceValue - sl.prevDeviceValue)).clip2(5);
		var stepval = nudgeval * 0.01;
		var nudgeseed = NeuLab.myseeds.wrapAt(i + 8);
		// [sl.key, stepval, nudgeseed].postln;
		NeuLab.nudge(stepval, nudgeseed);
	}
};



