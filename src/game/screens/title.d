module game.screens.title;

import game.cairo;
import game.emoji;
import game.geometry;
import game.glyph;
import game.interactive;
import game.memory;
import game.pango;
import game.screens.common;
import game.state;

static immutable titleScreen = InteractiveScreen(
	&onActivate,
	&onDraw,
	&onInput,
);

private:

version (none) {
	enum buttonPlay = Rectangle(Point(395, 80), Size(200, 50));
}
enum buttonPlay = Rectangle(Point(395, 140), Size(200, 50));
enum buttonFull = Rectangle(Point(395, 200), Size(200, 50));
enum buttonMute = Rectangle(Point(395, 260), Size(200, 50));
version (none) {
	enum buttonQuit = Rectangle(Point(395, 260), Size(200, 50));
}

void onActivate(ref GameState state) {
	version (none) {
		state.audio.play(state.assets.audioMenuURL.ptr, "start=+4,audio-pitch-correction=no,speed=0.9818181818181818");
	}
	state.audio.play(state.assets.audioMenuURL.ptr, "start=+3.95");

	state.clickL.reset();

	state.titleScreen.earthTicksCheckpoint = state.ticks.total;

	{
		state.framebuffer.flush();
		state.titleScreen.background.copyMemTo(state.framebuffer.dataAsRGB24);
		state.framebuffer.markDirty();
	}

	{
		auto painter = state.framebuffer.makePainter();

		painter.drawRectangle(ColorRGBA128F(0, 0, 0, 0.75), Size(state.width - 20, 44), Point(10, 10));
		painter.drawText(state.gameTitle, state.assets.fontTextM, 22, ColorRGB24(0xFF, 0xFF, 0xFF), Point(35, 19));

		painter.drawGlyph(Emoji.worm.ptr, state.assets.fontEmoji2, 90, Point(75, 120));
		painter.drawGlyph(Emoji.worm.ptr, state.assets.fontEmoji1, Point(175, 80));
		drawAnimatedEarth(state, painter);

		painter.drawRectangle(ColorRGBA128F(0.30, 0.75, 0.30, 0.75), buttonPlay.size, buttonPlay.upperLeft);
		painter.drawRectangle(ColorRGBA128F(1.00, 1.00, 1.00, 0.75), buttonFull.size, buttonFull.upperLeft);
		painter.drawRectangle(ColorRGBA128F(1.00, 1.00, 1.00, 0.75), buttonMute.size, buttonMute.upperLeft);
		version (none) {
			painter.drawRectangle(ColorRGBA128F(1.00, 1.00, 1.00, 0.75), buttonQuit.size, buttonQuit.upperLeft);
		}

		enum labelPlayPos = buttonPlay.upperLeft + Point(5, 0);
		enum labelFullPos = buttonFull.upperLeft + Point(5, 0);
		enum labelMutePos = buttonMute.upperLeft + Point(5, 0);
		version (none) {
			enum labelQuitPos = buttonQuit.upperLeft + Point(5, 0);
		}
		static immutable labelPlay = "Play";
		static immutable labelFull = "Fullscreen";
		static immutable labelMute = "Mute";
		version (none) {
			static immutable labelQuit = "Quit";
		}
		painter.drawText(labelPlay, state.assets.fontTextM, 40, ColorRGB24(0x00, 0x00, 0x00), labelPlayPos);
		painter.drawText(labelFull, state.assets.fontTextM, 40, ColorRGB24(0x00, 0x00, 0x00), labelFullPos);
		painter.drawText(labelMute, state.assets.fontTextM, 40, ColorRGB24(0x00, 0x00, 0x00), labelMutePos);

		version (none) {
			painter.drawText(labelQuit, state.assets.fontTextM, 40, ColorRGB24(0x00, 0x00, 0x00), labelQuitPos);
		}

		painter.free();
	}
}

void onDraw(ref GameState state) {
	const delta = state.ticks.total - state.titleScreen.earthTicksCheckpoint;
	if (delta < 313) {
		return;
	}

	state.titleScreen.earthTicksCheckpoint = state.ticks.total;
	auto painter = state.framebuffer.makePainter();
	drawAnimatedEarth(state, painter);
	painter.free();
}

void onInput(ref GameState state, MouseClick input) {
	import game.screens.intro : introScreen;

	if (input.button != MouseButton.left) {
		return;
	}

	if (!state.clickL.track(input.pos, input.action)) {
		return;
	}

	if (buttonPlay.contains(input.pos)) {
		state.nextScreen = &introScreen;
	}
	else if (buttonFull.contains(input.pos)) {
		state.fullscreen = !state.fullscreen;
	}
	else if (buttonMute.contains(input.pos)) {
		state.audio.muted = !state.audio.muted;
	}
	// dfmt off
	else version (none) if (buttonQuit.contains(input.pos)) {
		state.running = false;
	}
	// dfmt on
}

void drawAnimatedEarth(ref GameState state, ref Painter painter) {
	pragma(inline, true);
	immutable pos = Point(120, 170);
	game.screens.common.drawAnimatedEarth(state, painter, state.titleScreen.earth, pos, false);
}
