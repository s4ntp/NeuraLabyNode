// flexible project class for Neural Labyrinths
// redirects everything to internal dict:
NeuLab {
	classvar <q;
	*initClass {
		q = (
			run: {|dict, path|
				path = (path ? (NeuLab.dir.loadMe));
				path.postcs.loadPaths
			},
			// init necessary dicts
			defaults: (),
			mfx: (),
			dir: (),
			g: ()
		);
		// use defaults automatically if nil:
		NeuLab.q.parent = NeuLab.q.defaults;

		NeuLab.dir.setup = NeuLab.filenameSymbol.asString.dirname.dirname +/+ "code";
		NeuLab.dir.loadMe = NeuLab.dir.setup  +/+ "00_loadMeNeuLaby.scd";

		NeuLab.allPanNames = List['-']; // so we can add dynamically
		// use NeuLab.addPanNames to add
	}

	// redirect everything to NeuLab.q:
	*doesNotUnderstand { |selector ... args|
		^q.performList(selector, args)
	}
}
