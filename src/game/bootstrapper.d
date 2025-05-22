module game.bootstrapper;

import game.ui;
import game.screens.loading;

int bootstrapGame() {
	pragma(inline, true);

	const success = runUI(&loadingScreen);
	return (success) ? 0 : 1;
}
