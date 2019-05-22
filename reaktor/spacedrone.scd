// SpaceDrone remake

(
~geiger = {  |density, rndrange, dynamic|
    var freq, pulse, trig, rand;
    freq = (density + LocalIn.kr).midicps;
    pulse = Pulse.kr(freq);
    trig = Trig1.kr(pulse);
    LocalOut.kr(TRand.kr(lo: 1+(rndrange/2), hi: 1-(rndrange/2), trig: trig));
    // it's not clear how reaktor randomize works
    // does it output in+-rnd(range) or in+-rnd(range/2) ?
    TRand.kr(lo:dynamic.half.neg, hi:dynamic.half, trig: trig);
};

~pan_mod = { |pan, rnd|
    var frq, mod;
    mod = rnd.midicps;
    // approximation: reaktor "Slow Random" with LFNoise1
    frq = pan.midicps + LFNoise1.kr(freq: mod, mul: mod);
    LFTri.kr(freq: frq);
};

~filter_mod = { |pitch, env, speed, amount, offset, fundamental, voice_num|
    var s1, s2, s3, s4;
    s1 = offset + voice_num + 1;
    s2 = s1 * fundamental.midicps;
    s3 = pitch * env + s2.cpsmidi;
    s4 = s3 + LFNoise1.kr(speed, amount);
    s4.midicps;
};

~attenuator = { |damp, gain, offset, voice_num, voice_count|
    var arr, v1, v2;
    arr = Array.fill(voice_count, {|v| (v+1+offset).reciprocal.pow(damp)});
    v1 = arr[voice_num];
    v2 = v1 / arr.sum;
    v2 * gain.cubed;
};

~envelope = { |density, rndrange, dynamic, attack, decay|
    var ggr, env;
    ggr = ~geiger.value(density, rndrange, dynamic);
    env = EnvGen.ar(Env([0, 1, 0.5, 0], [attack, decay, decay]),
        gate: ggr, levelScale: ggr);
    env.squared;
};

)


(
{
    // input parameters
    var density, rndrange, dynamic;
    var attack, decay;
    var resonance;
    var pan, rnd;
    var pitch, speed, amount;
    var offset, fundamental;
    var damp, gain;

    var s1;

    ~voice_count = 64;

    density = -36;
    rndrange = 30;
    dynamic = 0.5;
    attack = 10;
    decay = 10;
    resonance = 0.49;
    pan = -60;
    rnd = -60;
    pitch = 0;
    speed = 5;
    amount = 1;
    offset = 16;
    fundamental = 60;
    damp = 0;
    gain = 0.9;


    s1 = Mix.ar(Array.fill(~voice_count, {
        arg voice_num;

        // local variables
        var env, sig, panmod, fmod, rq, att;

        env = ~envelope.value(density, rndrange, dynamic, attack, decay);
        sig = WhiteNoise.ar;
        fmod = ~filter_mod.value(pitch, env, speed, amount, offset, fundamental, voice_num);
        // rq formula from: native-instruments.com/forum/threads/filter-q-vs-resonance.234219/#post-1362202
        rq = 2 * (1 - resonance.pow(0.03125));
        sig = BPF.ar(sig, fmod, rq);
        sig = env * sig;
        sig = sig * ~attenuator.value(damp, gain, offset, voice_num, ~voice_count);
        panmod = ~pan_mod.value(pan, rnd);
        Pan2.ar(sig, panmod);
    }));
    GVerb.ar(s1);
}.scope;
)

