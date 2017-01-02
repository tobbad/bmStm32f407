#############################################################################
#
# Generic Makefile for C/C++ Program
#
# License: GPL (General Public License)
# Author:  whyglinux <whyglinux AT gmail DOT com>
# Date:    2006/03/04 (version 0.1)
#          2007/03/24 (version 0.2)
#          2007/04/09 (version 0.3)
#          2007/06/26 (version 0.4)
#          2008/04/05 (version 0.5)
#
# Description:
# ------------
# This is an easily customizable makefile template. The purpose is to
# provide an instant building environment for C/C++ programs.
#
# It searches all the C/C++ source files in the specified directories,
# makes dependencies, compiles and links to form an executable.
#
# Besides its default ability to build C/C++ programs which use only
# standard C/C++ libraries, you can customize the Makefile to build
# those using other libraries. Once done, without any changes you can
# then build programs using the same or less libraries, even if source
# files are renamed, added or removed. Therefore, it is particularly
# convenient to use it to build codes for experimental or study use.
#
# GNU make is expected to use the Makefile. Other versions of makes
# may or may not work.
#
# Usage:
# ------
# 1. Copy the Makefile to your program directory.
# 2. Customize in the "Customizable Section" only if necessary:
#    * to use non-standard C/C++ libraries, set pre-processor or compiler
#      options to <MY_CFLAGS> and linker ones to <MY_LIBS>
#      (See Makefile.gtk+-2.0 for an example)
#    * to search sources in more directories, set to <SRCDIRS>
#    * to specify your favorite program name, set to <PROGRAM>
# 3. Type make to start building your program.
#
# Make Target:
# ------------
# The Makefile provides the following targets to make:
#   $ make           compile and link
#   $ make NODEP=yes compile and link without generating dependencies
#   $ make objs      compile only (no linking)
#   $ make tags      create tags for Emacs editor
#   $ make ctags     create ctags for VI editor
#   $ make clean     clean objects and the executable file
#   $ make distclean clean objects, the executable and dependencies
#   $ make help      get the usage of the makefile
#
#===========================================================================

## Customizable Section: adapt those variables to suit your program.
##==========================================================================

# The pre-processor and compiler options.
MY_CFLAGS =

# The external libraries to link in.
EXT_LIBS   =

# The pre-processor options used by the cpp (man cpp for more).
CPPFLAGS  = -Wall

# The options used in linking as well as in any direct use of ld.
LDFLAGS   =

# Use the source from the expansion of 
# $(SRC_FOLDERS)/inc and 
#  $(SRC_FOLDERS)/src or... 
# SRC_FOLDERS = . lib/mylib

# ... use source from
SRCDIRS = src  
SRCDIRS += lib/src

# .. and headers from 
INCDIRS = inc 
INCDIRS += lib/inc 

# Folder keeping the linker file
LD_DIR   = ldscript

# Linker scripts
LD_FILE  = linker.ld

# Where the stuff should be build
BUILDDIR = build

# Where the final product(s) shall be put
BINARY = binary

# The executable file name.
# If not specified, current directory name or `a.out' will be used.
PROGRAM   = firmware

## Implicit Section: change the following only when necessary.
##==========================================================================

# The source file types (headers excluded).
# .c indicates C source files, and others C++ ones.
SRCEXTS = .c .C .cc .cpp .CPP .c++ .cxx .cp .s

# The header file types.
HDREXTS = .h .H .hh .hpp .HPP .h++ .hxx .hp

# How much optimization
OPTIMIZE=-O0

# The pre-processor and compiler options.
# Users can override those variables from the command line.
CFLAGS  = -g
CDIALECT=  -std=c99

CXXFLAGS  =  -g
CXXDIALECT=  -std=c++11

# Uncomment for cross compile
CROSS_COMPILE = arm-none-eabi-

# The C program compiler.
CC     = gcc

# The C++ program compiler.
CXX    = g++

# Generate libraries
ARCHIVE = ar

# Dump information of the binary-functions
SIZE = size

# Copy elf to other output format
CP = objcopy

# Copy elf to other output format
LD = ld

# Strip binaries
STRP = strip

# The command used to delete file
RM     = rm -f

# The command used to delete folders.
RMDIR  = rm -rf


ifneq ($(CROSS_COMPILE),) 
#
# Crosscompiler setting for cortex-M
# With hard floating point core
CFLAGS_CORTEX_M = -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=hard -fsingle-precision-constant -Wdouble-promotion
CFLAGS_MCU_f4 = $(CFLAGS_CORTEX_M) -mtune=cortex-m4 -mcpu=cortex-m4 -DMCU_SERIES_F4
CFLAGS_MCU_f7 = $(CFLAGS_CORTEX_M) -mtune=cortex-m7 -mcpu=cortex-m7 -DMCU_SERIES_F7
CFLAGS_MCU_l4 = $(CFLAGS_CORTEX_M) -mtune=cortex-m4 -mcpu=cortex-m4 -DMCU_SERIES_L4
CXXFLAGS +=  -fno-exceptions -fno-rtti

DEVICE = -DSTM32F407xx

CPPFLAGS += $(CFLAGS_MCU_f4) 
CPPFLAGS += $(DEVICE) 
CPPFLAGS += -DUSE_HAL_DRIVER

CFLAGS += -fdata-sections -ffunction-sections

# Linker flags
LDFLAGS += -static
LDFLAGS += --verbose
LDFLAGS += -Wl,-gc-sections 
LDFLAGS += -L $(LD_DIR) -T $(LD_FILE)
LDFLAGS += -Wl,-Map=$(BINARY)/$(@:.elf=.map),-cref
#LDFLAGS += --specs=nano.specs

endif

## Stable Section: usually no need to be changed. But you can add more.
##==========================================================================
SHELL   = /bin/bash

ifneq ($(SRC_FOLDERS),)
	# Use canonical structure
	SRCDIRS =$(foreach d,$(SRC_FOLDERS), $(d)/src)
	INCDIRS =$(foreach d,$(SRC_FOLDERS), $(d)/inc)
endif
SOURCES = $(foreach d,$(SRCDIRS),$(wildcard $(addprefix $(d)/*,$(SRCEXTS))))
HEADERS = $(foreach d,$(SRCDIRS),$(wildcard $(addprefix $(d)/*,$(HDREXTS))))
INCDIRSFLAG = $(foreach d,$(INCDIRS), -I$(d))
SRC_CXX = $(filter-out %.c,$(SOURCES))
OBJS    = $(foreach f,$(addsuffix .o, $(basename $(SOURCES))), $(BUILDDIR)/$(f))
OBJDIRS = $(foreach d,$(SRCDIRS), $(BUILDDIR)/$(d))
INT_LIBS = 

## Define some useful variables.
AR          = $(CROSS_COMPILE)$(ARCHIVE)
ASSEMBLER   = $(CROSS_COMPILE)$(AS) $(CFLAGS)
COMPILE.c   = $(CROSS_COMPILE)$(CC)  $(MY_CFLAGS) $(CFLAGS)   $(OPTIMIZE) $(CDIALECT)   $(CPPFLAGS) $(INCDIRSFLAG) -c
COMPILE.cxx = $(CROSS_COMPILE)$(CXX) $(MY_CFLAGS) $(CXXFLAGS) $(OPTIMIZE) $(CXXDIALECT) $(CPPFLAGS) $(INCDIRSFLAG) -c
LINK.c      = $(CROSS_COMPILE)$(CC)  $(MY_CFLAGS) $(CFLAGS)   $(OPTIMIZE) $(CDIALECT)   $(CPPFLAGS) $(LDFLAGS)
LINK.cxx    = $(CROSS_COMPILE)$(CXX) $(MY_CFLAGS) $(CXXFLAGS) $(OPTIMIZE) $(CXXDIALECT) $(CPPFLAGS) $(LDFLAGS)
COPY        = $(CROSS_COMPILE)$(CP) 
LINK        = $(CROSS_COMPILE)$(LD)
STRIP       = $(CROSS_COMPILE)$(STRP)

.PHONY: all objs  clean distclean help show bdir

# Delete the default suffixes
.SUFFIXES:

all: bdir $(PROGRAM).bin  $(PROGRAM).hex

# Rules for generating object files (.o).
#----------------------------------------
objs:$(OBJS)

$(BUILDDIR)/%.o:%.c
	$(COMPILE.c) $< -o $@

$(BUILDDIR)/%.o:%.C
	$(COMPILE.cxx) $< -o $@

$(BUILDDIR)/%.o:%.cc
	$(COMPILE.cxx) $< -o $@

$(BUILDDIR)/%.o:%.cpp
	$(COMPILE.cxx) $< -o $@

$(BUILDDIR)/%.o:%.CPP
	$(COMPILE.cxx) $< -o $@

$(BUILDDIR)/%.o:%.c++
	$(COMPILE.cxx) $< -o $@

$(BUILDDIR)/%.o:%.cp
	$(COMPILE.cxx) $< -o $@

$(BUILDDIR)/%.o:%.cxx
	$(COMPILE.cxx) $< -o $@

$(BUILDDIR)/%.o:%.s
	$(COMPILE.c) $< -o $@

# Rules for generating the build directory
#-------------------------------------
bdir:
	@mkdir -p $(OBJDIRS) $(BINARY)
	
	
# Rules for generating the executable.
#-------------------------------------
$(PROGRAM).elf:$(OBJS)
	# $(LINK) $(LDFLAGS) $(OBJS) -o $(BINARY)/$@ $(INT_LIBS) $(EXT_LIBS)
	$(LINK.c) $(OBJS) -o $(BINARY)/$@ $(INT_LIBS) $(EXT_LIBS)
	$(SIZE) $(BINARY)/$@

$(PROGRAM).bin:$(PROGRAM).elf
	$(COPY) -O binary $(BINARY)/$< $(BINARY)/$@

$(PROGRAM).hex:$(PROGRAM).elf
	$(COPY) -O ihex $(BINARY)/$< $(BINARY)/$@

clean:
	$(RMDIR) $(BUILDDIR) $(BINARY)

# Show help.
help:
	@echo 'Generic Makefile for C/C++ Programs (gcmakefile) version 0.5'
	@echo 'Copyright (C) 2007, 2008 whyglinux <whyglinux@hotmail.com>'
	@echo
	@echo 'Usage: make [TARGET]'
	@echo 'TARGETS:'
	@echo '  all       (=make) compile and link.'
	@echo '  objs      compile only (no linking).'
	@echo '  clean     clean objects and the executable file.'
	@echo '  distclean clean objects, the executable and dependencies.'
	@echo '  show      show variables (for debug use only).'
	@echo '  help      print this message.'
	@echo
	@echo 'Report bugs to <whyglinux AT gmail DOT com>.'

# Show variables (for debug use only.)
show:
	@echo 'PROGRAM     :' $(PROGRAM)
	@echo 'SRCDIRS     :' $(SRCDIRS)
	@echo 'HEADERS     :' $(HEADERS)
	@echo 'INCLUDS     :' $(INCDIRSFLAG)
	@echo 'OBJDIRS     :' $(OBJDIRS)
	@echo 'SOURCES     :' $(SOURCES)
	@echo 'SRC_CXX     :' $(SRC_CXX)
	@echo 'OBJS        :' $(OBJS)
	@echo 'COMPILE.c   :' $(COMPILE.c)
	@echo 'COMPILE.cxx :' $(COMPILE.cxx)
	@echo 'link.c      :' $(LINK.c)
	@echo 'link.cxx    :' $(LINK.cxx)

## End of the Makefile ##  Suggestions are welcome  ## All rights reserved ##
#############################################################################
