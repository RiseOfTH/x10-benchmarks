
SRCS	:= SSCA2.x10 runtime_consts.x10 types.x10 defs.x10 util.x10 genScaleData.x10 computeGraph.x10 getStartLists.x10 findSubGraphs.x10


NATIVE_HDR	:= $(PWD)/sprng2.0/sprng.h
NATIVE_LIB	:= $(PWD)/sprng2.0/lib/libsprng.a
NATIVE_INC	:= 
NATIVE_COMM_HDR := 
XRX_INC         := 

all: smp-dbg smp-opt


smp-dbg: ${SRCS}
	${X10CXX} -x10rt ${X10RTTRANSPORT} ${X10CXXFLAGS} -d ${OUTDIR} ${SRCS} \
		-post '${POSTCOMPILE_CXX} ${POSTCOMPILE_INCLUDEOPT}${NATIVE_HDR} ${POSTCOMPILE_CXXFLAGS} -g -DTRANSPORT=${PGASTRANSPORT} # ${NATIVE_SRC}  # ${POSTCOMPILE_LDFLAGS} ${POSTCOMPILE_LIBS} ${NATIVE_LIB}' 

smp-opt: ${SRCS}
	${X10CXX} -x10rt ${X10RTTRANSPORT} ${X10CXXFLAGS} -d ${OUTDIR} ${SRCS} \
		-post '${POSTCOMPILE_CXX} ${POSTCOMPILE_INCLUDEOPT}${NATIVE_HDR} ${POSTCOMPILE_CXXFLAGS} ${POSTCOMPILE_OPTFLAGS} -DTRANSPORT=${PGASTRANSPORT} # ${NATIVE_SRC}  # ${POSTCOMPILE_LDFLAGS} ${POSTCOMPILE_LIBS} ${NATIVE_LIB}' 

clean:
	$(MAKE) -C $(PWD)/sprng2.0 clean
