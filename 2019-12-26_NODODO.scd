// patch name: NODODO
// patch date: 2019-12-26
// patch desc: echoing thumps over a slow changing drone

(
{
    var f1, f2;
    y = LocalIn.ar;
    f1 = SinOsc.ar(1/20, mul: 300, add: 700);
    f2 = SinOsc.ar(1/15, mul: 500, add: 1000);
    z = LPF.ar(y * 0.2 + Decay.ar(Dust.ar(2, 0.5), 0.2, WhiteNoise.ar), [f1, f2]);
    z = z + AllpassL.ar(z, 0.1, 0.1, 2) + AllpassL.ar(z, 0.2, 0.2, 3);
    z = LeakDC.ar(z.distort);
    LocalOut.ar([z]);
    z;
}.play;
)
