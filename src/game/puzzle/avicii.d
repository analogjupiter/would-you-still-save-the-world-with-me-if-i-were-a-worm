module game.puzzle.avicii;

enum Region {
	dirt,
	gras,
	snow,
	volc,
}

// dfmt off

enum level1 =
/+       "0         1         2" +/
/+       "012345678901234567890" +/
/+ 00 +/ "#####                " ~
/+ 01 +/ "#   #                " ~
/+ 02 +/ "# P #   i            " ~
/+ 03 +/ "#   #   i            " ~
/+ 04 +/ "#   #   i            " ~
/+ 05 +/ "#   # y i y          " ~
/+ 06 +/ "# # #  yiy           " ~
/+ 07 +/ "#   #   y            " ~
/+ 08 +/ "# X #                " ~
/+ 09 +/ "#   #                " ~
/+ 10 +/ "#####                ";

enum level2 =
/+       "0         1         2" +/
/+       "012345678901234567890" +/
/+ 00 +/ "#####i               " ~
/+ 01 +/ "#   #i               " ~
/+ 02 +/ "# P #i               " ~
/+ 03 +/ "#   #i               " ~
/+ 04 +/ "#   #i               " ~
/+ 05 +/ "#   #i               " ~
/+ 06 +/ "# o #i               " ~
/+ 07 +/ "#   #i               " ~
/+ 08 +/ "# X #i               " ~
/+ 09 +/ "#ooo#i               " ~
/+ 10 +/ "#####i               ";

enum level3 =
/+       "0         1         2" +/
/+       "012345678901234567890" +/
/+ 00 +/ "#####iii############ " ~
/+ 01 +/ "#   #iii#          # " ~
/+ 02 +/ "# P #iii#  ######  # " ~
/+ 03 +/ "#   #iii#  #iiii#  # " ~
/+ 04 +/ "#   #iii#  ######  # " ~
/+ 05 +/ "#   #iii#      o   # " ~
/+ 06 +/ "#   #iii#  ######  ##" ~
/+ 07 +/ "#  o#iii#  #    #   #" ~
/+ 08 +/ "#   #####  #    # X #" ~
/+ 09 +/ "# o        #    #   #" ~
/+ 10 +/ "############    #####";

enum level4 =
/+       "0         1         2" +/
/+       "012345678901234567890" +/
/+ 00 +/ "#####################" ~
/+ 01 +/ "#   #          #   1#" ~
/+ 02 +/ "# P # 2        #2   #" ~
/+ 03 +/ "#   #          ######" ~
/+ 04 +/ "#   #              3#" ~
/+ 05 +/ "#   #               #" ~
/+ 06 +/ "#   #iii#############" ~
/+ 07 +/ "#   #iii#3          #" ~
/+ 08 +/ "# 1 #iii#         X #" ~
/+ 09 +/ "#   #iii#           #" ~
/+ 10 +/ "#####################";

enum level5 =
/+       "0         1         2" +/
/+       "012345678901234567890" +/
/+ 00 +/ "#####################" ~
/+ 01 +/ "#iii#4#4   o   o   3#" ~
/+ 02 +/ "# P #5#  o   o   o  #" ~
/+ 03 +/ "#  i#################" ~
/+ 04 +/ "#         #     #iii#" ~
/+ 05 +/ "#ooo        #       #" ~
/+ 06 +/ "################# o #" ~
/+ 07 +/ "# 2  1 #      #1    #" ~
/+ 08 +/ "#################ooo#" ~
/+ 09 +/ "#2 ##3  6##i6##5  X #" ~
/+ 10 +/ "#        ##ii########";

enum level6 =
/+       "0         1         2" +/
/+       "012345678901234567890" +/
/+ 00 +/ "#####################" ~
/+ 01 +/ "#P   2#2o6##i7ii8i# A" ~
/+ 02 +/ "#### 3##o###iiiiii# B" ~
/+ 03 +/ "o5o# 4#3       o  ###" ~
/+ 04 +/ "o i#######         ii" ~
/+ 05 +/ "i o#i5#4i#     i   iE" ~
/+ 06 +/ "o6o#i   i#    iii  ii" ~
/+ 07 +/ "##########     i ####" ~
/+ 08 +/ "                 #C 9" ~
/+ 09 +/ "   ii oo########o####" ~
/+ 10 +/ "7      E#98A#DC#D#B X";

enum level7 =
/+       "0         1         2" +/
/+       "012345678901234567890" +/
/+ 00 +/ "P #  #4 ####  # # # #" ~
/+ 01 +/ "  1#  #  ####  # # #9" ~
/+ 02 +/ " #  #6 #3 #### o#o#o#" ~
/+ 03 +/ "  #  #  #  #### o# #o" ~
/+ 04 +/ "#  #  #  #2 ####  # #" ~
/+ 05 +/ " #2 #  #  #  ####oo# " ~
/+ 06 +/ "  #  #  #5 #  ####o #" ~
/+ 07 +/ "#  #  #  #  #  ####  " ~
/+ 08 +/ " #3 #  #  #  #  ####8" ~
/+ 09 +/ "5 #  #  # 1#  #  ####" ~
/+ 10 +/ "#  #8 #6 #  #  #4 #9X";

enum level8 =
/+       "0         1         2" +/
/+       "012345678901234567890" +/
/+ 00 +/ "iiiioiiiiioi1oiiioiii" ~
/+ 01 +/ "iioioioooioiioioioioi" ~
/+ 02 +/ "iPoioioioiiiioio1oioi" ~
/+ 03 +/ "oooioioioooooiioooioi" ~
/+ 04 +/ "iiiioioiioiiiioiiiioi" ~
/+ 05 +/ "oioooiooioioiooiooooi" ~
/+ 06 +/ "oioiiiiiioioi2oioiiii" ~
/+ 07 +/ "oiiiooio2oioiooioio33" ~
/+ 08 +/ "oioiiiioooioiiiio ooo" ~
/+ 09 +/ "oiooooooiiioioiio X o" ~
/+ 10 +/ "oiiiiiiiioiiioiiooooo";

enum level9 =
/+       "0         1         2" +/
/+       "012345678901234567890" +/
/+ 00 +/ "yyyyyyy#yyyyyyyy#yyyy" ~
/+ 01 +/ "yyy#yyyyyy#yyyyyyy#yy" ~
/+ 02 +/ "                     " ~
/+ 03 +/ "                9    " ~
/+ 04 +/ "                   X " ~
/+ 05 +/ "                     " ~
/+ 06 +/ "#########            " ~
/+ 07 +/ "#1o23567#            " ~
/+ 08 +/ "#2P167o8#            " ~
/+ 09 +/ "#344o8o9#            " ~
/+ 10 +/ "#########            ";

enum level10 =
/+       "0         1         2" +/
/+       "012345678901234567890" +/
/+ 00 +/ "### #13# #3 # #876E5#" ~
/+ 01 +/ "#P# #26# # 4# #######" ~
/+ 02 +/ "#1# #### # 5#        " ~
/+ 03 +/ "###      ####  ##### " ~
/+ 04 +/ "    ####       #94A# " ~
/+ 05 +/ "    #79#  ###  ##### " ~
/+ 06 +/ " D  ####  #B#        " ~
/+ 07 +/ "          #A#    ####" ~
/+ 08 +/ "##        #2#  D #CB#" ~
/+ 09 +/ "X# #####  ### E  ####" ~
/+ 10 +/ "F# #8CF#             ";

enum level11 =
/+       "0         1         2" +/
/+       "012345678901234567890" +/
/+ 00 +/ "4o8ooo6oF X  o  o o1o" ~
/+ 01 +/ "o o o7ooo###oooo o2o " ~
/+ 02 +/ " o ooooo#####   o o  " ~
/+ 03 +/ "       ### # #      o" ~
/+ 04 +/ "     3### # ###    o " ~
/+ 05 +/ "    4### #######ooooo" ~
/+ 06 +/ "   3##### ### ###F  8" ~
/+ 07 +/ "  2####### # # ###5  " ~
/+ 08 +/ "  ######### ### ###6 " ~
/+ 09 +/ "i#####1######### ###i" ~
/+ 10 +/ "####7o#o5######## P##";

// dfmt on

static immutable levelNames = [
	"Level 1: Reach the wormhole to exit the puzzle.",
	"Level 2: Not every hole is a goal. — Avoid non-wormhole holes.",
	"Level 3: This is a MAZE-ing.",
	"Level 4: Wormholes. And they teleport. How convenient!",
	"Level 5: This is how we do.",
	"Level 6: Teleport Tango",
	"Level 7: Shivering Shenanigans",
	"Level 8: Punchcard Party",
	"Level 9: Oh dear…",
	"Level 10: Icy Investigation",
	"Level 11: Hot Hills",
];

// dfmt off
static immutable regions = [
	/*  1 */ Region.dirt,
	/*  2 */ Region.dirt,
	/*  3 */ Region.dirt,
	/*  4 */ Region.dirt,
	/*  5 */ Region.gras,
	/*  6 */ Region.gras,
	/*  7 */ Region.snow,
	/*  8 */ Region.gras,
	/*  9 */ Region.dirt,
	/* 10 */ Region.snow,
	/* 11 */ Region.volc,
];
// dfmt on

enum levelsTotal = 11;
enum firstLevel = 11;
enum guideLevel = 1;
