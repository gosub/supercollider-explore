
// should I ever need a sample
// b = Buffer.read(s, "/home/gg//dl/audio/samples/il_popolo_celebra.wav");
// {PlayBuf.ar(1, b, BufRateScale.kr(b))!2}.play;

(
SynthDef(\spettrovoce, {
	var car, spectrum, ffb, lfo;
	spectrum = [230, 320, 560, 830, 1200, 1700, 2300, 3200, 4500, 5400];
	lfo = SinOsc.ar(\lfofreq.kr(1/5)).range(1/4,4);
	car = Pulse.ar(\freq.kr(440));
	spectrum = spectrum * lfo;
	ffb = [LPF.ar(car, spectrum[0])] ++ BPF.ar(car, spectrum[1..8]) ++ [HPF.ar(car, spectrum[9])];
	Out.ar(\out.kr, ffb.sum!2);
}).add;
)

a = Synth(\spettrovoce);
a.free;
