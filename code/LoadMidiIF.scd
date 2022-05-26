/*   // load all interfaces:
(thisProcess.nowExecutingPath.dirname +/+ "interfaces/" ++ "*.scd").loadPaths;
*/

(
var here = thisProcess.nowExecutingPath.dirname;
var foundInfos, ifFilename, fullpath;

MKtl.find;
foundInfos = MKtlLookup.all.asArray.collect(_.idInfo)
.select(_.isString).reject(_.contains("_Apple")).asArray.sort;

"look for presence of supported MKtl interfaces;
load them if found, or else load beatstep by default.".postln;

if (foundInfos.notEmpty) {
		"---\n*** Found MKtl devices: %".postln;
		foundInfos.printcsAll;
		"---".postln;
	foundInfos.do { |entry|
		case
		{ entry == "nanoKONTROL2" } { ifFilename = "nanokontrol2.scd" }
		{ entry == "X-TOUCH MINI" } { ifFilename = "x-touch-mini.scd" }
		{ entry == "LPD8" } { ifFilename = "akai-lpd8.scd" }
		{ entry == "Arturia BeatStep" } { ifFilename = "beatstep.scd" }
		{ entry == "Faderfox UC4" } { ifFilename = "uc4.scd" };
	};
};
ifFilename ?? {
	// use beatstep as default when nothing found:
	"... no supported MKtl device found, default to beatstep.".postln;
	ifFilename = "beatstep.scd";
};

fullpath = (here +/+ "interfaces" +/+ ifFilename);
if (fullpath.pathMatch.notEmpty) {
	fullpath.loadPaths
};
)