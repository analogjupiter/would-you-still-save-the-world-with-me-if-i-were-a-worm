module game.puzzle.messenger;

private alias string = const(char)[];

enum MessageType {
	regular,
	alert,
	success,
}

struct Message {
	string content;
	MessageType type;
}

struct Messenger {
	private {
		Message _message = Message(null);
		ulong _current;
		ulong _checkpoint;
		ulong _ttl;
	}

@safe pure nothrow @nogc:

	bool tick(ulong current) {
		_current = current;

		if (_message.content is null) {
			return false;
		}

		const delta = _current - _checkpoint;
		if (delta > _ttl) {
			_message.content = null;
			return true;
		}

		return false;
	}

	void send(string message, MessageType type, ulong ttl = 2000) {
		_message = Message(message, type);
		_ttl = ttl;
		_checkpoint = _current;
	}

	Message receive() {
		return _message;
	}
}
