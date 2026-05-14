// «Periodic Lo-Fi Riff»
// by gosub

// based on «Periodic Carillion»
// by mimetikmusic
// https://sccode.org/1-4S3

(
SynthDef(\lofi, {
    var sig = Array.fill(3, { |n|
        SinOsc.ar(
            \freq.kr(440) * (1 + 0.02.rand) * (n+1),
            mul: \amp.kr(0.1) / (n*n+1))
    }).sum;
    var curve = Env.perc(0.1, \dur.kr(3));
    var env = EnvGen.kr(curve, gate: Impulse.kr(\rate.kr(1)));
    var env_baseline = LFNoise1.ar(1/3).range(0.1, 0.5);
    sig = sig + BrownNoise.ar(mul: -45.dbamp);
    sig = sig * env.linlin(0,1, env_baseline, 1);
    Out.ar(\out.kr(0), sig!2);
};
).add;
)

(
~root = 48;
//~degrees = [0,0,4,5,7,7,9,12,16,19].scramble;
~degrees = [0,0,4,5,7,7,9,11,14,19].scramble;
~len = ~degrees.size;
~coeff = 0.1;

~len.collect(
    {|n|
        Synth.new(\lofi,
            [
                \freq: (~root + ~degrees[n]).midicps,
                \amp: 0.4 / ~len,
                \rate: (1 + (n * ~coeff)) * 0.1
            ]);
    });
)
