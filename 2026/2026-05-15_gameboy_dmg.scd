// ============================================================
// Game Boy DMG - APU Simulation in SuperCollider
// Four channels: CH1 (pulse+sweep), CH2 (pulse), CH3 (wave),
//                CH4 (noise/LFSR)
//
// Boot the server first (s.boot or the GUI button), then:
//   1. Evaluate the SynthDefs block - wait for "SynthDefs ready."
//   2. Evaluate any demo block to play it.
//   3. Stop with Ctrl-. (CmdPeriod).
// ============================================================


// ============================================================
// BLOCK 1 - SynthDefs, wave buffers, helpers
// ============================================================
(
// ---- frequency helpers ----
// GB hardware freq register → Hz:  f = K / (2048 - reg)
//   CH1/CH2 pulse:  K = 131072
//   CH3 wave:       K =  65536   (sounds one octave lower for same reg)
~gbFreq  = { |reg| 131072 / (2048 - reg) };
~gbFreq3 = { |reg|  65536 / (2048 - reg) };


// ---- CH1: pulse + sweep --------------------------------------
// Duty: 0.125 / 0.25 / 0.5 / 0.75 (12.5/25/50/75 %)
// Sweep: XLine from freqStart → freqEnd over sweepTime seconds.
// Volume envelope: 15-step staircase (hardware-accurate).
// MantissaMask.ar(sig, 4) ≈ 4-bit per-channel DAC.
SynthDef(\gb_ch1_sweep, {
    |out = 0,
     freqStart = 440, freqEnd = 880,
     sweepTime = 0.4,
     duty = 0.5,
     decay = 0.3,                       // total time vol 15 → 0
     amp = 0.3,
     pan = 0|

    var nSteps = 15;
    var levels = (nSteps, nSteps-1 .. 0) / nSteps;
    var env    = EnvGen.kr(
        Env(levels, (decay/nSteps)!nSteps, \hold),
        doneAction: 2) * amp;
    var freq   = XLine.kr(freqStart, freqEnd, sweepTime);
    var osc    = Pulse.ar(freq, duty);
    var crush  = MantissaMask.ar(osc * env, 4);

    Out.ar(out, Pan2.ar(crush, pan));
}).add;


// ---- CH2: pulse (no sweep) -----------------------------------
SynthDef(\gb_ch2, {
    |out = 0,
     freq = 440,
     duty = 0.5,
     decay = 0.2,
     amp = 0.25,
     pan = 0|

    var nSteps = 15;
    var levels = (nSteps, nSteps-1 .. 0) / nSteps;
    var env    = EnvGen.kr(
        Env(levels, (decay/nSteps)!nSteps, \hold),
        doneAction: 2) * amp;
    var osc    = Pulse.ar(freq, duty);
    var crush  = MantissaMask.ar(osc * env, 4);

    Out.ar(out, Pan2.ar(crush, pan));
}).add;


// ---- CH3: wave channel (wavetable from buffer) ---------------
// Three GB-style wavetables (32 samples each).
~waveBuffers = Dictionary.new;

~waveBuffers[\triangle] = Buffer.loadCollection(s,
    Signal.fill(32, { |i|
        if(i < 16, { i / 15 * 2 - 1 }, { (31-i) / 15 * 2 - 1 })
    }).asWavetable);

~waveBuffers[\sawtooth] = Buffer.loadCollection(s,
    Signal.fill(32, { |i| 1 - (i / 31 * 2) }).asWavetable);

~waveBuffers[\stepped] = Buffer.loadCollection(s,
    Signal.fill(32, { |i|
        var v = if(i < 16, { i / 15 * 2 - 1 }, { (31-i) / 15 * 2 - 1 });
        (v * 7).round / 7                // 4-bit-style quantisation
    }).asWavetable);

// CH3 has no amplitude envelope on hardware - just gate the note flat.
// Attack/release are 2/3 ms only to suppress on/off clicks.
SynthDef(\gb_ch3, {
    |out = 0,
     bufnum = 0,
     freq = 440,
     attack = 0.002,
     sustain = 0.3,
     release = 0.003,
     amp = 0.2,
     pan = 0|

    var env = EnvGen.kr(
        Env([0, amp, amp, 0], [attack, sustain, release], 0),
        doneAction: 2);
    var osc = Osc.ar(bufnum, freq);

    Out.ar(out, Pan2.ar(osc * env, pan));
}).add;


// ---- CH4: noise (15-bit white / 7-bit buzzy) -----------------
// clockShift 1–13: 1 = bright, 13 = dark
// shortLFSR 0 = 15-bit (white-ish), 1 = 7-bit (pitched/buzzy)
SynthDef(\gb_ch4_noise, {
    |out = 0,
     clockShift = 4,
     shortLFSR = 0,
     decay = 0.15,
     amp = 0.3,
     pan = 0|

    var cutoff = (13 - clockShift).linexp(0, 12, 200, 18000);
    var noise  = WhiteNoise.ar;
    var shaped = Select.ar(shortLFSR, [
        LPF.ar(noise, cutoff),                 // 15-bit: filtered white
        BPF.ar(noise, cutoff * 0.5, 0.3)       //  7-bit: bandpass buzzy
    ]);
    var nSteps = 15;
    var levels = (nSteps, nSteps-1 .. 0) / nSteps;
    var env    = EnvGen.kr(
        Env(levels, (decay/nSteps)!nSteps, \hold),
        doneAction: 2) * amp;

    Out.ar(out, Pan2.ar(shaped * env, pan));
}).add;


"SynthDefs ready.".postln;
)


// ============================================================
// DEMO 1 - CH2 pulse duty showcase
//
// Same 8-note phrase loops with the duty cycling 12.5 → 25 → 50 → 75 %.
// Listen for the timbral progression:
//   12.5 %  thin, nasal, hollow
//   25 %    classic GB "lead"
//   50 %    full square, round/fat
//   75 %    sounds identical to 25 % (pulse wave is symmetric)
// ============================================================
(
TempoClock.default.tempo = 150/60;
Pbind(
    \instrument, \gb_ch2,
    \freq,  Pseq([659, 784, 880, 784, 659, 587, 659, 587], inf),
    \dur,   0.25,
    \decay, 0.22,
    \amp,   0.30,
    \duty,  Pdup(8, Pseq([0.125, 0.25, 0.5, 0.75], inf)),
).play;
)


// ============================================================
// DEMO 2 - CH3 wavetable comparison
//
// Same melody played in succession with each wave shape:
//   triangle  smooth, warm, sine-like
//   sawtooth  bright, buzzy, harmonically rich
//   stepped   "GB metallic" - staircased triangle (true CH3 sound)
// ============================================================
(
TempoClock.default.tempo = 150/60;
Pbind(
    \instrument, \gb_ch3,
    \freq,    Pseq([523, 587, 659, 698, 784, 698, 659, 587], inf),
    \dur,     0.25,
    \sustain, 0.22,
    \amp,     0.28,
    \bufnum,  Pdup(8, Pseq([
        ~waveBuffers[\triangle],
        ~waveBuffers[\sawtooth],
        ~waveBuffers[\stepped],
    ], inf)),
).play;
)


// ============================================================
// DEMO 3 - CH4 drum groove
//
// Two-bar K/S/H pattern on the single noise channel
// (real GB hardware: CH4 is monophonic - one drum at a time).
//   K = kick      clockShift 11 (dark)
//   S = snare     clockShift  5 (mid)
//   H = hi-hat    clockShift  3 (bright)
// Pattern: K H S H | K H S H | K K S H | K H S H
// ============================================================
(
TempoClock.default.tempo = 150/60;
Pbind(
    \instrument, \gb_ch4_noise,
    \dur,        0.25,
    \clockShift, Pseq([11, 3, 5, 3,  11, 3, 5, 3,
                       11,11, 5, 3,  11, 3, 5, 3], inf),
    \decay,      Pseq([0.20, 0.04, 0.10, 0.04,  0.20, 0.04, 0.10, 0.04,
                       0.20, 0.20, 0.10, 0.04,  0.20, 0.04, 0.10, 0.04], inf),
    \amp,        Pseq([0.40, 0.18, 0.32, 0.18,  0.40, 0.18, 0.32, 0.18,
                       0.40, 0.40, 0.32, 0.18,  0.40, 0.18, 0.32, 0.18], inf),
).play;
)


// ============================================================
// DEMO 4 - CH4 7-bit "buzzy" noise as tonal percussion
//
// shortLFSR=1 + low clockShift gives the periodic noise loop that
// real GB games used for tom rolls, laser bleeps and pitched perc.
// ============================================================
(
TempoClock.default.tempo = 150/60;
Pbind(
    \instrument, \gb_ch4_noise,
    \shortLFSR,  1,
    \clockShift, Pseq([4, 6, 8, 10, 8, 6], inf),
    \dur,        0.2,
    \decay,      0.15,
    \amp,        0.30,
).play;
)


// ============================================================
// DEMO 5 - Full 4-channel piece (4-bar Am - F - C - G loop)
//
// CH2 lead melody (50 % duty, left)
// CH1 counter-arpeggio (25 % duty, right)
// CH3 stepped-triangle bass (centred)
// CH4 standard drum kit
// ============================================================
(
TempoClock.default.tempo = 150/60;
Ppar([
    // CH2 - lead melody
    Pbind(
        \instrument, \gb_ch2,
        \freq, Pseq([
            440, 523, 659, 587,    // Am
            523, 494, 440, 392,    // F
            440, 523, 659, 784,    // C
            659, 587, 494, 440,    // G
        ], inf),
        \dur,   1.0,
        \decay, 0.6,
        \duty,  0.5,
        \amp,   0.26,
        \pan,  -0.3,
    ),
    // CH1 - arpeggio counter (8th notes)
    Pbind(
        \instrument, \gb_ch1_sweep,
        \freqStart, Pseq([
            220, 262, 330, 262,   220, 262, 330, 262,    // Am: A C E
            175, 220, 262, 220,   175, 220, 262, 220,    // F:  F A C
            262, 330, 392, 330,   262, 330, 392, 330,    // C:  C E G
            196, 247, 294, 247,   196, 247, 294, 247,    // G:  G B D
        ], inf),
        \freqEnd,   Pkey(\freqStart),       // fixed pitch, no sweep
        \sweepTime, 0.001,
        \dur,    0.5,
        \duty,   0.25,
        \decay,  0.30,
        \amp,    0.16,
        \pan,    0.3,
    ),
    // CH3 - stepped-triangle bass
    Pbind(
        \instrument, \gb_ch3,
        \bufnum, ~waveBuffers[\stepped],
        \freq, Pseq([
            110, 110, 110, 110,    // A2
             87,  87,  87,  87,    // F2
            131, 131, 131, 131,    // C3
             98,  98,  98,  98,    // G2
        ], inf),
        \dur,     1.0,
        \sustain, 0.95,
        \amp,     0.32,
    ),
    // CH4 - kick / hat / snare / hat
    Pbind(
        \instrument, \gb_ch4_noise,
        \clockShift, Pseq([11, 3, 5, 3], inf),
        \decay,      Pseq([0.18, 0.05, 0.10, 0.05], inf),
        \amp,        Pseq([0.32, 0.16, 0.26, 0.16], inf),
        \dur,        0.5,
    ),
], inf).play;
)


// ============================================================
// NOTES
// ============================================================
//
// CH1 (\gb_ch1_sweep):
//   freqStart / freqEnd → sweep range (set equal for fixed pitch)
//   duty 0.125 / 0.25 / 0.5 / 0.75 → timbre (thinner → fatter)
//   decay → total envelope time (15 hardware steps to silence)
//
// CH2 (\gb_ch2):
//   duty 0.5 → default, most-used in actual ROMs
//   decay → total envelope time
//
// CH3 (\gb_ch3):
//   swap bufnum with ~waveBuffers[\triangle / \sawtooth / \stepped]
//   sustain → flat amplitude hold time (no decay envelope on hardware)
//
// CH4 (\gb_ch4_noise):
//   clockShift 1–4   → bright (hi-hat)
//   clockShift 5–7   → mid (snare)
//   clockShift 9–13  → dark (kick)
//   shortLFSR 1      → buzzy 7-bit noise (tonal perc)
//   decay → total envelope time
//
// Frequency helpers:
//   ~gbFreq.(reg)   for CH1/CH2 pulse channels  (131072/(2048-reg))
//   ~gbFreq3.(reg)  for CH3 wave channel        ( 65536/(2048-reg))
//
// Stop everything:  CmdPeriod  (Ctrl-.)
