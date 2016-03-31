#############################################################################
# Project directory structure.
#############################################################################

# build scripts directory
build_scripts_dir := scripts/build

# directory layout
bin_dir     := bin
depend_dir  := depend
include_dir := include
src_dir     := src
test_dir    := test
matlab_dir  := matlab
doc_dir     := doc

#############################################################################
# C++ compilation settings.
#############################################################################

# compiler
CXX := g++

# compilation settings - libraries to link
CXX_LINK := -ljpeg -lpng

# compilation settings - warning flags
CXX_WARN_BASIC := -ansi -Wall -Wno-long-long
CXX_WARN_EXTRA := -Wundef -Wpointer-arith -Wold-style-cast \
                  -Woverloaded-virtual -Wsign-promo
CXX_WARN  := $(CXX_WARN_BASIC) $(CXX_WARN_EXTRA)

# compilation settings - build flags
CXX_BUILD := -pthread -fexceptions -fPIC -O3 -rdynamic
#force 64 bit build (e.g. on macos)
#CXX_BUILD := -pthread -fexceptions -fPIC -O3 -rdynamic -arch x86_64

# compilation settings - all flags
CXX_FLAGS := $(CXX_WARN) $(CXX_BUILD)

# compilation settings - linker flags
CXX_LDFLAGS := $(CXX_FLAGS) $(CXX_LINK)

#############################################################################
# Matlab mex file compilation settings (only used if building mex files).
#############################################################################

# matlab mex file compilation settings - matlab path
#MATLAB_PATH := /Applications/MATLAB_R2010a.app/
MATLAB_PATH := /usr/sww/pkg/matlab-r2008a

# matlab mex file compilation settings - matlab architecture (32-bit machines)
#MATLAB_ARCH := glnx86
#MEX_EXTN := mexglx

# matlab mex file compilation settings - matlab architecture (64-bit machines)
MATLAB_ARCH := glnxa64
MEX_EXTN := mexa64

# osx file compilation settings
#MATLAB_ARCH := maci64
#MEX_EXTN := mexmaci64

# matlab mex file compilation settings - include path for mex header files
MEX_INCLUDE_PATH := $(MATLAB_PATH)/extern/include

# matlab mex file compilation settings - libraries to link
MEX_LINK := $(CXX_LINK) -lmx -lmex -lmat

# matlab mex file compilation settings - warning flags
MEX_WARN := $(CXX_WARN)

# matlab mex file compilation settings - build flags
MEX_BUILD := $(CXX_BUILD) -DMATLAB_MEX_FILE -D_GNU_SOURCE -DNDEBUG

# matlab mex file compilation settings - all flags
MEX_FLAGS := $(MEX_WARN) $(MEX_BUILD)

# matlab mex file compilation settings - linker flags
MEX_LDFLAGS := \
   $(MEX_FLAGS) -shared \
   -Wl,--version-script,"$(MATLAB_PATH)/extern/lib/$(MATLAB_ARCH)/mexFunction.map" \
   -Wl,--rpath-link,"$(MATLAB_PATH)/bin/$(MATLAB_ARCH)" \
   -L"$(MATLAB_PATH)/bin/$(MATLAB_ARCH)" $(MEX_LINK)

# osx matlab mex file compilation settings - linker flags
#MEX_LDFLAGS := \
#   $(MEX_FLAGS) -bundle \
#   -Wl,-exported_symbols_list,"$(MATLAB_PATH)/extern/lib/$(MATLAB_ARCH)/mexFunction.map" \
#   -L"$(MATLAB_PATH)/bin/$(MATLAB_ARCH)" $(MEX_LINK)


#############################################################################
# Documentation build settings (only used if generating documentation).

# doxygen c++ source code documentation generator
DOXYGEN := doxygen
