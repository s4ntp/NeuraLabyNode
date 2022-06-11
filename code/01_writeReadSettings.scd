
// write out settings of RawIns, inMic, inPiezo:
// getkeysValues, write to a known file outside the quark,
// look for that file when booting
q.neuralDir = Platform.userAppSupportDir +/+ "neuralaby";
File.mkdir(q.neuralDir);

MFdef(\writeSettings).add(\write, { |ndef, where|
	var str = ndef.cs ++ ".set(*" ++ ndef.getKeysValues.flat.cs + ");\n";
	var filename = ndef.key ++ "_settings.scd";
	var path = where ?? q.neuralDir +/+ filename;
	"*** Saving settings: ".postln;
	File.use(path, "w", { |file| file.write(str.postln) });
	str;
});

MFdef(\readSettings).add(\read, { |ndef, where|
	var filename = ndef.key ++ "_settings.scd";
	var path = where ?? q.neuralDir +/+ filename;
	path.postcs.loadPaths;
});

/*
q.readSettings(Ndef(\RawIns));

q.readSettings(Ndef(\inMic));
q.writeSettings(Ndef(\inMic));

q.pollBut = q.mixer.editGui.zone.children[8];
q.pollBut.states = [[ "SAVE", Color.red, Color.green ]];
q.pollBut.action = {
	MFdef(\writeSettings).value(q.mixer.editGui.object)
};

MFdef(\readSettings).(Ndef(\inMic));

*/