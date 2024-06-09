// initial idea
{Streson.ar(LFNoise0.ar(333) * LFPulse.ar(5),delayTime: 70.reciprocal, res: 0.9)!2}.play

// modulable parameters:
// - base noise freq = 333
// - gate pulse freq = 5
// - Streson delay time = 1/70
// - Streason resonance = 0.9

// TODO: rewrite as SynthDef with parameters

