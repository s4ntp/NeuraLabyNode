(
MIDIClient.init;

~stationToMidi = (
	NLflower: 5,
	NLivm5: 7,
	NLadc5a: 0,
	NLawe4: 3,
	NLanon5: [2,6],
	NLmaya: 1,
);

~stationMinMax = [0,1]!6;

m = MIDIOut(0, MIDIClient.destinations[1].uid);

OSCdef(\NLamps, {|msg|
	var midiNote = 69+~stationToMidi[msg[1]];
	var idx = ~stationToMidi.keys.asArray.indexOf(msg[1]);
	var range = ~stationMinMax[idx].linlin(0,1,0,126);
	var velocity =  (\amp.asSpec.unmap(msg[2])*2).linlin(0,1,range[0],range[1]).asInteger;

	midiNote.asArray.do {|midiNote|
		"Set % (miditChan %) to %".format(msg[1], midiNote, velocity).postln;
		m.noteOn(0, midiNote, velocity);
	};
}, "/NL/amplitude");


w = Window.new("light mixer", Rect(0,60,800,420));
w.view.layout = GridLayout.rows(*[
	~stationToMidi.keys.asArray.collect{|txt|StaticText().string_(txt)},
	(~stationMinMax.collect{|vals, idx|
		RangeSlider().setSpan(*vals).knobColor_(Color.rand).action_({|rs|
			~stationMinMax[idx][0] = rs.lo;
			~stationMinMax[idx][1] = rs.hi;
		})
	})
]);
w.front;

)