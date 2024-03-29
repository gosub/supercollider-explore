// sc-140 track #03 - Tim Walters
// original code

play{({|k|({|i|y=SinOsc;y.ar(i*k*k,y.ar(i*k**i/[4,5])*Decay.kr(Dust.kr(1/4**i),y.ar(0.1)+1*k+i,k*999))}!8).product}!16).sum}//#supercollider


// rewritten for readability

(
{
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

/*

Let's start from the base function. The arguments to this functions are i and j, the indices of the two nested loop. This function returns a single SinOsc oscillator. The frequency of the oscillator is fixed, and depends only on i and j (j*i*i). The phase of the oscillator in the main source of modulation and movement in the patch. The phase is modulated with another SinOsc oscillator, whose amplitude is controlled with another signal, that looks like a random envelope (phase_env). This envelope is trigged by a Dust ugen and its decay time is modulated by another SinOsc oscillator.Each of these Ugens has parameters derived by different combinations of costants, i and j, so that every signal generated by the inner function is unique.

The inner loop collects a list of 8 outputs of the base function, and multiplies all eight with each other, obtaining a single signal that is the equivalent of ring modulating them all together.

The outer loop repeats this process 16 times, collects these ring modulated signals and mixes them (`.sum`).

Since the base function returns a stereo signal, in total we have 2*8*16=256 audio sources that goes into the final output. If we add the various modulating ugens, the total ugen count for this patch goes up to 1688u.

One interesting aspect of the patch is that without phase modulation the result is just silence. You can check it by removing the `phase` parameter from the last SinOsc in the base function. This happens because the index in the  inner loop goes from 0 to 7, so the first oscillator has a frequency of 0 Hz (i.e. a flat signal of constant zero value). The other 7 oscillators (with index from 1 to 7) have a non-zero frequency, but in the end all these sources are multipled together (.product method), so the zero signal would zero-out all the others. The outer loop then would just mix together 16 signals of only silence.

But when we add phase modulation in the mix, since phase modulation is equivalent to frequency modulation, even the firsts 0-base-frequency signals have moments where the frequency in non zero, and those are the moments where we hear sounds in the final output.

*/

// signal path graph


// interesting modifications

/*

- add a constant value to the frequency of the final SinOsc, e.g. +7, +20, +100 or +0.01

*/

// variation

