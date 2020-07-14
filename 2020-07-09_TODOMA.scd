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

MIDIClient.init;
MIDIIn.connectAll;
)

// TODO: factory defaults dictionary for notes/buttons

// TODO: inside the mididef function set the global var \symbol
// and call the global callback \on_symbol

// TODO: write the ~map_normalized_note_to_callback

(
~map_normalized_cc_to_callback = {|cc_num, midi_chan, symbol|
    MIDIdef.cc(symbol,
        func: {|val, cc, chan, src|
            symbol.envirGet.(val/127);
        },
        ccNum: cc_num,
        chan: midi_chan);
};

~nanopad_cc.keysValuesDo { |symbol, cc_num|
    cc_num.postln;
    symbol.postln;
    ~map_normalized_cc_to_callback.(cc_num, ~nanopad_chan, symbol);
};
)

(
~synth = Synth(\default, [\amp, 0]);
~xy_gate = {|val| ~synth.set(\amp, val)};
)

(
MIDIdef.freeAll;
~synth.release;
)