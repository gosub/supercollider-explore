// patch name: PEPUQEF
// patch date: 2020-07-22
// patch desc: korg nanopad midi test
// patch prev: TODOMA


(
// factory defaults
~nanopad_chan = 0;
~nanopad_cc = Dictionary[
    \xy_gate -> 16,
    \x_axis -> 1,
    \y_axis -> 2];

~nanopad_first_button = 36;
~nanopad_scenes = 4;
~nanopad_buttons_per_scene = 16;

~nanopad_notes = Dictionary.new;
~nanopad_scenes.do {|scene|
    ~nanopad_buttons_per_scene.do {|button|
        var symbol, note;
        if(scene==0,
            {symbol = format("butt%",button + 1).asSymbol},
            {symbol = format("butt%sc%",button + 1,scene).asSymbol});
        note = (scene * ~nanopad_buttons_per_scene) + button + ~nanopad_first_button;
        ~nanopad_notes.put(symbol, note);
    };
};
)

(
MIDIClient.init;
MIDIIn.connectAll;
)


(
~np = ~make_controller.(~nanopad_cc, ~nanopad_notes, ~nanopad_chan);
)

(
~np.on_butt1 = {|val|
    f = {var a = Synth(\default,[\amp, val, \freq, 500]);
            0.1.sleep;
            a.release
    };
    val.asBoolean.if({f.fork});
};
)

MIDIdef.freeAll;
