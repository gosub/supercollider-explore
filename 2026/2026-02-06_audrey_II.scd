// patch name: Audrey II
// patch date: 2026-02-06
// patch desc: software Audrey II drone synthesizer (Synthux Academy / Fede Repic)
//             feedback-driven self-oscillating drone machine
//
// signal flow:
//   noise seed (-90dBFS) + fb_return -> KS resonator -> overdrive -> LPF -> HPF -> reverb
//       ^                                                                            |
//       +--- feedback delay ("body", 1-100ms, stereo decorrelated) <--- fb_gain <----+
//                                                                                    |
//                                                                              echo send
//                                                                                    v
//                                                                     echo delay (50ms-5s)
//                                                                     BPF 800Hz -> tanh
//                                                                        (tape degradation)
//
// no oscillator generates sound -- the feedback loop self-excites when gain > ~0 dB

(
SynthDef(\audrey2, {
	|out=0, freq=48, fbGain= -20, body=0.01, lpf=12000, hpf=60,
	 verbMix=0.3, verbDecay=0.5,
	 echoSend=0, echoTime=0.3, echoFb=0.5,
	 vol=0.3|
	var seed, sigL, sigR, verbL, verbR;
	var fbRetL, fbRetR, echoRetL, echoRetR;
	var echoTapeL, echoTapeR, echoOutL, echoOutR;
	var kFreq = Lag.kr(freq, 0.2).midicps;
	var kBody = Lag.kr(body, 1.0);
	var kFbAmp = Lag.kr(fbGain, 0.05).dbamp;
	var kLpf = Lag.kr(lpf, 0.05);
	var kHpf = Lag.kr(hpf, 0.05);
	var kEchoTime = Lag.kr(echoTime, 0.5);
	var kEchoSend = Lag.kr(echoSend, 0.05);
	var kEchoFb = Lag.kr(echoFb, 0.05);

	// feedback return: 2 main fb + 2 echo fb
	#fbRetL, fbRetR, echoRetL, echoRetR = LocalIn.ar(4);

	// === MAIN FEEDBACK LOOP ===

	// white noise seed at -90 dBFS + feedback (independent L/R seeds)
	sigL = WhiteNoise.ar(-90.dbamp) + (fbRetL * kFbAmp);
	sigR = WhiteNoise.ar(-90.dbamp) + (fbRetR * kFbAmp);

	// karplus-strong resonator (tuned comb filter + brightness damping)
	sigL = OnePole.ar(CombL.ar(sigL, 0.2, kFreq.reciprocal, 2), 0.98);
	sigR = OnePole.ar(CombL.ar(sigR, 0.2, kFreq.reciprocal, 2), 0.98);

	// overdrive (soft clipping)
	sigL = (sigL * 1.5).tanh;
	sigR = (sigR * 1.5).tanh;

	// feedback loop filters + DC blocker
	sigL = LeakDC.ar(HPF.ar(LPF.ar(sigL, kLpf), kHpf));
	sigR = LeakDC.ar(HPF.ar(LPF.ar(sigR, kLpf), kHpf));

	// reverb (inside the feedback loop, as in original)
	#verbL, verbR = FreeVerb2.ar(sigL, sigR,
		Lag.kr(verbMix, 0.05), Lag.kr(verbDecay, 0.05), 0.5);

	// === ECHO DELAY (outside the feedback loop) ===
	// tape-style: each repetition passes through BPF + soft clip,
	// progressively losing highs and lows (telephone-like degradation)

	// tape degradation on echo feedback return
	echoTapeL = BPF.ar(echoRetL, 800, 1.0).tanh;
	echoTapeR = BPF.ar(echoRetR, 800, 1.0).tanh;

	// mix echo input (dry send) with degraded feedback, then delay
	echoOutL = DelayC.ar((verbL * kEchoSend) + (echoTapeL * kEchoFb), 5, kEchoTime);
	echoOutR = DelayC.ar((verbR * kEchoSend) + (echoTapeR * kEchoFb), 5, kEchoTime);

	// write all feedback paths
	LocalOut.ar([
		// main feedback delay ("body") -- right offset by 4 samples for stereo
		DelayC.ar(verbL, 0.25, kBody),
		DelayC.ar(verbR, 0.25, max(SampleDur.ir, kBody - (4 * SampleDur.ir))),
		// echo delay feedback
		echoOutL,
		echoOutR
	]);

	// final mix: dry + echo wet, then limiter
	Out.ar(out, Limiter.ar([
		verbL + echoOutL,
		verbR + echoOutR
	] * 0.5 * Lag.kr(vol, 0.05), 0.7));
}).add;

a = Synth(\audrey2);

w = Window.new("Audrey II", Rect(200, 200, 460, 480)).layout_(
	VLayout(
		StaticText().string_("Audrey II -- feedback drone synthesizer").align_(\center),
		HLayout(
			VLayout(StaticText().string_("Freq"),
				Slider().action_({|x| a.set(\freq, [16,72].asSpec.map(x.value))})),
			VLayout(StaticText().string_("Fb Gain"),
				Slider().action_({|x| a.set(\fbGain, [-60,12].asSpec.map(x.value))})),
			VLayout(StaticText().string_("Body"),
				Slider().action_({|x| a.set(\body, [0.001,0.1,\exp].asSpec.map(x.value))})),
		),
		HLayout(
			VLayout(StaticText().string_("LPF"),
				Slider().action_({|x| a.set(\lpf, [100,18000,\exp].asSpec.map(x.value))})),
			VLayout(StaticText().string_("HPF"),
				Slider().action_({|x| a.set(\hpf, [10,4000,\exp].asSpec.map(x.value))})),
		),
		HLayout(
			VLayout(StaticText().string_("Verb Mix"),
				Slider().action_({|x| a.set(\verbMix, x.value)})),
			VLayout(StaticText().string_("Verb Decay"),
				Slider().action_({|x| a.set(\verbDecay, [0.2,1.0].asSpec.map(x.value))})),
		),
		HLayout(
			VLayout(StaticText().string_("Echo Send"),
				Slider().action_({|x| a.set(\echoSend, [0.001,1.0,\exp].asSpec.map(x.value))})),
			VLayout(StaticText().string_("Echo Time"),
				Slider().action_({|x| a.set(\echoTime, [0.05,5.0,\exp].asSpec.map(x.value))})),
			VLayout(StaticText().string_("Echo Fb"),
				Slider().action_({|x| a.set(\echoFb, [0.0,1.5].asSpec.map(x.value))})),
		),
		HLayout(
			VLayout(StaticText().string_("Volume"),
				Slider().action_({|x| a.set(\vol, [0.001,1.0,\exp].asSpec.map(x.value))})),
		),
	)
).front;
)
