#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <windows.h>

int main(int argc, char* argv[]) {
    char cmdLine[8192] = "\"C:\\Program Files (x86)\\Microsoft Visual Studio\\Installer\\vswhere_orig.exe\"";
    
    int hasProducts = 0;
    for (int i = 1; i < argc; i++) {
        if (strstr(argv[i], "-products") != NULL) {
            hasProducts = 1;
        }
    }
    
    for (int i = 1; i < argc; i++) {
        strcat(cmdLine, " ");
        strcat(cmdLine, "\"");
        strcat(cmdLine, argv[i]);
        strcat(cmdLine, "\"");
    }
    
    if (!hasProducts) {
        strcat(cmdLine, " -products *");
    }
    
    STARTUPINFOA si;
    PROCESS_INFORMATION pi;
    ZeroMemory(&si, sizeof(si));
    si.cb = sizeof(si);
    ZeroMemory(&pi, sizeof(pi));
    
    if (CreateProcessA(NULL, cmdLine, NULL, NULL, TRUE, 0, NULL, NULL, &si, &pi)) {
        WaitForSingleObject(pi.hProcess, INFINITE);
        DWORD exitCode = 0;
        GetExitCodeProcess(pi.hProcess, &exitCode);
        CloseHandle(pi.hProcess);
        CloseHandle(pi.hThread);
        return exitCode;
    }
    
    return 1;
}
