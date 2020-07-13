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
// make a dictionary: cc -> variable name
~np_chan = 0;
~np_cc_xy_gate = 16;
~np_cc_x = 01;
~np_cc_y = 02;

MIDIClient.init;
MIDIIn.connectAll;
)

(
~map_normalized_cc_to_callback = {|cc_num, midi_chan, symbol|
    MIDIdef.cc(symbol,
        func: {|val, cc, chan, src|
            symbol.envirGet.(val/127);
        },
        ccNum: cc_num,
        chan: midi_chan);
};

~map_normalized_cc_to_callback.(~np_cc_xy_gate, ~np_chan, \xyGateCB);

~xyGateCB = {|val| "Nanopad XY Gate Callback".postln};
)

(
~synth = Synth(\default);

~xyGateCB = {|val| ~synth.set(\amp, val)};
)

(
MIDIdef.freeAll;
~synth.release;
)