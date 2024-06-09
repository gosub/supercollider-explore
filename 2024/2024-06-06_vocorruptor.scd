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
