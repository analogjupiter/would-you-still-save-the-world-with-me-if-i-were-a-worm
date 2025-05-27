module game.ui;

import game.cairo;
import game.crash;
import game.geometry;
import game.interactive;
import game.loader;
import game.memory;
import game.state;
import libsdl2;

enum SDL_WINDOWPOS_UNDEFINED = SDL_WINDOWPOS_UNDEFINED_DISPLAY(0);

void ezr(alias func, Args...)(Args args) {
	const r = func(args);
	if (r != 0) {
		enum funcName = __traits(identifier, func);
		crashf(funcName ~ ": %s\n", SDL_GetError());
	}
}

auto enr(alias func, Args...)(Args args) {
	auto r = func(args);
	if (r is null) {
		enum funcName = __traits(identifier, func);
		crashf(funcName ~ ": %s\n", SDL_GetError());
	}
	return r;
}

bool runUI(const(InteractiveScreen)* initialScreen) {
	GameState* gameState = setupGame();
	scope (exit) {
		gameState.loader.allocator.free();
		auto allocator = gameState.allocator;
		gameState = null;
		allocator.free();
	}

	loadGame(gameState);

	const(InteractiveScreen)* currentScreen = null;
	gameState.running = true;
	gameState.nextScreen = initialScreen;

	ezr!SDL_Init(SDL_INIT_VIDEO);
	scope (exit)
		SDL_Quit();

	int windowFlags = 0;
	windowFlags |= SDL_WINDOW_SHOWN;
	windowFlags |= SDL_WINDOW_RESIZABLE;

	SDL_Window* window = enr!SDL_CreateWindow(
		gameState.gameTitle.ptr,
		SDL_WINDOWPOS_UNDEFINED_DISPLAY(0),
		SDL_WINDOWPOS_UNDEFINED_DISPLAY(0),
		gameState.width,
		gameState.height,
		windowFlags,
	);

	scope (exit)
		SDL_DestroyWindow(window);

	uint rendererFlags = 0;
	rendererFlags |= SDL_RENDERER_PRESENTVSYNC;

	SDL_Renderer* renderer = enr!SDL_CreateRenderer(window, -1, rendererFlags);
	scope (exit)
		SDL_DestroyRenderer(renderer);

	ezr!SDL_SetRenderDrawColor(renderer, ubyte(0), ubyte(0), ubyte(0), ubyte(255));
	ezr!SDL_RenderSetIntegerScale(renderer, SDL_TRUE);
	ezr!SDL_RenderSetLogicalSize(renderer, gameState.width, gameState.height);

	SDL_SetWindowMinimumSize(window, gameState.width, gameState.height);
	version (none) {
		SDL_SetHint(SDL_HINT_MOUSE_DOUBLE_CLICK_TIME.ptr, "500");
	}

	SDL_Texture* texture = enr!SDL_CreateTexture(
		renderer,
		SDL_PIXELFORMAT_XRGB8888,
		SDL_TEXTUREACCESS_STREAMING,
		gameState.width,
		gameState.height,
	);
	scope (exit)
		SDL_DestroyTexture(texture);

	gameState.framebuffer = Pixmap.makeNew(gameState.width, gameState.height, false);
	gameState.framebufferPainter = gameState.framebuffer.makePainter();
	gameState.framebufferPainter.clear(ColorRGB24(0xFF, 0x00, 0x99));

	while (gameState.running) {
		nextScreenHandler(gameState, currentScreen);

		SDL_Event e;
		while (SDL_PollEvent(&e) != 0) {
			switch (e.type) {
			case SDL_QUIT:
				gameState.running = false;
				break;

			case SDL_MOUSEBUTTONDOWN:
				inputHandler(gameState, currentScreen, e.button, MouseAction.down);
				break;

			case SDL_MOUSEBUTTONUP:
				inputHandler(gameState, currentScreen, e.button, MouseAction.up);
				break;

			case SDL_KEYUP:
				if ((e.key.keysym.sym == SDLK_f) || (e.key.keysym.sym == SDLK_F11)) {
					gameState.fullscreen = !gameState.fullscreen;
				}
				else if (e.key.keysym.sym == SDLK_m) {
					gameState.audio.muted = !gameState.audio.muted;
				}
				break;

			default:
				break;
			}
		}

		ticksHandler(gameState);

		if (currentScreen.onDraw !is null) {
			currentScreen.onDraw(*gameState);
		}

		fullscreenHandler(gameState, window);

		enum pitch = gameState.width * 4;

		gameState.framebuffer.flush();
		const frameData = gameState.framebuffer.rawData;
		ezr!SDL_UpdateTexture(texture, null, frameData.ptr, pitch);

		ezr!SDL_RenderClear(renderer);
		ezr!SDL_RenderCopy(renderer, texture, null, null);
		SDL_RenderPresent(renderer);
	}

	version (none) {
		if (currentScreen !is null) {
			if (currentScreen.onDeactivate !is null) {
				currentScreen.onDeactivate(*gameState);
			}
		}
	}

	gameState.framebufferPainter.free();
	gameState.audio.stop();

	return true;
}

private:

GameState* setupGame() {
	pragma(inline, true);
	auto allocator = Allocator();
	GameState* state = allocator.make!GameState();
	state.allocator = allocator;
	return state;
}

void ticksHandler(GameState* state) {
	pragma(inline, true);
	const newTotal = SDL_GetTicks64();
	state.ticks.delta = newTotal - state.ticks.total;
	state.ticks.total = newTotal;
}

void fullscreenHandler(GameState* state, SDL_Window* window) {
	pragma(inline, true);

	const isFullscreen = (SDL_GetWindowFlags(window) & SDL_WINDOW_FULLSCREEN_DESKTOP) > 0;
	if (isFullscreen) {
		if (!state.fullscreen) {
			ezr!SDL_SetWindowFullscreen(window, 0);
		}
	}
	else {
		if (state.fullscreen) {
			ezr!SDL_SetWindowFullscreen(window, SDL_WINDOW_FULLSCREEN_DESKTOP);
		}
	}
}

void nextScreenHandler(GameState* state, ref const(InteractiveScreen)* currentScreen) {
	pragma(inline, true);

	if (state.nextScreen is null) {
		return;
	}

	if (state.nextScreen is currentScreen) {
		return;
	}

	version (none) {
		// Deactivate current screen.
		if (currentScreen !is null) {
			if (currentScreen.onDeactivate !is null) {
				currentScreen.onDeactivate(*state);
			}
		}
	}

	// Replace and activate current screen.
	currentScreen = state.nextScreen;
	if (currentScreen.onActivate !is null) {
		currentScreen.onActivate(*state);
	}
}

void inputHandler(
	GameState* state,
	const InteractiveScreen* currentScreen,
	const SDL_MouseButtonEvent mbe,
	const MouseAction action,
) {
	pragma(inline, true);

	if (currentScreen.onInput is null) {
		return;
	}

	MouseButton button;
	if (mbe.button == SDL_BUTTON_LEFT) {
		button = MouseButton.left;
	}
	else if (mbe.button == SDL_BUTTON_RIGHT) {
		button = MouseButton.right;
	}
	else {
		// ignore other mouse buttons
		return;
	}

	const input = MouseClick(
		Point(mbe.x, mbe.y),
		button,
		action,
		mbe.clicks,
	);

	currentScreen.onInput(*state, input);
}
