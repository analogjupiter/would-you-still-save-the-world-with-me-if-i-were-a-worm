module game.audio;

import core.stdc.stdlib;
import game.crash;
import game.memory;
import game.state;
import libmpv_2;

alias Chunk = const(ubyte)[];

struct AudioFile {
	private {
		Chunk _data = null;
		Chunk _cursor = null;
		int _volume = 100;
	}

@safe pure nothrow @nogc:

	public this(Chunk data, int volume) {
		_data = data;
		_cursor = data;
		_volume = volume;
	}

	int volume() const => _volume;

	void rewind() {
		_cursor = _data;
	}

	size_t size() const => _data.length;

	bool eof() const => _cursor.length == 0;

	size_t read(ubyte[] chunk) {
		if (chunk.length > _data.length) {
			_data.copyMemTo(chunk);
			return _data.length;
		}

		_data[0 .. chunk.length].copyMemTo(chunk);
		return chunk.length;
	}

	void seek(size_t offset) {
		_cursor = _data[offset .. $];
	}
}

struct AudioFileHandler {
extern (C) static:

	int64_t size_fn(void* cookie) {
		AudioFile* af = cast(AudioFile*) cookie;
		return af.size;
	}

	int64_t read_fn(void* cookie, char* buf, uint64_t nbytes) {
		AudioFile* af = cast(AudioFile*) cookie;

		ubyte* b = cast(ubyte*) buf;
		size_t bytesRead = af.read(b[0 .. nbytes]);
		if (bytesRead == 0) {
			return (af.eof) ? 0 : -1;
		}

		return bytesRead;
	}

	int64_t seek_fn(void* cookie, int64_t offset) {
		AudioFile* af = cast(AudioFile*) cookie;

		if ((offset < 0) || (offset >= af.size)) {
			return MPV_ERROR_GENERIC;
		}

		af.seek(offset);
		return 0;
	}

	void close_fn(void* cookie) {
	}

	int open_fn(void* user_data, char* uri, mpv_stream_cb_info* info) {
		GameState* state = cast(GameState*) user_data;

		AudioFile* af = null;

		if (uri[4] == 'm') {
			af = &state.assets.audioMenu;
		}
		else if (uri[4] == 'i') {
			af = &state.assets.audioIntro;
		}
		else if (uri[4] == 'p') {
			af = &state.assets.audioPuzzle;
		}

		info.cookie = cast(void*) af;
		info.size_fn = &size_fn;
		info.read_fn = &read_fn;
		info.seek_fn = &seek_fn;
		info.close_fn = &close_fn;

		if (af is null) {
			return MPV_ERROR_LOADING_FAILED;
		}

		state.audio.volume = af.volume;

		af.rewind();
		return 0;
	}
}

struct AudioPlayer {
	private {
		mpv_handle* _ctx;
	}

	public this(mpv_handle* mpv) {
		_ctx = mpv;
	}

	static AudioPlayer makeNew(GameState* state) {
		mpv_handle* ctx = mpv_create();
		if (!ctx) {
			crash("mpv_create() failed\n");
		}

		int no = 0;
		mpv_set_option(ctx, "input-default-bindings", MPV_FORMAT_FLAG, &no);
		mpv_set_option(ctx, "input-vo-keyboard", MPV_FORMAT_FLAG, &no);
		mpv_set_option(ctx, "osc", MPV_FORMAT_FLAG, &no);

		mpv_initialize(ctx);

		mpv_stream_cb_add_ro(ctx, "e", state, &AudioFileHandler.open_fn);

		return AudioPlayer(ctx);
	}

	void play(const(char)* url, const(char)* options = null) {
		const(char)*[6] cmd;
		cmd[0] = "loadfile".ptr;
		cmd[1] = url;
		cmd[2] = "replace";
		version (none) {
			cmd[3] = "-1";
			cmd[4] = options;
			cmd[5] = null;
		}
		else {
			cmd[3] = options;
			cmd[4] = null;
		}
		mpv_command(_ctx, cmd.ptr);

		int yes = 1;
		mpv_set_option(_ctx, "loop", MPV_FORMAT_FLAG, &yes);
	}

	void volume(int64_t value) {
		mpv_set_option(_ctx, "volume", MPV_FORMAT_INT64, &value);
	}

	void stop() {
		mpv_command_string(_ctx, "stop");
	}

	void free() {
		mpv_terminate_destroy(_ctx);
	}
}
