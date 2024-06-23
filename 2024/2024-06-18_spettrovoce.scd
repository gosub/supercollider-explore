
// should I ever need a sample
// b = Buffer.read(s, "/home/gg//dl/audio/samples/il_popolo_celebra.wav");
// {PlayBuf.ar(1, b, BufRateScale.kr(b))!2}.play;

(
SynthDef(\spettrovoce, {
	var car, spectrum, ffb, lfo;
	var rq = \rq.kr(1);
	spectrum = [230, 320, 560, 830, 1200, 1700, 2300, 3200, 4500, 5400];
	car = Pulse.ar(\freq.kr(440));
	lfo = SinOsc.ar(\lfofreq.kr(1/5)).range(1/4, 4);
	spectrum = spectrum * Gate.ar(lfo, \pass.kr(1));

	ffb = [RLPF.ar(car, spectrum[0], rq: rq)] ++
	BPF.ar(car, spectrum[1..8], rq: rq) ++
	[RHPF.ar(car, spectrum[9], rq: rq)];
	Out.ar(\out.kr, ffb.sum!2);
}).add;
)

a = Synth(\spettrovoce, [\freq, 42.midicps]);
a.set(\lfofreq, 2.reciprocal);
a.set(\freq, [30,32,35,42].choose.midicps);
a.set(\rq, 1/10);
a.set(\pass, 0);
a.set(\pass, 1);
a.free;
