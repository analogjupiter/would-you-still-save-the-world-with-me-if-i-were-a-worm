module game.interactive;

import core.stdc.stdlib : abs;
import game.cairo;
import game.geometry;
import game.state;

enum MouseButton {
	left,
	right,
}

enum MouseAction {
	up,
	down,
}

struct MouseClick {
	Point pos;
	MouseButton button;
	MouseAction action;
	int clicks;
}

enum driftTolerance = 4;

struct MouseClickTracker {
	enum ButtonState {
		none,
		down,
		triggered,
	}

	private {
		Point _pos;
		ButtonState _state;
	}

nothrow @nogc:

	bool track(const Point pos, const MouseAction action) {
		if (action == MouseAction.down) {
			_state = ButtonState.down;
			_pos = pos;
			return false;
		}
		else {
			if (_state == ButtonState.none) {
				return false;
			}

			if (_state == ButtonState.down) {
				Point delta = _pos - pos;
				delta.x = abs(delta.x);
				delta.y = abs(delta.y);

				if ((delta.x > driftTolerance) || (delta.y > driftTolerance)) {
					_state = ButtonState.none;
					return false;
				}

				return true;
			}

			return false;
		}
	}

	void reset() {
		_state = ButtonState.none;
	}
}

alias ActivateCallback = void function(ref GameState state);
alias DrawCallback = void function(ref GameState state);
alias InputCallback = void function(ref GameState state, MouseClick input);

struct InteractiveScreen {
	ActivateCallback onActivate = null;
	DrawCallback onDraw = null;
	InputCallback onInput = null;
}
