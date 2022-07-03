// example adjustment file - put on ~/Desktop/adjustments.scd

///// e.g. set balance more toward object
// Ndef(\RawIns).set(\balance, 0.7);

///// turn on autoMutate
Tdef(\autoMutate).play;

// // start with a specific preset:
// NdefPreset(\NeuraLaby).setCurr(\rand4).setProxy(\rand4);

// // disable filter on/off buttons
// q.pcg.buttons.do(_.visible_(false));

///// hide some gui elements for installation mode?

// [ q.mixerbut, q.findbut, q.ifbut ].do(_.visible_(false));

