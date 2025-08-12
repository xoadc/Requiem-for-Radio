~testTone = {SinOsc.ar(Array.fill(13, {|i| (i + 60).midicps}), 0, 0.1)}.play;

~testTone.free;
////////////////////////////////////////////
////////////////////////////////////////////
(
fork {
	// set up MOTU
	s.options.device = "xoadc";
	s.options.numOutputBusChannels = 13;

	// load towers
	"./prep/01-tower.scd".loadRelative;
	~towers = [$C, $D, $E, $F, $H, $I, $J, $K, $M, $N, $O, $P, $Q].collect({arg i; ~tower.new(i, "../media/") });
	s.sync;

	// route the towers
	"./prep/02-spacer.scd".loadRelative;
	~spacer = ~spacer.new(~towers);

	// YOU CAN ONLY HAVE ONE OF THESE ACTIVE
	~spacer.route;    // individual outputs
	//~spacer.spread; // stereo mix
}
)
//////////////////////////
// Calibrate !!!!!!!!!! //
//////////////////////////
~towers.do(_.calibrate);
~towers.do(_.stopCalibration);

////////////////////////////////////////////
// STOP !!!!!!!!!!!!!!!!
////////////////////////////////////////////
(
~towers.do(_.free);
~spacer.do(_.free);
)

////////////////////////////////////////////
////////////////////////////////////////////

~towers[11].playAm;
~towers[11].stopAm;

~towers[11].calibrate;
~towers[11].stopCalibration;

~towers[11].rawBuses[0].get;


~towers[11].oscRaw.func.def.sourceCode;

~towers[11].oscRaw.func_({|msg| msg.postln;});

s.queryAllNodes

a = Synth.tail(s ,\towerAm);

~towers[5].play;
~towers[5].stop;