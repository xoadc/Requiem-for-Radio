(
~tower =Proto({
	~server = Server.default;
	forkIfNeeded {
		SynthDef(\towerLooper, {
			arg out=0, bufnum=0, atk=5, rel=6, amp=1, gate=0;
			var sig, env;
			env = EnvGen.kr(Env.asr(atk,1,rel, curve:\sqr), gate, amp);
			sig = PlayBufCF.ar(
				1,
				bufnum,
				BufRateScale.kr(bufnum),
				trigger: LFPulse.kr((BufDur.kr(bufnum) - 10.0).reciprocal),
				lag: 8);
			Out.ar(out,sig * env);
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
			~towerIP = "192.168.0." ++ ~towerID.ascii;
			~sfPaths = (
				~mediaPath.resolveRelative ++ ~towerID ++ "_glitch.wav").pathMatch;
			~sfPaths.addFirst(
				~mediaPath.resolveRelative ++ ~towerID ++ "_drone.wav");
			~buffers = ~sfPaths.collect({ |i|
				Buffer.read(~server, i);
			});
			~rawBuses = ~numSensors.collect({ Bus.control(~server, 1) });
			~calBuses = ~numSensors.collect({ Bus.control(~server, 1) });
			~sensorSpecs = ~numSensors.collect({ ControlSpec(); });
			~oscRaw = OSCFunc({|msg|
				msg[1..~numSensors].do({|i, j|
					~rawBuses[j].set(~sensorSpecs[j].unmap(i));
				});
			}.inEnvir, "/raw", NetAddr(~towerIP, 50202), 50101);
			~oscTouch = OSCFunc({|msg|
				var val;
				val = (msg[1] & 0xFFF).asBoolean; // filter out proximity on bit 13
				(val != ~touched).if({
					~touched = val;
					~touched.if({
						~play.value;
					},{
						~stop.value;
					})
				});
			}.inEnvir, "/touch", NetAddr(~towerIP, 50202), 50101);
			~drone = Synth.head(~server, \towerLooper,[
				\out, ~outBus,
				\bufnum,  ~buffers[0],
				\atk, 5,
				\rel, 6,
				\amp, 1.0
			]);
			~glitch = Synth.head(~server, \towerLooper,[
				\out, ~outBus,
				\bufnum,  ~buffers[1],
				\atk, 5,
				\rel, 6,
				\amp, 1.0
			]);

		};
		currentEnvironment;
	};
	~play = {
		~drone.set(\gate, 1);
		~glitch.set(\gate, 1);
		("Tower " ++ ~towerID ++ " touched.").postln;

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
	~stop = {
		~drone.set(\gate, 0);
		~glitch.set(\gate, 0);
		("Tower " ++ ~towerID ++ " released.").postln;
	};
	~stopAm = {
		~amSynth.set(\gate, 0);
	};
	~calibrate = {
		~sensorSpecs.do({ |i|
			i.minval_(0);
			i.maxval_(1023);
		});
		~calibrationDef = OSCdef( (~towerID ++ "--Cal").asSymbol, { |msg|
			msg[1..~numSensors].do({ |i, j|
				(i < ~sensorSpecs[j].maxval).if({
					~sensorSpecs[j].maxval_(i);
				});
				(i > ~sensorSpecs[j].minval).if({
					~sensorSpecs[j].minval_(i);
				})
			});
		}.inEnvir, "/raw", NetAddr(~towerIP, 50202), 50101);
	};
	
	~stopCalibration = {
		~calibrationDef.free;
		~dumpCalibration.value;
	};
	
	~dumpCalibration = {
		"[ ".post;
		~sensorSpecs.do({|i|
			[i.minval, i.maxval].post;
			", ".post;
		});
		("], " + "// " + ~name).postln;
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
