// ============================================================
// Tetris - Theme A "Korobeiniki" (Game Boy DMG)
// SuperCollider - Pbind / Pseq / Ppar
//
// Melodia: robsoncouto/arduino-songs + correzioni da MIDI vgmusic
// Basso: trascrizione MIDI vgmusic (6 tracce, 150 BPM)
//        note sotto 64 Hz (limite hardware GB CH1/CH2) clampate all'ottava sopra
// Struttura: A A B A A B - loop infinito
//
// Uso:
//   1. Esegui blocco 1 - aspetta "SynthDefs ready."
//   2. Esegui blocco 2
//   3. Stop: Ctrl+.
// ============================================================


// ============================================================
// BLOCCO 1 - SynthDef e Buffer
//
// Bit-crushing: (sig).round(1/8) → 17 livelli lineari ≈ 4-bit DAC
// ============================================================
(
SynthDef(\t_lead, {
    |out=0, freq=440, sustain=0.18, amp=0.5, duty=0.5|
    // GB NR22=$84: vol 8/15, decrease, pace 4 → 8 steps × 4/64 s = 0.5 s
    var stepEnv = EnvGen.kr(Env((8,7..0)/15, (4/64)!8, \hold));
    // Note gate: hold at 1 for sustain-3ms, then 3ms fade-out to kill clicks
    var gateEnv = EnvGen.kr(
        Env([0, 1, 1, 0], [0.0001, sustain - 0.003, 0.003], [-4, 0, -4]),
        doneAction: 2);
    var sig = Pulse.ar(freq, duty) * stepEnv * gateEnv * amp;
    Out.ar(out, Pan2.ar(sig, -0.3));
}).add;

SynthDef(\t_bass, {
    |out=0, freq=110, sustain=0.18, amp=0.5, duty=0.5|
    // GB NR12=$43: vol 4/15, decrease, pace 3 → 4 steps × 3/64 s ≈ 0.19 s
    var stepEnv = EnvGen.kr(Env((4,3..0)/15, (3/64)!4, \hold));
    var gateEnv = EnvGen.kr(
        Env([0, 1, 1, 0], [0.0001, sustain - 0.003, 0.003], [-4, 0, -4]),
        doneAction: 2);
    var sig = Pulse.ar(freq, duty) * stepEnv * gateEnv * amp;
    Out.ar(out, Pan2.ar(sig, 0.3));
}).add;

~bassBuf = Buffer.loadCollection(s,
    Signal.fill(32, { |i|
        var v = if(i < 16, { i/15*2-1 }, { (31-i)/15*2-1 });
        (v * 7).round / 7
    }).asWavetable);

SynthDef(\t_wave, {
    |out=0, bufnum=0, freq=110, sustain=0.18, amp=0.5, pan=0|
    // GB CH3 with NR32=$20 (100% output) has NO amplitude envelope.
    // Flat amplitude for the note; minimal attack/release just to suppress clicks.
    var env = EnvGen.kr(
        Env([0, 1, 1, 0], [0.002, sustain - 0.005, 0.003], [-4, 0, -4]),
        doneAction: 2);
    Out.ar(out, Pan2.ar(Osc.ar(bufnum, freq) * env * amp, pan));
}).add;

// CH4 noise - GB NR42=$A1 vol 10/15, pace 1 → 10 × 1/64 s ≈ 156 ms decay
// NR43=$00 → 15-bit LFSR, clock shift 0, divisor 0 (brightest noise)
SynthDef(\t_noise, {
    |out=0, amp=0.5, sustain=0.18, cutoff=15000|
    var stepEnv = EnvGen.kr(Env((10,9..0)/15, (1/64)!10, \hold));
    var gateEnv = EnvGen.kr(
        Env([0, 1, 1, 0], [0.0001, sustain - 0.003, 0.003], [-4, 0, -4]),
        doneAction: 2);
    var sig = LPF.ar(WhiteNoise.ar, cutoff) * stepEnv * gateEnv * amp;
    Out.ar(out, sig ! 2);
}).add;

"SynthDefs ready.".postln;
)


// ============================================================
// BLOCCO 2 - Pattern (dati diretti dalla ROM kaspermeerts/tetris)
//
// Frequenze Hz dalla tabella NotePitches ($6E02):
//   CH1/CH2: f = 131072 / (2048 - reg)
//   CH3:     f =  65536 / (2048 - reg)  (ottava sotto per stesso registro)
//
// Struttura ROM per canale (loop indipendenti):
//   CH2 melodia: [7168, 7168, 71AE]  → A A B  = 96 beat/ciclo
//   CH1 c-mel:   [71CB, 71CB, 721D]  → A A B  = 64 beat/ciclo
//   CH3 basso:   [723A, 723A, 727F, 727F] → A A B B = 96 beat/ciclo
//   CH4 noise:   loop continuo
// ============================================================
(
var bpm   = 150;
var tempo = bpm / 60;   // beat/s

// ---------- CH2: melodia principale - GB CH2 (pulse, duty 50%) ----------
// Sezione A [7168], 32 beat
var m2Af = [
    658.65, 494.61, 524.29, 587.77, 524.29, 494.61,   // b1 E5 B4 C5 D5 C5 B4
    439.84, 439.84, 524.29, 658.65, 587.77, 524.29,   // b2 A4 A4 C5 E5 D5 C5
    494.61, 524.29, 587.77, 658.65,                    // b3 B4(dq) C5 D5 E5
    524.29, 439.84, 439.84, Rest(),                    // b4 C5 A4 A4 rest(q)
    Rest(), 587.77, 697.19, 879.68, 784.86, 697.19,   // b5 rest(e) D5 F5 A5 G5 F5
    658.65, 524.29, 658.65, 587.77, 524.29,           // b6 E5(dq) C5 E5 D5 C5
    494.61, 494.61, 524.29, 587.77, 658.65,           // b7 B4 B4(e) C5 D5 E5
    524.29, 439.84, 439.84, Rest()                     // b8 C5 A4 A4 rest(q)
];
var m2Ad = [
    1.0, 0.5, 0.5, 1.0, 0.5, 0.5,
    1.0, 0.5, 0.5, 1.0, 0.5, 0.5,
    1.5, 0.5, 1.0, 1.0,
    1.0, 1.0, 1.0, 1.0,
    0.5, 1.0, 0.5, 1.0, 0.5, 0.5,
    1.5, 0.5, 1.0, 0.5, 0.5,
    1.0, 0.5, 0.5, 1.0, 1.0,
    1.0, 1.0, 1.0, 1.0
];

// Sezione B [71AE], 32 beat
var m2Bf = [
    329.33, 261.10, 293.88, 246.84,   // b9-10  E4 C4 D4 B3
    261.10, 219.92, 207.72, Rest(),   // b11-12 C4 A3 G#3(dq) rest
    329.33, 261.10, 293.88, 246.84,   // b13-14 E4 C4 D4 B3
    261.10, 329.33, 439.84, 414.78, Rest()  // b15-16 C4 E4 A4 G#4 rest
];
var m2Bd = [
    2.0, 2.0, 2.0, 2.0,
    2.0, 2.0, 3.0, 1.0,
    2.0, 2.0, 2.0, 2.0,
    1.0, 1.0, 2.0, 2.0, 2.0
];

// ---------- CH1: contromelodia - GB CH1 (pulse, duty 25%) ----------
// Sezione A [71CB], 16 beat
var m1Af = [
    494.61, 414.78, 439.84, 494.61, 658.65, 587.77, 439.84, 414.78,
    329.33, 439.84, 524.29, Rest(), 494.61, 439.84,
    414.78, 414.78, 329.33, 414.78, 439.84,
    494.61, 524.29, 439.84, 329.33, 329.33, Rest()
];
var m1Ad = [
    1.0, 0.5, 0.5, 0.5, 0.25, 0.25, 0.5, 0.5,
    1.5, 0.5, 0.5, 0.5, 0.5, 0.5,
    0.25, 0.25, 0.5, 0.5, 0.5,
    1.0, 1.0, 1.0, 1.0, 1.0, 1.0
];

// Sezione B [721D], 32 beat
var m1Bf = [
    261.10, 219.92, 246.84, 207.72, 219.92, 164.87, 164.87, 246.84, Rest(),
    261.10, 219.92, 246.84, 207.72, 219.92, 261.10, 329.33, 293.88, Rest()
];
var m1Bd = [
    2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 1.0, 1.0,
    2.0, 2.0, 2.0, 2.0, 1.0, 1.0, 2.0, 2.0, 2.0
];

// ---------- CH3: basso wave - GB CH3 (wavetable stepped-triangle) ----------
// Sezione A [723A], 32 beat
// Hz = 65536/(2048-reg) - stessa reg di CH1/CH2 suona un'ottava sotto
var b3Af = [
    // Em: E2/E3 x4
     82.44,164.66,  82.44,164.66,  82.44,164.66,  82.44,164.66,
    // Am: A2/A3 x4
    109.96,219.92, 109.96,219.92, 109.96,219.92, 109.96,219.92,
    // G#2/G#3 x2 + E2/E3 x2
    103.86,207.39, 103.86,207.39,  82.44,164.66,  82.44,164.66,
    // Am + note di passaggio: A2/A3 x3, B2 C3
    109.96,219.92, 109.96,219.92, 109.96,219.92, 123.42,130.55,
    // Dm: D3 D2 rest D2 rest
    146.94,  73.39,Rest(),  73.39,Rest(),
    // Dm cont.: D2 A2 F2 C2 C3 rest
     73.39,109.96,  87.26,  65.41,130.55,Rest(),
    // C: C3 C2 G2 G2 rest
    130.55,  65.41,  97.96,  97.96,Rest(),
    // B/Em: B2 B3 rest B3 rest
    123.42,247.31,Rest(),247.31,Rest(),
    // chiusura: E3 rest G#3 A2 E3 A2 E3
    164.66,Rest(),207.39,109.96,164.66,109.96,164.66,
    // finale: A2(q) rest(q)
    109.96,Rest()
];
var b3Ad = [
    0.5,0.5, 0.5,0.5, 0.5,0.5, 0.5,0.5,
    0.5,0.5, 0.5,0.5, 0.5,0.5, 0.5,0.5,
    0.5,0.5, 0.5,0.5, 0.5,0.5, 0.5,0.5,
    0.5,0.5, 0.5,0.5, 0.5,0.5, 0.5,0.5,
    0.5, 0.5,0.5, 0.5,0.5,
    0.5,0.5, 0.5, 0.5,0.5,0.5,
    0.5, 0.5, 0.5, 0.5,0.5,
    0.5,0.5,0.5, 0.5,0.5,
    0.5,0.5, 0.5,0.5,0.5,0.5,0.5,
    1.0,1.0
];

// Sezione B [727F], 16 beat
var b3Bf = [
    // A3/E4 x4
    219.92,329.33, 219.92,329.33, 219.92,329.33, 219.92,329.33,
    // G#3/E4 x4
    207.39,329.33, 207.39,329.33, 207.39,329.33, 207.39,329.33,
    // A3/E4 x4
    219.92,329.33, 219.92,329.33, 219.92,329.33, 219.92,329.33,
    // G#3/E4 x2 + rest
    207.39,329.33, 207.39,329.33, Rest()
];
var b3Bd = [
    0.5,0.5, 0.5,0.5, 0.5,0.5, 0.5,0.5,
    0.5,0.5, 0.5,0.5, 0.5,0.5, 0.5,0.5,
    0.5,0.5, 0.5,0.5, 0.5,0.5, 0.5,0.5,
    0.5,0.5, 0.5,0.5, 2.0
];

// ---------- Factory functions ----------
var mkCh2 = { |f, d|
    Pbind(
        \instrument, \t_lead,
        \freq,    Pseq(f, 1),
        \dur,     Pseq(d, 1),
        \sustain, Pkey(\dur) * (0.92 / tempo),
        \amp,     0.5,
        \duty,    0.5,
    )
};
var mkCh1 = { |f, d|
    Pbind(
        \instrument, \t_bass,
        \freq,    Pseq(f, 1),
        \dur,     Pseq(d, 1),
        \sustain, Pkey(\dur) * (0.90 / tempo),
        \amp,     0.5,
        \duty,    0.5,   // GB NR11=$81 → 50% duty (was 25%, was wrong)
    )
};
var mkCh3 = { |f, d|
    Pbind(
        \instrument, \t_wave,
        \bufnum,  ~bassBuf,
        \freq,    Pseq(f, 1),
        \dur,     Pseq(d, 1),
        \sustain, Pkey(\dur) * (0.95 / tempo),
        \amp,     0.5,
        \pan,     0,
    )
};

// CH4 noise - Section_72A3 dal ROM (ciclo 8 beat, loop infinito)
// Tutti i colpi: NR43=$00 (15-bit LFSR, brillante), NR42=$A1 (vol 10/15)
// Pattern: R N R N R | n n | R N R N R N R | N N N
//   R/N = 0.5 beat (eighth),  n = 0.25 beat (sixteenth)
var n4f = [Rest(), 0, Rest(), 0, Rest(),  0,   0,
           Rest(), 0, Rest(), 0, Rest(), 0, Rest(),
           0, 0, 0];
var n4d = [0.5,    0.5, 0.5,  0.5, 0.5,  0.25, 0.25,
           0.5,    0.5, 0.5,  0.5, 0.5,  0.5,  0.5,
           0.5, 0.5, 0.5];
var pNoise = Pbind(
    \instrument, \t_noise,
    \freq,    Pseq(n4f, inf),         // Rest() per pause, 0 placeholder per noise
    \dur,     Pseq(n4d, inf),
    \sustain, Pkey(\dur) * (0.95 / tempo),
    \amp,     0.22,
    \cutoff,  15000,
);

// Loop indipendenti per canale (come nella ROM)
var pMel2 = Pseq([mkCh2.(m2Af,m2Ad), mkCh2.(m2Af,m2Ad), mkCh2.(m2Bf,m2Bd)], inf);
var pMel1 = Pseq([mkCh1.(m1Af,m1Ad), mkCh1.(m1Af,m1Ad), mkCh1.(m1Bf,m1Bd)], inf);
var pBass = Pseq([mkCh3.(b3Af,b3Ad), mkCh3.(b3Af,b3Ad), mkCh3.(b3Bf,b3Bd), mkCh3.(b3Bf,b3Bd)], inf);

Ppar([pMel2, pMel1, pBass, pNoise], 1).play(TempoClock(bpm / 60));
)
