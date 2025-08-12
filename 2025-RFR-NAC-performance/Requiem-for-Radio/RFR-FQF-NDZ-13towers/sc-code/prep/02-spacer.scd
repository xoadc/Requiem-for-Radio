(
~spacer = Proto({
	~server = Server.default;
	~initialize = { |towers|
		forkIfNeeded {
			~towers = towers;
			SynthDef(\router, {
				arg out=0, in=100;
				Out.ar( out, In.ar(in, 1) );
			}).add;
			~server.sync;
			SynthDef(\spreader, {
				arg out=0, in=100, pos=0;
				Out.ar(
					out,
					Pan2.ar(In.ar(in, 1), pos)
				);
			}).add;
			~server.sync;
		};
		currentEnvironment;
	};

	~route = {
		~free.value;
		~synths = ~towers.collect({|tower, i|
			Synth.tail(~server, \router,[
				\out, i,
				\in, tower.outBus
			]);
		});
	};

	~spread = {
		~free.value;
		~synths = ~towers.collect({|tower, i|
			Synth.tail(~server, \spreader,[
				\out, 0,
				\in, tower.outBus,
				\pos, [-1, 1.0].resamp1(~towers.size)[i]
			]);
		});
	};

	~free = {
		try { ~synths.do(_.free); };
	};
});
)

