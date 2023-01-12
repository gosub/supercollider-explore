// patch name: VICRIMA
// patch date: 2019-12-01
// patch desc: sine percussions ring-modded with a pitch-shifted version of themself (twice)

(
{
    var a;
    a = SinOsc.ar(LFNoise0.ar(1).exprange(100,1000));
    a = a * EnvGen.ar(Env.perc, Dust.ar(8));
    a = a ring1: DelayL.ar(PitchShift.ar(a, pitchRatio: [0.2, 0.21]), 1, 0.2);
    a = a ring2: DelayL.ar(PitchShift.ar(a, pitchRatio: [0.2, 0.21]), 1, 0.2);
    a.tanh * 0.2;
}.play;
)
