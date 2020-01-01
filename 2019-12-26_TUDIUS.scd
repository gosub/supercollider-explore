// patch name: TUDIUS
// patch date: 2019-12-26
// patch desc: schizophrenic strings
// patch prev: NODODO

(
{
    var f1, f2, d1, d2;
    y = LocalIn.ar;
    f1 = SinOsc.ar(1/20, mul: 300, add: 700);
    f2 = SinOsc.ar(1/15, mul: 500, add: 1000);
    d1 = LFNoise0.ar(2).range(0.001, 0.1).lag(0.01);
    d2 = LFNoise1.ar(1/4).range(0.002, 0.2);
    z = LPF.ar(y * 0.3 + Decay.ar(Dust.ar(2, 0.5), 0.2, PinkNoise.ar), [f1, f2]);
    z = z + AllpassL.ar(z, 0.1, d1, 2);
    z + AllpassL.ar(z, 0.2, d2, 3);
    z = LeakDC.ar(z.distort);
    LocalOut.ar([z]);
    z * 3;
}.play;
)
