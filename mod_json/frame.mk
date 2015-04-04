##
##   Copyright (C) RainVan(Yunfeng.Xiao). All rights reserved.
##
##   \file     frame.mk
##   \author   RainVan (Yunfeng.Xiao)
##   \date     Oct 2013
##   \version  1.0.0
##   \brief    Generic GNU Makefile for C/C++ Program
##

## The following variables used by user's Makefile: 
##   TARGETS              (MUST)      e.g. libxxx.a libxxx.so xxx ...
##   TARGETS_BUILD.DIR    (OPTION)    e.g. ./build
##   TARGETS_BIN.DIR      (OPTION)    e.g. ./bin ...
##   TARGETS_LIB.DIR      (OPTION)    e.g. ./lib ...
##   TARGETS_CFLAGS       (OPTION)    e.g. -fPIC ...
##   TARGETS_LDFLAGS      (OPTION)    e.g. -fPIC ...
##   TARGETS_INCS         (OPTION)    e.g. ./include ...
##   TARGETS_LIBS         (OPTION)    e.g. -Ldir1 -llib1 ...
##   TARGET_DIRS          (MUST)      e.g. dir1 dir2 dir3 ...
##   <TARGET>_CFLAGS      (OPTION)    e.g. -fPIC ...
##   <TARGET>_LDFLAGS     (OPTION)    e.g. -fPIC ...
##   <TARGET>_SRCS        (MUST)      e.g. *.c *.cc *.cpp ...
##   <TARGET>_INCS        (OPTION)    e.g. ./include ...
##   <TARGET>_LIBS        (OPTION)    e.g. -Ldir1 -llib1 ...
##   <TARGET>_DEPS        (OPTION)    e.g. libxxx.so / dir1 ...

# export those variables
export BIN.DIR   ?= $(CURDIR)/bin
export LIB.DIR   ?= $(CURDIR)/lib
export BUILD.DIR ?= $(CURDIR)/build

# color of display
RED    := \033[1m\033[31m
GREEN  := \033[1m\033[32m
YELLOW := \033[1m\033[33m
BLUE   := \033[1m\033[34m
PURPLE := \033[1m\033[35m
CYAN   := \033[1m\033[36m
BOLD   := \033[1m
RESET  := \033[0m

# default application
AR  := ar -rc
CC  := cc
CXX := c++
RM  := rm -f
MD  := mkdir -p
INS := install
ifneq ($(shell echo -e ""), )
  ECHO := echo
else
  ECHO := echo -e
endif

# C/C++ flags
CFLAGS += -pipe -Wall -Wextra -Wshadow
CXXFLAGS += -pipe -Wall -Wextra -Wshadow
LDFLAGS += -pipe

# extension filter
EXTS ?= .c .cc .cpp .cxx .c++ .C

# function for running command in verbose mode
define RUN_COMMAND_VERBOSE
  $(ECHO) "$$(strip $1)"; \
  RES=`$$(strip $1) 2>&1`; \
  RET=$$$$?; \
  if [ ! "$$$$RES" = "" ]; then \
    $(ECHO) "$(RED)$$$$RES$(RESET)"; \
  fi; \
  if [ $$$$RET -ne 0 ]; then \
    exit $$$$RET; \
  fi
endef

# function for running command in silent mode
define RUN_COMMAND_SILENT
  RES=`$$(strip $1) 2>&1`; \
  RET=$$$$?; \
  if [ ! "$$$$RES" = "" ]; then \
    $(ECHO) "$(PURPLE)$$(strip $1)$(RESET)"; \
    $(ECHO) "$(RED)$$$$RES$(RESET)"; \
  fi; \
  if [ $$$$RET -ne 0 ]; then \
    exit $$$$RET; \
  fi
endef

# function for running command (eval)
define RUN_COMMAND
  if [ "$(VERBOSE)" != "" ] && [ "$(VERBOSE)" != "0" ]; then \
    $(call RUN_COMMAND_VERBOSE, $1); \
  else \
    $(call RUN_COMMAND_SILENT, $1); \
  fi
endef

# function for printing message
define MESSAGE
  $(ECHO) "$(BOLD)$(strip $1)$(RESET)"
endef

# function for compiling C file
define COMPILE_C_FILE
  $(call MESSAGE, Compiling C file $(GREEN)$(strip $1)); \
  $(call RUN_COMMAND, $(CC) -MMD -c $$(CFLAGS) $1 -o $2)
endef

# function for compiling C++ file
define COMPILE_CXX_FILE
  $(call MESSAGE, Compiling C++ file $(GREEN)$(strip $1)); \
  $(call RUN_COMMAND, $(CXX) -MMD -c $$(CXXFLAGS) $1 -o $2)
endef

# function for linking executable program
define LINK_EXEC_PROGRAM
  $(call MESSAGE, Linking executable program $(YELLOW)$(strip $1)); \
  $(call RUN_COMMAND, $$(LD) $2 $$(LDFLAGS) -o $1)
endef

# function for linking shared library
define LINK_SHARED_LIBRARY
  $(call MESSAGE, Linking shared library $(YELLOW)$(strip $1)); \
  $(call RUN_COMMAND, $$(LD) $2 $$(LDFLAGS) -shared -o $1)
endef

# function for linking static library
define LINK_STATIC_LIBRARY
  $(call MESSAGE, Linking static library $(YELLOW)$(strip $1)); \
  $(call RUN_COMMAND, $(AR) $1 $2)
endef

# function for creating dir
define CREATE_DIR
  if [ ! -d $1 ]; then \
    $(call MESSAGE, Creating directory $(BLUE)$(strip $1)); \
    $(call RUN_COMMAND, $(MD) $1); \
  fi
endef

# function for removing dir
define REMOVE_DIR
  if [ -d $1 ]; then \
    $(call MESSAGE, Removing directory $(BLUE)$(strip $1)); \
    $(call RUN_COMMAND, $(RM) -r $1); \
  fi
endef

# function for installing dir
define INSTALL_DIR
  if [ ! -d $1 ]; then \
    $(call MESSAGE, Installing directory $(BLUE)$(strip $1)); \
    $(call RUN_COMMAND, $(INS) -d $1); \
  fi
endef

# function for installing dirs
define INSTALL_DIRS
  $(foreach x, $1, $(call INSTALL_DIR, $x);)
endef

# function for installing file
define INSTALL_FILE
  $(call RUN_COMMAND, $(INS) -m $3 $1 $2)
endef

# function for uninstalling file
define UNINSTALL_FILE
  $(call RUN_COMMAND, $(RM) $(strip $2)/$(strip $1))
endef

# function for installing executable program
define INSTALL_EXEC_PROGRAM
  $(call MESSAGE, Installing executable program $(CYAN)$(strip $1)); \
  $(foreach x, $2, $(call INSTALL_FILE, $1, $x, 755);)
endef

# function for uninstalling executable program
define UNINSTALL_EXEC_PROGRAM
  $(call MESSAGE, Uninstalling executable program $(CYAN)$(strip $1)); \
  $(foreach x, $2, $(call UNINSTALL_FILE, $1, $x);)
endef

# function for installing shared library
define INSTALL_SHARED_LIBRARY
  $(call MESSAGE, Installing shared library $(CYAN)$(strip $1)); \
  $(foreach x, $2, $(call INSTALL_FILE, $1, $x, 755);)
endef

# function for uninstalling shared library
define UNINSTALL_SHARED_LIBRARY
  $(call MESSAGE, Uninstalling shared library $(CYAN)$(strip $1)); \
  $(foreach x, $2, $(call UNINSTALL_FILE, $1, $x);)
endef

# function for installing static library
define INSTALL_STATIC_LIBRARY
  $(call MESSAGE, Installing static library $(CYAN)$(strip $1)); \
  $(foreach x, $2, $(call INSTALL_FILE, $1, $x, 644);)
endef

# function for uninstalling static library
define UNINSTALL_STATIC_LIBRARY
  $(call MESSAGE, Uninstalling static library $(CYAN)$(strip $1)); \
  $(foreach x, $2, $(call UNINSTALL_FILE, $1, $x);)
endef

# function for cleanning up executable program
define CLEANUP_EXEC_PROGRAM
  if [ -f $1 ]; then \
    $(call MESSAGE, Removing executable program $(CYAN)$(strip $1)); \
    $(call RUN_COMMAND, $(RM) $1); \
  fi; \
  if [ -f $(strip $1).exe ]; then \
    $(call MESSAGE, Removing executable program $(CYAN)$(strip $1).exe); \
    $(call RUN_COMMAND, $(RM) $(strip $1).exe); \
  fi; \
  $(call REMOVE_DIR, $(strip $1).d)
endef

# function for cleanning up shared library
define CLEANUP_SHARED_LIBRARY
  if [ -f $1 ]; then \
    $(call MESSAGE, Removing shared library $(CYAN)$(strip $1)); \
    $(call RUN_COMMAND, $(RM) $1); \
  fi; \
  $(call REMOVE_DIR, $(strip $1).d)
endef

# function for cleanning up static library
define CLEANUP_STATIC_LIBRARY
  if [ -f $1 ]; then \
    $(call MESSAGE, Removing static library $(CYAN)$(strip $1)); \
    $(call RUN_COMMAND, $(RM) $1); \
  fi; \
  $(call REMOVE_DIR, $(strip $1).d)
endef

# function for detecting shared library
define IS_SHARED_LIBRARY
  $(filter %.so, $1)$(findstring .so., $1)
endef

# function for detecting static library
define IS_STATIC_LIBRARY
  $(filter %.a, $1)
endef

# function for defining sources
define DEFINE_SOURCES
  $(foreach x, $(EXTS), $(filter %$x, $1))
endef

# function for defining targets
define DEFINE_TARGETS
  $(strip $2).clean    :
	@$(call CLEANUP_$(strip $1), $(strip $(BUILD.DIR))/$(strip $2))
  $(strip $2).coverage : CFLAGS += -g -O0 --coverage
  $(strip $2).coverage : CXXFLAGS += -g -O0 --coverage
  $(strip $2).coverage : LDFLAGS += --coverage
  $(strip $2).debug    : CFLAGS += -g
  $(strip $2).debug    : CXXFLAGS += -g
  $(strip $2).release  : CFLAGS += -O2 -DNDEBUG
  $(strip $2).release  : CXXFLAGS += -O2 -DNDEBUG
  all      : $(strip $2).all
  clean    : $(strip $2).clean
  coverage : $(strip $2).coverage
  debug    : $(strip $2).debug
  rebuild  : $(strip $2).clean $(strip $2).all
  release  : $(strip $2).release
  $(addprefix $2, .all .coverage .debug .release) : \
    $(strip $(BUILD.DIR))/$(strip $2)
  $(strip $(BUILD.DIR))/$(strip $2) : \
    $(patsubst %, \
      $(strip $(BUILD.DIR))/$(strip $2).d/%.o, \
      $(call DEFINE_SOURCES, $3) \
    )
	@$(call CREATE_DIR, $$(@D))
	@$(call LINK_$(strip $1), $$@, $$^)
endef

# function for defining compiles
define DEFINE_COMPILES
$(strip $(BUILD.DIR))/$(strip $1).d/%.c.o : %.c
	@$(call CREATE_DIR, $$(@D))
	@$(call COMPILE_C_FILE, $$<, $$@)
$(strip $(BUILD.DIR))/$(strip $1).d/%.cc.o : %.cc
	@$(call CREATE_DIR, $$(@D))
	@$(call COMPILE_CXX_FILE, $$<, $$@)
$(strip $(BUILD.DIR))/$(strip $1).d/%.cpp.o : %.cpp
	@$(call CREATE_DIR, $$(@D))
	@$(call COMPILE_CXX_FILE, $$<, $$@)
$(strip $(BUILD.DIR))/$(strip $1).d/%.cxx.o : %.cxx
	@$(call CREATE_DIR, $$(@D))
	@$(call COMPILE_CXX_FILE, $$<, $$@)
$(strip $(BUILD.DIR))/$(strip $1).d/%.c++.o : %.c++
	@$(call CREATE_DIR, $$(@D))
	@$(call COMPILE_CXX_FILE, $$<, $$@)
$(strip $(BUILD.DIR))/$(strip $1).d/%.C.o : %.C
	@$(call CREATE_DIR, $$(@D))
	@$(call COMPILE_CXX_FILE, $$<, $$@)
endef

# function for defining target compiler flags
define DEFINE_CFLAGS
  $(strip $(BUILD.DIR))/$(strip $1) : CFLAGS += $2
  $(strip $(BUILD.DIR))/$(strip $1) : CXXFLAGS += $2
endef

# function for defining target linker flags
define DEFINE_LDFLAGS
  $(strip $(BUILD.DIR))/$(strip $1) : LDFLAGS += $2
endef

# function for defining target linker
define DEFINE_LINKER
  $(strip $(BUILD.DIR))/$(strip $1) : LD := \
    $(if $(filter-out %.c, $(call DEFINE_SOURCES, $2)), $(CXX), $(CC))
endef

# function for installing executable program
define DEFINE_EXEC_INSTALL
  install   : $(strip $1).install
  uninstall : $(strip $1).uninstall
  $(strip $1).install : $(strip $(BUILD.DIR))/$(strip $1)
  ifneq ($2, )
	@$(call INSTALL_DIRS, $2)
	@$(call INSTALL_EXEC_PROGRAM, $$<, $2)
  endif
  $(strip $1).uninstall :
  ifneq ($2, )
	@$(call UNINSTALL_EXEC_PROGRAM, $1, $2)
  endif
endef

# function for installing shared library
define DEFINE_SHARED_INSTALL
  install   : $(strip $1).install
  uninstall : $(strip $1).uninstall
  $(strip $1).install : $(strip $(BUILD.DIR))/$(strip $1)
  ifneq ($2, )
	@$(call INSTALL_DIRS, $2)
	@$(call INSTALL_SHARED_LIBRARY, $$<, $2)
  endif
  $(strip $1).uninstall :
  ifneq ($2, )
	@$(call UNINSTALL_SHARED_LIBRARY, $1, $2)
  endif
endef

# function for installing static library
define DEFINE_STATIC_INSTALL
  install   : $(strip $1).install
  uninstall : $(strip $1).uninstall
  $(strip $1).install : $(strip $(BUILD.DIR))/$(strip $1)
  ifneq ($2, )
	@$(call INSTALL_DIRS, $2)
	@$(call INSTALL_STATIC_LIBRARY, $$<, $2)
  endif
  $(strip $1).uninstall :
  ifneq ($2, )
	@$(call UNINSTALL_STATIC_LIBRARY, $1, $2)
  endif
endef

# function for defining auto install
define DEFINE_AUTO_INSTALL
  ifneq ($(call IS_STATIC_LIBRARY, $1), )
    $(call DEFINE_STATIC_INSTALL, $1, $(LIB.DIR))
  else
    ifneq ($(call IS_SHARED_LIBRARY, $1), )
      $(call DEFINE_SHARED_INSTALL, $1, $(LIB.DIR))
    else
      $(call DEFINE_EXEC_INSTALL, $1, $(BIN.DIR))
    endif
  endif
endef

# function for defining usage
define DEFINE_USAGE
  usage : $(strip $1).usage
  $(strip $1).usage :
	@$(ECHO) "... $(strip $1).*"
endef

# function for including depends
define INCLUDE_DEPENDS
  ifneq ($(call DEFINE_SOURCES, $2), )
    -include $(patsubst %, \
      $(strip $(BUILD.DIR))/$(strip $1).d/%.d, $(call DEFINE_SOURCES, $2) \
      )
  endif
endef

# function for defining executable program
define DEFINE_EXEC_PROGRAM
  $(call INCLUDE_DEPENDS, $1, $2)
  $(call DEFINE_COMPILES, $1)
  $(call DEFINE_LINKER, $1, $2)
  $(call DEFINE_CFLAGS, $1, $(addprefix -I, $3))
  $(call DEFINE_LDFLAGS, $1, $4)
  $(call DEFINE_TARGETS, EXEC_PROGRAM, $1, $2)
  $(call DEFINE_USAGE, $1)
endef

# function for defining shared library
define DEFINE_SHARED_LIBRARY
  $(call INCLUDE_DEPENDS, $1, $2)
  $(call DEFINE_COMPILES, $1)
  $(call DEFINE_LINKER, $1, $2)
  $(call DEFINE_CFLAGS, $1, -fPIC $(addprefix -I, $3)) 
  $(call DEFINE_LDFLAGS, $1, $4)
  $(call DEFINE_TARGETS, SHARED_LIBRARY, $1, $2)
  $(call DEFINE_USAGE, $1)
endef

# function for defining static library
define DEFINE_STATIC_LIBRARY
  $(call INCLUDE_DEPENDS, $1, $2)
  $(call DEFINE_COMPILES, $1)
  $(call DEFINE_CFLAGS, $1, $(addprefix -I, $3))
  $(call DEFINE_TARGETS, STATIC_LIBRARY, $1, $2)
  $(call DEFINE_USAGE, $1)
endef

# function for defining auto target
define DEFINE_AUTO_TARGET
  ifneq ($(call IS_STATIC_LIBRARY, $1), )
    $(call DEFINE_STATIC_LIBRARY, $1, $2, $3)
  else
    ifneq ($(call IS_SHARED_LIBRARY, $1), )
      $(call DEFINE_SHARED_LIBRARY, $1, $2, $3, $4)
    else
      $(call DEFINE_EXEC_PROGRAM, $1, $2, $3, $4)
    endif
  endif
endef

# function for defining target depends
define DEFINE_DEPENDS
  $(strip $1).all       : $(addsuffix .all, $2)
  $(strip $1).clean     : $(addsuffix .clean, $2)
  $(strip $1).coverage  : $(addsuffix .coverage, $2)
  $(strip $1).debug     : $(addsuffix .debug, $2)
  $(strip $1).install   : $(addsuffix .install, $2)
  $(strip $1).rebuild   : $(addsuffix .rebuild, $2)
  $(strip $1).release   : $(addsuffix .release, $2)
  $(strip $1).uninstall : $(addsuffix .uninstall, $2)
endef

# function for making executable program
define MAKE_EXEC
  $(eval $(call DEFINE_EXEC_PROGRAM, \
    $1, $(wildcard $2), $3, $4 \
  ))
endef

# function for making shared library
define MAKE_SHARED
  $(eval $(call DEFINE_SHARED_LIBRARY, \
    lib$(strip $1).so, $(wildcard $2), $3, $4 \
  ))
endef

# function for making static library
define MAKE_STATIC
  $(eval $(call DEFINE_STATIC_LIBRARY, \
    lib$(strip $1).a, $(wildcard $2), $3 \
  ))
endef

# function for making target
define MAKE_AUTO
  $(eval $(call DEFINE_AUTO_TARGET, $1, $(wildcard $2), $3, $4))
endef

# function for installing executable program
define MAKE_EXEC_INSTALL
  $(eval $(call DEFINE_EXEC_INSTALL, $1, $2))
endef

# function for installing shared library
define MAKE_SHARED_INSTALL
  $(eval $(call DEFINE_SHARED_INSTALL, $1, $2))
endef

# function for installing static library
define MAKE_STATIC_INSTALL
  $(eval $(call DEFINE_STATIC_INSTALL, $1, $2))
endef

# function for making install
define MAKE_INSTALL
  $(eval $(call DEFINE_AUTO_INSTALL, $1))
endef

# function for making depends
define MAKE_DEPENDS
  $(eval $(call DEFINE_DEPENDS, $1, $2))
endef

# function for making target compiler flags
define MAKE_CFLAGS
  $(eval $(call DEFINE_CFLAGS, $1, $2))
endef

# function for making target linker flags
define MAKE_LDFLAGS
  $(eval $(call DEFINE_LDFLAGS, $1, $2))
endef

# function for defining global compiler flags
define DEFINE_GLOBAL_CFLAGS
  CFLAGS += $1
  CXXFLAGS += $1
endef

# function for defining global linker flags
define DEFINE_GLOBAL_LDFLAGS
  LDFLAGS += $1
endef

# function for defining global build/binary/library dir
define DEFINE_GLOBAL_DIRS
  ifneq ($1, )
    BUILD.DIR := $1
  endif
  ifneq ($2, )
    BIN.DIR := $2
  endif
  ifneq ($3, )
    LIB.DIR := $3
  endif
endef

# function for making global compiler flags
define MAKE_GLOBAL_CFLAGS
  $(eval $(call DEFINE_GLOBAL_CFLAGS, $1))
endef

# function for making global linker flags
define MAKE_GLOBAL_LDFLAGS
  $(eval $(call DEFINE_GLOBAL_LDFLAGS, $1))
endef

# function for making global build/binary/library dir
define MAKE_GLOBAL_DIRS
  $(eval $(call DEFINE_GLOBAL_DIRS, $1, $2, $3))
endef

# function for defining dir's compiles
define DEFINE_DIR_COMPILES
  all       : $(strip $1).all
  clean     : $(strip $1).clean
  coverage  : $(strip $1).coverage
  debug     : $(strip $1).debug
  install   : $(strip $1).install
  rebuild   : $(strip $1).rebuild
  release   : $(strip $1).release
  uninstall : $(strip $1).uninstall
  $(strip $1).all : 
	+@$(MAKE) -C $1 all
  $(strip $1).clean : 
	+@$(MAKE) -C $1 clean
  $(strip $1).coverage : 
	+@$(MAKE) -C $1 coverage
  $(strip $1).debug : 
	+@$(MAKE) -C $1 debug
  $(strip $1).install : 
	+@$(MAKE) -C $1 install
  $(strip $1).rebuild : 
	+@$(MAKE) -C $1 rebuild
  $(strip $1).release : 
	+@$(MAKE) -C $1 release
  $(strip $1).uninstall : 
	+@$(MAKE) -C $1 uninstall
endef

# function for defining dir
define DEFINE_DIR
  $(call DEFINE_DIR_COMPILES, $1)
  $(call DEFINE_USAGE, $1)
endef

# function for making dir
define MAKE_DIR
  $(eval $(call DEFINE_DIR, $1, $2))
endef

.PHONY : all clean coverage debug help 
.PHONY : install release rebuild uninstall usage 

all   :
usage : help

help : 
	@$(ECHO) "The following are some of the valid targets for this Makefile:"
	@$(ECHO) "... all (the default if no target is provided)"
	@$(ECHO) "... clean"
	@$(ECHO) "... coverage"
	@$(ECHO) "... debug"
	@$(ECHO) "... help"
	@$(ECHO) "... install"
	@$(ECHO) "... rebuild"
	@$(ECHO) "... release"
	@$(ECHO) "... uninstall"
	@$(ECHO) "... usage"

$(call MAKE_GLOBAL_DIRS, \
  $(TARGETS_BUILD.DIR), $(TARGETS_BIN.DIR), $(TARGETS_LIB.DIR) \
  )

$(call MAKE_GLOBAL_CFLAGS, \
  $(TARGETS_CFLAGS) $(addprefix -I, $(TARGETS_INCS)) \
  )

$(call MAKE_GLOBAL_LDFLAGS, \
  $(TARGETS_LDFLAGS) -L$(BUILD.DIR) $(TARGETS_LIBS) \
  )

$(foreach x, $(TARGETS), \
  $(call MAKE_CFLAGS, $x, $($x_CFLAGS)) \
  $(call MAKE_LDFLAGS, $x, $($x_LDFLAGS)) \
  $(call MAKE_AUTO, $x, $($x_SRCS), $($x_INCS), $($x_LIBS)) \
  $(call MAKE_DEPENDS, $x, $($x_DEPS)) \
  $(call MAKE_INSTALL, $x) \
  )

$(foreach x, $(TARGET_DIRS), \
  $(call MAKE_DIR, $x) \
  $(call MAKE_DEPENDS, $x, $($x_DEPS)) \
  )

