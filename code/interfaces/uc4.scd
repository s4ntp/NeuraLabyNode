// to switch encoders to relative: on the device, select grp1,
// then go into edit mode: hold \shift, press \edit_setup
// select enc1 on knob 1, change ctlmode to Ccr2,
// hold until running bars go away -> all encoders are now relative

/***
MKtl(\uc4).gui.showLabels;
***/

MKtl.all[\uc4].free;
MKtl(\uc4, "*uc4_pg");


MKtl(\uc4).elAt(\pgSl1, \bt, 0, 0)
.action_({ q.autoOn })
.elemDesc.label = "autoON";
MKtl(\uc4).elAt(\pgSl1, \bt, 1, 0)
.action_({ q.autoOff })
.elemDesc.label = "autoOFF";

MKtl(\uc4).elAt(\pgSl1, \bt, 4, 0)
.action_({ q.preset.stepCurr(1) })
.elemDesc.label_("pre L +");
MKtl(\uc4).elAt(\pgSl1, \bt, 5, 0)
.action_({ q.preset.stepCurr(-1) })
.elemDesc.label_("pre L -");

MKtl(\uc4).elAt(\pgSl1, \bt, 6, 0)
.action_({ q.preset.stepTarg(1) })
.elemDesc.label_("pre R +");
MKtl(\uc4).elAt(\pgSl1, \bt, 7, 0)
.action_({ q.preset.stepTarg(-1) })
.elemDesc.label_("pre R -");


// encoders to 64
MKtl(\uc4).elAt(\pgKn1, \kn).deviceValue = 64;

// first encoder does less/more
MKtl(\uc4).elAt(\pgKn1, \kn, 0).action_({ |enc|
	var step = (enc.deviceValue - 64).clip2(5);
	q.stepDryWet((step * 0.015));
	defer ({ enc.deviceValue = 64 }, 0.02);
}).elemDesc.label = "LessMore";

// first bottom encoder does spk object balance
MKtl(\uc4).elAt(\pgKn1, \kn, 4).action_({ |enc|
	var step = (enc.deviceValue - 64).clip2(5);
	q.stepSpkObj((step * 0.015));
	defer ({ enc.deviceValue = 64 }, 0.02);
}).elemDesc.label = "Spk Obj";


// // use knobs for relative control
MKtl(\uc4).elAt(\pgKn1, \kn, [1, 2, 3, 5, 6, 7]).do { |enc, i|
	enc.elemDesc.label = "nudge rd" + (i+1);
	enc.action = { |enc|
		var diff = (enc.deviceValue - 64).clip2(5);
		var step = (diff * 0.02);
		q.nudge(step, q.myseeds[i]);
		defer ({ enc.deviceValue = 64 }, 0.02);
	}
};

// // use sliders for relative control
MKtl(\uc4).elAt(\pgSl1, \sl, (0..7)).do { |enc, i|
	enc.elemDesc.label = "nudge rd" + (i+1);
	enc.action = { |sl|
		var diff = (sl.deviceValue - sl.prevDeviceValue).clip2(5);
		var step = (diff * 0.005);
		q.nudge(step, q.myseeds[i]);
		// defer ({ sl.deviceValue = 64 }, 0.02);
	}
};

// // use xfader for preset crossfade
MKtl(\uc4).elAt('xfader').do { |fad|
	fad.elemDesc.label = "LpreR";
	fad.action = { |fad|
		var nudgeval = fad.value - fad.prevValue * 2;
		q.preset.morphValStep(q.preset.morphVal + nudgeval);
	}
};

