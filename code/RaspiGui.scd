/*
NeuLab.g.testRaspiScreen
Window.closeAll
*/

(
// put all gui things in NeuLab.g:

WinBounds.addMake(\Mixer, {
	NeuLab.g.mixer = NdefMixer.small(s, 8);
	NeuLab.g.mixer.parent.name_(\Mixer);
	ProxyMeter.addMixer(NeuLab.g.mixer);
	// return window for WinBounds:
	NeuLab.g.mixer.parent;
});

try { NeuLab.g.win.close };

NeuLab.g.font = Font(Font.defaultMonoFace, 14);
NeuLab.g.win = Window(NeuLab.g.myhostname ++ "_NeuraLaby", 800@455).front;
NeuLab.g.win.userCanClose = false;

// Left side: meter, stethoscope, buttons

NeuLab.g.meter = ServerMeterView(s, NeuLab.g.win, 0@0, 2, 2);
NeuLab.g.stetho = Stethoscope(s, 4, view: CompositeView(NeuLab.g.win, Rect(0, 220, 250, 250)));
NeuLab.g.stetho.view.children.keep(4).do(_.visible_(false));
NeuLab.g.stetho.xZoom = 0.1;

NeuLab.g.uv = UserView(NeuLab.g.win, NeuLab.g.stetho.view.bounds.moveTo(0, 220).width_(200));
NeuLab.g.uv.background_(Color.blue(1, 0));

NeuLab.g.uv.drawFunc = {
	Pen.stringCenteredIn("Out_Spk\n\n\nOut_Obj\n\n\nIn_Mic\n\n\nIn_Obj\n", NeuLab.g.uv.bounds.moveTo(0, 0), NeuLab.g.font.copy.size_(16), Color(0.62, 0.62, 1.0));
};
NeuLab.g.win.refresh;

NeuLab.g.stetho.view.visible = true;

NeuLab.g.testRaspiScreen = {
	NeuLab.g.raspibounds = Rect(0, 0, 797, 439);

	"windows outside raspi bounds:".postln;
	Window.allWindows.select { |win|
		NeuLab.g.raspibounds.contains(win.bounds).not
	}.collect { |win| [win.name, win.bounds] }.printAll;
	"";
};


NeuLab.g.butsize = 100@25;
NeuLab.g.texsize = 100@36;

NeuLab.g.guibutzone = CompositeView(NeuLab.g.win, Rect(130, 0, 110, 220)).background_(Color.grey(0.7));
NeuLab.g.guibutzone.addFlowLayout(2@2, 1@1);

StaticText(NeuLab.g.guibutzone, NeuLab.g.texsize).string_("Extras:")
.align_(\center).font_(NeuLab.g.font);

NeuLab.g.neuralbut = Button(NeuLab.g.guibutzone, NeuLab.g.butsize) .states_([["NeuralSynth"]]).font_(NeuLab.g.font);
NeuLab.g.neuralbut.action = { WinBounds.showOrMake(\NeuralSynth) };

NeuLab.g.redobut = Button(NeuLab.g.guibutzone, NeuLab.g.butsize) .states_([["RESET SOUND"]]).font_(NeuLab.g.font);
NeuLab.g.redobut.action = { Ndef(\NeuraLaby).rebuild.resetNodeMap };

NeuLab.g.autoBut = Button(NeuLab.g.guibutzone, NeuLab.g.butsize)
.states_([["autoMutate?"],
	["autoMutate!", Color.black, Color.green]
]).font_(NeuLab.g.font);
NeuLab.g.autoBut.action = nil;
NeuLab.g.autoBut.mouseDownAction = { |bt, x, y, mod|
	var tdef = Tdef(\autoMutate);
	if (x >= 90) {
		tdef.gui;
	} { NeuLab.auto.autoToggle };
	defer ({ bt.value = tdef.isPlaying.not.binaryValue }, 0.05);
};

NeuLab.g.mixerbut = Button(NeuLab.g.guibutzone, NeuLab.g.butsize)
.states_([["Mixer"]]).font_(NeuLab.g.font);
NeuLab.g.mixerbut.action = { WinBounds.showOrMake(\Mixer) };

NeuLab.g.findbut = Button(NeuLab.g.guibutzone, NeuLab.g.butsize) .states_([["MKtl.find"]]).font_(NeuLab.g.font);
NeuLab.g.findbut.action = {
	MKtl.find([\midi, \hid]);
	(NeuLab.dir.laby +/+ "LoadMidiIF.scd".postln).loadPaths;
};

NeuLab.g.ifbut = Button(NeuLab.g.guibutzone, NeuLab.g.butsize) .states_([["interface"]]).font_(NeuLab.g.font);
NeuLab.g.ifbut.action = { MKtl.all.do { |mk| mk.gui.showLabels } };

NeuLab.g.udbut = Button(NeuLab.g.guibutzone, NeuLab.g.butsize) .states_([["quarkUpdate"]]).font_(NeuLab.g.font);
NeuLab.g.udbut.action = { Quark("NeuraLabyNode").update };


/////// middle strip: presets, balance, nudges

NeuLab.g.butZone = CompositeView(NeuLab.g.win, Rect(248, 0, 106, 440)).background_(Color.grey(0.7));
NeuLab.g.butZone.addFlowLayout(2@2, 1@1);

StaticText(NeuLab.g.butZone, NeuLab.g.texsize).string_("Presets:")
.font_(NeuLab.g.font).align_(\center);

Button(NeuLab.g.butZone, 50 @ NeuLab.g.butsize.y).font_(NeuLab.g.font)
.states_([["- ? +"]])
.mouseDownAction_({ |bt, x, y|
	var step = x div: 16 - 1;
	if (step == 0) { step = NeuLab.preset.settings.size.rand };
	NeuLab.preset.stepCurr(step);
});

Button(NeuLab.g.butZone, 50 @ NeuLab.g.butsize.y).font_(NeuLab.g.font)
.states_([["- ? +"]])
.mouseDownAction_({ |bt, x, y|
	var step = x div: 16 - 1;
	if (step == 0) { step = NeuLab.preset.settings.size.rand };
	NeuLab.preset.stepTarg(step);
});

Button(NeuLab.g.butZone, NeuLab.g.butsize).font_(NeuLab.g.font)
.states_([["<< <-> >>"]])
.mouseDownAction_({ |bt, x, y|
	var step = (x / 50 - 1);
	step = step * step.abs;
	NeuLab.preset.morphValStep(NeuLab.preset.morphVal + step);
});

StaticText(NeuLab.g.butZone, NeuLab.g.texsize).string_("Balance:")
.font_(NeuLab.g.font).align_(\center);


// make a JITView: value, parent, bounds
NeuLab.g.balgui = MView(0.5, NeuLab.g.butZone, Rect(0, 0, 100, 25));
// needs a spec to display proper number range
NeuLab.g.balgui.putDict(\myspec, \pan).refresh;
NeuLab.g.balgui.label_('Spk<-->Obj');
NeuLab.g.balgui.action.add(\set, { |sl| Ndef(\RawIns).set(\balance, sl.value) });

NeuLab.g.balskip.stop.free;
NeuLab.g.balskip = SkipJack({
	var balval = Ndef(\RawIns).get(\balance);
	var autoval = Tdef(\autoMutate).isPlaying;
	if (NeuLab.g.balgui.value != balval) {
		NeuLab.g.balgui.value = balval
	};
	if (NeuLab.g.autoBut.value != autoval) {
		NeuLab.g.autoBut.value = autoval
	};
}, 0.2);

NeuLab.g.balgui.drawFunc.disable(\code);
NeuLab.g.balgui.drawFunc.enable(\number);

NeuLab.g.drywetBut = Button(NeuLab.g.butZone, NeuLab.g.butsize).states_([["dry <-> FX"]])
.font_(NeuLab.g.font);
NeuLab.g.drywetBut.mouseDownAction = { |b, x, y|
	// [b, x, y].postln;
	NeuLab.stepDryWet(x-50 * 0.01);
};

NeuLab.g.randBut = Button(NeuLab.g.butZone, NeuLab.g.butsize).states_([["vary...RAND"]]).font_(NeuLab.g.font);
NeuLab.g.randBut.mouseDownAction = { |b, x, y|
	// [b, x, y].postln;
	NdefPreset(\NeuraLaby).setRand((x * 0.01).squared);
};

StaticText(NeuLab.g.butZone, NeuLab.g.texsize).string_("Nudges:")
.font_(NeuLab.g.font).align_(\center);
(1..7).do { |num, i|
	Button(NeuLab.g.butZone, NeuLab.g.butsize)
	.states_([["-- - % + ++".format(num)]])
	.font_(NeuLab.g.font)
	.mouseDownAction_({ |b, x, y|
		// [b, x, y].postln;
		NeuLab.nudge(x-50 * 0.01, NeuLab.myseeds[i]);
	});
};
);

// right side: NdefPresetGui
(
// NeuLab.g.nlwin = Window('NeuraLaby', Rect(350,0,450,460)).front;
NeuLab.g.nlwin = CompositeView(NeuLab.g.win, Rect(350,0,450,460));
NeuLab.g.nlwin.addFlowLayout;
NeuLab.g.nlwin.asView.decorator.shift(25, 0);
NeuLab.g.npg = NdefPresetGui(NdefPreset(\NeuraLaby), 0, NeuLab.g.nlwin);
NeuLab.g.pcg = ProxyChain('NeuraLaby').gui(22,
	parent: NeuLab.g.nlwin
);
NeuLab.g.pcg.butZone.bounds = NeuLab.g.pcg.butZone.bounds.width_(70);
NeuLab.g.pcg.buttons.do { |bt| bt.bounds = bt.bounds.width_(60) };

///// for installation mode:
///// disable all on/off buttons:
// NeuLab.g.pcg.buttons.do(_.enabled_(false));
//// disable sto, del, edit, doc

// editGui shows levels
ProxyMeter.addNdefGui(NeuLab.g.pcg.editGui);
// make it smaller
NeuLab.g.pcg.editGui.zone.bounds_(NeuLab.g.pcg.editGui.zone.bounds.moveBy(-40, 0));
// make nameView more visible
NeuLab.g.pcg.editGui.nameView
.background_(Color.blue).stringColor_(Color.white)
.font_(Font(Font.defaultSansFace, 13));
);


