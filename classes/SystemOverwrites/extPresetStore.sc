/*
https://en.wikipedia.org/wiki/Hawaiian_alphabet
    A, E, I, O, U, H, K, L, M, N, P, W, F, G, J, S, Y, Z[1]

and seven diphthongs:

    AE, AI, AO, AU, EI, EU, OU
However, the letters F, G, J, S, Y, and Z were used solely to spell foreign words.
String.randName(rrand(5, 13));
*/
+ String {

	*randName { |size = 8|
		var vowels = "aeiou";
		var consonants = "HKLMNPW".toLower;
		var string = if (size.odd) { vowels.choose.asString } { "" };
		size.div(2).do { |i|
			string = string ++ consonants.choose ++ vowels.choose;
		};
		^string
	}
}
+ ProxyPreset {
	storeDialog { |name, loc| 		// check before overwriting a setting?
		var w, t;
		loc = loc ?? {400@300};
		name = this.checkName(name);
		w = Window("", Rect(loc.x, loc.y - 40, 150, 40), false);
		StaticText(w, Rect(0,0,70,20)).align_(\center).string_("name set:");
		t = TextField(w, Rect(70,0,70,20)).align_(\center)
		.string_(name)
		.action_({ arg field;
			this.addSet(field.value.asSymbol, toDisk: storeToDisk);
			w.close;
		})
		.focus(true);
		// add rand name and store buttons for touchscreen-only use
		Button(w, Rect(0,20,46,20)).states_([["dismiss"]])
		.action_({ w.close; });
		Button(w, Rect(47,20,46,20)).states_([["rand?"]])
		.action_({ t.string = String.randName });
		Button(w, Rect(95,20,46,20)).states_([["store!"]])
		.action_({
			this.addSet(t.value.asSymbol, toDisk: storeToDisk);
			w.close;
		});


		w.front;
	}
}