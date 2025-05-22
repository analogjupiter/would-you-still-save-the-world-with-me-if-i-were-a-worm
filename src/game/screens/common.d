module game.screens.common;

import game.cairo;
import game.emoji;
import game.geometry;
import game.glyph;
import game.state;

void clearRandom(Pixmap pixmap) {
	pixmap.flush();
	clearRandom(pixmap.dataAsRGB24);
	pixmap.markDirty();
}

void clearRandom(ColorRGB24[] data) {
	import core.stdc.stdlib : rand;

	foreach (ref px; data) {
		const colorBase = (rand() % 0xDD);
		const color = ColorRGB24(
			(colorBase + 0x00) & 0xFF,
			(colorBase + 0x11) & 0xFF,
			(colorBase + 0x22) & 0xFF,
		);
		px = color;
	}
}

void drawAnimatedEarth(ref GameState state, ref Painter painter, ref int animationFrame, Point pos, bool keepState) {
	if (animationFrame == 0) {
		painter.drawGlyph(Emoji.earthGlobeEuropeAfrica.ptr, state.assets.fontEmoji1, pos);
	}
	else if (animationFrame == 1) {
		painter.drawGlyph(Emoji.earthGlobeAsiaAustralia.ptr, state.assets.fontEmoji1, pos);
	}
	else if (animationFrame == 2) {
		painter.drawGlyph(Emoji.earthGlobeAmerics.ptr, state.assets.fontEmoji1, pos);
	}

	if (keepState) {
		return;
	}

	++animationFrame;
	if (animationFrame == 3) {
		animationFrame = 0;
	}
}
