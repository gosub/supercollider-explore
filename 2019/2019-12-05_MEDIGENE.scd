// patch name: MEDIGENE
// patch date: 2019-12-05
// patch desc: hyper-distorted drones

(
{
    var sig, env, freqs, gate, gens;
    freqs = [100,50,75,90];
    gate = Impulse.ar(1/3);
    env = EnvGen.ar(Env.perc, gate: gate);
    gens = [SinOsc.ar(freqs), Pulse.ar(freqs), Saw.ar(freqs)];
    sig = Select.ar(Stepper.ar(gate, max:2), gens);
    sig = Mix.ar(sig);
    sig = env * sig;
    2.do {
        sig = Limiter.ar(sig**2);
        sig = FreeVerb.ar(sig, mix:0.6, room:0.9,
            damp:0.99, mul:10);
        sig = sig.distort;
    };
    sig.dup * 0.3;
}.play;
)