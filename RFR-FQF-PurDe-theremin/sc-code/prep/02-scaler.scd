~enveloper = Proto({
	~server = Server.default;
	~maxVolume = 700; // maximum value of volume antenna.
	~minVolume = 0; // minimum value of volume antenna.

	~initEnvs = { |maxPitch, minPitch, numSeg, xf|
		~maxPitch = maxPitch ? 700;
		~minPitch = minPitch ? 0;
		~len = ~maxPitch - ~minPitch;
		~numSeg = numSeg ? 13;
		~xf = xf ? 0.1; // duration of x-fade as a ratio of segment length ~segLen.
		~segLen = ~len / (~numSeg + ~xf); // Size of one segment.
		~basicEnv = Signal.fill(~segLen * (1 + ~xf), 1);
		~basicEnv.fade(0, ~segLen * ~xf);
		~basicEnv.fade(~segLen, ~segLen * (1 + ~xf), 1, 0);
		~basicEnv = ~basicEnv * ~basicEnv; // equal power
		// One segment length = fade in + sustain
		// fade in + sustain + fade out = ~segLen * (1 + xfade)
		// In other words, ~segLen does not include the fade out.
		//    ____
		//   /    |\
		//
		~envs = ~numSeg.collect({ |i| // create full length envs.
			// ~len + 1 to actually reach 0 at fade out.
			Signal.fill(~len + 1, 0).overWrite(~basicEnv, ~segLen * i);
		});
	};

	~plot = { // Plot the curves for testing.
		~envs.do(_.plot); // to plot
	};

	~initialize = { |maxPitch, minPitch, numSeg, xf|
		~initEnvs.value(maxPitch, minPitch, numSeg, xf);
	};
	currentEnvironment;
});
