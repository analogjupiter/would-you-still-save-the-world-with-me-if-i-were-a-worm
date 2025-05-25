module game.screens.gg;

import game.cairo;
import game.emoji;
import game.geometry;
import game.glyph;
import game.interactive;
import game.memory;
import game.pango;
import game.state;

static immutable ggScreen = InteractiveScreen(
	&onActivate,
	null,
	null,
);

private:

void onActivate(ref GameState state) {
	state.clickL.reset();
	state.audio.play(state.assets.audioMenuURL.ptr);

	{
		state.framebuffer.flush();
		state.titleScreen.background.copyMemTo(state.framebuffer.dataAsRGB24);
		state.framebuffer.markDirty();
	}

	auto painter = state.framebuffer.makePainter();

	painter.drawRectangle(ColorRGBA128F(0, 0, 0, 0.75), Size(state.width, 200), Point(0, 0));
	painter.drawRectangle(ColorRGBA128F(1, 1, 1, 0.75), Size(state.width, 50), Point(0, 200));

	painter.drawGlyph(Emoji.partyPopper.ptr, state.assets.fontEmoji1, Point(20, 210));

	painter.drawText(
		"Yes!",
		state.assets.fontTextM,
		64,
		ColorRGB24(0x00, 0xFF, 0x66),
		Point(20, 20),
	);

	painter.drawText(
		"I would you still save the world with you\nif you were a worm.",
		state.assets.fontTextM,
		32,
		ColorRGB24(0x00, 0xFF, 0x66),
		Point(20, 100),
	);

	painter.drawText(
		"Thanks for playing!",
		state.assets.fontTextM,
		32,
		ColorRGB24(0xFF, 0x00, 0x66),
		Point(335, 205),
	);

	painter.free();
}
