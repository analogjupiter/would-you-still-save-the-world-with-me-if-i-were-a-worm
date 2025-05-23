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
	partner = 'P',
}

bool isWall(Entity entity) {
	return (entity == Entity.rock);
}

struct World {
	Entity[] field;

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
		Messenger messenger;
	}

	private {
		bool _moved;
	}

	static PuzzleGame makeNew(ref Allocator allocator) {
		auto pg = PuzzleGame();

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
	}

	void tick() {
		if (_moved) {
			this.handleTrigger();
		}
		_moved = this.movePartner();
	}

private:
	bool movePartner() {
		static immutable msgHitAWall = "Obstacle!";

		if (partner.wormTo.x < 0) {
			return false;
		}

		if (partner.pos == partner.wormTo) {
			partner.wormTo.x = -1;
			partner.lastTrigger = Entity.air;
			return true; // run trigger on current cell if applicable
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
						return false;
					}
				}
			}

			partner.pos = next;
			return true;
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
			return false;
		}

		partner.pos = next;
		return true;
	}

	void handleTrigger() {
		const entity = world.getEntity(partner.pos);

		switch (entity) {
		default:
			break;

		case Entity.hole:
			messenger.send("Ouch! Your partner has fallen into a hole.", MessageType.alert, 3500);
			this.loadLevel();
			break;

		case Entity.apple:
			this.handleApple();
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
			this.handleWormhole(entity);
			break;

		case Entity.finish:
			if (!this.finishIsUnlocked) {
				messenger.send("Locked. Eat all apples first.", MessageType.alert, 5000);
				break;
			}
			++level;
			messenger.send("Level complete. Good job!", MessageType.success);
			this.loadLevel();
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

		const msg = (rand() % 2 == 1) ? "Delicious!" : "Yummy!";
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
