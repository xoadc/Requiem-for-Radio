(
forkIfNeeded {
	//s.options.device = "hw:2";
	s.options.device = nil;
	s.reboot;
	10.wait;

	"./prep/01-enveloper.scd".loadRelative;
	"./prep/02-theremuino.scd".loadRelative;
	"./prep/03-tower.scd".loadRelative;
	"./prep/04-spacer.scd".loadRelative;

	Server.default.sync;
	// parameters : maxPitch, minPitch, numTowers, xFadeLength, maxVolume, minVolume, curve, startGap.
	~env = ~enveloper.new(650, 0, 13, 0.5, 150, 0, \lin, 21);
	// When volume knob on theremin is at minimum, 150 seems to be a
	// good value for maxVolume.

	//parameters : ~env (previous object), print (true or false), portName.
	~theremine = ~theremuino.new(~env, false, "/dev/ttyACM0");
	Server.default.sync;

	~towers = [$C, $D, $E, $F, $H, $I, $J, $K, $M, $N, $O, $P, $Q].collect({
		|i, j|
		var t;
		t = ~tower.new(i, "./media/");
		Server.default.sync;
		t.drone.map(\volPitch, ~theremine.buses[j]);
		t.glitch.map(\volPitch, ~theremine.buses[j]);
		t.drone.map(\volVolume, ~theremine.volumeBus);
		t.drone.map(\volVolume, ~theremine.volumeBus);
		t;
	});

	~spacer = ~spacer.new(~towers);
	~spacer.mono;
	//"../bluePrints/application.macosx/bluePrints/Contents/MacOS/bluePrints".resolveRelative.unixCmd;
};
)

Quarks.gui;

s.options.

s.options.device = "hw:1";
Server.default.options.device = nil;
ServerOptions.devices(true);
(
s.quit;
Server.default.options.device = nil;
Server.default.options.inDevice = nil;
Server.default.options.outDevice = nil;
s.options.numOutputBusChannels = 2;
s.options.numInputBusChannels = 2;
s.reboot;
)

// To print antennae values.
~theremine.printVals = true;
~theremine.printVals = false;
~theremine.values

~theremine.processingAddress.sendBundle(0.0, "/alphaCha", 1.0);

~t.play