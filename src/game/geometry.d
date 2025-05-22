module game.geometry;

import game.crash;

private int max(int a, int b) @nogc nothrow pure @safe {
	return a >= b ? a : b;
}

private int min(int a, int b) @nogc nothrow pure @safe {
	return a <= b ? a : b;
}

/++
	2D location point
 +/
struct Point {
	int x; /// x-coordinate (aka abscissa)
	int y; /// y-coordinate (aka ordinate)

pure const nothrow @safe:

	Point opBinary(string op)(in Point rhs) @nogc {
		return Point(mixin("x" ~ op ~ "rhs.x"), mixin("y" ~ op ~ "rhs.y"));
	}

	Point opBinary(string op)(int rhs) @nogc {
		return Point(mixin("x" ~ op ~ "rhs"), mixin("y" ~ op ~ "rhs"));
	}

	Size opCast(T : Size)() inout @nogc {
		return Size(x, y);
	}

	/++
		Calculates the point of linear offset in a rectangle.

		`Offset = 0` is assumed to be equivalent to `Point(0,0)`.

		See_also:
			[linearOffset] is the inverse function.

		History:
			Added October 05, 2024.
	 +/
	static Point fromLinearOffset(int linearOffset, int width) @nogc {
		const y = (linearOffset / width);
		const x = (linearOffset % width);
		return Point(x, y);
	}
}

///
struct Size {
	int width; ///
	int height; ///

pure nothrow @safe:

	/++
		Rectangular surface area

		Calculates the surface area of a rectangle with dimensions equivalent to the width and height of the size.
	 +/
	int area() const @nogc {
		return width * height;
	}

	Point opCast(T : Point)() inout @nogc {
		return Point(width, height);
	}

	// gonna leave this undocumented for now since it might be removed later
	/+ +
		Adding (and other arithmetic operations) two sizes together will operate on the width and height independently. So Size(2, 3) + Size(4, 5) will give you Size(6, 8).
	+/
	Size opBinary(string op)(in Size rhs) const @nogc {
		return Size(
			mixin("width" ~ op ~ "rhs.width"),
			mixin("height" ~ op ~ "rhs.height"),
		);
	}

	Size opBinary(string op)(int rhs) const @nogc {
		return Size(
			mixin("width" ~ op ~ "rhs"),
			mixin("height" ~ op ~ "rhs"),
		);
	}
}

///
struct Rectangle {
	int left; ///
	int top; ///
	int right; ///
	int bottom; ///

pure const nothrow @safe @nogc:

	///
	this(int left, int top, int right, int bottom) {
		this.left = left;
		this.top = top;
		this.right = right;
		this.bottom = bottom;
	}

	///
	this(in Point upperLeft, in Point lowerRight) {
		this(upperLeft.x, upperLeft.y, lowerRight.x, lowerRight.y);
	}

	///
	this(in Point upperLeft, in Size size) {
		this(upperLeft.x, upperLeft.y, upperLeft.x + size.width, upperLeft.y + size.height);
	}

	///
	@property Point upperLeft() {
		return Point(left, top);
	}

	///
	@property Point upperRight() {
		return Point(right, top);
	}

	///
	@property Point lowerLeft() {
		return Point(left, bottom);
	}

	///
	@property Point lowerRight() {
		return Point(right, bottom);
	}

	///
	@property Point center() {
		return Point((right + left) / 2, (bottom + top) / 2);
	}

	///
	@property Size size() {
		return Size(width, height);
	}

	///
	@property int width() {
		return right - left;
	}

	///
	@property int height() {
		return bottom - top;
	}

	/// Returns true if this rectangle entirely contains the other
	bool contains(in Rectangle r) {
		return contains(r.upperLeft) && contains(r.lowerRight);
	}

	/// ditto
	bool contains(in Point p) {
		return (p.x >= left && p.x < right && p.y >= top && p.y < bottom);
	}

	/// Returns true of the two rectangles at any point overlap
	bool overlaps(in Rectangle r) {
		// the -1 in here are because right and top are exclusive
		return !((right - 1) < r.left || (r.right - 1) < left || (bottom - 1) < r.top || (r.bottom - 1) < top);
	}

	/++
		Returns a Rectangle representing the intersection of this and the other given one.

		History:
			Added July 1, 2021
	+/
	Rectangle intersectionOf(in Rectangle r) {
		auto tmp = Rectangle(max(left, r.left), max(top, r.top), min(right, r.right), min(bottom, r.bottom));
		if (tmp.left >= tmp.right || tmp.top >= tmp.bottom)
			tmp = Rectangle.init;

		return tmp;
	}
}

/++
	Calculates the linear offset of a point
	from the start (0/0) of a rectangle.

	This assumes that (0/0) is equivalent to offset `0`.
	Each step on the x-coordinate advances the resulting offset by `1`.
	Each step on the y-coordinate advances the resulting offset by `width`.

	This function is only defined for the 1st quadrant,
	i.e. both coordinates (x and y) of `pos` are positive.

	Returns:
		`y * width + x`

	See_also:
		[Point.fromLinearOffset] is the inverse function.

	History:
		Added December 19, 2023 (dub v11.4)
 +/
int linearOffset(const Point pos, const int width) @safe pure nothrow @nogc {
	return ((width * pos.y) + pos.x);
}

/// ditto
int linearOffset(const int width, const Point pos) @safe pure nothrow @nogc {
	return ((width * pos.y) + pos.x);
}
