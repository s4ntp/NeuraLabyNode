(
q.myseeds = 8.collect { 1000.rand };

try { q.win.close };

q.font = Font(Font.defaultMonoFace, 14);
q.win = Window("Neural Labyrinths 2022 ... made in Berl¡n", 800@460).front;
q.meter = ServerMeterView(s, q.win, 0@0, 2, 2);
q.stetho = Stethoscope(s, 4, view: CompositeView(q.win, Rect(0, 220, 250, 250)));
q.stetho.view.children.keep(4).do(_.visible_(false));
q.stetho.xZoom = 0.1;

q.mixerbut = Button(q.win, Rect(140, 44, 100, 40))
.states_([["mixer"]]).font_(q.font);
q.mixerbut.action = {
		q.mixer = NdefMixer.small(s, 8);
		q.mixer.parent.name_(\NdefMixer);
		ProxyMeter.addMixer(q.mixer);
};
q.mktlbut = Button(q.win, Rect(140, 86, 100, 40)) .states_([["interface"]]).font_(q.font);
q.mktlbut.action = { MKtl.all.do { |mk| mk.gui.showLabels } };


q.butZone = CompositeView(q.win, Rect(250, 0, 104, 460)).background_(Color.grey(0.7));

q.butZone.addFlowLayout(2@2, 1@1);

StaticText(q.butZone, 100@40).string_("FX Balance").font_(q.font).align_(\center);

q.drywetBut = Button(q.butZone, 100@40).states_([["less...MORE"]]).font_(q.font);
q.drywetBut.mouseDownAction = { |b, x, y|
	[b, x, y].postln;
	q.stepDryWet(x-50 * 0.01);
};

q.randBut = Button(q.butZone, 100@40).states_([["vary...RAND"]]).font_(q.font);
q.randBut.mouseDownAction = { |b, x, y|
	// [b, x, y].postln;
	NdefPreset(\NeuraLaby).setRand((x * 0.01).squared);
};

StaticText(q.butZone, 100@40).string_("< Nudges >").font_(q.font).align_(\center);
(1..7).do { |num, i|
	Button(q.butZone, 100@40)
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
	[
		[\LessFX, \extra, { q.stepDryWet(-0.05) } ],
		[\MoreFX, \extra, { q.stepDryWet(0.05) } ],
		[ \ins, \slotCtl ],
		[ \freqMod, \slotCtl ],
		[ \ampMod, \slotCtl ],
		[ \hiPass, \slotCtl ],
		[ \gapz, \slotCtl ],
		[ \limiter, \slotCtl ];
	],
	q.nlwin
);
q.pcg.butZone.bounds = q.pcg.butZone.bounds.width_(70);
q.pcg.buttons.do { |bt| bt.bounds = bt.bounds.width_(60) };
// disable all on/off buttons?
q.pcg.buttons.copyRange(2, 7).do(_.enabled_(false));

// editGui shows levels
ProxyMeter.addNdefGui(q.pcg.editGui);
// make it smaller
q.pcg.editGui.zone.bounds_(q.pcg.editGui.zone.bounds.moveBy(-40, 0));
// make nameView more visible
q.pcg.editGui.nameView
.background_(Color.blue).stringColor_(Color.white)
.font_(Font(Font.defaultSansFace, 13));
);


