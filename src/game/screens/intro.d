module game.screens.intro;

import game.cairo;
import game.crash;
import game.emoji;
import game.geometry;
import game.glyph;
import game.interactive;
import game.pango;
import game.screens.common;
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

	if ((state.introScreen.slide >= animatedEarthSlideFrom) && (state.introScreen.slide <= animatedEarthSlideTo)) {
		drawAnimatedEarth(state, false);
	}
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
			if (state.introScreen.slide <= introFinalSlide) {
				skipIntro(state);
			}
			else if (state.introScreen.slide <= interludeFinalSlide) {
				skipInterlude(state);
			}
			else if (state.introScreen.slide <= endingFinalSlide) {
				skipEnding(state);
			}
		}
	}
	else {
		if (state.introScreen.pressedSkipOnce) {
			state.introScreen.pressedSkipOnce = false;
			drawSlide(state);
		}

		if (buttonPrev.contains(input.pos)) {
			if (state.isAnyFirstSlide) {
				return;
			}

			--state.introScreen.slide;
			drawSlide(state);
		}
		else if (buttonNext.contains(input.pos)) {
			if (state.introScreen.slide == introFinalSlide) {
				skipIntro(state);
				return;
			}

			if (state.introScreen.slide == interludeFinalSlide) {
				skipInterlude(state);
				return;
			}

			if (state.introScreen.slide == endingFinalSlide) {
				skipEnding(state);
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

	state.introScreen.slide = interludeFirstSlide;
	state.nextScreen = &puzzleScreen;
}

void skipInterlude(ref GameState state) {
	pragma(inline, true);
	import game.screens.puzzle;

	state.introScreen.slide = endingFirstSlide;
	state.nextScreen = &puzzleScreen;
}

void skipEnding(ref GameState state) {
	pragma(inline, true);
	import game.screens.gg;

	version (none) {
		state.introScreen.slide = postCreditsFirstSlide;
	}
	state.nextScreen = &ggScreen;
}

bool isAnyFinalSlide(ref GameState state) {
	return (
		(state.introScreen.slide == introFinalSlide)
			|| (state.introScreen.slide == interludeFinalSlide)
			|| (state.introScreen.slide == endingFinalSlide));
}

bool isAnyFinalPrePuzzleSlide(ref GameState state) {
	return (
		(state.introScreen.slide == introFinalSlide)
			|| (state.introScreen.slide == interludeFinalSlide));
}

bool isVeryLastSlide(ref GameState state) {
	return state.introScreen.slide == endingFinalSlide;
}

bool isAnyFirstSlide(ref GameState state) {
	return (
		(state.introScreen.slide == introFirstSlide)
			|| (state.introScreen.slide == interludeFirstSlide)
			|| (state.introScreen.slide == endingFirstSlide));
}

bool isIntro(ref GameState state) {
	return (state.introScreen.slide <= introFinalSlide);
}

void drawSlide(ref GameState state) {
	state.framebufferPainter.clear(ColorRGB24(0x21, 0x21, 0x32));

	version (none) {
		state.framebufferPainter.drawRectangle(ColorRGB24(0xFF, 0x00, 0x99), Size(20, 360), Point(620, 0));
	}

	enum switchCase(int slideIdx) =
		`case ` ~ slideIdx.stringof ~ `:`
		~ `drawSlide` ~ slideIdx.stringof ~ `(state);`
		~ `break slideSelection;`;

slideSelection: // @suppress(dscanner.suspicious.unused_label)
	switch (state.introScreen.slide) {
		static foreach (slideIdx; 0 .. totalSlides) {
			mixin(switchCase!slideIdx);
		}

	default:
		crashf("No slide %d\n", state.introScreen.slide);
	}

	const skipText = (state.introScreen.pressedSkipOnce) ? "Are you sure?" : ((isIntro(state)) ? "Skip Intro" : "Skip");
	const skipColr = (state.introScreen.pressedSkipOnce) ? ColorRGB24(0xFF, 0x99, 0x77) : ColorRGB24(0x9A, 0x9B, 0x9C);
	const prevColr = ColorRGB24(0xBC, 0xBE, 0xBF);
	const nextText = (isVeryLastSlide(state)) ? "Continue" : ((isAnyFinalPrePuzzleSlide(state)) ? "Play" : "Next");
	const nextColr = (isAnyFinalSlide(state)) ? ColorRGB24(0x00, 0xFF, 0x99) : ColorRGB24(0xDD, 0xDE, 0xDF);

	state.framebufferPainter.drawRectangle(skipColr, buttonSkip.size, buttonSkip.upperLeft);
	state.framebufferPainter.drawRectangle(prevColr, buttonPrev.size, buttonPrev.upperLeft);
	state.framebufferPainter.drawRectangle(nextColr, buttonNext.size, buttonNext.upperLeft);

	state.assets.fontTextM.size = 16;
	state.framebufferPainter.drawText(skipText, state.assets.fontTextM, buttonTextColor, Point(10, 335));
	if (!state.isAnyFirstSlide) {
		state.framebufferPainter.drawText("Prev", state.assets.fontTextM, buttonTextColor, Point(130, 335));
	}
	state.framebufferPainter.drawText(nextText, state.assets.fontTextM, buttonTextColor, Point(350, 335));
}

void drawAnimatedEarth(ref GameState state, bool keepState) {
	pragma(inline, true);
	static import game.screens.common;

	immutable pos = Point(230, 150);
	game.screens.common.drawAnimatedEarth(state, state.introScreen.earth, pos, keepState);
}

void drawEvildoers(ref GameState state, Point pos) {
	const posDotted = Point(pos.x, pos.y + 15);
	const posFriend = Point(pos.x + 125, pos.y);
	state.framebufferPainter.drawGlyph(Emoji.orange.ptr, state.assets.fontEmoji1, pos);
	state.framebufferPainter.drawGlyph(Emoji.dottedLineFace.ptr, state.assets.fontEmoji1, posDotted);
	state.framebufferPainter.drawGlyph(Emoji.manLightSkinTone.ptr, state.assets.fontEmoji1, posFriend);
}

void drawWaves(ref GameState state) {
	enum waveSize = 30;
	foreach (n; 0 .. (state.width / waveSize)) {
		enum drownIntoGUI = 4;
		enum xOffset = (state.width % waveSize) / 2;
		const x = xOffset + (n * waveSize);
		enum y = buttonNext.top - waveSize + drownIntoGUI;

		state.framebufferPainter.drawGlyph(Emoji.waterwave.ptr, state.assets.fontEmoji2, waveSize, Point(x, y));
	}
}

void drawApparatus(ref GameState state, Point pos) {
	const posFax = Point(pos.x, pos.y + 10);
	const posSlut = Point(pos.x + 42, pos.y);
	const posSign = Point(pos.x + 51, pos.y + 105);
	state.framebufferPainter.drawGlyph(Emoji.faxMachine.ptr, state.assets.fontEmoji1, posFax);
	state.framebufferPainter.drawGlyph(Emoji.slotMachine.ptr, state.assets.fontEmoji1, posSlut);
	state.framebufferPainter.drawGlyph(Emoji.radioactiveSign.ptr, state.assets.fontEmoji2, 16, posSign);
}

enum Chapter {
	intro,
	interlude,
	ending,
}

pragma(inline, true) {

	void drawPageText(int pageIdx, Chapter chapter)(ref GameState state, string text) {
		static if (chapter == Chapter.intro) {
			enum first = introFirstSlide;
			enum total = introTotalSlides;
			enum name = "Introduction";
		}
		static if (chapter == Chapter.interlude) {
			enum first = interludeFirstSlide;
			enum total = interludeTotalSlides;
			enum name = "Interlude";
		}
		static if (chapter == Chapter.ending) {
			enum first = endingFirstSlide;
			enum total = endingTotalSlides;
			enum name = "Ending";
		}

		enum pageNoInt = pageIdx - first + 1;
		enum pageNo = pageNoInt.stringof;
		static immutable page = "Page " ~ pageNo ~ " of " ~ total.stringof ~ " — " ~ name;

		state.framebufferPainter.drawText(page, state.assets.fontTextM, 12, pageColor, pagePos);
		state.framebufferPainter.drawText(text, state.assets.fontTextR, 18, textColor, textPos);
	}

	void drawSlide0(ref GameState state) {
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

		state.framebufferPainter.drawGlyph(Emoji.cloudWithRain.ptr, state.assets.fontEmoji2, 24, Point(20, 70));
		state.framebufferPainter.drawGlyph(Emoji.moon.ptr, state.assets.fontEmoji1, Point(500, 190));
		drawPageText!(0, Chapter.intro)(state, text);
	}

	void drawSlide1(ref GameState state) {
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

		state.framebufferPainter.drawGlyph(Emoji.cloudWithRain.ptr, state.assets.fontEmoji2, 24, Point(20, 70));
		state.framebufferPainter.drawGlyph(Emoji.worm.ptr, state.assets.fontEmoji2, 24, Point(540, 245));
		state.framebufferPainter.drawGlyph(Emoji.moon.ptr, state.assets.fontEmoji1, Point(500, 190));
		drawPageText!(1, Chapter.intro)(state, text);
	}

	void drawSlide2(ref GameState state) {
		static immutable text =
			"Meanwhile in a different place…"
			~ "\n"
			~ "\nObscured by the darkness of night — and state-of-the-art stealth aircraft"
			~ "\ntechnology — a plane is flying over the Atlantic Ocean. On board are a"
			~ "\nwell-known politician, the Orange, and his immigrant friend who have"
			~ "\njoined forces to put an end to all immigration. Gotta deport ’em all!";

		drawWaves(state);
		state.framebufferPainter.drawGlyph(Emoji.airplane.ptr, state.assets.fontEmoji2, 48, Point(90, 200));
		state.framebufferPainter.drawGlyph(Emoji.moon.ptr, state.assets.fontEmoji2, 48, Point(170, 180));
		drawEvildoers(state, Point(365, 170));
		drawPageText!(2, Chapter.intro)(state, text);
	}

	void drawSlide3(ref GameState state) {
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

		drawWaves(state);
		drawToothbrushMustacheMan(state, 100, Point(520, 185));
		drawPageText!(3, Chapter.intro)(state, text);
	}

	void drawSlide4(ref GameState state) {
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

		drawApparatus(state, Point(450, 200));
		drawPageText!(4, Chapter.intro)(state, text);
	}

	void drawSlide5(ref GameState state) {
		static immutable text =
			"The team fills the collected remains into an ash tray and mounts it on the"
			~ "\nmachinery. After a routine check, the apparatus gets finally turned on."
			~ "\nLEDs start blinking, unpleasantly loud noises are generated. “It is"
			~ "\nworking,” the scientists are relieved."
			~ "\n"
			~ "\nAfter hours of waiting, results are coming in: Everything looks good so far."
			~ "\nThe Orange and his friend are happy about their achievement.";

		drawEvildoers(state, Point(20, 190));
		drawApparatus(state, Point(450, 200));
		drawPageText!(5, Chapter.intro)(state, text);
	}

	void drawSlide6(ref GameState state) {
		static immutable text =
			"All of a sudden, the bizarre appartus goes up in smoke."
			~ "\nThe particle accelerator implodes."
			~ "\nThe whole situation gets out of control."
			~ "\nPanic sets in.";

		//drawApparatus(state, Point(200, 160));
		drawApparatus(state, Point(220, 180));
		state.framebufferPainter.drawGlyph(Emoji.fire.ptr, state.assets.fontEmoji2, 84, Point(210, 170));
		state.framebufferPainter.drawGlyph(Emoji.fire.ptr, state.assets.fontEmoji2, 84, Point(320, 140));
		state.framebufferPainter.drawGlyph(Emoji.fire.ptr, state.assets.fontEmoji1, Point(245, 160));
		state.framebufferPainter.drawGlyph(Emoji.dashSymbol.ptr, state.assets.fontEmoji1, Point(400, 190));
		state.framebufferPainter.drawGlyph(Emoji.shakingFace.ptr, state.assets.fontEmoji1, Point(25, 190));
		drawPageText!(6, Chapter.intro)(state, text);
	}

	void drawSlide7(ref GameState state) {
		static immutable text =
			"When smoke and dust finally settle, the team gets a chance to look at"
			~ "\nthe wreckage that used to be their machine. A good chunk of the"
			~ "\ncomponents seems to have disappeared."
			~ "\n"
			~ "\nInstead of leaving behind a void, a wormhole has opened up. It has already"
			~ "\nabsorbed large parts of the apparatus. And it proceeds to absorb"
			~ "\nwhatever comes near it. “That is…?” — “Eventually the whole planet!”";

		state.framebufferPainter.drawGlyph(Emoji.hole.ptr, state.assets.fontEmoji1, Point(230, 190));
		state.framebufferPainter.drawGlyph(Emoji.hole.ptr, state.assets.fontEmoji2, 84, Point(259, 258));
		state.framebufferPainter.drawGlyph(Emoji.dashSymbol.ptr, state.assets.fontEmoji1, Point(400, 190));
		state.framebufferPainter.drawGlyph(Emoji.shakingFace.ptr, state.assets.fontEmoji1, Point(25, 190));
		drawPageText!(7, Chapter.intro)(state, text);
	}

	void drawSlide8(ref GameState state) {
		static immutable text =
			"During its travel through the wormhole, Earth is shaken and deformed."
			~ "\nIts oceans are stirred up, volcanos turn inside out.";

		drawToothbrushMustacheMan(state, 20, Point(335, 160));
		state.framebufferPainter.drawGlyph(Emoji.hole.ptr, state.assets.fontEmoji1, Point(230, 190));
		state.framebufferPainter.drawGlyph(Emoji.hole.ptr, state.assets.fontEmoji2, 84, Point(259, 258));
		state.framebufferPainter.drawGlyph(Emoji.earthGlobeAmerics.ptr, state.assets.fontEmoji1, Point(230, 150));
		state.framebufferPainter.drawGlyph(Emoji.shakingFace.ptr, state.assets.fontEmoji1, Point(400, 190));
		state.framebufferPainter.drawGlyph(Emoji.waterwave.ptr, state.assets.fontEmoji2, 10, Point(240, 200));
		state.framebufferPainter.drawGlyph(Emoji.waterwave.ptr, state.assets.fontEmoji2, 12, Point(260, 235));
		state.framebufferPainter.drawGlyph(Emoji.waterwave.ptr, state.assets.fontEmoji2, 7, Point(280, 255));
		state.framebufferPainter.drawGlyph(Emoji.waterwave.ptr, state.assets.fontEmoji2, 10, Point(300, 180));
		state.framebufferPainter.drawGlyph(Emoji.waterwave.ptr, state.assets.fontEmoji2, 9, Point(330, 210));
		state.framebufferPainter.drawGlyph(Emoji.collisionSymbol.ptr, state.assets.fontEmoji2, 20, Point(260, 200));
		state.framebufferPainter.drawGlyph(Emoji.collisionSymbol.ptr, state.assets.fontEmoji2, 20, Point(250, 155));
		state.framebufferPainter.drawGlyph(Emoji.collisionSymbol.ptr, state.assets.fontEmoji2, 20, Point(315, 215));
		state.framebufferPainter.drawGlyph(Emoji.collisionSymbol.ptr, state.assets.fontEmoji2, 20, Point(300, 245));
		drawPageText!(8, Chapter.intro)(state, text);
	}

	void drawSlide9(ref GameState state) {
		static immutable text =
			"After a while Earth reaches its new location in a galaxy far, far away…"
			~ "\n"
			~ "\nYou catch a glimpse of your surroundings. Unfortunately, there’s no Luke"
			~ "\nSkywalker, Leia Organa, Padmé Amidala, Darth Vader or dichotomy in"
			~ "\nsight. — However it looks like your partner has turned into, well, a worm!";

		state.framebufferPainter.drawGlyph(Emoji.worm.ptr, state.assets.fontEmoji1, Point(400, 150));

		drawAnimatedEarth(state, true);
		drawPageText!(9, Chapter.intro)(state, text);
	}

	void drawSlide10(ref GameState state) {
		static immutable seg1 = "“" ~ state.gameTitle ~ "”";
		static immutable seg2 = " your partner\nasks you once again.";
		static immutable text = seg1 ~ seg2;

		state.framebufferPainter.drawGlyph(Emoji.worm.ptr, state.assets.fontEmoji1, Point(400, 150));

		drawAnimatedEarth(state, true);
		drawPageText!(10, Chapter.intro)(state, text);
		state.framebufferPainter.drawText(seg1, state.assets.fontTextR, 18, ColorRGB24(0x00, 0xFF, 0x66), textPos);
	}

	void drawSlide11(ref GameState state) {
		static immutable text = "Are you ready?";

		drawAnimatedEarth(state, true);
		state.framebufferPainter.drawGlyph(Emoji.worm.ptr, state.assets.fontEmoji1, Point(400, 150));
		drawPageText!(11, Chapter.intro)(state, "");
		state.framebufferPainter.drawText(text, state.assets.fontTextR, 72, ColorRGB24(0x00, 0xFF, 0x66), textPos);
	}

	void drawSlide12(ref GameState state) {
		static immutable text =
			"You and your partner have reached the end of the world."
			~ "\n"
			~ "\nHappy to have made it past all these turtles, you two bump into a guy."
			~ "\n“I’m Joseph, Man of Steel. Who are you?” he introduces himself and twirls"
			~ "\nhis mustache. You explain your situation and, eventually, he agrees to help"
			~ "\nyou."
			~ "\n"
			~ "\nA moment later you find yourself waiting for the second world’s very best"
			~ "\nscientists working on building an apparatus that ought to make things go"
			~ "\nback to normal. They make quick progress and soon or later their work is"
			~ "\nall set and done.";

		drawPageText!(12, Chapter.interlude)(state, text);
	}

	void drawSlide13(ref GameState state) {
		static immutable text =
			"Your partner thanks them for their hard work and you join the chorus."
			~ "\n"
			~ "\nTheir machine starts and proceeds to open another huge wormhole."
			~ "\nWith a word of warning they bid you farewell while Earth once again"
			~ "\nfalls through a wormhole.";

		state.framebufferPainter.drawGlyph(Emoji.hole.ptr, state.assets.fontEmoji1, Point(250, 190));
		state.framebufferPainter.drawGlyph(Emoji.cyclone.ptr, state.assets.fontEmoji2, 10, Point(315, 280));
		state.framebufferPainter.drawGlyph(Emoji.earthGlobeAmerics.ptr, state.assets.fontEmoji1, Point(250, 150));

		drawPageText!(13, Chapter.interlude)(state, text);
	}

	void drawSlide14(ref GameState state) {
		static immutable text =
			"Thanks to the help of “our” friend from the past, you and the whole globe"
			~ "\nhave made it back home. Land masses are back intact, the oceans flow as"
			~ "\nusual."
			~ "\n"
			~ "\nUnfortunately, there are two oddities left to be resolved:"
			~ "\nToothbrush-Moustache Man is haunting the world in his newly found"
			~ "\nundead presence. And your partner"
			~ "\nis still a worm.";

		drawPageText!(14, Chapter.interlude)(state, text);

		enum promptPos = textPos + Point(0, 190);
		static immutable promptText = "This is our final fight.\nAre you ready?";
		state.framebufferPainter.drawText(promptText, state.assets.fontTextM, 24, ColorRGB24(0x00, 0xFF, 0x66), promptPos);

		state.framebufferPainter.drawGlyph(Emoji.worm.ptr, state.assets.fontEmoji1, Point(450, 160));
		state.framebufferPainter.drawGlyph(Emoji.earthGlobeEuropeAfrica.ptr, state.assets.fontEmoji1, Point(300, 180));
		drawToothbrushMustacheMan(state, 50, Point(350, 200));
	}

	void drawSlide15(ref GameState state) {
		static immutable text =
			"Sweet Victory!"
			~ "\n"
			~ "\nToothbrush-Moustache Man has been defeated for good."
			~ "\nYour partner is back to their human-form — just as “our” friend from the"
			~ "\npast has promised."
			~ "\n"
			~ "\nWith a smirk on their face, your partner tries to ask you one more time,"
			~ "\n“Would you still…”";

		state.framebufferPainter.drawGlyph(Emoji.partyPopper.ptr, state.assets.fontEmoji1, Point(265, 190));
		drawPageText!(15, Chapter.ending)(state, text);
	}
}

enum animatedEarthSlideFrom = 9;
enum animatedEarthSlideTo = 11;

enum introFirstSlide = 0;
enum introTotalSlides = 12;
enum introFinalSlide = introTotalSlides - 1;

enum interludeFirstSlide = introFinalSlide + 1;
enum interludeTotalSlides = 3;
enum interludeFinalSlide = introFinalSlide + interludeTotalSlides;

enum endingFirstSlide = interludeFinalSlide + 1;
enum endingTotalSlides = 1;
enum endingFinalSlide = interludeFinalSlide + endingTotalSlides;

enum totalSlides = endingFinalSlide + 1;
