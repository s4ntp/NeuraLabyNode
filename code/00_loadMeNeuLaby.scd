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


	// all GUI stuff is here:
	// always load the RaspiGui
	"RaspiGui.scd".postln.loadRelative;
	// additional ones only if on big enough laptop screen:
	if (Window.availableBounds.width >= 1200) {

		WinBounds.showOrMake(\Mixer);
		try { Window.find(\Mixer).moveTo(10, 480) };

		MKtl.all.do { |mk| mk.gui.showLabels };

		/*
		Window.getAllCS;
		*/
		// assume average laptop, screen size > 1200@800
		0.2.wait;

		// Window("GETS HERE?").front;
		//
		// Window.setAll([
		// 	[ "NdefMixer", Rect(0.0, 487.0, 632, 203.0) ],
		// 	[ "NeuraLaby", Rect(0, 0, 800, 460) ],
		// 	[ "lpd8", Rect(128.0, 36.0, 490.0, 150.0) ],
		// 	[ "beatstep", Rect(99.0, 0.0, 610.0, 270.0) ],
		// 	[ "nanokontrol2", Rect(0.0, 0.0, 912.0, 194.0) ],
		// 	[ "uc4", Rect(780.0, 9.0, 490.0, 510.0) ],
		// 	[ "xtouch", Rect(135.0, -141.0, 610.0, 510.0) ],
		// 	[ "lpd8", Rect(128.0, 36.0, 490.0, 150.0) ]
		// ])
	};

	"*** NeuralLabyrinths setup loaded in % seconds.\n".postf(
		(Main.elapsedTime - t0).round(0.01));
};
