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
// define a function: (cc, varname) -> set a mididef on that cc with
//                                     a fun that changes the global variable
//                                     to the cc value
~npXyGateCB = {|val| "Nanopad XY Gate Callback".postln};

MIDIdef.cc(\nanoTouchGate,
    func: {|val, cc, chan, src|
        ~npXyGateCB.value(val/127);
    },
    ccNum:~np_cc_xy_gate,
    chan:~np_chan);
)

(
~synth = Synth(\default);

~npXyGateCB = {|val| ~synth.set(\amp, val)};
)

(
MIDIdef.freeAll;
~synth.release;
)