module game.screens.puzzle;

import game.cairo;
import game.crash;
import game.emoji;
import game.geometry;
import game.glyph;
import game.interactive;
import game.memory;
import game.pango;
import game.puzzle.avicii;
import game.puzzle.data;
import game.puzzle.messenger;
import game.state;

static immutable puzzleScreen = InteractiveScreen(
	&onActivate,
	&onDraw,
	&onInput,
);

private:

enum defaultSpeed = 200;

void onActivate(ref GameState state) {
	state.puzzleScreen.speed = defaultSpeed;
	state.puzzleScreen.ticksCheckpoint = state.ticks.total;
	state.clickL.reset();
	handleAudio(state, true);
	state.puzzleScreen.g.messenger.tick(state.ticks.total);
	drawAll(state);
}

void onDraw(ref GameState state) {
	bool shouldDraw() {
		bool shouldDraw = false;
		const messageCleared = state.puzzleScreen.g.messenger.tick(state.ticks.total);
		if (messageCleared) {
			shouldDraw = true;
		}

		const deltaTicks = state.ticks.total - state.puzzleScreen.ticksCheckpoint;
		if (deltaTicks < state.puzzleScreen.speed) {
			return shouldDraw;
		}

		state.puzzleScreen.ticksCheckpoint = state.ticks.total;
		state.puzzleScreen.g.tick();
		handleAudio(state, false);
		return true;

	}

	if (shouldDraw()) {
		drawAll(state);
	}
}

void onInput(ref GameState state, MouseClick input) {
	if (input.button == MouseButton.right) {
		if (state.puzzleScreen.g.partner.wormTo.x >= 0) {
			state.puzzleScreen.g.partner.wormTo.x = -1;
			state.puzzleScreen.g.messenger.send("Movement cancled.", MessageType.regular, 1000);
		}
		return;
	}

	if (input.button != MouseButton.left) {
		return;
	}

	const clicked = state.clickL.track(input.pos, input.action);
	if (!clicked) {
		return;
	}

	if (buttonSpeedInc.contains(input.pos)) {
		if (state.puzzleScreen.speed > 50) {
			state.puzzleScreen.speed -= 50;
		}

		sendSpeedAsMessage(state);
		return;
	}

	if (buttonSpeedDec.contains(input.pos)) {
		if (state.puzzleScreen.speed < 1000) {
			state.puzzleScreen.speed += 50;
		}

		sendSpeedAsMessage(state);
		return;
	}

	const gridPos = input.pos.clickPosToGridPos();
	if (gridPos.isOffGrid) {
		return;
	}

	state.puzzleScreen.g.partner.wormTo = gridPos;
	drawAll(state);
}

void handleAudio(ref GameState state, bool force) {
	auto associatedAudio(Region r) {
		return (r == Region.snow)
			? state.assets.audioPuzzle2URL.ptr : state.assets.audioPuzzle1URL.ptr;
	}

	auto audioNext = associatedAudio(state.puzzleScreen.g.currentRegion);
	auto audioPrev = associatedAudio(state.puzzleScreen.previousAudioRegion);

	if (force || (audioPrev != audioNext)) {
		state.puzzleScreen.previousAudioRegion = state.puzzleScreen.g.currentRegion;
		state.audio.play(audioNext);
	}
}

void drawBackground(ref GameState state, ref Painter painter) {
	const region = state.puzzleScreen.g.currentRegion;

	switch (region) with (Region) {
	case dirt:
		painter.clear(colorDirt);
		break;

	case gras:
		painter.clear(colorGras);
		break;

	case snow:
		painter.clear(colorSnow);
		break;

	case volc:
		painter.clear(colorVolc);
		break;

	default:
		crashf("Region %d\n", region);
	}
}

void drawAll(ref GameState state) {
	auto painter = state.framebuffer.makePainter();

	drawBackground(state, painter);
	drawHUD(state, painter);
	drawGameFrame(state, painter);

	if (state.puzzleScreen.g.level == guideLevel) {
		drawGuide(state, painter);
	}

	painter.free();
}

void sendSpeedAsMessage(ref GameState state) {
	import core.stdc.stdio : snprintf;

	const playerComprehensibleSpeed = (float(defaultSpeed) / state.puzzleScreen.speed);
	const msgLength = snprintf(
		state.puzzleScreen.speedMessage.ptr,
		state.puzzleScreen.speedMessage.length,
		"Speed: %.3f",
		playerComprehensibleSpeed,
	);

	if (msgLength > 0) {
		state.puzzleScreen.g.messenger.send(
			state.puzzleScreen.speedMessage[0 .. msgLength],
			MessageType.regular,
			1000
		);
	}
}

enum gridCell = Point(30, 30);
enum sizeHUD = Size(GameState.width, gridCell.y);
enum offset = Point(
		(GameState.width - (grid.width * gridCell.x)) >> 1,
		sizeHUD.height,
	);

enum colorDirt = ColorRGB24(0xCC, 0xAA, 0x66);
enum colorGras = ColorRGB24(0xAA, 0xCC, 0x66);
enum colorSnow = ColorRGB24(0xCC, 0xFF, 0xFF);
enum colorVolc = ColorRGB24(0xFF, 0xCC, 0xCC);

enum colorMessageAlert = ColorRGB24(0xFF, 0x22, 0x22);
enum colorMessageSuccess = ColorRGB24(0x00, 0xFF, 0x66);

enum colorGuideText = ColorRGB24(0x00, 0x00, 0x00);

enum colorHUDText = ColorRGB24(0xFF, 0xFF, 0xFF);
enum colorHUDBackground = ColorRGB24(0x00, 0x00, 0x00);
enum colorHUDButton1 = ColorRGB24(0x66, 0x66, 0x66);
enum colorHUDButton2 = ColorRGB24(0x44, 0x44, 0x44);

enum speedButtonSize = Size(sizeHUD.height, sizeHUD.height);
enum Rectangle buttonSpeedInc = Rectangle(Point(640 - (speedButtonSize.width << 1), 0), speedButtonSize);
enum Rectangle buttonSpeedDec = Rectangle(Point(640 - (speedButtonSize.width << 0), 0), speedButtonSize);

Point clickPosToGridPos(const Point clickPos) {
	int y = clickPos.y - offset.y;
	y = (y < 0) ? -1 : (y / gridCell.y);

	int x;
	if (clickPos.x < 0) {
		x = -1;
	}
	else {
		x = clickPos.x - offset.x;
		x = (x < 0) ? 0 : x / gridCell.x;
	}

	return Point(x, y);
}

bool isOffGrid(const Point gridPos) {
	return (gridPos.x < 0)
		|| (gridPos.x >= grid.width)
		|| (gridPos.y < 0)
		|| (gridPos.y >= grid.height);
}

ColorRGB24 associatedColor(const Message msg) {
	switch (msg.type) with (MessageType) {
	case alert:
		return colorMessageAlert;
	case success:
		return colorMessageSuccess;
	default:
		return colorHUDText;
	}
}

void drawHUD(ref GameState state, ref Painter painter) {
	painter.drawRectangle(colorHUDBackground, sizeHUD, Point(0, 0));

	const Message message = state.puzzleScreen.g.messenger.receive();
	if (message.content !is null) {
		painter.drawText(message.content, state.assets.fontTextM, 14, message.associatedColor, Point(10, 5));
	}
	else {
		painter.drawText(state.puzzleScreen.g.currentLevelName, state.assets.fontTextM, 14, colorHUDText, Point(10, 5));
	}

	painter.drawText("Speed", state.assets.fontTextR, 14, colorHUDText, Point(532, 5));
	painter.drawRectangle(colorHUDButton2, buttonSpeedInc.size, buttonSpeedInc.upperLeft);
	painter.drawRectangle(colorHUDButton1, buttonSpeedDec.size, buttonSpeedDec.upperLeft);
	painter.drawText("+", state.assets.fontTextR, 18, colorHUDText, buttonSpeedInc.upperLeft + Point(9, 3));
	painter.drawText("-", state.assets.fontTextR, 18, colorHUDText, buttonSpeedDec.upperLeft + Point(13, 3));
}

void drawGuide(ref GameState state, ref Painter painter) {
	static immutable text = "Instructions:"
		~ "\nGuide your partner through the course."
		~ "\n"
		~ "\nLEFT CLICK to place a marker. Your"
		~ "\npartner will try to walk in its"
		~ "\ndirection."
		~ "\n"
		~ "\nRIGHT CLICK to unset the marker and"
		~ "\nstop your partners movement."
		~ "\n"
		~ "\nPress [F] to toggle fullscreen."
		~ "\nPress [M] to mute/unmute audio.";
	painter.drawText(text, state.assets.fontTextR, 16, colorGuideText, Point(350, 100));
}

void drawGridCell(ref GameState state, ref Painter painter, Point gridPos, Entity entity) {
	Point pos = (gridPos * gridCell) + offset;

	void drawImpl(string glyph) {
		painter.drawGlyph(glyph.ptr, state.assets.fontEmoji2, pos);
	}

	switch (entity) {
	case Entity.air:
	case Entity.partner:
		break;
	case Entity.rock:
		const region = state.puzzleScreen.g.currentRegion;
		if (region == Region.snow) {
			drawImpl(Emoji.iceCube);
		}
		else {
			drawImpl(Emoji.rock);
		}
		break;
	case Entity.hole:
		pos.y += 10;
		drawImpl(Emoji.hole);
		break;
	case Entity.wormhole1:
	case Entity.wormhole2:
	case Entity.wormhole3:
	case Entity.wormhole4:
	case Entity.wormhole5:
	case Entity.wormhole6:
	case Entity.wormhole7:
	case Entity.wormhole8:
	case Entity.wormhole9:
	case Entity.wormholeA:
	case Entity.wormholeB:
	case Entity.wormholeC:
	case Entity.wormholeD:
	case Entity.wormholeE:
	case Entity.wormholeF:
		drawImpl(Emoji.cyclone);
		break;
	case Entity.herb:
		drawImpl(Emoji.herb);
		break;
	case Entity.seedling:
		drawImpl(Emoji.seedling);
		break;
	case Entity.bean:
		drawImpl(Emoji.beans);
		break;

	case Entity.finish:
		drawImpl(Emoji.cyclone);

		enum flagSize = gridCell.y * 2 / 3;
		state.assets.fontEmoji2.pixelSizes = flagSize;
		pos = pos + Point(13, -2);
		drawImpl(Emoji.chequeredFlag);
		state.assets.fontEmoji2.pixelSizes = gridCell.y;
		break;

	default:
		crashf("Bad entity %d\n", entity);
	}
}

void drawPartner(ref GameState state, ref Painter painter) {
	const gridPosPartner = state.puzzleScreen.g.partner.pos;
	const canvPosPartner = (gridPosPartner * gridCell) + offset;
	painter.drawGlyph(Emoji.worm.ptr, state.assets.fontEmoji2, canvPosPartner);
}

void drawPin(ref GameState state, ref Painter painter) {
	const gridPosPin = state.puzzleScreen.g.partner.wormTo;
	if (state.puzzleScreen.g.partner.wormTo.x >= 0) {
		enum offsetPin = offset + Point(7, -10);
		const canvPosPin = (gridPosPin * gridCell) + offsetPin;
		painter.drawGlyph(Emoji.roundPushpin.ptr, state.assets.fontEmoji2, canvPosPin);
	}
}

void drawGameFrame(ref GameState state, ref Painter painter) {
	state.assets.fontEmoji2.pixelSizes = gridCell.y;

	int y = 0;
	foreach (row; chunks(state.puzzleScreen.g.world.field, grid.width)) {
		int x = 0;
		foreach (entity; row) {
			drawGridCell(state, painter, Point(x, y), entity);
			++x;
		}
		++y;
	}

	drawPartner(state, painter);
	drawPin(state, painter);
}
