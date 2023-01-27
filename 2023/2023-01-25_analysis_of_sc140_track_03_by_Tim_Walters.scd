// sc-140 track #03 - Tim Walters
// original code

play{({|k|({|i|y=SinOsc;y.ar(i*k*k,y.ar(i*k**i/[4,5])*Decay.kr(Dust.kr(1/4**i),y.ar(0.1)+1*k+i,k*999))}!8).product}!16).sum}//#supercollider


// rewritten for readability

(
{
    var external_function, internal_function;
    // outer loop
    16.collect({ |i|
        // inner loop
        8.collect({ |j|
            // base function
            var frequency, phase, phase_env, phase_env_trig, phase_env_decay_time;
            frequency = j*i*i;
            phase_env_trig = Dust.kr(1/4 ** j);
            phase_env_decay_time = SinOsc.ar(0.1)+1 * i + j;
            phase_env = Decay.kr(phase_env_trig, decayTime: phase_env_decay_time, mul: i*999);
            phase = SinOsc.ar(j*i**j / [4,5]) * phase_env;
            SinOsc.ar(frequency, phase);
        }).product;
    }).sum;
}.play;
)

// analysis


// signal path graph


// interesting modifications


// variation

{|x| x}!7