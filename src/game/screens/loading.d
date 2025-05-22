module game.screens.loading;

import game.cairo;
import game.geometry;
import game.interactive;
import game.loader;
import game.screens.common;
import game.state;

static immutable loadingScreen = InteractiveScreen(
	&onActivate,
	&onDraw,
	null,
);

private:

void onActivate(ref GameState state) {
	clearRandom(state.framebuffer);
	drawL(state.framebuffer);
}

void onDraw(ref GameState state) {
	if (loaderIsDone()) {
		import game.screens.title : titleScreen;

		state.nextScreen = &titleScreen;
	}
}

void drawL(Pixmap framebuffer) {
	pragma(inline, true);
	enum fg = ColorRGB24(0xFF, 0x00, 0x99);

	foreach (x; 10 .. 15) {
		foreach (y; 300 .. 345) {
			framebuffer.setPixel(Point(x, y), fg);
		}
	}

	foreach (x; 10 .. 40) {
		foreach (y; 345 .. 350) {
			framebuffer.setPixel(Point(x, y), fg);
		}
	}
}
