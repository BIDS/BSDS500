#flex -P__cfl_ -s -o$@ $<

CXX = g++ -g -O3 -Wall
#specify 64-bit architecture (for macos)
#CXX = g++ -g -O3 -Wall -arch x86_64
IFLAGS = -Iutil -Igroup -Ipartition 
LFLAGS = -lm -ljpeg
F90FLAGS = -lgfortran -llapack -lblas 

#######################################################################################333

UTILOBJS = util/configFileLexer.o util/configure.o util/exception.o util/random.o util/regex.o \
						util/string.o util/timer.o util/util.o util/kmeans.o util/image.o util/message.o util/segmentation.o

OBJS = ic.o affinity.o smatrix.o 

#######################################################################################333

.SUFFIXES : .o .cc 

.cc.o:
	${CXX} -fPIC -c ${IFLAGS} -o $@ -x c++ $<

#######################################################################################333

all: buildW.mexglx

#######################################################################################333

buildW.mexglx: util/libutil.a
	matlab -nodisplay -nojvm -r "mex buildW.cpp -Iutil smatrix.cc ic.cc affinity.cc util/libutil.a; exit"

#######################################################################################

util/libutil.a: ${UTILOBJS} 
	rm -f util/libutil.a && ar cr util/libutil.a $(UTILOBJS) && ranlib util/libutil.a

#######################################################################################333

clean :
	rm -f util/*.a
	rm -f *.o util/*.o
	rm -f *~ util/*~ 

