// patch name: ACORESIA
// patch date: 2019-11-27
// patch desc: tuned comb filters array (cf. Ableton Live Resonators)

(
{
    var in, notes, deltimes;
    notes = [60, 64, 67, 71, 72];
    in = SoundIn.ar([0,1]);
    deltimes = notes.midicps.reciprocal;
    Mix.new(deltimes.collect({|t| CombC.ar(in, delaytime: t)})) / 5;
}.play
)
