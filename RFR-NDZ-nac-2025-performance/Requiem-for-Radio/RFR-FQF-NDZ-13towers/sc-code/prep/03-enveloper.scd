~enveloper = Proto({
	~server = Server.default;

	~initEnvs = { |maxPitch, minPitch, numSef, xf, startGap|
		~maxPitch = maxPitch ? 700;
		~minPitch = minPitch ? 0;
		~startGap = startGap ? 21;
		~len      = ~maxPitch - ~minPitch - ~startGap; // 21 0s at beginning of envelope
		~numSeg   = numSeg ? 13;
		~xf       = xf ? 0.1; // duration of cross fade
		~segLen   = ~len / (~numSeg + ~xf); // size of one segment
		~basicEnv = Signal.fill(~segLen);