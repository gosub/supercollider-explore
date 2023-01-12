// patch name: ISOTIPA
// patch date: 2020-07-06
// patch desc: aliasing square-wave fm noise machine

(
{
    var rnd_rate, freq, mod, max_freq;
    rnd_rate = MouseY.kr(20,1,1);
    mod = LFNoise0.ar(rnd_rate).linexp(-1,1,20,5000);
    max_freq =MouseX.kr(100,5000,1);
    freq = Pulse.ar(mod).range(20,max_freq);
    LFPulse.ar(freq) *0.2!2;
}.play
)