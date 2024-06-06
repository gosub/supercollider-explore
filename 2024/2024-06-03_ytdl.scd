// Helper function to extract audio from a youtube video
// and save it to a file
//
// Note:
// - Linux/OSX/Unix only (uses .unixCmd)
// - Needs yt-dlp to be installed
// - The download procedure is synchronous

(
~ytdl = {|vid, filename, debug=false|
	var output;
	if (File.exists(filename)) {
		if (debug) {(filename + "already present").postln};
		filename;
	} {
		if (debug) {("downloading" + vid + "into" + filename).postln};
		output = ["yt-dlp", "--extract-audio", "--audio-format", "wav",
			"--output", filename, vid].unixCmdGetStdOut;
		if (debug) {output.postln};
		filename;
	};
};
)

// example usage
(
~rr = "dQw4w9WgXcQ";
~file = "/tmp/rr.wav";

("downloading:" + ~file).postln;
~ytdl.(~rr, ~file);
("download complete:" + ~file).postln;

~buffer = Buffer.read(s, ~file);
)

(
// BUFFER MUST BE STEREO!
SynthDef(\hellish, {
	|out, bufnum, descent=20, dist=7|
	var beat = 60/113;
	var cuts = [beat, beat/2, beat/3];
	var rates = Line.kr([-1,1,-1], [-1.5, 1.3, -1.2], descent);
	var frames = BufFrames.kr(bufnum);
	var lf = LFNoise0.ar(cuts).linlin(-1, 1, 0, frames);
	var snd = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum)/rates,
		Impulse.kr(cuts), startPos: lf);
	snd = Splay.ar(snd.flatten.scramble) * Line.kr(1, dist, descent);
	snd = snd.tanh * 0.5;
	Out.ar(out, snd);
}).add;
)

Synth(\hellish, [\bufnum, ~buffer]);

File.delete(~file);
