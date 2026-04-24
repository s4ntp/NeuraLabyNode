
// write out settings of RawIns, inMic, inPiezo:
// getkeysValues, write to a known file outside the quark,
// look for that file when booting
NeuLab.neuralDir = Platform.userAppSupportDir +/+ "neuralaby";
File.mkdir(NeuLab.neuralDir);

MFdef(\writeSettings).add(\write, { |ndef, where|
	var str = ndef.cs ++ ".set(*" ++ ndef.getKeysValues.flat.cs + ");\n";
	var filename = ndef.key ++ "_settings.scd";
	var path = where ?? NeuLab.neuralDir +/+ filename;
	"*** Saving settings: ".postln;
	File.use(path, "w", { |file| file.write(str.postln) });
	str;
});

MFdef(\readSettings).add(\read, { |ndef, where|
	var filename = ndef.key ++ "_settings.scd";
	var path = where ?? NeuLab.neuralDir +/+ filename;
	path.postcs.loadPaths;
});

/*
NeuLab.readSettings(Ndef(\RawIns));

NeuLab.readSettings(Ndef(\inMic));
NeuLab.writeSettings(Ndef(\inMic));

NeuLab.pollBut = NeuLab.mixer.editGui.zone.children[8];
NeuLab.pollBut.states = [[ "SAVE", Color.red, Color.green ]];
NeuLab.pollBut.action = {
	MFdef(\writeSettings).value(NeuLab.mixer.editGui.object)
};

MFdef(\readSettings).(Ndef(\inMic));

*/