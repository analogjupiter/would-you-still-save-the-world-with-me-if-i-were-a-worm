module game.puzzle.data;

import game.cairo;
import game.crash;
import game.geometry;
import game.memory;
import game.puzzle.avicii;
import game.puzzle.messenger;

struct Partner {
	Point pos;
	Point wormTo;
	Entity lastTrigger;
}

struct Level {
	Partner partner;
}

enum Entity : char {
	air = ' ',
	rock = '#',
	hole = 'o',
	apple = 'a',
	turtle = 'T',
	wormhole1 = '1',
	wormhole2 = '2',
	wormhole3 = '3',
	wormhole4 = '4',
	wormhole5 = '5',
	wormhole6 = '6',
	wormhole7 = '7',
	wormhole8 = '8',
	wormhole9 = '9',
	wormholeA = 'A',
	wormholeB = 'B',
	wormholeC = 'C',
	wormholeD = 'D',
	wormholeE = 'E',
	wormholeF = 'F',
	herb = 'y',
	seedling = 'i',
	finish = 'X',
	toothbrushMoustacheMan = 'H',
	partner = 'P',
}

bool isWall(Entity entity) {
	return (entity == Entity.rock);
}

bool isWormhole(Entity entity) {
	return (
		((entity >= Entity.wormhole1) && (entity <= Entity.wormhole9))
			|| ((entity >= Entity.wormholeA) && (entity <= Entity.wormholeF))
	);
}

struct World {
	Entity[] field;
	Point[] turtles;

	Entity getEntity(Point gridPos) {
		const idx = gridPos.linearOffset(grid.width);
		return field[idx];
	}

	bool hasApplesLeft() {
		foreach (entity; field) {
			if (entity == Entity.apple) {
				return true;
			}
		}

		return false;
	}
}

///
enum grid = Size(21, 11);

struct PuzzleGame {
	public {
		Partner partner;
		World world;
		int level;
		bool gameCompleteMain;
		bool gameCompleteBoss;
		Messenger messenger;
	}

	private {
		bool _moved;
	}

	static PuzzleGame makeNew(ref Allocator allocator) {
		auto pg = PuzzleGame();

		pg.gameCompleteMain = false;
		pg.gameCompleteBoss = false;

		enum entitiesCount = grid.area;
		Entity[] field = allocator.makeSlice!Entity(entitiesCount);
		pg.world = World(field);

		pg.level = firstLevel;
		pg.loadLevel();

		return pg;
	}

	Region currentRegion() {
		return regions[level - 1];
	}

	string currentLevelName() {
		return levelNames[level - 1];
	}

	bool finishIsUnlocked() {
		return !world.hasApplesLeft;
	}

	void loadLevel() {

		enum switchCase(int levelNo) =
			`case ` ~ levelNo.stringof ~ `:`
			~ `fillLevel!level` ~ levelNo.stringof ~ `(world);`
			~ `break loadLevelSwitch;`;

	loadLevelSwitch: // @suppress(dscanner.suspicious.unused_label)
		switch (this.level) {
			static foreach (lvl; 1 .. levelsTotal + 1) {
				mixin(switchCase!lvl);
			}

		default:
			crashf("No level %d\n", this.level);
		}

		_moved = false;

		partner.pos = Point(0, 0);
		partner.wormTo = Point(-1, -1);
		partner.lastTrigger = Entity.air;

		foreach (idx, ref entity; world.field) {
			if (entity == Entity.partner) {
				entity = Entity.air;
				partner.pos = Point.fromLinearOffset(cast(int) idx, grid.width);
				break;
			}
		}

		size_t turtlesCount = 0;
		foreach (idx, entity; world.field) {
			if (entity == Entity.turtle) {
				++turtlesCount;
			}
		}
		if (turtlesCount == 0) {
			world.turtles = null;
		}
		else {
			if (turtlesCount != world.turtles.length) {
				// TODO: memory leak
				auto allocator = Allocator();
				world.turtles = allocator.makeSlice!Point(turtlesCount);
			}

			size_t cursor = 0;
			foreach (idx, ref entity; world.field) {
				if (entity == Entity.turtle) {
					entity = Entity.air;
					world.turtles[cursor] = Point.fromLinearOffset(cast(int) idx, grid.width);

					++cursor;
					if (cursor == turtlesCount) {
						break;
					}
				}
			}
		}
	}

	void tick() {
		if (_moved) {
			this.handleTrigger();
		}

		const status = this.movePartner();
		_moved = (status != 0);

		if (status == 2) {
			this.moveTurtles();
		}
	}

private:
	int movePartner() {
		static immutable msgHitAWall = "Obstacle!";

		if (partner.wormTo.x < 0) {
			return 0;
		}

		if (partner.pos == partner.wormTo) {
			partner.wormTo.x = -1;
			partner.lastTrigger = Entity.air;
			return 1; // run trigger on current cell if applicable
		}

		const Point delta = partner.wormTo - partner.pos;
		Point next;
		if (delta.x != 0 && delta.y != 0) {
			const directionX = (delta.x > 0) ? 1 : -1;
			const directionY = (delta.y > 0) ? 1 : -1;

			// X and Y
			next = partner.pos + Point(directionX, directionY);
			if (world.getEntity(next).isWall) {
				// X only
				next = partner.pos + Point(directionX, 0);
				if (world.getEntity(next).isWall) {
					// Y only
					next = partner.pos + Point(0, directionY);
					if (world.getEntity(next).isWall) {
						// none
						partner.wormTo.x = -1;
						messenger.send(msgHitAWall, MessageType.alert);
						return 0;
					}
				}
			}

			partner.pos = next;
			return 2;
		}

		if (delta.x != 0) {
			const direction = (delta.x > 0) ? 1 : -1;
			next = partner.pos;
			next.x += direction;
		}
		else {
			const direction = (delta.y > 0) ? 1 : -1;
			next = partner.pos;
			next.y += direction;
		}

		if (world.getEntity(next).isWall) {
			partner.wormTo.x = -1;
			messenger.send(msgHitAWall, MessageType.alert);
			return 0;
		}

		partner.pos = next;
		return 2;
	}

	void moveTurtles() {
		static void moveTurtle(ref Point pos, World world) {
			import core.stdc.stdlib : rand;

			const direction = (rand() % 5);

			Point move;
			if (direction == 0) {
				move = Point(0, -1);
			}
			else if (direction == 1) {
				move = Point(1, 0);
			}
			else if (direction == 2) {
				move = Point(0, 1);
			}
			else if (direction == 3) {
				move = Point(-1, 0);
			}
			else {
				return;
			}

			const next = pos + move;

			if (
				(next.x < 0) ||
				(next.y < 0) ||
				(next.x >= grid.width) ||
				(next.y >= grid.height)
				) {
				return;
			}

			if (world.getEntity(next).isWall) {
				return;
			}

			pos = next;
		}

		foreach (ref turtle; world.turtles) {
			moveTurtle(turtle, world);
		}
	}

	void handleTrigger() {
		const entity = world.getEntity(partner.pos);

		if (entity.isWormhole) {
			this.handleWormhole(entity);
			partner.lastTrigger = entity;
			return;
		}
		else if (entity == Entity.finish) {
			if (!this.finishIsUnlocked) {
				messenger.send("Locked. Eat all apples first.", MessageType.alert, 5000);
				partner.lastTrigger = entity;
				return;
			}

			++level;
			if (level <= bossLevel) {
				messenger.send("Level complete. Good job!", MessageType.success, 1000);
			}
			if (level == bossLevel) {
				gameCompleteMain = true;
			}
			return this.loadLevel();
		}
		else {
			foreach (turtle; world.turtles) {
				if (turtle == partner.pos) {
					messenger.send("Ouch! Your partner got attacked by a turtle.", MessageType.alert, 3500);
					return this.loadLevel();
				}
			}
		}

		switch (entity) {
		default:
			break;

		case Entity.hole:
			messenger.send("Ouch! Your partner has fallen into a hole.", MessageType.alert, 3500);
			return this.loadLevel();

		case Entity.apple:
			this.handleApple();
			break;

		case Entity.toothbrushMoustacheMan:
			gameCompleteBoss = true;
			break;
		}

		partner.lastTrigger = entity;
	}

	void handleWormhole(Entity type) {
		if (partner.lastTrigger == type) {
			return;
		}

		const idxPartner = partner.pos.linearOffset(grid.width);
		foreach (idx, entity; world.field) {
			if ((entity == type) && (idx != idxPartner)) {
				partner.pos = Point.fromLinearOffset(cast(int) idx, grid.width);
				partner.wormTo.x = -1;
				break;
			}
		}
	}

	void handleApple() {
		import core.stdc.stdlib : rand;

		const idx = partner.pos.linearOffset(grid.width);
		world.field[idx] = Entity.air;

		static immutable msg1 = "Yummy!";
		static immutable msg2 = "Delicious!";
		static immutable msg3 = "An apple a day keeps the doctor away!";

		// dfmt off
		const msg =
			(rand() % 2 == 1)
				? msg2
				: (rand() % 20 == 19)
					? msg3
					: msg1;
		// dfmt on

		messenger.send(msg, MessageType.success);
	}
}

private:

void fillLevel(string levelData)(World world) {
	static assert(levelData.length == grid.area);

	foreach (ref cell; world.field) {
		cell = Entity.air;
	}

	static foreach (idx, cell; levelData) {
		static if (cell != Entity.air) {
			world.field[idx] = cast(Entity) cell;
		}
	}
}
