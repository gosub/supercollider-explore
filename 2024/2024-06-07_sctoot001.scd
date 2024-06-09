// initial idea
{Streson.ar(LFNoise0.ar(333) * LFPulse.ar(5),delayTime: 70.reciprocal, res: 0.9)!2}.play

// modulable parameters:
// - base noise freq = 333
// - gate pulse freq = 5
// - Streson delay time = 1/70
// - Streason resonance = 0.9

// TODO: rewrite as SynthDef with parameters

// version 2
{n=LFNoise0; Streson.ar(n.ar(n.kr(1/4).linlin(0,1,200,500)) * LFTri.ar(n.kr(1/2).linlin(0,1,3,10)),delayTime: 30.midicps.reciprocal, res: 0.8).tanh!2}.play
