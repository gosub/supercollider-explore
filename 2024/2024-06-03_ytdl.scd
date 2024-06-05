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

File.delete(~file);