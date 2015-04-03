// InputStation, a graphical front-end for generating game controller
// configuration files.
// Created by Florian Mueller <contact@petrockblock.com>.
// Based on the work of "Aloshi" Lofquist.

#include <SDL.h>
#include <iostream>
#include <iomanip>
#include "Renderer.h"
#include <boost/filesystem.hpp>
#include "guis/GuiDetectDevice.h"
#include "guis/GuiMsgBox.h"
#include "Log.h"
#include "Window.h"
#include "InputStation.h"
#include "Settings.h"
#include <sstream>
#include <boost/locale.hpp>

namespace fs = boost::filesystem;

bool scrape_cmdline = false;

bool parseArgs(int argc, char *argv[], unsigned int *width,
        unsigned int *height) {
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "--resolution") == 0) {
            if (i >= argc - 2) {
                std::cerr << "Invalid resolution supplied.";
                return false;
            }

            *width = atoi(argv[i + 1]);
            *height = atoi(argv[i + 2]);
            i += 2; // skip the argument value
        } else if (strcmp(argv[i], "--gamelist-only") == 0) {
            Settings::getInstance()->setBool("ParseGamelistOnly", true);
        } else if (strcmp(argv[i], "--ignore-gamelist") == 0) {
            Settings::getInstance()->setBool("IgnoreGamelist", true);
        } else if (strcmp(argv[i], "--draw-framerate") == 0) {
            Settings::getInstance()->setBool("DrawFramerate", true);
        } else if (strcmp(argv[i], "--no-exit") == 0) {
            Settings::getInstance()->setBool("ShowExit", false);
        } else if (strcmp(argv[i], "--debug") == 0) {
            Settings::getInstance()->setBool("Debug", true);
            Settings::getInstance()->setBool("HideConsole", false);
            Log::setReportingLevel (LogDebug);
        } else if (strcmp(argv[i], "--windowed") == 0) {
            Settings::getInstance()->setBool("Windowed", true);
        } else if (strcmp(argv[i], "--vsync") == 0) {
            bool vsync =
                    (strcmp(argv[i + 1], "on") == 0
                            || strcmp(argv[i + 1], "1") == 0) ? true : false;
            Settings::getInstance()->setBool("VSync", vsync);
            i++; // skip vsync value
        } else if (strcmp(argv[i], "--scrape") == 0) {
            scrape_cmdline = true;
        } else if (strcmp(argv[i], "--help") == 0
                || strcmp(argv[i], "-h") == 0) {
            std::cout
                    << "EmulationStation, a graphical front-end for ROM browsing.\n"
                            "Written by Alec \"Aloshi\" Lofquist.\n"
                            "Version " << PROGRAM_VERSION_STRING << ", built "
                    << PROGRAM_BUILT_STRING
                    << "\n\n"
                            "Command line arguments:\n"
                            "--resolution [width] [height]  try and force a particular "
                            "resolution\n"
                            "--gamelist-only            skip automatic game search, only read "
                            "from gamelist.xml\n"
                            "--ignore-gamelist      ignore the gamelist (useful for "
                            "troubleshooting)\n"
                            "--draw-framerate       display the framerate\n"
                            "--no-exit          don't show the exit option in the menu\n"
                            "--debug                more logging, show console on Windows\n"
                            "--scrape           scrape using command line interface\n"
                            "--windowed         not fullscreen, should be used with "
                            "--resolution\n"
                            "--vsync [1/on or 0/off]        turn vsync on or off (default is "
                            "on)\n"
                            "--help, -h         summon a sentient, angry tuba\n\n"
                            "More information available in README.md.\n";
            return false; // exit after printing help
        }
    }

    return true;
}

// called on exit, assuming we get far enough to have the log initialized
void onExit() {
    Log::close();
}

int main(int argc, char *argv[]) {
    unsigned int width = 0;
    unsigned int height = 0;

    std::locale::global(boost::locale::generator().generate(""));
    boost::filesystem::path::imbue(std::locale());

    if (!parseArgs(argc, argv, &width, &height))
        return 0;

    // start the logger
    Log::open();
    LOG(LogInfo) << "InputStation - v" << PROGRAM_VERSION_STRING << ", built "
            << PROGRAM_BUILT_STRING;

    // always close the log on exit
    atexit(&onExit);

    Window window;

    if (!window.init(width, height)) {
        LOG(LogError) << "Window failed to initialize!";
        return 1;
    }

    std::string glExts = (const char *) glGetString(GL_EXTENSIONS);
    LOG(LogInfo) << "Checking available OpenGL extensions...";
    LOG(LogInfo) << " ARB_texture_non_power_of_two: "
            << (glExts.find("ARB_texture_non_power_of_two")
                    != std::string::npos ? "ok" : "MISSING");

    const char *errorMsg = NULL;

    // dont generate joystick events while we're loading (hopefully fixes
    // "automatically started emulator" bug)
    SDL_JoystickEventState (SDL_DISABLE);

    if (errorMsg == NULL) {
        window.pushGui(new GuiDetectDevice(&window, true, [] {}));
    }

    // generate joystick events since we're done loading
    SDL_JoystickEventState (SDL_ENABLE);

    int lastTime = SDL_GetTicks();
    bool running = true;

    while (running) {
        SDL_Event event;
        while (SDL_PollEvent(&event)) {
            switch (event.type) {
            case SDL_JOYHATMOTION:
            case SDL_JOYBUTTONDOWN:
            case SDL_JOYBUTTONUP:
            case SDL_KEYDOWN:
            case SDL_KEYUP:
            case SDL_JOYAXISMOTION:
            case SDL_TEXTINPUT:
            case SDL_TEXTEDITING:
            case SDL_JOYDEVICEADDED:
            case SDL_JOYDEVICEREMOVED:
                InputManager::getInstance()->parseEvent(event, &window);
                break;
            case SDL_QUIT:
                running = false;
                break;
            }
        }

        if (window.isSleeping()) {
            lastTime = SDL_GetTicks();
            SDL_Delay(1); // this doesn't need to be accurate, we're just giving up
                          // our CPU time until something wakes us up
            continue;
        }

        int curTime = SDL_GetTicks();
        int deltaTime = curTime - lastTime;
        lastTime = curTime;

        // cap deltaTime at 1000
        if (deltaTime > 1000 || deltaTime < 0)
            deltaTime = 1000;

        window.update(deltaTime);
        window.render();
        Renderer::swapBuffers();

        Log::flush();
    }

    window.deinit();

    LOG(LogInfo) << "InputStation cleanly shutting down.";

    return 0;
}
