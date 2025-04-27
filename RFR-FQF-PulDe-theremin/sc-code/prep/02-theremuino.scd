(
~theremuino = Proto({
	~server = Server.default;
	~baudrate = 115200;
	~packetSize = 4; // Expected size of the SLIP packet sent by the Arduino.
	~values = Int16Array.newClear(~packetSize); // raw values (need to combine bytes).
	~pitchBus = Bus.control(~server);
	~volumeBus = Bus.control(~server);
	~processingAddress = NetAddr("127.0.0.1", 60120);
	forkIfNeeded {
		SynthDef(\transferDef, {
			arg antennaIn=0, out=0, buf;
			var antennaVal;
			antennaVal = In.kr(antennaIn);
			Out.kr(out, BufRd.kr(1, buf, antennaVal, loop:0, interpolation:2));
		}).add;
		~server.sync;
	};


	~action = {|vals|
		var res;
		res = Int16Array(maxSize: ~packetSize / 2);
		forBy(0, vals.size - 2, 2) { |i|
			res.add( (vals[i] << 8) | vals[i+1] );
		};
		try {
			var volume, alphas;
			volume = ~enveloper.volumeSpec.warp.unmap(res[1]);
			alphas = ~enveloper.envs.collect({|env|	env[res[0]]; });
			~pitchBus.set(res[0]);
			~volumeBus.set(volume);
			~printVals.if({
				"Pitch:\t".post; res[0].post; "\t".post;
				"Volume:\t".post; volume.postln;
			});
			~processingAddress.sendMsg("/volume", volume);
			~processingAddress.sendMsg("/alphaChannels", * alphas);
		};
	};

	~initialize = { |enveloper, printVals, portName|
		~initArduino.value(portName);
		~enveloper = enveloper;
		~printVals = false ? printVals;
		forkIfNeeded {
			~buffers = ~enveloper.envs.collect({|env|
				Buffer.loadCollection(~server, env);
			});
			~server.sync;
			~buses = ~enveloper.numSeg.collect({ |i|
				Bus.control(~server, 1);
			});
			~server.sync;
			~transferSynths = ~enveloper.numSeg.collect({ |i|
				Synth.head(~server, \transferDef, [
					\antennaIn, ~pitchBus,
					\out, ~buses[i],
					\buf, ~buffers[i]
				]);
			});
			~server.sync;
		};
		currentEnvironment;
	};

	~initArduino = { |portName|
		Platform.case(
			\linux, {
				SerialPort.devicePattern = "/dev/tty[A,U]*"
			},
			\osx, {
				SerialPort.devicePattern = "/dev/tty.usbmodem*"
			},
			\windows, {
				SerialPort.devicePattern = nil
			},
		);
		// If the portname is not specified, select the first matching port.
		// This is platform dependant, but not thoroughly tested.
		~portName = portName ? SerialPort.devices[0];
		~port = SerialPort(
			port: ~portName,
			baudrate: ~baudrate
		);

		~inputThread = fork {
			// SLIP ENCODED THEREMUINO 
			// =======================
			// 
			// The theremuino has 2 antennae.  Each has a 10 bit value
			// encoded in two bytes.  A theremuino packet contains 4
			// bytes:
			// 
			// |  0 | pitch-MSB   |
			// |  1 | pitch-LSB   |
			// |  2 | volume-MSB  |
			// |  3 | volume-LSB  |
			// 
			// The packets are SLIP encoded using these special characters:
			// end = 8r300 (2r11000000 or 0xc0 or 192)
			// esc = 8r333 (2r11011011 or 0xdb or 219)
			// esc_end = 8r334 (2r011011100 or 0xdc or 220)
			// esc_esc = 8r335 (2r011011101 or 0xdd or 221)

			var data, buffer, serialByte;
			var slipEND = 192;
			var slipESC = 219;
			var slipESC_END = 220;
			var slipESC_ESC = 221;
			buffer = Int16Array(maxSize: ~packetSize);
			{
				serialByte = ~port.read;
				serialByte.switch(
					slipEND, {
						(buffer.size > 0).if({
							~values = buffer;
							~action.value(~values);
						});
						buffer = Int16Array(maxSize: ~packetSize);
					},
					slipESC, {
						serialByte = ~port.read;
						serialByte.switch(
							slipESC_END, { buffer.add(slipEND) },
							slipESC_ESC, { buffer.add(slipESC) },
							{"SLIP encoding error.".warn; buffer.postln; }
						)
					},
					{ buffer.add(serialByte); }
				);
			}.loop
		};
	};

	~free = {
		~port.close;
		~pitchBus.free;
		~volumeBus.free;
		~buffers.do(_.free);
		~buses.do(_.free);
		~transferSynths.do(_.free);
	};
});
)
