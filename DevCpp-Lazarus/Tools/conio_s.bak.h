/**
 * This file has no copyright assigned and is placed in the Public Domain.
 * This file is part of the mingw-w64 runtime package.
 * No warranty is given; refer to the file DISCLAIMER.PD within this package.
 */

#ifndef _INC_CONIO_S
#define _INC_CONIO_S

#include <conio.h>

#if defined(MINGW_HAS_SECURE_API)

#ifdef __cplusplus
extern "C" {
#endif

_CRTIMP errno_t __cdecl _cgets_s (char *_Buffer, size_t _Size, size_t *_SizeRead);
__DEFINE_CPP_OVERLOAD_SECURE_FUNC_0_1(errno_t, _cgets_s, char, _Buffer, size_t *, _SizeRead)

_CRTIMP int __cdecl _cprintf_s (const char *_Format, ...);
_CRTIMP int __cdecl _cscanf_s(const char *_Format, ...);
_CRTIMP int __cdecl _cscanf_s_l(const char *_Format, _locale_t _Locale, ...);
_CRTIMP int __cdecl _vcprintf_s (const char *_Format, va_list _ArgList);
_CRTIMP int __cdecl _cprintf_s_l (const char *_Format, _locale_t _Locale, ...);
_CRTIMP int __cdecl _vcprintf_s_l (const char *_Format, _locale_t _Locale, va_list _ArgList);

#ifndef _WCONIO_DEFINED_S
#define _WCONIO_DEFINED_S
_CRTIMP errno_t __cdecl _cgetws_s (wchar_t *_Buffer, size_t _SizeInWords, size_t *_SizeRead);
__DEFINE_CPP_OVERLOAD_SECURE_FUNC_0_1(errno_t, _cgetws_s, wchar_t, _Buffer, size_t *, _SizeRead)

_CRTIMP int __cdecl _cwprintf_s (const wchar_t *_Format, ...);
_CRTIMP int __cdecl _cwscanf_s(const wchar_t *_Format, ...);
_CRTIMP int __cdecl _cwscanf_s_l(const wchar_t *_Format, _locale_t _Locale, ...);
_CRTIMP int __cdecl _vcwprintf_s (const wchar_t *_Format, va_list _ArgList);
_CRTIMP int __cdecl _cwprintf_s_l (const wchar_t *_Format, _locale_t _Locale, ...);
_CRTIMP int __cdecl _vcwprintf_s_l (const wchar_t *_Format, _locale_t _Locale, va_list _ArgList);
#endif

#ifdef __cplusplus
}
#endif

#endif


// The following compatible functions to Borland 'conio.h' are written by Anbang LI, 2021

//#if defined(_INC_CONIO) || defined(_CONIO_H_)
//#error can not include "conio.h" before "graphics.h"
//#endif
#ifndef _INC_WINDOWS
#include "windows.h"
#endif

void windowtitle(const char *title) {	//set the title of window;
	SetConsoleTitle(title);
}

void windowsize(short width, short height) {	//set window size (-1 to restore)
	static int firstrun = 1, wid = 0, hgt = 0;
	HANDLE hdout = GetStdHandle(STD_OUTPUT_HANDLE);
	CONSOLE_SCREEN_BUFFER_INFO csbi;
	GetConsoleScreenBufferInfo(hdout, &csbi);
	if (firstrun) {
		wid = csbi.dwSize.X;
		hgt = csbi.dwSize.Y;
		firstrun = 0;
	}
	width = (width == -1 ? wid : width);
	height = (height == -1 ? hgt : height);
	COORD size = {width, height};
	SetConsoleScreenBufferSize(hdout, size);
	SMALL_RECT rc = {0, 0, width, height};
	SetConsoleWindowInfo(hdout, 1, &rc);
	//CloseHandle(hdout);
}


void fontsize(int size) {	//set font size
//https://stackoverflow.com/questions/36590430/in-windows-does-setcurrentconsolefontex-change-consoles-font-size
	static int firstrun  = 1, sz = 0;
	HANDLE hcsb = GetStdHandle(STD_OUTPUT_HANDLE);	//handle to the current console
	CONSOLE_FONT_INFOEX cfi = {sizeof(cfi)}; 	//current font info
	GetCurrentConsoleFontEx(hcsb, FALSE, &cfi);
	cfi.nFont = 0;
	//cfi.FontFamily = TMPF_VECTOR;
	//cfo.FontWeight = 200;
	//wcscpy(cfi.FaceName, "Courier");
	if (firstrun) {
		sz = cfi.dwFontSize.X * 2;
		firstrun = 0;
	}
	size = (size == -1 ? sz : size);
	cfi.dwFontSize.X = size / 2;
	cfi.dwFontSize.Y = cfi.dwFontSize.X * 2 * 9 / 8;
	SetCurrentConsoleFontEx(hcsb, FALSE, &cfi);	//set the screen buffer's new font
}

void clrscr(void) {		//clear screen
	HANDLE hOutPut = GetStdHandle(STD_OUTPUT_HANDLE);
	CONSOLE_SCREEN_BUFFER_INFO csbi;
	GetConsoleScreenBufferInfo(hOutPut, &csbi);
	COORD pos = {0, 0};
	DWORD num;
	FillConsoleOutputCharacter(hOutPut, ' ', (csbi.dwSize.X * csbi.dwSize.Y), pos, &num);
	// https://docs.microsoft.com/zh-cn/windows/console/fillconsoleoutputcharacter
	SetConsoleCursorPosition(hOutPut, pos);
	// https://docs.microsoft.com/zh-cn/windows/console/setconsolecursorposition
}

void delay (int tm) {	//delay some time (in ms)
	Sleep(tm);
}

void gotoxy(short x, short y) {		//goto coordinate (x, y)
	COORD pos = {x, y};
	HANDLE hOut = GetStdHandle(STD_OUTPUT_HANDLE);
	SetConsoleCursorPosition(hOut, pos);
}

void showcursor(bool stat = 1) { //show or hide cursor (stat: 1-show, 0-hide£©
	CONSOLE_CURSOR_INFO cursor_info = {20, stat};
	SetConsoleCursorInfo(GetStdHandle(STD_OUTPUT_HANDLE), &cursor_info);
}
//Note: don't confused with function "ShowCursor" in windows.h. It behaves quite different.

void hidecursor() { 		//hide cursor
	CONSOLE_CURSOR_INFO cursor_info = {20, 0};
	SetConsoleCursorInfo(GetStdHandle(STD_OUTPUT_HANDLE), &cursor_info);
}


enum COLORS {BLACK, BLUE, GREEN, CYAN, RED, MAGENTA, BROWN, LIGHTGRAY, DARKGRAY,
             LIGHTBLUE, LIGHTGREEN, LIGHTCYAN, LIGHTRED, LIGHTMAGENTA, YELLOW, WHITE,
             BLINK = 128
            };

void textcolor(int forecolor, int backcolor = -1) { //set text color
	static short int firstrun = 1, back = 0, fore = 0;
	HANDLE hOut = GetStdHandle(STD_OUTPUT_HANDLE);
	CONSOLE_SCREEN_BUFFER_INFO csbi;
	GetConsoleScreenBufferInfo(hOut, &csbi);

	if (firstrun) {	//first run, save original colors
		//high 4 bits of scr.wAttributes is background color; low 4 bits is foreground color.
		//keep previous background color and set new foreground color.
		fore = csbi.wAttributes % 16;
		back = csbi.wAttributes / 16 * 16;
		firstrun = 0;
	}
	backcolor = (backcolor == -1 ? back : backcolor % 16 * 16);
	forecolor = (forecolor == -1 ? fore : forecolor % 16);
	SetConsoleTextAttribute(hOut, backcolor | forecolor);
}

void textbackground(int backcolor) {	//set text background color
	static short int firstrun = 1, back = 0;
	HANDLE hOut = GetStdHandle(STD_OUTPUT_HANDLE);
	CONSOLE_SCREEN_BUFFER_INFO csbr;
	GetConsoleScreenBufferInfo(hOut, &csbr);
	if (firstrun) {
		back = csbr.wAttributes / 16 * 16;
		firstrun = 0;
	}
	backcolor = (backcolor == -1 ? back : backcolor % 16 * 16);
	SetConsoleTextAttribute(hOut, backcolor | (csbr.wAttributes % 16));

}

#endif

