dlls        += ddrio-lua-bind
imps		+= ddrio lua53

deplibs_ddrio-lua-bind  := \
    ddrio \
    lua53 \

ldflags_ddrio-lua-bind      := \

libs_ddrio-lua-bind         := \
    util \

src_ddrio-lua-bind          := \
    ddrio-lua-bind.c \
