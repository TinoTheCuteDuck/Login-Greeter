cmake_minimum_required(VERSION 3.20)

project(
		LoginGreeter
		VERSION 0.1
		LANGUAGES CXX
)


# ----------------------------
# C++ configuration
# ----------------------------


set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# MSVC runtime
if(MSVC)
	set(CMAKE_MSVC_RUNTIME_LIBRARY
			"MultiThreaded$<$<CONFIG:Debug>:Debug>"
	)
endif()


# ----------------------------
# Build options
# ----------------------------


option(
		PRODUCTION_BUILD
		"Build production version"
		OFF
)


# ----------------------------
# Dependencies
# ----------------------------


add_subdirectory(src/lib/json)


# ----------------------------
# Sources
# ----------------------------


file(GLOB_RECURSE QML_FILES
	CONFIGURE_DEPENDS
	RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
	qml/*.qml
)

list(
	FILTER QML_FILES EXCLUDE REGEX
	"${CMAKE_CURRENT_SOURCE_DIR}/src/lib/.*"
)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick Concurrent Multimedia)
find_package(Qt6 REQUIRED COMPONENTS Gui Core5Compat)

qt_policy(SET QTP0001 NEW)
qt_standard_project_setup()

qt_add_executable(
	LoginGreeter
	src/main.cpp
	src/backend.cpp
	src/backend.h
)

set_source_files_properties(
    qml/Colors.qml
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE
)

qt_add_qml_module(
    LoginGreeter
    URI MainQML
    VERSION 1.0
    QML_FILES
        ${QML_FILES}
	RESOURCES
		assets/background.png
		assets/background-ambient.wav
		assets/typing.wav
		assets/fadeInOut.wav
		assets/error.wav
		assets/success.wav
		assets/click.wav
)

target_link_libraries(
	LoginGreeter
	PRIVATE 
	Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
	Qt6::Core5Compat
	Qt6::Concurrent
	Qt6::Multimedia
	json
)

set_source_files_properties(
	qml/Colors.qml
	PROPERTIES QT_QML_SINGLETON_TYPE TRUE
)


# ----------------------------
# Defines
# ----------------------------


target_compile_definitions(
		LoginGreeter
		PRIVATE
		_CRT_SECURE_NO_WARNINGS
)


if(PRODUCTION_BUILD)

	target_compile_definitions(
			LoginGreeter
			PRIVATE
			PRODUCTION_BUILD=1
			DEVELOPMENT_BUILD=0
	)

else()

	target_compile_definitions(
			LoginGreeter
			PRIVATE
			PRODUCTION_BUILD=0
			DEVELOPMENT_BUILD=1
	)

endif()


# ----------------------------
# Compiler warnings
# ----------------------------


if(MSVC)

	target_compile_options(
			LoginGreeter
			PRIVATE
			/W4
	)

else()

	target_compile_options(
			LoginGreeter
			PRIVATE
			-Wall
			-Wextra
			-Wpedantic
	)

endif()


# ----------------------------
# Optimizations
# ----------------------------


if(PRODUCTION_BUILD)

	include(CheckIPOSupported)

	check_ipo_supported(
			RESULT ipo_supported
	)

	if(ipo_supported)
		set_target_properties(
				LoginGreeter
				PROPERTIES
				INTERPROCEDURAL_OPTIMIZATION TRUE
		)
	endif()

endif()