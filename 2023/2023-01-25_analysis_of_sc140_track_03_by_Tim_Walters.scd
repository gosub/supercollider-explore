// sc-140 track #03 - Tim Walters
// original code

play{({|k|({|i|y=SinOsc;y.ar(i*k*k,y.ar(i*k**i/[4,5])*Decay.kr(Dust.kr(1/4**i),y.ar(0.1)+1*k+i,k*999))}!8).product}!16).sum}//#supercollider


// rewritten for readability

(
{
    var external_function, internal_function;
    16.collect({ |i|
        8.collect({ |j|
            var frequency, phase;
            frequency = j*i*i;
            phase = SinOsc.ar(j*i**j/[4,5]) * Decay.kr(Dust.kr(1/4**j), SinOsc.ar(0.1)+1*i+j, i*999);
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