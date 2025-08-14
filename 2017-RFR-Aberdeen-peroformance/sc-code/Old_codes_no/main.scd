~testTone = {SinOsc.ar(Array.fill(13, {|i| (i + 60).midicps}), 0, 0.1)}.play;

~testTone.free;
////////////////////////////////////////////
////////////////////////////////////////////
(
fork {
	"./prep/01-tower.scd".loadRelative;

	~towers = [$C, $D, $E, $F, $H, $I, $J, $K, $M, $N, $O, $P, $Q].collect({arg i; ~tower.new(i, "../media/") });
	s.sync;
	"./prep/02-spacer.scd".loadRelative;
	~spacer = ~spacer.new(~towers);
	// ~spacer.route;
	~spacer.mono;
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

~towers[10].playAm;
~towers[10].stopAm;

~towers[10].calibrate;
~towers[10].stopCalibration;

~towers[11].rawBuses[0].get;


~towers[11].oscRaw.func.def.sourceCode;

~towers[11].oscRaw.func_({|msg| msg.postln;});

s.queryAllNodes

a = Synth.tail(s ,\towerAm);
