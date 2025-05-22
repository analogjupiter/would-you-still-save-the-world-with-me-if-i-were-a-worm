module game.screens.intro;

import game.cairo;
import game.crash;
import game.emoji;
import game.geometry;
import game.glyph;
import game.interactive;
import game.pango;
import game.state;

static immutable introScreen = InteractiveScreen(
	&onActivate,
	&onDraw,
	&onInput,
);

private:

static immutable buttonSkip = Rectangle(Point(0, 330), Size(120, 30));
static immutable buttonPrev = Rectangle(Point(buttonSkip.left + buttonSkip.width, 330), Size(220, 30));
static immutable buttonNext = Rectangle(Point(buttonPrev.left + buttonPrev.width, 330), Size(300, 30));
static immutable buttonTextColor = ColorRGB24(0x00, 0x00, 0x00);

static immutable pagePos = Point(20, 20);
static immutable textPos = Point(20, 40);
static immutable pageColor = ColorRGB24(0x99, 0x99, 0x99);
static immutable textColor = ColorRGB24(0xFF, 0xFF, 0xFF);

void onActivate(ref GameState state) {
	state.audio.play(state.assets.audioIntroURL.ptr);

	state.clickL.reset();
	state.introScreen.pressedSkipOnce = false;
	state.introScreen.slide = 0;
	state.introScreen.earth = 0;
	state.introScreen.earthTicksCheckpoint = state.ticks.total;
	drawSlide(state);
}

void onDraw(ref GameState state) {
	const delta = state.ticks.total - state.introScreen.earthTicksCheckpoint;
	if (delta < 1000) {
		return;
	}

	state.introScreen.earthTicksCheckpoint = state.ticks.total;

	if (state.introScreen.slide < 9) {
		return;
	}

	auto painter = state.framebuffer.makePainter();
	drawAnimatedEarth(state, painter, false);
	painter.free();
}

void onInput(ref GameState state, MouseClick input) {
	if (input.button != MouseButton.left) {
		return;
	}

	if (!state.clickL.track(input.pos, input.action)) {
		return;
	}

	if (buttonSkip.contains(input.pos)) {
		if (!state.introScreen.pressedSkipOnce) {
			state.introScreen.pressedSkipOnce = true;
			drawSlide(state);
		}
		else {
			skipIntro(state);
		}
	}
	else {
		if (state.introScreen.pressedSkipOnce) {
			state.introScreen.pressedSkipOnce = false;
			drawSlide(state);
		}

		if (buttonPrev.contains(input.pos)) {
			if (state.introScreen.slide == 0) {
				return;
			}

			--state.introScreen.slide;
			drawSlide(state);
		}
		else if (buttonNext.contains(input.pos)) {
			if (state.introScreen.slide == finalSlide) {
				skipIntro(state);
				return;
			}

			++state.introScreen.slide;
			drawSlide(state);
		}
	}
}

void skipIntro(ref GameState state) {
	pragma(inline, true);
	import game.screens.puzzle;

	state.nextScreen = &puzzleScreen;
}

void drawSlide(ref GameState state) {
	auto painter = state.framebuffer.makePainter();
	painter.clear(ColorRGB24(0x21, 0x21, 0x32));

	version (none) {
		painter.drawRectangle(ColorRGB24(0xFF, 0x00, 0x99), Size(20, 360), Point(620, 0));
	}

	enum switchCase(int slideIdx) =
		`case ` ~ slideIdx.stringof ~ `:`
		~ `drawSlide` ~ slideIdx.stringof ~ `(state, painter);`
		~ `break slideSelection;`;

slideSelection: // @suppress(dscanner.suspicious.unused_label)
	switch (state.introScreen.slide) {
		static foreach (slideIdx; 0 .. totalSlides) {
			mixin(switchCase!slideIdx);
		}

	default:
		crashf("No slide %d\n", state.introScreen.slide);
	}

	const skipText = (state.introScreen.pressedSkipOnce) ? "Are you sure?" : "Skip Intro";
	const skipColr = (state.introScreen.pressedSkipOnce) ? ColorRGB24(0xFF, 0x99, 0x77) : ColorRGB24(0x9A, 0x9B, 0x9C);
	const prevColr = ColorRGB24(0xBC, 0xBE, 0xBF);
	const nextText = (state.introScreen.slide == finalSlide) ? "Play" : "Next";
	const nextColr = (state.introScreen.slide == finalSlide) ? ColorRGB24(0x00, 0xFF, 0x99) : ColorRGB24(0xDD, 0xDE, 0xDF);

	painter.drawRectangle(skipColr, buttonSkip.size, buttonSkip.upperLeft);
	painter.drawRectangle(prevColr, buttonPrev.size, buttonPrev.upperLeft);
	painter.drawRectangle(nextColr, buttonNext.size, buttonNext.upperLeft);

	state.assets.fontTextM.size = 16;
	painter.drawText(skipText, state.assets.fontTextM, buttonTextColor, Point(10, 335));
	if (state.introScreen.slide > 0) {
		painter.drawText("Prev", state.assets.fontTextM, buttonTextColor, Point(130, 335));
	}
	painter.drawText(nextText, state.assets.fontTextM, buttonTextColor, Point(350, 335));
	painter.free();
}

void drawAnimatedEarth(ref GameState state, ref Painter painter, bool keepState) {
	pragma(inline, true);
	static import game.screens.common;

	immutable pos = Point(230, 150);
	game.screens.common.drawAnimatedEarth(state, painter, state.introScreen.earth, pos, keepState);
}

void drawEvildoers(ref GameState state, ref Painter painter, Point pos) {
	const posDotted = Point(pos.x, pos.y + 15);
	const posFriend = Point(pos.x + 125, pos.y);
	painter.drawGlyph(Emoji.orange.ptr, state.assets.fontEmoji1, pos);
	painter.drawGlyph(Emoji.dottedLineFace.ptr, state.assets.fontEmoji1, posDotted);
	painter.drawGlyph(Emoji.manLightSkinTone.ptr, state.assets.fontEmoji1, posFriend);
}

void drawWaves(ref GameState state, ref Painter painter) {
	enum waveSize = 30;
	foreach (n; 0 .. (state.width / waveSize)) {
		enum drownIntoGUI = 4;
		enum xOffset = (state.width % waveSize) / 2;
		const x = xOffset + (n * waveSize);
		enum y = buttonNext.top - waveSize + drownIntoGUI;

		painter.drawGlyph(Emoji.waterwave.ptr, state.assets.fontEmoji2, waveSize, Point(x, y));
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

void drawApparatus(ref GameState state, ref Painter painter, Point pos) {
	const posFax = Point(pos.x, pos.y + 10);
	const posSlut = Point(pos.x + 42, pos.y);
	const posSign = Point(pos.x + 51, pos.y + 105);
	painter.drawGlyph(Emoji.faxMachine.ptr, state.assets.fontEmoji1, posFax);
	painter.drawGlyph(Emoji.slotMachine.ptr, state.assets.fontEmoji1, posSlut);
	painter.drawGlyph(Emoji.radioactiveSign.ptr, state.assets.fontEmoji2, 16, posSign);
}

pragma(inline, true) {

	void drawPageText(int pageIdx)(ref GameState state, ref Painter painter, string text) {
		enum pageNoInt = pageIdx + 1;
		enum pageNo = pageNoInt.stringof;
		static immutable page = "Page " ~ pageNo ~ " of " ~ totalSlides.stringof ~ " — Introduction";

		painter.drawText(page, state.assets.fontTextM, 12, pageColor, pagePos);
		painter.drawText(text, state.assets.fontTextR, 18, textColor, textPos);
	}

	void drawSlide0(ref GameState state, ref Painter painter) {
		enum titleChomped = state.gameTitle[0 .. ($ - 1)];
		static immutable text =
			"Welcome to “" ~ titleChomped ~ "”."
			~ "\n\n"
			~ "\nIt’s a rainy Saturday night. (Or is it Sunday already? Hm… Does it really"
			~ "\nmatter? Well, kinda. It could be a Sunday night then. Still a rainy one"
			~ "\nobviously. But on a Sunday. I suppose you get what I mean.)"
			~ "\n"
			~ "\nSo… You and your partner are sitting on your bed, talking to each"
			~ "\nother, laughing about stories from the past, discussing your plans for"
			~ "\nthe future.";

		painter.drawGlyph(Emoji.cloudWithRain.ptr, state.assets.fontEmoji2, 24, Point(20, 70));
		painter.drawGlyph(Emoji.moon.ptr, state.assets.fontEmoji1, Point(500, 190));
		drawPageText!0(state, painter, text);
	}

	void drawSlide1(ref GameState state, ref Painter painter) {
		static immutable text =
			"\n\n"
			~ "\nThe rain patters gently against windows and windowsills, accompanying"
			~ "\nyour conversation with a calming atmosphere."
			~ "\n"
			~ "\nYou find yourself thinking about adding a fireplace to your home, when"
			~ "\nall of a sudden your cosy daydream is interrupted by an innocent"
			~ "\nquestion."
			~ "\n"
			~ "\n“Would you still love me if I were a worm?” your partner asks.";

		painter.drawGlyph(Emoji.cloudWithRain.ptr, state.assets.fontEmoji2, 24, Point(20, 70));
		painter.drawGlyph(Emoji.worm.ptr, state.assets.fontEmoji2, 24, Point(540, 245));
		painter.drawGlyph(Emoji.moon.ptr, state.assets.fontEmoji1, Point(500, 190));
		drawPageText!1(state, painter, text);
	}

	void drawSlide2(ref GameState state, ref Painter painter) {
		static immutable text =
			"Meanwhile in a different place…"
			~ "\n"
			~ "\nObscured by the darkness of night — and state-of-the-art stealth aircraft"
			~ "\ntechnology — a plane is flying over the Atlantic Ocean. On board are a"
			~ "\nwell-known politician, the Orange, and his immigrant friend who have"
			~ "\njoined forces to put an end to all immigration. Gotta deport ’em all!";

		drawWaves(state, painter);
		painter.drawGlyph(Emoji.airplane.ptr, state.assets.fontEmoji2, 48, Point(90, 200));
		painter.drawGlyph(Emoji.moon.ptr, state.assets.fontEmoji2, 48, Point(170, 180));
		drawEvildoers(state, painter, Point(365, 170));
		drawPageText!2(state, painter, text);
	}

	void drawSlide3(ref GameState state, ref Painter painter) {
		static immutable text =
			"Accompanied by a team of the world’s greatest scientists — all volunteers"
			~ "\nwho did definitely not receive no threats of being sent to Alcatraz — they"
			~ "\nare heading towards Europe; looking forward to resurrect their idol, the"
			~ "\nunsuccessful “Austrian” painter known as Toothbrush-Moustache Man:"
			~ "\nInfamous for his “DEI programs” offering state-sponsored trips to"
			~ "\nimperial “campsites” and a joint-venture special military operation with"
			~ "\n“Il Duce” and the Empire of The Rising Sun."
			~ "\n"
			~ "\nWith the crew being hopeful that they’ll be able to locate"
			~ "\nand pick up a little bit of the remains of their favorite war"
			~ "\ncriminal’s body as needed for the mission, the plane starts"
			~ "\nits final descent.";

		drawWaves(state, painter);
		drawToothbrushMustacheMan(state, painter, 100, Point(520, 185));
		drawPageText!3(state, painter, text);
	}

	void drawSlide4(ref GameState state, ref Painter painter) {
		static immutable text =
			"Disregarding all laws concerning the violation of graves, the Orange and"
			~ "\nhis Team go on a torch-lit walk to retrieve the ashes of"
			~ "\nToothbrush-Moustache Man. A few hours later they finally hit pay dirt."
			~ "\n"
			~ "\nBack at the landing spot, the scientists begin to set up a bizarre apparatus."
			~ "\nPowered by a fusion reactor a particle accelerator will speed up the"
			~ "\nashes to a negative multiple speed of light. According to their calculations"
			~ "\nthis procedure would reverse the aging process. The rejuvenated"
			~ "\nmatter is then fed into a fusion-reactor gene-gun combo"
			~ "\nthat joines the particles to form a human body.";

		drawApparatus(state, painter, Point(450, 200));
		drawPageText!4(state, painter, text);
	}

	void drawSlide5(ref GameState state, ref Painter painter) {
		static immutable text =
			"The team mounts fills the collected remains into an ash tray and mounts it"
			~ "\non the machinery. After a routine check, the apparatus gets finally turned"
			~ "\non. LEDs start blinking, unpleasantly loud noises are generated. “It is"
			~ "\nworking,” the scientists are relieved."
			~ "\n"
			~ "\nAfter hours of waiting, results are coming in: Everything looks good so far."
			~ "\nThe Orange and his friend are happy about their achievement.";

		drawEvildoers(state, painter, Point(20, 190));
		drawApparatus(state, painter, Point(450, 200));
		drawPageText!5(state, painter, text);
	}

	void drawSlide6(ref GameState state, ref Painter painter) {
		static immutable text =
			"All of a sudden, the bizarre appartus goes up in smoke."
			~ "\nThe particle accelerator implodes."
			~ "\nThe whole situation gets out of control."
			~ "\nPanic sets in.";

		//drawApparatus(state, painter, Point(200, 160));
		drawApparatus(state, painter, Point(220, 180));
		painter.drawGlyph(Emoji.fire.ptr, state.assets.fontEmoji2, 84, Point(210, 170));
		painter.drawGlyph(Emoji.fire.ptr, state.assets.fontEmoji2, 84, Point(320, 140));
		painter.drawGlyph(Emoji.fire.ptr, state.assets.fontEmoji1, Point(245, 160));
		painter.drawGlyph(Emoji.dashSymbol.ptr, state.assets.fontEmoji1, Point(400, 190));
		painter.drawGlyph(Emoji.shakingFace.ptr, state.assets.fontEmoji1, Point(25, 190));
		drawPageText!6(state, painter, text);
	}

	void drawSlide7(ref GameState state, ref Painter painter) {
		static immutable text =
			"When smoke and dust finally settle, the team gets a chance to look at"
			~ "\nthe wreckage that used to be their machine. A good chunk of the"
			~ "\ncomponents seems to have disappeared."
			~ "\n"
			~ "\nInstead of leaving behind a void, a wormhole has opened up. It has has"
			~ "\nalready absorbed large parts of the apparatus. And it proceeds to absorb"
			~ "\nwhatever comes near it. “That is…?” — “Eventually the whole planet!”";

		painter.drawGlyph(Emoji.hole.ptr, state.assets.fontEmoji1, Point(230, 190));
		painter.drawGlyph(Emoji.hole.ptr, state.assets.fontEmoji2, 84, Point(259, 258));
		painter.drawGlyph(Emoji.dashSymbol.ptr, state.assets.fontEmoji1, Point(400, 190));
		painter.drawGlyph(Emoji.shakingFace.ptr, state.assets.fontEmoji1, Point(25, 190));
		drawPageText!7(state, painter, text);
	}

	void drawSlide8(ref GameState state, ref Painter painter) {
		static immutable text =
			"During its travel through the wormhole, Earth is shaken and deformed."
			~ "\nIts oceans are stirred up, volcanos turn inside out.";

		drawToothbrushMustacheMan(state, painter, 20, Point(335, 160));
		painter.drawGlyph(Emoji.hole.ptr, state.assets.fontEmoji1, Point(230, 190));
		painter.drawGlyph(Emoji.hole.ptr, state.assets.fontEmoji2, 84, Point(259, 258));
		painter.drawGlyph(Emoji.earthGlobeAmerics.ptr, state.assets.fontEmoji1, Point(230, 150));
		painter.drawGlyph(Emoji.shakingFace.ptr, state.assets.fontEmoji1, Point(400, 190));
		painter.drawGlyph(Emoji.waterwave.ptr, state.assets.fontEmoji2, 10, Point(240, 200));
		painter.drawGlyph(Emoji.waterwave.ptr, state.assets.fontEmoji2, 12, Point(260, 235));
		painter.drawGlyph(Emoji.waterwave.ptr, state.assets.fontEmoji2, 7, Point(280, 255));
		painter.drawGlyph(Emoji.waterwave.ptr, state.assets.fontEmoji2, 10, Point(300, 180));
		painter.drawGlyph(Emoji.waterwave.ptr, state.assets.fontEmoji2, 9, Point(330, 210));
		painter.drawGlyph(Emoji.collisionSymbol.ptr, state.assets.fontEmoji2, 20, Point(260, 200));
		painter.drawGlyph(Emoji.collisionSymbol.ptr, state.assets.fontEmoji2, 20, Point(250, 155));
		painter.drawGlyph(Emoji.collisionSymbol.ptr, state.assets.fontEmoji2, 20, Point(315, 215));
		painter.drawGlyph(Emoji.collisionSymbol.ptr, state.assets.fontEmoji2, 20, Point(300, 245));
		drawPageText!8(state, painter, text);
	}

	void drawSlide9(ref GameState state, ref Painter painter) {
		static immutable text =
			"After a while Earth reaches its new location in a galaxy far, far away…"
			~ "\n"
			~ "\nYou catch a glimpse of your surroundings. Unfortunately, there’s no Luke"
			~ "\nSkywalker, Leia Organa, Padmé Amidala, Darth Vader or dichotomy in"
			~ "\nsight. — However it looks like your partner has turned into, well, a worm!";

		painter.drawGlyph(Emoji.worm.ptr, state.assets.fontEmoji1, Point(400, 150));

		drawAnimatedEarth(state, painter, true);
		drawPageText!9(state, painter, text);
	}

	void drawSlide10(ref GameState state, ref Painter painter) {
		static immutable seg1 = "“" ~ state.gameTitle ~ "”";
		static immutable seg2 = " your partner\nasks you once again.";
		static immutable text = seg1 ~ seg2;

		painter.drawGlyph(Emoji.worm.ptr, state.assets.fontEmoji1, Point(400, 150));

		drawAnimatedEarth(state, painter, true);
		drawPageText!10(state, painter, text);
		painter.drawText(seg1, state.assets.fontTextR, 18, ColorRGB24(0x00, 0xFF, 0x66), textPos);
	}

	void drawSlide11(ref GameState state, ref Painter painter) {
		static immutable text = "Are you ready?";

		drawAnimatedEarth(state, painter, true);
		painter.drawGlyph(Emoji.worm.ptr, state.assets.fontEmoji1, Point(400, 150));
		drawPageText!11(state, painter, "");
		painter.drawText(text, state.assets.fontTextR, 72, ColorRGB24(0x00, 0xFF, 0x66), textPos);
	}
}

enum finalSlide = 11;
enum totalSlides = finalSlide + 1;
