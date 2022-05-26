/*
MKtl(\xtouch).gui.showLabels;
*/

MKtl.all[\xtouch].free;
MKtl(\xtouch, "*x-touch-mini");

q = q ? ();
q.myseeds = 8.collect { 1000.rand };

// first encoder does less/more
MKtl(\xtouch).elAt(\A, \chan, 0, \enc, 0).action_({ |enc|
	var diff = (enc.deviceValue - enc.prevDeviceValue).clip2(5);
	q.stepDryWet(diff * 0.015);
}).elemDesc.label = "LessMore";

// // use knobs for relative control
MKtl(\xtouch).elAt(\A, \chan, (1..7), \enc, 0).do { |enc, i|
	enc.elemDesc.label = "nudge rd" + (i+1);
	enc.action = { |enc|
		var diff = (enc.deviceValue - enc.prevDeviceValue).clip2(5);
		var step = (diff * 0.02);
		q.nudge(step, q.myseeds[i]);
	}
};
