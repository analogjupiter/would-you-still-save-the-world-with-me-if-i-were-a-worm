module game.puzzle.avicii;

enum Region {
	dirt,
	gras,
	snow,
	volc,
	boss,
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

enum level12 =
/+       "0         1         2" +/
/+       "012345678901234567890" +/
/+ 00 +/ " P                   " ~
/+ 01 +/ " a   i    a    i   a " ~
/+ 02 +/ " o       a a       o " ~
/+ 03 +/ " a      a   a      a " ~
/+ 04 +/ " a     a  i  a     a " ~
/+ 05 +/ " a    a       a    a " ~
/+ 06 +/ " a   a         a   a " ~
/+ 07 +/ " a  a     X     a  a " ~
/+ 08 +/ " a a             a a " ~
/+ 09 +/ " aa      iii      aa " ~
/+ 10 +/ " a        i        a ";

enum level13 =
/+       "0         1         2" +/
/+       "012345678901234567890" +/
/+ 00 +/ " 1#       P        1 " ~
/+ 01 +/ "a #########  #   #   " ~
/+ 02 +/ "###o  5  o# o# o #o o" ~
/+ 03 +/ "    o   o #o #o o# o " ~
/+ 04 +/ "#### oao  # o# o #o o" ~
/+ 05 +/ "X 6#  o   #2 # 3 # 4 " ~
/+ 06 +/ "#####################" ~
/+ 07 +/ "      #       #      " ~
/+ 08 +/ "  a   #   5   #   6  " ~
/+ 09 +/ "      #       #      " ~
/+ 10 +/ "  2   #   3   #   4  ";

enum level14 =
/+       "0         1         2" +/
/+       "012345678901234567890" +/
/+ 00 +/ "2#6#3#A#7#B#9#8#5#4#1" ~
/+ 01 +/ " # # # # # # # # # # " ~
/+ 02 +/ " # # # # # # # # # # " ~
/+ 03 +/ " # # # # # # # # # # " ~
/+ 04 +/ " # # # # # # # # # # " ~
/+ 05 +/ "P#a#a#a#a#X#a#a#a#a#i" ~
/+ 06 +/ " # # # # # # # # # # " ~
/+ 07 +/ " # # # # # # # # # # " ~
/+ 08 +/ " # # # # # # # # # # " ~
/+ 09 +/ " # # # # # # # # # # " ~
/+ 10 +/ "1#4#5#8#9#A#B#6#7#2#3";

enum level15 =
/+       "0         1         2" +/
/+       "012345678901234567890" +/
/+ 00 +/ "##  oo    a    oo  ##" ~
/+ 01 +/ "#  i oo   1   oo i  #" ~
/+ 02 +/ "  iai oo  o  oo iai  " ~
/+ 03 +/ "   i  Ao#####oB  i   " ~
/+ 04 +/ "oooooooA#o1o#Booooooo" ~
/+ 05 +/ " a    4o#4P2#o2    X " ~
/+ 06 +/ "oooooooD#o3o#Cooooooo" ~
/+ 07 +/ "   i  Do#####oC  i   " ~
/+ 08 +/ "  iai oo  o  oo iai  " ~
/+ 09 +/ "#  i oo   3   oo i  #" ~
/+ 10 +/ "##  oo    a    oo  ##";

enum level16 =
/+       "0         1         2" +/
/+       "012345678901234567890" +/
/+ 00 +/ " X          Ao#oB  ao" ~
/+ 01 +/ "################## ##" ~
/+ 02 +/ "6   5o#o5 ao#o9     A" ~
/+ 03 +/ "## ##################" ~
/+ 04 +/ "4    3oo#E  a#o8 a  6" ~
/+ 05 +/ "################### #" ~
/+ 06 +/ "a C a D Eo# 4 ao#oa  " ~
/+ 07 +/ "#####################" ~
/+ 08 +/ "8 a 9o#o3  1oo#oB  Co" ~
/+ 09 +/ "#####################" ~
/+ 10 +/ "oa D#o 2 ao#oo1  P 2o";

enum level17 =
/+       "0         1         2" +/
/+       "012345678901234567890" +/
/+ 00 +/ "#####################" ~
/+ 01 +/ "#P                 a#" ~
/+ 02 +/ "# iiiiiiiiiiiiiiiii #" ~
/+ 03 +/ "# iT             Ti #" ~
/+ 04 +/ "# i               i #" ~
/+ 05 +/ "# i       X       i #" ~
/+ 06 +/ "# i               i #" ~
/+ 07 +/ "# iT             Ti #" ~
/+ 08 +/ "# iiiiiiiiiiiiiiiii #" ~
/+ 09 +/ "#a                 a#" ~
/+ 10 +/ "#####################";

enum level18 =
/+       "0         1         2" +/
/+       "012345678901234567890" +/
/+ 00 +/ "1P        a       T#a" ~
/+ 01 +/ "          a       T#3" ~
/+ 02 +/ "          a       T##" ~
/+ 03 +/ "####T     a       3 T" ~
/+ 04 +/ "a  #T     a         T" ~
/+ 05 +/ "  2#T     a         T" ~
/+ 06 +/ "####T     a         T" ~
/+ 07 +/ "    2     a         T" ~
/+ 08 +/ "          a      T###" ~
/+ 09 +/ "          a      T#1 " ~
/+ 10 +/ "T         a       # X";

enum level19 =
/+       "0         1         2" +/
/+       "012345678901234567890" +/
/+ 00 +/ "ooooooooooooooooooooo" ~
/+ 01 +/ "o                   o" ~
/+ 02 +/ "o P               X o" ~
/+ 03 +/ "o                   o" ~
/+ 04 +/ "oooooooooooooooooo  o" ~
/+ 05 +/ "o T T T T T T T T T o" ~
/+ 06 +/ "o                   o" ~
/+ 07 +/ "o         a         o" ~
/+ 08 +/ "ooo               ooo" ~
/+ 09 +/ "a o               o a" ~
/+ 10 +/ "T1o1T           T2o2T";

enum level20 =
/+       "0         1         2" +/
/+       "012345678901234567890" +/
/+ 00 +/ "ooooooooooooooooooooo" ~
/+ 01 +/ "o     ooooooooooooooo" ~
/+ 02 +/ "o  P  oo           oo" ~
/+ 03 +/ "o     oo    T T    oo" ~
/+ 04 +/ "oo   ooo  ooooooo  oo" ~
/+ 05 +/ "oo   ooo  ooooooo  oo" ~
/+ 06 +/ "oo   ooo  ooooooo  oo" ~
/+ 07 +/ "oo   ooo  ooooooo  oo" ~
/+ 08 +/ "oo        ooooooo  oo" ~
/+ 09 +/ "oo      a ooooo      " ~
/+ 10 +/ "oo        ooooo   X  ";

enum level21 =
/+       "0         1         2" +/
/+       "012345678901234567890" +/
/+ 00 +/ "                     " ~
/+ 01 +/ " a        P          " ~
/+ 02 +/ "                     " ~
/+ 03 +/ "        TTTTT        " ~
/+ 04 +/ "        T###T        " ~
/+ 05 +/ "  oooo  T#H#T  oooo  " ~
/+ 06 +/ "        T###T        " ~
/+ 07 +/ "        TTTTT        " ~
/+ 08 +/ "                     " ~
/+ 09 +/ "          X        a " ~
/+ 10 +/ "                     ";

enum level22 =
/+       "0         1         2" +/
/+       "012345678901234567890" +/
/+ 00 +/ "          o          " ~
/+ 01 +/ " a        X        a " ~
/+ 02 +/ "          o          " ~
/+ 03 +/ "        TTTTT        " ~
/+ 04 +/ "        T###T        " ~
/+ 05 +/ "  oooo  T#H#T  oooo  " ~
/+ 06 +/ "        T###T        " ~
/+ 07 +/ "        TTTTT        " ~
/+ 08 +/ "          o          " ~
/+ 09 +/ " a        P        a " ~
/+ 10 +/ "          o          ";

enum level23 =
/+       "0         1         2" +/
/+       "012345678901234567890" +/
/+ 00 +/ "          o          " ~
/+ 01 +/ " a    o   P   o    a " ~
/+ 02 +/ "       o  o  o       " ~
/+ 03 +/ "        TTTTT        " ~
/+ 04 +/ "        T###T        " ~
/+ 05 +/ "  oooo  T#H#T  oooo  " ~
/+ 06 +/ "        T###T        " ~
/+ 07 +/ "        TTTTT        " ~
/+ 08 +/ "       o  o  o       " ~
/+ 09 +/ " a    o   X   o    a " ~
/+ 10 +/ "          o          ";

enum level24 =
/+       "0         1         2" +/
/+       "012345678901234567890" +/
/+ 00 +/ "          o          " ~
/+ 01 +/ "      o       o      " ~
/+ 02 +/ "       o  o  o       " ~
/+ 03 +/ "        TTTTT        " ~
/+ 04 +/ "        T# #T        " ~
/+ 05 +/ "  oooo  T H T  oooo  " ~
/+ 06 +/ "        T# #T        " ~
/+ 07 +/ "        TTTTT        " ~
/+ 08 +/ "       o  o  o       " ~
/+ 09 +/ "      o   P   o      " ~
/+ 10 +/ "          o          ";

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
	"Level 12: ABC — as in: Apple Bobbing Challenge",
	"Level 13: Cruel Chambers",
	"Level 14: Lonely Lanes",
	"Level 15: Ancient Altar (another alliteration)",
	"Level 16: Haunted House",
	"Level 17: Watch out! Hungry turtles ahead.",
	"Level 18: Turtle Terror",
	"Level 19: At the End of the World — Where turtles can walk on holes.",
	"Level 20: Forward to the Past",
	"Boss Stage",
	"Boss Stage [Phase 2]",
	"Boss Stage [Phase 3]",
	"Boss Stage [Phase 4]",
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
	/* 12 */ Region.gras,
	/* 13 */ Region.volc,
	/* 14 */ Region.dirt,
	/* 15 */ Region.gras,
	/* 16 */ Region.snow,
	/* 17 */ Region.dirt,
	/* 18 */ Region.gras,
	/* 19 */ Region.volc,
	/* 20 */ Region.volc,
	/* 20 */ Region.boss,
	/* 21 */ Region.boss,
	/* 22 */ Region.boss,
	/* 23 */ Region.boss,
	/* 24 */ Region.boss,
];
// dfmt on

enum levelsTotal = 24;
enum firstLevel = 1;
enum guideLevel = 1;
enum bossLevel = 21;
