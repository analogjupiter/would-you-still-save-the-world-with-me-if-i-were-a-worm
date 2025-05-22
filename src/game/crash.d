module game.crash;

import core.stdc.stdarg;
import core.stdc.stdio;
import core.stdc.string;

nothrow @nogc:

// faux
pure {
	extern (C) void* malloc(size_t size) @safe;
	extern (C) void* realloc(void* ptr, size_t size);
	extern (C) void free(void* ptr);
	extern (C) noreturn exit(int status) @trusted;
	extern (C) int system(scope const char* string);
}

extern (C) noreturn crashf(const(char)* fmt, ...) {
	va_list args;
	va_start(args, fmt);
	const messageLength = vsnprintf(null, 0, fmt, args);
	va_end(args);
	if (messageLength <= 0) {
		showMessage("Error");
		exit(1);
	}

	const messageLengthz = messageLength + 1;
	auto message = cast(char*) malloc(messageLengthz);

	va_start(args, fmt);
	vsnprintf(message, messageLengthz, fmt, args);
	va_end(args);

	showMessage(message[0 .. messageLength]);
	version (none)
		free(message);
	exit(1);
}

noreturn crash(const(char)[] message) @safe pure {
	showMessage(message);
	exit(1);
}

private void showMessage(const(char)[] message) @trusted pure {
	static immutable tpl = "zenity --error --text=";

	const length = tpl.length + message.length + 3;

	auto ptr = cast(char*) malloc(length);

	memcpy(ptr, tpl.ptr, tpl.length);
	ptr[tpl.length] = '\'';
	foreach (idx, char c; message) {
		if (c == '\'') {
			c = '"';
		}
		else if (c == '\0') {
			c = '?';
		}
		ptr[tpl.length + 1 + idx] = c;
	}
	ptr[length - 2] = '\'';
	ptr[length - 1] = '\0';
	cast(void) system(ptr);

	version (none)
		free(ptr);
}
