// patch name: TODOMA
// patch date: 2020-07-09
// patch desc: an experiment in decoupling MIDIdef and SynthDef


/*

KORG NANOPAD2 MIDI DATA
dumped with: amidi -p hw:1 --dump

// XY TOUCH
B0 10 7F // touch on
B0 01 49 // touch x
B0 02 50 // touch y
B0 10 00 // touch off

// BUTTON PRESS
90 24 57  // button 1 on
80 24 40  // button 1 off

90 25 60  // button 2 on
80 25 40  // button 2 on

*/

(
// factory defaults
~nanopad_chan = 0;
~nanopad_cc = Dictionary[
    \xy_gate -> 16,
    \x_axis -> 1,
    \y_axis -> 2];

~nanopad_note_butt1 = 36;

MIDIClient.init;
MIDIIn.connectAll;
)

// TODO: factory defaults dictionary for notes/buttons
// TODO: change order of parameters in ~map_normalized_ functions: symbol, cc_num, midi_chan
// TODO: provide default value (nil) for midi_chan param in ~map_normalized_ funcs
// TODO: write the ~map_normalized_note_to_callback
MIDIdef.noteOn(\butt1on, {|vel, note, chan, src| vel.postln}, ~nanopad_note_butt1, ~nanopad_chan);
MIDIdef.noteOff(\butt1off, {|vel, note, chan, src| vel.postln}, ~nanopad_note_butt1, ~nanopad_chan);

(
~map_normalized_cc_to_callback = {|cc_num, midi_chan, symbol|
    MIDIdef.cc(symbol,
        func: {|val, cc, chan, src|
            symbol.envirPut(val/127);
            ("on_" ++ symbol).asSymbol.envirGet.(val/127);
        },
        ccNum: cc_num,
        chan: midi_chan);
};

~map_normalized_note_to_callback = {|note_num, midi_chan, symbol|
    MIDIdef.noteOn(symbol,
        func: {|velocity, note, chan, src|
            symbol.envirPut(velocity/127);
            ("on_" ++ symbol).asSymbol.envirGet.(velocity/127);
        },
        noteNum: note_num,
        chan: midi_chan);
    //TODO: .noteOff
};
)


(
~nanopad_cc.keysValuesDo { |symbol, cc_num|
    ~map_normalized_cc_to_callback.(cc_num, ~nanopad_chan, symbol);
};
)

(
~synth = Synth(\default, [\amp, 0]);
~on_xy_gate = {|val| ~synth.set(\amp, val)};
)

(
~synth.release;
~on_xy_gate = nil;
)

(
~pattern = Pbind(
    \note, Pseq([0,7,4,11],inf),
    \dur, Pfunc({~xy_gate}) * 0.3 + 0.3
).play;
)

~pattern.stop;

MIDIdef.freeAll;