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
import game.screens.common;
import game.state;

static immutable puzzleScreen = InteractiveScreen(
	&onActivate,
	&onDraw,
	&onInput,
);

enum defaultSpeed = 200;

private:

void onActivate(ref GameState state) {
	state.puzzleScreen.ticksCheckpoint = state.ticks.total;
	state.puzzleScreen.circleTicksCheckpoint = state.ticks.total;
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

		if (state.puzzleScreen.g.gameCompleteMain && !state.puzzleScreen.gameCompleteMainHandled) {
			import game.screens.intro;

			state.puzzleScreen.gameCompleteMainHandled = true;
			state.nextScreen = &introScreen;
			return false;
		}

		if (state.puzzleScreen.g.gameCompleteBoss) {
			import game.screens.intro;

			state.nextScreen = &introScreen;
			return false;
		}

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
		return (r == Region.boss)
			? state.assets.audioPuzzle2URL.ptr : state.assets.audioPuzzle1URL.ptr;
	}

	auto audioNext = associatedAudio(state.puzzleScreen.g.currentRegion);
	auto audioPrev = associatedAudio(state.puzzleScreen.previousAudioRegion);

	if (force || (audioPrev != audioNext)) {
		state.puzzleScreen.previousAudioRegion = state.puzzleScreen.g.currentRegion;
		state.audio.play(audioNext);
	}
}

void drawBackground(ref GameState state) {
	const region = state.puzzleScreen.g.currentRegion;

	switch (region) with (Region) {
	case dirt:
		state.framebufferPainter.clear(colorDirt);
		break;

	case gras:
		state.framebufferPainter.clear(colorGras);
		break;

	case snow:
		state.framebufferPainter.clear(colorSnow);
		break;

	case volc:
		state.framebufferPainter.clear(colorVolc);
		break;

	case boss:
		state.framebufferPainter.clear(colorBoss);
		break;

	default:
		crashf("Region %d\n", region);
	}
}

void drawAll(ref GameState state) {
	drawBackground(state);
	drawHUD(state);
	drawGameFrame(state);

	if (state.puzzleScreen.g.level == guideLevel) {
		drawGuide(state);
	}
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
enum colorBoss = ColorRGB24(0x11, 0x11, 0x1A);

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

void drawHUD(ref GameState state) {
	state.framebufferPainter.drawRectangle(colorHUDBackground, sizeHUD, Point(0, 0));

	const Message message = state.puzzleScreen.g.messenger.receive();
	if (message.content !is null) {
		state.framebufferPainter.drawText(message.content, state.assets.fontTextM, 14, message.associatedColor, Point(10, 5));
	}
	else {
		state.framebufferPainter.drawText(
			state.puzzleScreen.g.currentLevelName,
			state.assets.fontTextM,
			14,
			colorHUDText,
			Point(10, 5)
		);
	}

	state.framebufferPainter.drawText("Speed", state.assets.fontTextR, 14, colorHUDText, Point(532, 5));
	state.framebufferPainter.drawRectangle(colorHUDButton2, buttonSpeedInc.size, buttonSpeedInc.upperLeft);
	state.framebufferPainter.drawRectangle(colorHUDButton1, buttonSpeedDec.size, buttonSpeedDec.upperLeft);
	state.framebufferPainter.drawText("+", state.assets.fontTextR, 18, colorHUDText, buttonSpeedInc.upperLeft + Point(9, 3));
	state.framebufferPainter.drawText("-", state.assets.fontTextR, 18, colorHUDText, buttonSpeedDec.upperLeft + Point(13, 3));
}

void drawGuide(ref GameState state) {
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
	state.framebufferPainter.drawText(text, state.assets.fontTextR, 16, colorGuideText, Point(350, 100));
}

void drawGridCell(ref GameState state, Point gridPos, Entity entity) {
	Point pos = (gridPos * gridCell) + offset;

	void drawImpl(string glyph) {
		state.framebufferPainter.drawGlyph(glyph.ptr, state.assets.fontEmoji2, pos);
	}

	switch (entity) {
	case Entity.air:
	case Entity.turtle:
	case Entity.partner:
		break;

	case Entity.rock:
		if (state.puzzleScreen.g.currentRegion == Region.snow) {
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

	case Entity.apple:
		pos.x += 3;
		if (state.puzzleScreen.g.currentRegion == Region.volc) {
			drawImpl(Emoji.greenApple);
		}
		else {
			drawImpl(Emoji.redApple);
		}
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

	case Entity.finish:
		drawImpl(Emoji.cyclone);

		enum flagSize = gridCell.y * 2 / 3;
		state.assets.fontEmoji2.pixelSizes = flagSize;

		if (state.puzzleScreen.g.finishIsUnlocked) {
			pos = pos + Point(13, -2);
			drawImpl(Emoji.chequeredFlag);
		}
		else {
			pos = pos + Point(13, -2);
			drawImpl(Emoji.lock);
		}

		state.assets.fontEmoji2.pixelSizes = gridCell.y;
		break;

	case Entity.toothbrushMoustacheMan:
		drawToothbrushMustacheMan(state, gridCell.y, pos);
		break;

	default:
		crashf("Bad entity %d\n", entity);
	}
}

void drawPartner(ref GameState state) {
	const gridPosPartner = state.puzzleScreen.g.partner.pos;
	const canvPosPartner = (gridPosPartner * gridCell) + offset;

	enum boxHalf = (gridCell >> 1);
	const canvPosCircle = canvPosPartner + boxHalf;
	enum diamtr = (gridCell.x + (gridCell.x >> 1));
	enum radius = (diamtr >> 1);
	enum step = 0x10;

	const deltaCircleTicks = state.ticks.total - state.puzzleScreen.circleTicksCheckpoint;
	if (deltaCircleTicks >= 16) {
		state.puzzleScreen.circleTicksCheckpoint = state.ticks.total;

		if (state.puzzleScreen.circleIntensityUp) {
			state.puzzleScreen.circleIntensity += step;
			if (state.puzzleScreen.circleIntensity >= 0x50) {
				state.puzzleScreen.circleIntensityUp = false;
			}
		}
		else {
			state.puzzleScreen.circleIntensity -= step;
			enum threshold = (step + 1);
			if (state.puzzleScreen.circleIntensity <= threshold) {
				state.puzzleScreen.circleIntensityUp = true;
			}
		}
	}

	const intensity = state.puzzleScreen.circleIntensity / 255.0f;
	const circleColor = ColorRGBA128F(1, 1, 1, intensity);
	state.framebufferPainter.drawCircle(circleColor, radius, canvPosCircle);

	state.framebufferPainter.drawGlyph(Emoji.worm.ptr, state.assets.fontEmoji2, canvPosPartner);
}

void drawTurtles(ref GameState state) {
	enum turtleOffset = offset + Point(0, 5);
	foreach (gridPosTurtle; state.puzzleScreen.g.world.turtles) {
		const canvPosTurtle = (gridPosTurtle * gridCell) + turtleOffset;
		state.framebufferPainter.drawGlyph(Emoji.turtle.ptr, state.assets.fontEmoji2, canvPosTurtle);
	}
}

void drawPin(ref GameState state) {
	const gridPosPin = state.puzzleScreen.g.partner.wormTo;
	if (state.puzzleScreen.g.partner.wormTo.x >= 0) {
		enum offsetPin = offset + Point(7, -10);
		const canvPosPin = (gridPosPin * gridCell) + offsetPin;
		state.framebufferPainter.drawGlyph(Emoji.roundPushpin.ptr, state.assets.fontEmoji2, canvPosPin);
	}
}

void drawGameFrame(ref GameState state) {
	state.assets.fontEmoji2.pixelSizes = gridCell.y;

	int y = 0;
	foreach (row; chunks(state.puzzleScreen.g.world.field, grid.width)) {
		int x = 0;
		foreach (entity; row) {
			drawGridCell(state, Point(x, y), entity);
			++x;
		}
		++y;
	}

	drawTurtles(state);
	drawPartner(state);
	drawPin(state);
}
