// to switch encoders to relative: on the device, select grp1,
// then go into edit mode: hold \shift, press \edit_setup
// select enc1 on knob 1, change ctlmode to Ccr2,
// hold until running bars go away -> all encoders are now relative


MKtl.all[\uc4].free;
MKtl(\uc4, "*uc4_pg");

// encoders to 64
MKtl(\uc4).elAt(\pgKn1, \kn).deviceValue = 64;

// first encoder does less/more
MKtl(\uc4).elAt(\pgKn1, \kn, 0).action_({ |enc|
	var step = (enc.deviceValue - 64).clip2(5);
	q.stepDryWet((step * 0.015));
	defer ({ enc.deviceValue = 64 }, 0.02);
}).elemDesc.label = "LessMore";

// // use knobs for relative control
MKtl(\uc4).elAt(\pgKn1, \kn, (1..7)).do { |enc, i|
	enc.elemDesc.label = "nudge rd" + (i+1);
	enc.action = { |enc|
		var diff = (enc.deviceValue - 64).clip2(5);
		var step = (diff * 0.02);
		q.nudge(step, q.myseeds[i]);
		defer ({ enc.deviceValue = 64 }, 0.02);
	}
};

// // use knobs for relative control
MKtl(\uc4).elAt(\pgSl1, \sl, (0..7)).do { |enc, i|
	enc.elemDesc.label = "nudge rd" + (i+1);
	enc.action = { |sl|
		var diff = (sl.deviceValue - sl.prevDeviceValue).clip2(5);
		var step = (diff * 0.005);
		q.nudge(step, q.myseeds[i]);
		// defer ({ sl.deviceValue = 64 }, 0.02);
	}
};

