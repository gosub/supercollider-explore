(

a = {
    |freq=100,freq2=100, amp=0,filtfreq=20, delay=0.001, amfb=0, fmfb=0, fffb=0, delfb=0|
    ~fb = LocalIn.ar(1,0);
    ~saw = LFSaw.ar(freq+(freq*~fb*fmfb), 0, amp + (amp*~fb*amfb));
    ~saw = ~saw + LFSaw.ar(freq2+(freq2*~fb*fmfb), 0, amp + (amp*~fb*amfb));
    ~saw = LPF.ar(~saw, filtfreq+(filtfreq*~fb*fffb));
    ~del = DelayC.ar(~saw, 1, (delay*~fb*delfb).abs);
    LocalOut.ar([~del]);
    ~saw.tanh.dup;
}.play();

w = Window.new("saw").layout_(
    HLayout(
        Slider().action_({|self| a.set(\amp, self.value)}),
        Slider().action_({|x| a.set(\freq, [100,2000].asSpec.map(x.value))}),
        Slider().action_({|x| a.set(\freq2, [100,2000].asSpec.map(x.value))}),
        Slider().action_({|x| a.set(\filtfreq, [20,2000].asSpec.map(x.value))}),
        Slider().action_({|x| a.set(\delay, [0.001,1].asSpec.map(x.value))}),
        Slider().action_({|x| a.set(\amfb, x.value)}),
        Slider().action_({|x| a.set(\fmfb, x.value)}),
        Slider().action_({|x| a.set(\fffb, x.value)}),
        Slider().action_({|x| a.set(\delfb, x.value)}),
    )
).front;
)

(
a = {
    |f1=40,f2=40,f3=40,f4=40,f5=40,f6=40,f7=40,f8=40,fb1=0,fb2=0,fb3=0,fb4=0,fb5=0,fb6=0,fb7=0,fb8=0,fbfreq=1, delay=0.001|
    ~fb = LocalIn.ar(1,0);
    ~saw = LFSaw.ar(f1+(1000*~fb*fb1), 0, 0.05);
    ~saw = ~saw + LFSaw.ar(f2+(1000*~fb*fb2), 0, 0.05);
    ~saw = ~saw + LFSaw.ar(f3+(1000*~fb*fb3), 0, 0.05);
    ~saw = ~saw + LFSaw.ar(f4+(1000*~fb*fb4), 0, 0.05);
    ~saw = ~saw + LFSaw.ar(f5+(1000*~fb*fb5), 0, 0.05);
    ~saw = ~saw + LFSaw.ar(f6+(1000*~fb*fb6), 0, 0.05);
    ~saw = ~saw + LFSaw.ar(f7+(1000*~fb*fb7), 0, 0.05);
    ~saw = ~saw + LFSaw.ar(f8+(1000*~fb*fb8), 0, 0.05);
    ~saw = ~saw.tanh;
    LocalOut.ar([DelayC.ar(LPF.ar(~saw,fbfreq),1,delay)]);
    ~saw.dup;
}.play();

w = Window.new("saw").layout_(
    VLayout(
      HLayout(
        Slider().action_({|x| a.set(\f1, [40,777,\exp].asSpec.map(x.value))}),
        Slider().action_({|x| a.set(\f2, [40,777,\exp].asSpec.map(x.value))}),
        Slider().action_({|x| a.set(\f3, [40,777,\exp].asSpec.map(x.value))}),
        Slider().action_({|x| a.set(\f4, [40,777,\exp].asSpec.map(x.value))}),
        Slider().action_({|x| a.set(\f5, [40,777,\exp].asSpec.map(x.value))}),
        Slider().action_({|x| a.set(\f6, [40,777,\exp].asSpec.map(x.value))}),
        Slider().action_({|x| a.set(\f7, [40,777,\exp].asSpec.map(x.value))}),
        Slider().action_({|x| a.set(\f8, [40,777,\exp].asSpec.map(x.value))}),
      ),
      HLayout(
        Slider().action_({|x| a.set(\fb1, (x.value))}),
        Slider().action_({|x| a.set(\fb2, (x.value))}),
        Slider().action_({|x| a.set(\fb3, (x.value))}),
        Slider().action_({|x| a.set(\fb4, (x.value))}),
        Slider().action_({|x| a.set(\fb5, (x.value))}),
        Slider().action_({|x| a.set(\fb6, (x.value))}),
        Slider().action_({|x| a.set(\fb7, (x.value))}),
        Slider().action_({|x| a.set(\fb8, (x.value))}),
      ),
      HLayout(
        Slider().action_({|x| a.set(\fbfreq, [1,100,\exp].asSpec.map(x.value))}),
        Slider().action_({|x| a.set(\delay, [0.001,1].asSpec.map(x.value))}),
      )
   )
).front;
)