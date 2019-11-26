// patch name: OLOVASE
// patch date: 2019-11-25
// patch desc: distorted percussions in a sea of reverb

(
{
    ~beat = Impulse.ar(4);
    ~env = EnvGen.ar(Env.perc(releaseTime:0.1), gate: ~beat);
    ~distortion = LFPulse.kr(1/2).range(4, 8);
    ~osc = SinOsc.ar(freq:100 * (1+~env));
    ~noise_osc = PinkNoise.ar * 0.3 + ~osc * 0.7;
    ~perc = ~env * ~distortion * ~noise_osc;
    ~mix = SinOsc.kr(freq: 1/10).range(0.5, 0.999);
    ~signal = FreeVerb.ar(~perc, room: 1, mix: ~mix, damp: 0.5);
    ~signal.tanh.dup * 0.3;
}.play
)