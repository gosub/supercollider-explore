// initial idea
{Streson.ar(LFNoise0.ar(333) * LFPulse.ar(5),delayTime: 70.reciprocal, res: 0.9)!2}.play

// modulable parameters:
// - base noise freq = 333
// - gate pulse freq = 5
// - Streson delay time = 1/70
// - Streson resonance = 0.9

// as a SynthDef
(
SynthDef(\sctoot001, {
	| out |
	var snd;
	snd = LFNoise0.ar(333) * LFPulse.ar(5);
	snd = Streson.ar(snd, delayTime: 70.reciprocal, res: 0.9);
	Out.ar(out, snd!2);
}).add;
)

// as a SynthDef with parameters
(
SynthDef(\sctoot001b, {
	| out |
	var snd;
	snd = LFNoise0.ar(\freq.kr(333)) * LFPulse.ar(\gatefreq.kr(5));
	snd = Streson.ar(snd, delayTime: \delay.kr(70.reciprocal), res: \res.kr(0.9));
	Out.ar(out, snd!2);
}).add;
)

a = Synth(\sctoot001b, [\freq, 333, \gatefreq, 5, \delay, 30.midicps.reciprocal, \res, 0.7]);

(
a.set(\delay, (30,32..40).choose.midicps.reciprocal,
	\res, (0.5,0.6..0.9).choose,
	\freq, (110,165..880).choose,
	\gatefreq, (2..10).choose);
)

// version 2
{n=LFNoise0; Streson.ar(n.ar(n.kr(1/4).linlin(0,1,200,500)) * LFTri.ar(n.kr(1/2).linlin(0,1,3,10)),delayTime: 30.midicps.reciprocal, res: 0.8).tanh!2}.play

// SynthDef of version 2
(
SynthDef(\sctoot001c, {
	| out |
	var snd, ff, gf, amf, note = \note.kr(30), f;
	ff = LFNoise0.kr(\freqfreq.kr(1/4)).linlin(0,1,200,500);
	amf = LFNoise0.kr(\amfreq.kr(1/2)).linlin(0,1,5,15);
	gf =  LFNoise0.kr(\gatefreq.kr(1/3)).linlin(0,1,3,10);
	snd = LFNoise0.ar(ff) * LFSaw.ar(amf) * LFPulse.ar(gf);
	f = note.midicps;
	snd = Streson.ar(snd, delayTime: 1/f, res: \res.kr(0.8));
	snd = (snd * \gain.kr(2)).tanh;
	Out.ar(out, snd!2);
}).add;
)

a = Synth(\sctoot001c);
a.set(\note, 30);
a.set(\res, 0.85);
