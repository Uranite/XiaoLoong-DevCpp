/*********************************************************************
DevCppPortable is a shell program to run command "DevCpp -c config".
It must be compiled with  MinGW32  instead of MinGW-w64.
*********************************************************************/

#include <windows.h>
#include <Shlwapi.h>
#include <string>
using std::wstring;

int main(int argc, char *argv[]) {
	std::string ArgToDev = "-c config ";	//"-c .\\config ";
	for (int i = 1; i < argc; i++) {	//extra parameters
		ArgToDev += '\"';
		ArgToDev += argv[i];
		ArgToDev += '\"';
		if (i != argc - 1) {
			ArgToDev += ' ';
		}
	}

	// Run "devcpp.exe" from the current directory
	char CurrentDirectory[32768]; // NTFS max length
	GetModuleFileName(NULL, CurrentDirectory, 32768); // get full file path with filename
	PathRemoveFileSpec(CurrentDirectory); // remove filename

	// Attempt to execute
	int Result = (INT_PTR)ShellExecute(
	                 NULL, // no parent window
	                 "open", // open the file
	                 "devcpp.exe", // the executable file to open
	                 ArgToDev.c_str(), // extra parameters to pass
	                 CurrentDirectory, // use the current directory
	                 SW_SHOWNORMAL // activate and display window
	             );
	if (Result <= 32) {
		switch (Result) {
			case ERROR_FILE_NOT_FOUND: {
				MessageBoxW(NULL, L"devcpp.exe", L"File not found", MB_OK);
				break;
			}
			default: {
				MessageBoxW(NULL, L"An unspecified error has occured!", L"Error", MB_OK);
				break;
			}
		}
	}
	return 0;
}
