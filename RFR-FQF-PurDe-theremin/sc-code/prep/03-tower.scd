(
~tower =Proto({
	~server = Server.default;
	forkIfNeeded {
		SynthDef(\towerLooper, {
			arg out=0, bufnum=0, atk=5, rel=6, amp=1, gate=1,
			volPitch=0.0, volVolume=0;
			var sig, env;
			env = EnvGen.kr(Env.asr(atk,1,rel, curve:\sqr), gate, amp);
			sig = PlayBufCF.ar(
				1,
				bufnum,
				BufRateScale.kr(bufnum),
				trigger: LFPulse.kr((BufDur.kr(bufnum) - 10.0).reciprocal),
				lag: 8);
			Out.ar(out,sig * env * volPitch * volVolume );
		}).add;
		SynthDef(\towerAm, {
			arg out=0, in=0, inA=100, atk=5, rel=6, amp=1, gate=1, freq=800, phase=0,frMul=2000;
			var sig, env;
			env = EnvGen.kr(Env.asr(atk,1,rel, curve:\sqr), gate, amp);
			in = In.kr(in, 1);
			// inA = In.ar(inA, 1);
			sig = SinOsc.ar(Lag.kr(freq + (in * frMul), 0.1), phase, in * 0.001);
			Out.ar(out,sig * env);
		}).add;

		~server.sync;
	};
	~initialize = { |id, mediaPath|
		forkIfNeeded {
			~sfNumChan = 1;
			~touched = 0;
			~towerID = id;
			~numSensors = 4;
			~mediaPath = mediaPath ? "../../media/";
			~outBus = Bus.audio(~server, 1);
			~sfPaths = (
				~mediaPath.resolveRelative ++ ~towerID ++ "_glitch.wav").pathMatch;
			~sfPaths.addFirst(
				~mediaPath.resolveRelative ++ ~towerID ++ "_drone.wav");
			~buffers = ~sfPaths.collect({ |i|
				Buffer.read(~server, i);
			});
			~drone = Synth.head(~server, \towerLooper,[
				\out, ~outBus,
				\bufnum,  ~buffers[0],
				\atk, 0.01,
				\rel, 0.01,
				\amp, 1.0,
				\vol, 0
			]);
			~glitch = Synth.head(~server, \towerLooper,[
				\out, ~outBus,
				\bufnum,  ~buffers[1],
				\atk, 0.01,
				\rel, 0.01,
				\amp, 1.0,
				\vol, 0
			]);
			~server.sync;
		};
		currentEnvironment;
	};
	~playAm = {
		~amSynth = Synth.after(~glitch, \towerAm,[
			\out, ~outBus,
			\in,  ~rawBuses[0],
			\inA, ~outBus,
			\freq, 800,
			\atk, 5,
			\rel, 6,
			\amp, 1.0
		]);
	};

	~stopAm = {
		~amSynth.set(\gate, 0);
	};

	~free = {
		~drone.free;
		~glitch.free;
		~buffers.do(_.free);
		~oscRaw.free;
		~oscTouch.free;
	};
});
)
