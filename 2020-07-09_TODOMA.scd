// patch name: TODOMA
// patch date: 2020-07-09
// patch desc: an experiment in decoupling MIDIdef and SynthDef

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