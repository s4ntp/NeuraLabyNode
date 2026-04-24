/*
NeuLab.testRaspiScreen
Window.closeAll
*/

(
WinBounds.addMake(\Mixer, {
	NeuLab.mixer = NdefMixer.small(s, 8);
	NeuLab.mixer.parent.name_(\Mixer);
	ProxyMeter.addMixer(NeuLab.mixer);
	// return window for WinBounds:
	NeuLab.mixer.parent;
});

try { NeuLab.win.close };

NeuLab.font = Font(Font.defaultMonoFace, 14);
NeuLab.win = Window(NeuLab.myhostname ++ "_NeuraLaby", 800@455).front;
NeuLab.win.userCanClose = false;
NeuLab.meter = ServerMeterView(s, NeuLab.win, 0@0, 2, 2);
NeuLab.stetho = Stethoscope(s, 4, view: CompositeView(NeuLab.win, Rect(0, 220, 250, 250)));
NeuLab.stetho.view.children.keep(4).do(_.visible_(false));
NeuLab.stetho.xZoom = 0.1;

NeuLab.uv = UserView(NeuLab.win, NeuLab.stetho.view.bounds.moveTo(0, 220).width_(200));
NeuLab.uv.background_(Color.blue(1, 0));

NeuLab.uv.drawFunc = {
	Pen.stringCenteredIn("Out_Spk\n\n\nOut_Obj\n\n\nIn_Mic\n\n\nIn_Obj\n", NeuLab.uv.bounds.moveTo(0, 0), NeuLab.font.copy.size_(16), Color(0.62, 0.62, 1.0));
};
NeuLab.win.refresh;

NeuLab.stetho.view.visible = true;

NeuLab.testRaspiScreen = {
	NeuLab.laby.raspibounds = Rect(0, 0, 797, 439);

	"windows outside raspi bounds:".postln;
	Window.allWindows.select { |win|
		NeuLab.laby.raspibounds.contains(win.bounds).not
	}.collect { |win| [win.name, win.bounds] }.printAll;
	"";
};


NeuLab.butsize = 100@25;
NeuLab.texsize = 100@36;

NeuLab.guibutzone = CompositeView(NeuLab.win, Rect(130, 0, 110, 220)).background_(Color.grey(0.7));
NeuLab.guibutzone.addFlowLayout(2@2, 1@1);

StaticText(NeuLab.guibutzone, NeuLab.texsize).string_("Extras:")
.align_(\center).font_(NeuLab.font);

NeuLab.neuralbut = Button(NeuLab.guibutzone, NeuLab.butsize) .states_([["NeuralSynth"]]).font_(NeuLab.font);
NeuLab.neuralbut.action = { WinBounds.showOrMake(\NeuralSynth) };

NeuLab.redobut = Button(NeuLab.guibutzone, NeuLab.butsize) .states_([["RESET SOUND"]]).font_(NeuLab.font);
NeuLab.redobut.action = { Ndef(\NeuraLaby).rebuild };

NeuLab.autoBut = Button(NeuLab.guibutzone, NeuLab.butsize)
.states_([["autoMutate?"],
	["autoMutate!", Color.black, Color.green]
]).font_(NeuLab.font);
NeuLab.autoBut.action = nil;
NeuLab.autoBut.mouseDownAction = { |bt, x, y, mod|
	var tdef = Tdef(\autoMutate);
	if (x >= 90) {
		tdef.gui;
	} { NeuLab.autoToggle };
	defer ({ bt.value = tdef.isPlaying.not.binaryValue }, 0.05);
};

NeuLab.mixerbut = Button(NeuLab.guibutzone, NeuLab.butsize)
.states_([["Mixer"]]).font_(NeuLab.font);
NeuLab.mixerbut.action = { WinBounds.showOrMake(\Mixer) };

NeuLab.findbut = Button(NeuLab.guibutzone, NeuLab.butsize) .states_([["MKtl.find"]]).font_(NeuLab.font);
NeuLab.findbut.action = {
	MKtl.find([\midi, \hid]);
	(NeuLab.dir.laby +/+ "LoadMidiIF.scd".postln).loadPaths;
};

NeuLab.ifbut = Button(NeuLab.guibutzone, NeuLab.butsize) .states_([["interface"]]).font_(NeuLab.font);
NeuLab.ifbut.action = { MKtl.all.do { |mk| mk.gui.showLabels } };

NeuLab.udbut = Button(NeuLab.guibutzone, NeuLab.butsize) .states_([["quarkUpdate"]]).font_(NeuLab.font);
NeuLab.udbut.action = { Quark("NeuraLabyNode").update };

///////

NeuLab.butZone = CompositeView(NeuLab.win, Rect(248, 0, 106, 440)).background_(Color.grey(0.7));
NeuLab.butZone.addFlowLayout(2@2, 1@1);

StaticText(NeuLab.butZone, NeuLab.texsize).string_("Presets:")
.font_(NeuLab.font).align_(\center);

Button(NeuLab.butZone, 50 @ NeuLab.butsize.y).font_(NeuLab.font)
.states_([["- ? +"]])
.mouseDownAction_({ |bt, x, y|
	var step = x div: 16 - 1;
	if (step == 0) { step = NeuLab.preset.settings.size.rand };
	NeuLab.preset.stepCurr(step);
});

Button(NeuLab.butZone, 50 @ NeuLab.butsize.y).font_(NeuLab.font)
.states_([["- ? +"]])
.mouseDownAction_({ |bt, x, y|
	var step = x div: 16 - 1;
	if (step == 0) { step = NeuLab.preset.settings.size.rand };
	NeuLab.preset.stepTarg(step);
});

Button(NeuLab.butZone, NeuLab.butsize).font_(NeuLab.font)
.states_([["<< <-> >>"]])
.mouseDownAction_({ |bt, x, y|
	var step = (x / 50 - 1);
	step = step * step.abs;
	NeuLab.preset.morphValStep(NeuLab.preset.morphVal + step);
});

StaticText(NeuLab.butZone, NeuLab.texsize).string_("Balance:")
.font_(NeuLab.font).align_(\center);


// make a JITView: value, parent, bounds
NeuLab.balgui = MView(0.5, NeuLab.butZone, Rect(0, 0, 100, 25));
// needs a spec to display proper number range
NeuLab.balgui.putDict(\myspec, \pan).refresh;
NeuLab.balgui.label_('Spk<-->Obj');
NeuLab.balgui.action.add(\set, { |sl| Ndef(\RawIns).set(\balance, sl.value) });

NeuLab.balskip.stop.free;
NeuLab.balskip = SkipJack({
	var balval = Ndef(\RawIns).get(\balance);
	var autoval = Tdef(\autoMutate).isPlaying;
	if (NeuLab.balgui.value != balval) {
		NeuLab.balgui.value = balval
	};
	if (NeuLab.autoBut.value != autoval) {
		NeuLab.autoBut.value = autoval
	};
}, 0.2);

NeuLab.balgui.drawFunc.disable(\code);
NeuLab.balgui.drawFunc.enable(\number);

NeuLab.drywetBut = Button(NeuLab.butZone, NeuLab.butsize).states_([["dry <-> FX"]])
.font_(NeuLab.font);
NeuLab.drywetBut.mouseDownAction = { |b, x, y|
	// [b, x, y].postln;
	NeuLab.stepDryWet(x-50 * 0.01);
};

NeuLab.randBut = Button(NeuLab.butZone, NeuLab.butsize).states_([["vary...RAND"]]).font_(NeuLab.font);
NeuLab.randBut.mouseDownAction = { |b, x, y|
	// [b, x, y].postln;
	NdefPreset(\NeuraLaby).setRand((x * 0.01).squared);
};

StaticText(NeuLab.butZone, NeuLab.texsize).string_("Nudges:")
.font_(NeuLab.font).align_(\center);
(1..7).do { |num, i|
	Button(NeuLab.butZone, NeuLab.butsize)
	.states_([["-- - % + ++".format(num)]])
	.font_(NeuLab.font)
	.mouseDownAction_({ |b, x, y|
		// [b, x, y].postln;
		NeuLab.nudge(x-50 * 0.01, NeuLab.myseeds[i]);
	});
};
);

(
// NeuLab.nlwin = Window('NeuraLaby', Rect(350,0,450,460)).front;
NeuLab.nlwin = CompositeView(NeuLab.win, Rect(350,0,450,460));
NeuLab.nlwin.addFlowLayout;
NeuLab.nlwin.asView.decorator.shift(25, 0);
NeuLab.npg = NdefPresetGui(NdefPreset(\NeuraLaby), 0, NeuLab.nlwin);
NeuLab.pcg = NeuLab.pchain.gui(22,
	parent: NeuLab.nlwin
);
NeuLab.pcg.butZone.bounds = NeuLab.pcg.butZone.bounds.width_(70);
NeuLab.pcg.buttons.do { |bt| bt.bounds = bt.bounds.width_(60) };

///// for installation mode:
///// disable all on/off buttons:
// NeuLab.pcg.buttons.do(_.enabled_(false));
//// disable sto, del, edit, doc

// editGui shows levels
ProxyMeter.addNdefGui(NeuLab.pcg.editGui);
// make it smaller
NeuLab.pcg.editGui.zone.bounds_(NeuLab.pcg.editGui.zone.bounds.moveBy(-40, 0));
// make nameView more visible
NeuLab.pcg.editGui.nameView
.background_(Color.blue).stringColor_(Color.white)
.font_(Font(Font.defaultSansFace, 13));
);


