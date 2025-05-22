module game.memory;

static import core.stdc.stdlib;
import game.crash;

nothrow @nogc:

struct Array(T) {
	private {
		T* _data = null;
		size_t _capacity = 0;
		size_t _length = 0;
	}

nothrow @nogc:

	public this(size_t initialCapacity) {
		capacity = initialCapacity;
	}

	size_t capacity() @safe pure {
		return _capacity;
	}

	void capacity(size_t value) {
		if (value < _capacity) {
			crash("Cannot shrink Array by reducing the capacity.");
		}

		_data = cast(T*) core.stdc.stdlib.realloc(_data, T.sizeof * value);
		if (_data is null) {
			crash("Out of memory.");
		}

		_capacity = value;
	}

	size_t length() @safe pure {
		return _length;
	}

	void length(size_t value) {
		if (value > capacity) {
			capacity = value;
		}

		_length = value;
	}

	private void ensureCapacity() {
		if (length < capacity) {
			return;
		}

		if (capacity < 2) {
			capacity = 2;
			return;
		}

		capacity = capacity + (capacity >> 1);
	}

	void opOpAssign(string op : "~", T)(T value) @trusted {
		this.ensureCapacity();
		_data[_length] = value;
		++_length;
	}

	T[] opSlice() @trusted pure {
		return _data[0 .. _length];
	}

	T[] opSlice(size_t start, size_t end) @trusted pure {
		if (end >= _length) {
			crash("Out of range.");
		}

		return _data[start .. end];
	}

	void free() @system {
		if (_data is null) {
			return;
		}

		core.stdc.stdlib.free(_data);
		_data = null;
		_capacity = 0;
	}
}

struct Allocator {
	private {
		Array!(void*) _pointers;
	}

	T* make(T, Args...)(Args args) {
		auto ptr = cast(T*) core.stdc.stdlib.malloc(T.sizeof);
		if (ptr is null) {
			crash("Out of memory.");
		}

		_pointers ~= ptr;

		*ptr = T(args);
		return ptr;
	}

	T[] makeSlice(T)(size_t length) {
		auto ptr = cast(T*) core.stdc.stdlib.malloc(T.sizeof * length);
		if (ptr is null) {
			crash("Out of memory.");
		}

		_pointers ~= ptr;

		return ptr[0 .. length];
	}

	void free() @system {
		foreach (ptr; _pointers[]) {
			core.stdc.stdlib.free(ptr);
		}

		_pointers.free();
	}
}

pragma(inline, true)
void copyMemTo(const(void)[] src, void[] dst) @trusted pure
in (src.length <= dst.length) {
	import core.stdc.string : memcpy;

	memcpy(dst.ptr, src.ptr, src.length);
}

pragma(inline, true)
void copyMemTo(const(void)* src, void* dst, size_t length) @system pure {
	import core.stdc.string : memcpy;

	memcpy(dst, src, length);
}

struct Chunks(T) {
	private {
		T[] _data;
		size_t _chunkLength;
	}

@safe pure nothrow @nogc:

	public this(T[] data, size_t chunkLength) {
		_data = data;
		_chunkLength = chunkLength;
	}

	bool empty() const => _data.length == 0;

	inout(T)[] front() inout {
		return _data[0 .. _chunkLength];
	}

	void popFront() {
		_data = _data[_chunkLength .. $];
	}
}

Chunks!T chunks(T)(T[] data, size_t chunkLength) @safe pure nothrow @nogc {
	pragma(inline, true);
	return Chunks!T(data, chunkLength);
}
