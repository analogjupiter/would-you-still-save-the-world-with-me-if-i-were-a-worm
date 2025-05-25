module game.cairo;

import game.geometry;
import libpangocairo_2;

private enum M_PI = 3.14159265358979323846;

int bytesPerPixel(cairo_format_t format) {
	switch (format) {
	case CAIRO_FORMAT_ARGB32:
		return 4;
	case CAIRO_FORMAT_RGB24:
		return 4;

	case CAIRO_FORMAT_A8:
		return 1;

	case CAIRO_FORMAT_RGB16_565:
		return 2;

	default:
		return -1;
	}
}

struct ColorRGBA128F {
	float r;
	float g;
	float b;
	float a;

	void setAsSource(cairo_t* cr) {
		cairo_set_source_rgba(cr, r, g, b, a);
	}
}

struct ColorARGB32 {
	public this(ubyte r, ubyte g, ubyte b, ubyte a = 0xFF) {
		this.r = r;
		this.g = g;
		this.b = b;
		this.a = a;
	}

	version (LittleEndian) {
		ubyte b;
		ubyte g;
		ubyte r;
		ubyte a;
	}
	else version (BigEndian) {
		ubyte a;
		ubyte r;
		ubyte g;
		ubyte b;
	}
}

struct ColorRGB24 {
	public this(ubyte r, ubyte g, ubyte b) {
		this.r = r;
		this.g = g;
		this.b = b;
	}

	void setAsSource(cairo_t* cr) {
		cairo_set_source_rgb(cr, r / 255.0, g / 255.0, b / 255.0);
	}

	version (LittleEndian) {
		ubyte b;
		ubyte g;
		ubyte r;
		ubyte x;
	}
	else version (BigEndian) {
		ubyte x;
		ubyte r;
		ubyte g;
		ubyte b;
	}
}

struct Pixmap {
	private {
		cairo_surface_t* _surface;
	}

	public this(cairo_surface_t* surface) {
		_surface = surface;
	}

	static Pixmap makeNew(Size size, bool rgba) {
		return makeNew(size.width, size.height, rgba);
	}

	static Pixmap makeNew(int width, int height, bool rgba) {
		const cairo_format_t format = (rgba)
			? CAIRO_FORMAT_ARGB32 : CAIRO_FORMAT_RGB24;

		return Pixmap(cairo_image_surface_create(format, width, height));
	}

	void setPixel(Point pos, ColorRGB24 color) {
		this.flush();
		const idx = linearOffset(pos, width);
		dataAsRGB24()[idx] = color;
		this.markDirty();
	}

	int width() {
		pragma(inline, true);
		return cairo_image_surface_get_width(_surface);
	}

	int height() {
		pragma(inline, true);
		return cairo_image_surface_get_height(_surface);
	}

	int length() {
		return width * height;
	}

	int stride() {
		pragma(inline, true);
		return cairo_image_surface_get_stride(_surface);
	}

	cairo_format_t format() {
		pragma(inline, true);
		return cairo_image_surface_get_format(_surface);
	}

	Size size() {
		pragma(inline, true);
		return Size(width, height);
	}

	void flush() {
		pragma(inline, true);
		cairo_surface_flush(_surface);
	}

	void markDirty() {
		pragma(inline, true);
		cairo_surface_mark_dirty(_surface);
	}

	Painter makePainter() {
		pragma(inline, true);
		cairo_t* cr = cairo_create(_surface);
		return Painter(cr);
	}

	ubyte[] rawData() {
		ubyte* data = cairo_image_surface_get_data(_surface);
		const length = width * height * format.bytesPerPixel;
		return data[0 .. length];
	}

	ColorRGB24[] dataAsRGB24() {
		auto data = cast(ColorRGB24*) cast(void*) cairo_image_surface_get_data(_surface);
		const length = width * height;
		return data[0 .. length];
	}

	ColorARGB32[] dataAsARGB32() {
		auto data = cast(ColorARGB32*) cast(void*) cairo_image_surface_get_data(_surface);
		const length = width * height;
		return data[0 .. length];
	}

	void free() {
		cairo_surface_destroy(_surface);
		_surface = null;
	}
}

struct Painter {
	private {
		cairo_t* _cr;
	}

	public this(cairo_t* cr) {
		_cr = cr;
	}

	void clear(ColorRGBA128F color) {
		color.setAsSource(_cr);
		cairo_set_source_rgba(_cr, color.r, color.g, color.b, color.a);
		cairo_paint(_cr);
	}

	void clear(ColorRGB24 color) {
		color.setAsSource(_cr);
		cairo_paint(_cr);
	}

	void drawRectangle(ColorRGB24 color, Size size, Point pos) {
		cairo_rectangle(_cr, pos.x, pos.y, size.width, size.height);
		color.setAsSource(_cr);
		cairo_fill(_cr);
	}

	void drawRectangle(ColorRGBA128F color, Size size, Point pos) {
		cairo_rectangle(_cr, pos.x, pos.y, size.width, size.height);
		color.setAsSource(_cr);
		cairo_fill(_cr);
	}

	void drawCircle(ColorRGBA128F color, double radius, Point pos) {
		cairo_arc(_cr, pos.x, pos.y, radius, 0.0, 2.0 * M_PI);
		color.setAsSource(_cr);
		cairo_fill(_cr);
	}

	void drawPixmap(Pixmap pixmap, Point pos) {
		cairo_set_source_surface(_cr, pixmap._surface, pos.x, pos.y);
		cairo_paint(_cr);
	}

	void free() {
		cairo_destroy(_cr);
		_cr = null;
	}
}
