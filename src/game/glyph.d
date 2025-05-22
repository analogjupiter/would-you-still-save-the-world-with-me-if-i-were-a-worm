module game.glyph;

import game.cairo;
import game.crash;
import game.geometry;
import libfreetype2_2;
import libharfbuzz_2;

private enum FT_Int32 FT_LOAD_DEFAULT = 0x0;
private enum FT_Int32 FT_LOAD_COLOR = (1L << 20);

private extern extern (C) FT_Error FT_Load_Sfnt_Table( // @suppress(dscanner.style.phobos_naming_convention)
	FT_Face face,
	FT_ULong tag,
	FT_Long offset,
	FT_Byte* buffer,
	FT_ULong* length);

private void ezr(alias func, Args...)(Args args) {
	const r = func(args);
	if (r != 0) {
		enum funcName = __traits(identifier, func);
		crashf(funcName ~ ": 0x%X\n", r);
	}
}

struct GlyphIndex {
	private FT_UInt _value;
}

struct FontFace {
	private FT_Face _face;
	private bool _isColor;
	private int _height = -1;

	void pixelSizes(int height) {
		enum width = 0;

		if (_isColor) {
			import core.stdc.stdlib : abs;

			if (_face.num_fixed_sizes == 0) {
				return;
			}

			FT_Int idxMatch = 0;
			int deltaMatch = abs(height - _face.available_sizes[0].height);
			foreach (idx, size; _face.available_sizes[1 .. _face.num_fixed_sizes]) {
				const delta = abs(height - size.height);
				if (delta < deltaMatch) {
					idxMatch = cast(FT_Int) idx + 1;
					deltaMatch = delta;
				}
			}

			ezr!FT_Select_Size(_face, idxMatch);
			return;
		}

		ezr!FT_Set_Pixel_Sizes(_face, width, height);
		_height = height;
	}

	Pixmap renderGlyph(GlyphIndex glyph) {
		const FT_Int32 flags = FT_LOAD_COLOR;
		ezr!FT_Load_Glyph(_face, glyph._value, flags);
		ezr!FT_Render_Glyph(_face.glyph, FT_RENDER_MODE_NORMAL);

		const width = _face.glyph.bitmap.width;
		const height = _face.glyph.bitmap.rows;

		auto pixmap = Pixmap.makeNew(width, height, true);

		if (_face.glyph.bitmap.pixel_mode == FT_PIXEL_MODE_BGRA) {
			foreach (idx, ref px; pixmap.dataAsARGB32) {
				const idxSrc = idx * 4;
				ubyte b = _face.glyph.bitmap.buffer[idxSrc + 0];
				ubyte g = _face.glyph.bitmap.buffer[idxSrc + 1];
				ubyte r = _face.glyph.bitmap.buffer[idxSrc + 2];
				ubyte a = _face.glyph.bitmap.buffer[idxSrc + 3];

				// TODO: premultiply alpha?
				px = ColorARGB32(r, g, b, a);
			}

			pixmap.markDirty();
		}
		else if (_face.glyph.bitmap.pixel_mode == FT_PIXEL_MODE_GRAY) {
			foreach (idx, ref px; pixmap.dataAsARGB32) {
				ubyte p = _face.glyph.bitmap.buffer[idx];
				// TODO: premultiply alpha?
				px = ColorARGB32(0x00, 0x00, 0x00, p);
			}

			pixmap.markDirty();
		}

		return pixmap;
	}

	Pixmap renderGlyph(const(char)* s) {
		pragma(inline, true);
		return renderGlyph(resolveGlyph(s));
	}

	GlyphIndex resolveGlyph(const(char)* s) {
		hb_buffer_t* buffer = hb_buffer_create();
		hb_buffer_add_utf8(buffer, s, -1, 0, -1);

		hb_buffer_set_direction(buffer, HB_DIRECTION_LTR);
		hb_buffer_set_script(buffer, HB_SCRIPT_LATIN);
		hb_buffer_set_language(buffer, hb_language_from_string("en", -1));

		hb_face_t* face = hb_ft_face_create_referenced(_face);
		hb_font_t* font = hb_font_create(face);
		hb_ft_font_set_funcs(font);
		hb_shape(font, buffer, null, 0);

		uint glyph_count;
		hb_glyph_info_t* glyph_info = hb_buffer_get_glyph_infos(buffer, &glyph_count);

		if (glyph_count != 1) {
			crashf("unexpected glyph count %d", glyph_count);
		}

		const result = GlyphIndex(glyph_info[0].codepoint);
		hb_buffer_destroy(buffer);
		hb_font_destroy(font);

		return result;
	}
}

struct GlyphRenderer {
	private {
		FT_Library _ft;
	}

	void open() {
		ezr!FT_Init_FreeType(&_ft);
	}

	FontFace openFontFace(const(char)* font) {
		FT_Face face;
		ezr!FT_New_Face(_ft, font, 0, &face);

		//enum FT_ULong tag = FT_MAKE_TAG('C', 'B', 'D', 'T');
		enum FT_ULong tag = 0x43424454;
		FT_ULong tableLength = 0;
		const hasTable = FT_Load_Sfnt_Table(face, tag, 0, null, &tableLength) == 0;
		const isColor = (hasTable && tableLength > 0);

		return FontFace(face, isColor);
	}

	void close() {
		FT_Done_FreeType(_ft);
	}
}

void drawGlyph(Painter painter, const(char)* glyph, FontFace face, Point pos) {
	auto pixmap = face.renderGlyph(glyph);
	painter.drawPixmap(pixmap, pos);
	pixmap.free();
}

void drawGlyph(Painter painter, const(char)* glyph, FontFace face, int pixelSize, Point pos) {
	face.pixelSizes = pixelSize;
	return drawGlyph(painter, glyph, face, pos);
}
