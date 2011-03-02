MACRO (GET_PLATFORM_DETAILS OSNAME ARCH)
    IF(UNIX)
        EXECUTE_PROCESS (
            COMMAND uname -a 
            OUTPUT_VARIABLE OUT 
            RESULT_VARIABLE out_return
            OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_STRIP_TRAILING_WHITESPACE
            )
        SEPARATE_ARGUMENTS (OUT)
        LIST (GET OUT 0 ${OSNAME})

        IF (${OSNAME} STREQUAL "Linux")
            LIST (GET OUT 11 arch)
            IF (${arch} STREQUAL "x86_64")
                SET (${ARCH} "64")
            ELSE (${arch} STREQUAL "x86_64")
                SET (${ARCH} "32")
            ENDIF (${arch} STREQUAL "x86_64")

        ENDIF (${OSNAME} STREQUAL "Linux")
	ELSE (UNIX)
		SET (${OSNAME} "Windows")
		IF (CMAKE_CL_64)
			SET (${ARCH} "64")
		ELSE (CMAKE_CL_64)
			SET (${OSNAME} "32")
		ENDIF (CMAKE_CL_64)
    ENDIF(UNIX)

ENDMACRO (GET_PLATFORM_DETAILS)
