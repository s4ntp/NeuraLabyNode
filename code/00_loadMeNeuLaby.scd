/*
StartupFile.dialog;

var rw = Window("raspiBackground", Window.availableBounds).front.alpha_(0.5);
rw.background = Color.black;
StaticText(rw, rw.bounds.right_(800).top_(rw.bounds.height - 460))
.background_(Color.white);
Window.allWindows.do(_.front);
rw.bounds

*/

var t0 = Main.elapsedTime;

"NeuralLabyrinths setup loading...\n\n".postln;
q = q ? ();

q.dir = q.dir ? ();
q.dir.labyPath = thisProcess.nowExecutingPath;
q.dir.labyDesk = "~/Desktop/NeuraLaby/".standardizePath;
File.mkdir(q.dir.labyDesk);

q.dir.labyAdjustPath = q.dir.labyDesk +/+ "adjustments.scd";


// check for interfaces before server boots:
// dont show new apple internal HIDs
HIDMKtlDevice.deviceProductNamesToHide.addAll(
	[ "", "BTM", "Headset", "Keyboard Backlight"]
);
fork { MKtl.find };

// give it enough
s.options.memSize = 8192 * 16;

s.waitForBoot {

	"NodeIns.scd".postln.loadRelative;
	s.sync;

	"PepsiChain.scd".postln.loadRelative;
	s.sync;
	0.2.wait;

	"LoadMidiIF.scd".postln.loadRelative;

	0.2.wait;

	"autoMutate.scd".postln.loadRelative;

	0.2.wait;


	// always make the small RaspiGui
	"RaspiGui.scd".postln.loadRelative;

	0.2.wait;

	if (q.dir.labyAdjustPath.pathMatch.isEmpty) {
		unixCmd("cp" + (thisProcess.nowExecutingPath.dirname.dirname
			+/+ "adjustments.scd").quote + q.dir.labyAdjustPath.quote);
	};

	q.dir.labyAdjustPath.loadPaths;

	// toggle one effect on/off to get green sliders
	fork ({
		q.pchain.remove(\freqMod);
		0.5.wait;
		q.pchain.add(\freqMod, 1);
	});

	// additional ones only if on big enough laptop screen:
	if (Window.availableBounds.width >= 1200) {

		WinBounds.showOrMake(\Mixer);
		try { Window.find(\Mixer).moveTo(10, 480) };

		MKtl.all.do { |mk| mk.gui.showLabels };

		"*** NeuralLabyrinths setup loaded in % seconds.\n".postf(
			(Main.elapsedTime - t0).round(0.01));
	};

};
