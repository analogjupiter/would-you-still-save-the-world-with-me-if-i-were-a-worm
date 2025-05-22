module game.state;

import game.audio;
import game.cairo;
import game.geometry;
import game.glyph;
import game.interactive;
import game.memory;
import game.puzzle.data;
import game.pango;

private alias Pixmap = game.cairo.Pixmap;

struct GameState {
	enum width = 640;
	enum height = 360;

	enum totalPixels = width * height;

	version (none) {
		static immutable gameTitle = "Ah, yes! My favourite game: “Game Title”!!";
	}
	else {
		static immutable gameTitle = "Would you still save the world with me if I were a worm?";
	}

	Allocator allocator;

	bool running;
	bool fullscreen = false;
	const(InteractiveScreen)* nextScreen;

	Pixmap framebuffer;

	Ticks ticks;

	Assets assets;

	MouseClickTracker clickL;
	MouseClickTracker clickR;

	AudioPlayer audio;

	LoaderState loader;
	TitleScreenState titleScreen;
	IntroScreen introScreen;
	PuzzleScreen puzzleScreen;
}

struct Ticks {
	ulong total;
	ulong delta;
}

struct Assets {
	Font fontTextM;
	Font fontTextR;

	GlyphRenderer glyphRenderer;

	FontFace fontEmoji1;
	FontFace fontEmoji2;

	static immutable audioMenuURL = "e://m";
	static immutable audioIntroURL = "e://i";
	static immutable audioPuzzleURL = "e://p";
	AudioFile audioMenu;
	AudioFile audioIntro;
	AudioFile audioPuzzle;
}

struct LoaderState {
	Allocator allocator;
}

struct TitleScreenState {
	ColorRGB24[] background;
	int earth;
	ulong earthTicksCheckpoint;
}

struct IntroScreen {
	int slide;
	bool pressedSkipOnce;
	int earth;
	ulong earthTicksCheckpoint;
}

struct PuzzleScreen {
	PuzzleGame g;
	int speed;
	char[] speedMessage;
	ulong ticksCheckpoint;
}
