module game.pango;

import libpangocairo_2;
import game.cairo;
import game.geometry;
import game.memory;

alias Pixmap = game.cairo.Pixmap;

private enum PANGO_SCALE = 1024;

struct Font {
	private {
		PangoFontDescription* _desc;
	}

	private this(PangoFontDescription* desc) {
		_desc = desc;
	}

	static void clearRegistrations() {
		import libfontconfig;

		FcConfig* fc = FcConfigCreate();
		FcConfigSetCurrent(fc);
	}

	static void register(const(char)* path) {
		import libfontconfig;

		FcConfigAppFontAddFile(
			FcConfigGetCurrent(),
			cast(const(ubyte)*) path
		);
	}

	static Font open(const(char)* fontName) {
		return Font(pango_font_description_from_string(fontName));
	}

	void close() {
		pango_font_description_free(_desc);
		_desc = null;
	}

	void size(int size) {
		pango_font_description_set_absolute_size(_desc, size * PANGO_SCALE);
	}

	Text render(const(char)[] text, ColorRGB24 color) {
		return Text.render(text, this, color);
	}

	private void applyTo(PangoLayout* layout) {
		pango_layout_set_font_description(layout, _desc);
	}
}

struct Text {
	private {
		cairo_surface_t* _surface;
	}

	private this(cairo_surface_t* surface) {
		_surface = surface;
	}

	static Text render(const(char)[] text, Font font, ColorRGB24 color) {

		static void measureText(cairo_surface_t* surface, Font font, const(char)[] text, out int width, out int height) {
			cairo_t* cr = cairo_create(surface);
			PangoLayout* layout = pango_cairo_create_layout(cr);

			font.applyTo(layout);
			pango_layout_set_text(layout, text.ptr, cast(int) text.length);
			pango_layout_get_pixel_size(layout, &width, &height);

			g_object_unref(layout);
			cairo_destroy(cr);
		}

		static void drawText(cairo_surface_t* surface, Font font, ColorRGB24 color, const(char)[] text) {
			cairo_t* cr = cairo_create(surface);
			PangoLayout* layout = pango_cairo_create_layout(cr);

			cairo_set_source_rgba(cr, 0, 0, 0, 0);
			cairo_paint(cr);

			color.setAsSource(cr);
			font.applyTo(layout);
			pango_layout_set_text(layout, text.ptr, cast(int) text.length);
			pango_cairo_show_layout(cr, layout);

			g_object_unref(layout);
			cairo_destroy(cr);
		}

		cairo_surface_t* surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, 0, 0);

		int width = 0;
		int height = 0;
		measureText(surface, font, text, width, height);
		cairo_surface_destroy(surface);

		surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, width, height);
		drawText(surface, font, color, text);

		return Text(surface);
	}

	Pixmap toPixmap() {
		return Pixmap(_surface);
	}

	void free() {
		cairo_surface_destroy(_surface);
		_surface = null;
	}
}

void drawText(Painter painter, Text text, Point pos) {
	return painter.drawPixmap(text.toPixmap(), pos);
}

void drawText(Painter painter, const(char)[] text, Font font, ColorRGB24 color, Point pos) {
	Text txt = font.render(text, color);
	drawText(painter, txt, pos);
	txt.free();
}

void drawText(Painter painter, const(char)[] text, Font font, int size, ColorRGB24 color, Point pos) {
	font.size = size;
	return drawText(painter, text, font, color, pos);
}
