// Run a test tone.  MIDI notes 60-72 in outputs 0-12 (towers C-Q).
~testTone = {SinOsc.ar(Array.fill(13, {|i| (i + 60).midicps}), 0, 0.01)}.play;
// Idea: Hide words inside towers if a specific freq is held?


~testTone.free; // Stop the test tones.

s.options.dump;
s.queryAllNodes;
Server.default.options.device.postln;
Server.default.options.dump;
s.quit;
s.boot;

s.options.numOutputBusChannels.postln;
s.options.numInputBusChannels.postln;



///////// SETUP /////////////////////////////
(
//s.options.device = "MOTU - AVB";
s.options.numInputBusChannels_(13);
s.options.numOutputBusChannels_(13);
s.options.sampleRate = 44100;
s.options.blockSize = 1024;
s.options.memSize = 8192 * 4;
s.options.numWireBufs = 128;
s.options.maxNodes = 2048;
s.options.numAudioBusChannels = 2048;
s.boot;
)



////////////////////////////////////////////
////////////////////////////////////////////
// Execute the paren below to start RFR.NDZ
(
fork {


	"./prep/01-tower.scd".loadRelative;
	~towers = [$C, $D, $E, $F, $H, $I, $J, $K, $M, $N, $O, $P, $Q].collect({arg i; ~tower.new(i, "../media/") });
	s.sync;

	"./prep/02-spacer.scd".loadRelative;
	~spacer = ~spacer.new(~towers);
	~spacer.route;
	s.sync;
}
)

////////////////////////////////////////////
// Run the paren below to stop RFR.NDZ.
////////////////////////////////////////////
(
~towers.do(_.free);
~spacer.do(_.free);
s.quit;
)

//////////////////////////
// Calibrate !!!!!!!!!! //
//////////////////////////
~towers.do(_.calibrate); // start calibration for all towers
~towers.do(_.stopCalibration); // stop calibration for all towers


////////////////////////////////////////////
////////////////////////////////////////////

~towers[0].playAm; // Turn on AM synthesis on tower 11 (tower P)
~towers[0].stopAm; // Turn off AM synthesis on tower 11 (tower P)

~towers[2].playAm;
~towers[2].stopAm;

~towers[11].calibrate; // Turn on calibration on tower 11 (tower P)
~towers[11].stopCalibration; // Turn off calibration on tower 11 (tower P)

/////////////////////////////////////////////
// Here be dragons (just testing stuff)
////////////////////////////////////////////

~towers[11].rawBuses[0].get;


~towers[11].oscRaw.func.def.sourceCode;

~towers[11].oscRaw.func_({|msg| msg.postln;});

s.queryAllNodes
