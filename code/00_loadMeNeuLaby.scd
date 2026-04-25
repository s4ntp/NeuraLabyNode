/*
loadscript for one Neural Labyrinths node.
usually runs on one raspberry or similar;
audio interface is a simple USB mixer with 6 inputs,
phantom power, and 2chan USB connection.

left input is assumed to be a mic,
right input is a contect mic;

left output goes to a loudspeaker
right output goes to a shaker that activates
the object that the contact mic listens to.


*/

var t0 = Main.elapsedTime;


"NeuralLabyrinths setup loading...\n\n".postln;

NeuLab.myhostname = NeuLab.myhostname ? unixCmdGetStdOut("whoami").split($.).first;
"*** NeuLab.myhostname: %\n".postf(NeuLab.myhostname);

NeuLab.dir.labyPath = thisProcess.nowExecutingPath;
NeuLab.dir.laby = NeuLab.dir.labyPath.dirname;

// Desktop path may not work on Windows?
NeuLab.dir.labyDesk = "~/Desktop/NeuLab/".standardizePath;
File.mkdir(NeuLab.dir.labyDesk);
NeuLab.dir.labyAdjustPath = NeuLab.dir.labyDesk +/+ "adjustments.scd";


// give server enough realtime memory,
// otherwise leave defaults to system
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


	if (\ARMLP.asClass.notNil) {
		"trying to load ARMLP patch: ".postln;
		try {
			"armlpNL.scd".postln.loadRelative.postln;
		};
	};

	0.2.wait;

	// always make the small RaspiGui
	"RaspiGui.scd".postln.loadRelative;

	0.2.wait;

	if (NeuLab.dir.labyAdjustPath.pathMatch.isEmpty) {
		unixCmd("cp" + (thisProcess.nowExecutingPath.dirname.dirname
			+/+ "adjustments.scd").quote + NeuLab.dir.labyAdjustPath.quote);
	};

	NeuLab.dir.labyAdjustPath.loadPaths;

	// toggle one effect on/off to get green sliders
	fork ({
		NeuLab.pchain.remove(\freqMod);
		0.5.wait;
		NeuLab.pchain.add(\freqMod, 1);
	});

	// additional GUIs only if on big enough laptop screen:
	if (Window.availableBounds.width >= 1200) {

		WinBounds.showOrMake(\Mixer);
		try { Window.find(\Mixer).moveTo(10, 480) };

		MKtl.all.do { |mk| mk.gui.showLabels };

		WinBounds.showOrMake(\NeuralSynth);

	};
	"*** NeuralLabyrinths setup loaded in % seconds.\n".postf(
		(Main.elapsedTime - t0).round(0.01));

};
