module game.loader;

import core.atomic;
import core.sys.posix.pthread;
import core.sys.posix.unistd;
import game.audio;
import game.cairo;
import game.glyph;
import game.pango;
import game.state;

private shared bool _done = false;

bool loaderIsDone() {
	return _done.atomicLoad;
}

void loadGame(GameState* state) {
	pthread_t thread;
	pthread_create(&thread, null, &gameLoaderImpl, cast(void*) state);
}

private:

extern (C) void* gameLoaderImpl(void* gameState) {
	GameState* state = cast(GameState*) gameState;

	// Audio
	{
		state.audio = AudioPlayer.makeNew(state);

		static immutable string audioMenu = import("dintro2.mod");
		state.assets.audioMenu = AudioFile(cast(Chunk) audioMenu, 65);

		static immutable string audioIntro = import("forestry.mod");
		state.assets.audioIntro = AudioFile(cast(Chunk) audioIntro, 35);

		static immutable string audioPuzzle1 = import("not it.mod");
		state.assets.audioPuzzle1 = AudioFile(cast(Chunk) audioPuzzle1, 60);

		static immutable string audioPuzzle2 = import("maandban.xm");
		state.assets.audioPuzzle2 = AudioFile(cast(Chunk) audioPuzzle2, 100);
	}

	// Fonts
	{
		Font.clearRegistrations();
		Font.register("/usr/share/fonts/truetype/ubuntu/Ubuntu-M.ttf");
		Font.register("/usr/share/fonts/truetype/ubuntu/Ubuntu-R.ttf");

		state.assets.fontTextM = Font.open("Ubuntu, Medium");
		state.assets.fontTextR = Font.open("Ubuntu, Regular");

		state.assets.glyphRenderer = GlyphRenderer();
		state.assets.glyphRenderer.open();

		state.assets.fontEmoji1 = state.assets.glyphRenderer.openFontFace("/usr/share/fonts/truetype/noto/NotoColorEmoji.ttf"); // @suppress(dscanner.style.long_line)
		state.assets.fontEmoji2 = state.assets.glyphRenderer.openFontFace("/usr/lib/thunderbird/fonts/TwemojiMozilla.ttf");

		state.assets.fontEmoji1.pixelSizes = 109;
	}

	// Title screen
	{
		import game.screens.common;

		state.titleScreen.background = state.allocator.makeSlice!ColorRGB24(state.totalPixels);
		clearRandom(state.titleScreen.background);
	}

	// Title screen
	{
		state.introScreen.slide = 0;
	}

	// Puzzle
	{
		import game.puzzle.data;
		import game.screens.puzzle;

		state.puzzleScreen.g = PuzzleGame.makeNew(state.allocator);
		state.puzzleScreen.speed = defaultSpeed;
		state.puzzleScreen.speedMessage = state.allocator.makeSlice!char(24);
		state.puzzleScreen.gameCompleteMainHandled = false;
	}

	_done.atomicStore = true;
	return null;
}
