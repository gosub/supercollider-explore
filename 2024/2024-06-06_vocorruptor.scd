b = Buffer.read(s, "/home/gg//dl/audio/samples/il_popolo_celebra.wav");
{PlayBuf.ar(1, b, BufRateScale.kr(b))!2}.play;

(
SynthDef(\vocorruptor, {
	| bufnum |
	var car, mod, freqs;
	var bands = 30;
	var q = \q.kr(20);
	var fcar = BPF;
	var fmod = BRF;
	freqs = (1..bands).linexp(1, bands, 25, 15000);
	mod = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum), loop: 1) * \bufamp.kr(1);
	mod = fmod.ar(in: mod, freq: freqs, rq: 1/q, mul: sqrt(q));
	mod = Amplitude.kr(mod).lag(0.03);
	car = CombL.ar(PinkNoise.ar, 0.2, \freq.kr(50).reciprocal, mul: \caramp.kr(3));
	car = fcar.ar(in: car, freq: freqs, rq: 1/q, mul: mod);
	Out.ar(\out.kr, Splay.ar(car.scramble, spread: 0.2));
}).add;
)

a = Synth(\vocorruptor, [\bufnum, b, \bufamp, 2, \caramp, 5]);
a.set(\freq, [50,54,58,62,66,70].choose);


// original vocoder from Eli Fieldsteel - Supercollider minitutorial 12
(
x = SynthDef(\vocoder, {
	var mod, car, bpfmod, num = 30, track, bpfcar,
	bpfhz = (1..num).linexp(1, num, 25, 16000),
	q = \q.kr(20);

	// create modulator & carrier
	mod = PlayBuf.ar(1, b, BufRateScale.ir(b), loop: 1);
	car = CombL.ar(WhiteNoise.ar(1), 1/20, 1/\freq.kr(50), 3);

	// track spectrum of modulator
	bpfmod = BPF.ar(mod, bpfhz, 1/q, q.sqrt);
	track = Amplitude.kr(bpfmod).lag3(0.03) * 2;

	// apply spectrum to carrier
	bpfcar = BPF.ar(car, bpfhz, 1/q, q.sqrt) * track;

	Out.ar(0, Splay.ar(bpfcar.scramble, spread: 0.1));
}).play;
)
