(
q.myseeds = 8.collect { 1000.rand };

try { q.win.close };

q.font = Font(Font.defaultMonoFace, 14);
q.win = Window("Neural Labyrinths 2022 ... made in Berl¡n", 800@460).front;
q.meter = ServerMeterView(s, q.win, 0@0, 2, 2);
q.stetho = Stethoscope(s, 4, view: CompositeView(q.win, Rect(0, 220, 250, 250)));
q.stetho.view.children.keep(4).do(_.visible_(false));
q.stetho.xZoom = 0.1;


q.butsize = 100@30;
q.texsize = 100@36;

q.guibutzone = CompositeView(q.win, Rect(130, 0, 110, 220)).background_(Color.grey(0.7));
q.guibutzone.addFlowLayout(2@2, 1@1);

StaticText(q.guibutzone, q.texsize).string_("More Guis:")
.align_(\center).font_(q.font);

q.mixerbut = Button(q.guibutzone, q.butsize)
.states_([["mixer"]]).font_(q.font);
q.mixerbut.action = {
	q.mixer = NdefMixer.small(s, 8);
	q.mixer.parent.name_(\NdefMixer);
	ProxyMeter.addMixer(q.mixer);
};
q.mktlbut = Button(q.guibutzone, q.butsize) .states_([["MKtl find"]]).font_(q.font);
q.mktlbut.action = { MKtl.find };

q.mktlbut = Button(q.guibutzone, q.butsize) .states_([["interface"]]).font_(q.font);
q.mktlbut.action = { MKtl.all.do { |mk| mk.gui.showLabels } };

///////

q.butZone = CompositeView(q.win, Rect(248, 0, 106, 460)).background_(Color.grey(0.7));
q.butZone.addFlowLayout(2@2, 1@1);

StaticText(q.butZone, q.texsize).string_("Presets:")
.font_(q.font).align_(\center);

Button(q.butZone, 50 @ q.butsize.y).font_(q.font)
.states_([["- ? +"]])
.mouseDownAction_({ |bt, x, y|
	var step = x div: 16 - 1;
	if (step == 0) { step = q.preset.settings.size.rand };
	q.preset.stepCurr(step);
});

Button(q.butZone, 50 @ q.butsize.y).font_(q.font)
.states_([["- ? +"]])
.mouseDownAction_({ |bt, x, y|
	var step = x div: 16 - 1;
	if (step == 0) { step = q.preset.settings.size.rand };
	q.preset.stepTarg(step);
});

Button(q.butZone, q.butsize).font_(q.font)
.states_([["<< <-> >>"]])
.mouseDownAction_({ |bt, x, y|
	var step = (x / 50 - 1);
	step = step * step.abs;
	q.preset.morphValStep(q.preset.morphVal + step);
});


StaticText(q.butZone, q.texsize).string_("FX Balance:").font_(q.font).align_(\center);

q.drywetBut = Button(q.butZone, q.butsize).states_([["less...MORE"]]).font_(q.font);
q.drywetBut.mouseDownAction = { |b, x, y|
	[b, x, y].postln;
	q.stepDryWet(x-50 * 0.01);
};

q.randBut = Button(q.butZone, q.butsize).states_([["vary...RAND"]]).font_(q.font);
q.randBut.mouseDownAction = { |b, x, y|
	// [b, x, y].postln;
	NdefPreset(\NeuraLaby).setRand((x * 0.01).squared);
};

StaticText(q.butZone, q.texsize).string_("Nudges:")
.font_(q.font).align_(\center);
(1..7).do { |num, i|
	Button(q.butZone, q.butsize)
	.states_([["-- - % + ++".format(num)]])
	.font_(q.font)
	.mouseDownAction_({ |b, x, y|
		// [b, x, y].postln;
		q.nudge(x-50 * 0.01, q.myseeds[i]);
	});
};
);

(
// q.nlwin = Window('NeuraLaby', Rect(350,0,450,460)).front;
q.nlwin = CompositeView(q.win, Rect(350,0,450,460));
q.nlwin.addFlowLayout;
q.nlwin.asView.decorator.shift(25, 0);
q.npg = NdefPresetGui(NdefPreset(\NeuraLaby), 0, q.nlwin);
q.pcg = q.pchain.gui(22,
	// [
	// 	[\LessFX, \extra, { q.stepDryWet(-0.05) } ],
	// 	[\MoreFX, \extra, { q.stepDryWet(0.05) } ],
	// 	[ \ins, \slotCtl ],
	// 	[ \freqMod, \slotCtl ],
	// 	[ \ampMod, \slotCtl ],
	// 	[ \hiPass, \slotCtl ],
	// 	[ \gapz, \slotCtl ],
	// 	[ \limiter, \slotCtl ];
	// ],
	parent: q.nlwin
);
q.pcg.butZone.bounds = q.pcg.butZone.bounds.width_(70);
q.pcg.buttons.do { |bt| bt.bounds = bt.bounds.width_(60) };

///// for installation mode:
///// disable all on/off buttons:
// q.pcg.buttons.do(_.enabled_(false));
//// disable sto, del, edit, doc

// editGui shows levels
ProxyMeter.addNdefGui(q.pcg.editGui);
// make it smaller
q.pcg.editGui.zone.bounds_(q.pcg.editGui.zone.bounds.moveBy(-40, 0));
// make nameView more visible
q.pcg.editGui.nameView
.background_(Color.blue).stringColor_(Color.white)
.font_(Font(Font.defaultSansFace, 13));
);


