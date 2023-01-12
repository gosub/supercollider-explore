// patch name: RESINICA
// patch date: 2019-11-28
// patch desc: tuned comb filters array v2 (cf. Ableton Live Resonators)
// patch prev: ACORESIA

(
{
    var note, semi, deltimes;
    var in, inl, inr;
    var filt, sel, freq;
    var c1,c2,c3,c4,c5;
    var sumL, sumR;
    var gain, spread;
    sel = 3;
    freq = SinOsc.kr(1/10).range(50, 500);
    note = 60;
    semi = [4,7,11,12];
    gain = -10;
    spread = 0.5;
    in = LeakDC.ar(PinkNoise.ar).dup/5 + SoundIn.ar([0,1]);
    filt = Select.ar(sel, [in, LPF.ar(in, freq), HPF.ar(in, freq),
        BPF.ar(in, freq), BRF.ar(in, freq)]);
    # inl, inr = filt;
    deltimes = (([0] ++ semi) + note).midicps.reciprocal;
    c1 = CombL.ar(inl+inr, delaytime: deltimes[0]);
    c2 = CombL.ar(inl, delaytime: deltimes[1]);
    c3 = CombL.ar(inr, delaytime: deltimes[2]);
    c4 = CombL.ar(inl, delaytime: deltimes[3]);
    c5 = CombL.ar(inr, delaytime: deltimes[4]);
    sumL = (c1/2 + c2 + c4) * gain.dbamp;
    sumR = (c1/2 + c3 + c5) * gain.dbamp;
    Splay.ar([sumL, sumR], spread);
}.play
)
