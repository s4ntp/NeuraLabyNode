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

// check for interfaces before server boots:
// dont show new apple internal HIDs
HIDMKtlDevice.deviceProductNamesToHide.addAll(
	[ "", "BTM", "Headset", "Keyboard Backlight"]
);
fork { MKtl.find };

s.waitForBoot {

	"NodeIns.scd".postln.loadRelative;
	s.sync;

	"PepsiChain.scd".postln.loadRelative;
	s.sync;
	0.2.wait;

	"LoadMidiIF.scd".postln.loadRelative;

	0.2.wait;

	// all GUI stuff here:
	// always load the RaspiGui
	"RaspiGui.scd".postln.loadRelative;
	// additional ones if on laptop screen:
	if (Window.availableBounds.width >= 1200) {

		q.mixer = NdefMixer.small(s, 8);
		q.mixer.parent.name_(\NdefMixer);
		ProxyMeter.addMixer(q.mixer);

		MKtl.all.do { |mk| mk.gui.showLabels };

		/*
		Window.getAllCS;
		*/
		// assume average laptop, screen size > 1200@800
		0.2.wait;

		Window.setAll([
			[ "NdefMixer", Rect(0.0, 487.0, 632, 203.0) ],
			[ "Levels", Rect(0.0, 223.0, 134.0, 230.0) ],
			[ "NeuraLaby", Rect(658.0, 164.0, 469.0, 461.0) ],
			[ "lpd8", Rect(128.0, 36.0, 490.0, 150.0) ],
			[ "beatstep", Rect(99.0, 0.0, 610.0, 270.0) ],
			[ "nanokontrol2", Rect(0.0, 0.0, 912.0, 194.0) ],
			[ "uc4", Rect(780.0, 9.0, 490.0, 510.0) ],
			[ "xtouch", Rect(135.0, -141.0, 610.0, 510.0) ],
			[ "lpd8", Rect(128.0, 36.0, 490.0, 150.0) ]
		])
	};


	"*** NeuralLabyrinths setup loaded in % seconds.\n".postf(
		(Main.elapsedTime - t0).round(0.01));
};
