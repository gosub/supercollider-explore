// patch name: TODOMA
// patch date: 2020-07-09
// patch desc: an experiment in decoupling MIDIdef and SynthDef


// possible solution: https://scsynth.org/t/buses-and-functions-questions/1902/5


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
~np_chan = 0;
~np_cc_x = 11;
~np_cc_y = 12;
~nanopadX = Bus.control();
~nanopadY = Bus.control();

MIDIClient.init;
MIDIIn.connectAll;

MIDIdef.cc(\nanoX, {|val, cc, chan, src| ~nanopadX.set(val/127)}, ~np_cc_x, ~np_chan);
MIDIdef.cc(\nanoY, {|val, cc, chan, src| ~nanopadY.set(val/127)}, ~np_cc_y, ~np_chan);
)

(
// NOT WORKING
~nanopadX.linlin(0,1,1,100).poll
)