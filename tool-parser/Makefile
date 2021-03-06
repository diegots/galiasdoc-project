# GaliasDoc: information extraction from PDF sources with common templates
# Copyright (C) 2021 Diego Trabazo Sardón
#
# This file is part of GaliasDoc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>

APP := parser
MAIN := main
LIB := lib
PLUGIN := plugin

DEL_EXT_PLUGIN := $(addprefix $(PLUGIN)/,*.output *.tab.c *.tab.h *.yy.c)
DEL_EXT_MAIN := $(addprefix $(MAIN)/,*.o)
DEL_EXT_ROOT := $(addprefix ,*.o *.so)

PLUGIN_DEPS := $(addprefix $(MAIN)/,bison-prologue bison-epilogue flex-prologue gen gen-amount)
PLUGIN_OBJS := $(notdir $(basename $(wildcard $(PLUGIN)/*.y)))

LIB_OBJS := $(patsubst %c, %o, $(wildcard $(LIB)/*.c))
#MAIN_OBJS := $(patsubst %c, %o, $(wildcard $(MAIN)/gen.c))
MAIN_OBJS := $(MAIN)/gen.o $(MAIN)/gen-amount.o

INCLUDE_DIRS = $(PLUGIN) $(LIB) $(MAIN)
INCLUDE = $(addprefix -I, $(INCLUDE_DIRS))

CFLAGS += -Wall -g -lpcre2-8 $(INCLUDE) # full warnings + debug symbols
#CFLAGS += -Wall -g -DDEBUG_LEXER $(INCLUDE) # full warnings + debug symbols + Flex PRINT calls
#CFLAGS += $(INCLUDE) # For production

all: $(APP) plugin

$(APP): $(LIB_OBJS) $(MAIN_OBJS)
	@echo
	@echo '----> Main app'
	gcc -g -rdynamic $(MAIN)/$(MAIN).c -o $@ $^ -ldl -Wl,-rpath,./ $(CFLAGS)

plugin: $(PLUGIN_DEPS) $(PLUGIN_OBJS)

$(PLUGIN_OBJS):
	@echo
	@echo '----> Plugin' $@
	bison -d -y -Wno-yacc -d -r all -o $(PLUGIN)/$@.tab.c $(PLUGIN)/$@.y
	flex -o $(PLUGIN)/$@.yy.c $(PLUGIN)/$@.l # with -d flex prints debug info
	gcc -fPIC -c $(PLUGIN)/$@.tab.c $(INCLUDE) $(CFLAGS)
	gcc -fPIC -c $(PLUGIN)/$@.yy.c $(INCLUDE) $(CFLAGS)
	gcc -o $@.so -shared bison-epilogue.o flex-prologue.o $@.tab.o $@.yy.o $(CFLAGS)

$(PLUGIN_DEPS):
	@echo
	@echo '----> Plugin deps' $@
	gcc -fPIC -c $@.c $(CFLAGS)


clean:
	rm -fv $(APP) $(LIB_OBJS) $(DEL_EXT_PLUGIN) $(DEL_EXT_MAIN) $(DEL_EXT_ROOT)

.PHONY: all plugin clean
