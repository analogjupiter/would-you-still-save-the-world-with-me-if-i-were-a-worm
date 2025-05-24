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

void drawToothbrushMustacheMan(ref GameState state, ref Painter painter, int size, Point pos) {
	painter.drawGlyph(Emoji.poutingFace.ptr, state.assets.fontEmoji2, size, pos);

	const mustacheSize = Size(
		(size >> 3) + (size >> 6),
		(size >> 3) - (size >> 5),
	);

	const posMustache = pos + Point(
		(size >> 1) - (mustacheSize.width >> 1),
		(size >> 1) + ((size * 5) >> 5),
	);

	painter.drawRectangle(ColorRGB24(0x29, 0x2F, 0x33), mustacheSize, posMustache);
}
