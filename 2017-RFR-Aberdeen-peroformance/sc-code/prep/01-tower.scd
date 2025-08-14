(
~tower =Proto({
	~server = Server.default;
	forkIfNeeded {
		SynthDef(\towerLooper, {
			arg out=0, bufnum=0, atk=5, rel=6, amp=1, gate=0, rate=1.0, in=0;
			var sig, env;
			in = In.kr(in, 1);
			env = EnvGen.kr(Env.asr(atk,1,rel, curve:\sqr), gate, amp*in);
			sig = PlayBufCF.ar(
				1,
				bufnum,
				BufRateScale.kr(bufnum)*rate,
				trigger: LFPulse.kr(((BufDur.kr(bufnum)/rate) - 10.0).reciprocal),
				lag: 8);
			Out.ar(out,sig * env);
		}).add;
		SynthDef(\towerAm, {
			arg out=0, in=0, inA=100, atk=5, rel=6, amp=1, gate=1, freq=800, phase=0,frMul=2000;
			var sig, env;
			env = EnvGen.kr(Env.asr(atk,1,rel, curve:\sqr), gate, amp);
			in = In.kr(in, 1);
			// inA = In.ar(inA, 1);
			sig = SinOsc.ar(Lag.kr(freq + (in * frMul), 0.1), phase, in * 0.01);
			Out.ar(out,sig * env);
		}).add;

		~server.sync;
	};
	~initialize = { |id, mediaPath|
		forkIfNeeded {
			~sfNumChan = 1;
			~touched = [0, 0, 0, 0];
			~sustainFlags = [false, false, false];
			~glitches = [0, 0, 0];
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
			~oscTouch = OSCFunc({arg msg;
				var vals, pads, pipe;
				vals = (msg[1] & 0xFFF).asBinaryDigits(4).reverse; // filter out proximity on bit 13
				pads = vals.keep(3);
				pipe = vals.last;
				(vals != ~touched).if({
					pads.do({
						arg status, number;
						status.asBoolean.if({
							~play.value(number);
						},{
							(~touched[number] != vals[number]).if({
								~stop.value(number);
							});
						});
					});
					pipe.asBoolean.if({
						~amSynth.set(\gate,1);
						pads.do({
							arg status, number;
							status.asBoolean.if({
								~sustainFlags[number] = true;
							});
						});
					},{
						~amSynth.set(\gate,0);
					});
					~touched = vals;
				});
			}.inEnvir, "/touch", NetAddr(~towerIP, 50202), 50101);
			~drone = 3.collect({
				arg number;
				Synth.head(~server, \towerLooper,[
					\out, ~outBus,
					\bufnum,  ~buffers[0],
					\atk, [1,1,1][number],
					\rel, [3,3,3][number],
					\amp, 0.333,
					\rate, 2.pow(number),
					\in, ~rawBuses[number]
				]);
			});
			~glitch = Synth.head(~server, \towerLooper,[
				\out, ~outBus,
				\bufnum,  ~buffers[1],
				\atk, 0.5,
				\rel, 1.5,
				\amp, 0.5
			]);
		};
		currentEnvironment;
	};
	~play = {
		arg id=0;
		~drone[id].set(\gate,1);
		~glitch.set(\gate, 1);
		~glitches[id] = 1;
		("Tower " ++ ~towerID ++ ", pad " ++ id ++ " touched.").postln;
	};
		~playAm = {
		~amSynth = Synth.after(~glitch, \towerAm,[
			\out, ~outBus,
			\in,  ~rawBuses[3],
			//\inA, ~outBus,
			\freq, 800,
			\atk, 0.01,
			\rel, 1,
			\amp, 1.0
		]);
	};
	~stop = {
		arg id=0;
		~sustainFlags[id].if({
			~sustainFlags[id] = false;
		},{
		~drone[id].set(\gate, 0);
		~glitches[id] = 0;
		(~glitches.sum == 0).if({
			~glitch.set(\gate, 0);
		});
		("Tower " ++ ~towerID ++ ", pad " ++ id ++ " released.").postln;
			});
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
		~drone.do({
			arg syn;
			syn.free});
		~glitch.free;
		~buffers.do(_.free);
		~oscRaw.free;
		~oscTouch.free;
	};
});
)
