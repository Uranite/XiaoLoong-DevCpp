{
    This file is part of Dev-C++
    Copyright (c) 2004 Bloodshed Software

    Dev-C++ is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    Dev-C++ is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Dev-C++; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
}

unit Version;

{$MODE Delphi}

interface

//path delimiter
const
{$IFDEF MSWINDOWS}
  pd = '\';
{$ELSE}
  pd = '/';
{$ENDIF}

  // exe properties
  DEVCPP = 'Dev-C++';
  DEVCPP_VERSION = '7.0';   //2026-09-08

  // delimiters
  DEV_INTERNAL_OPEN = '$__DEV_INTERNAL_OPEN';

  // config file names
  DEV_CODEINS_FILE = 'codeinsertion.ini';
  DEV_DEFAULTCODE_FILE = 'defaultcode.ini';
  DEV_TOOLS_FILE = 'tools.ini';
  //DEV_LINKER_FILE = 'autolink.ini';

  DEV_SHORTCUTS_FILE = 'shortcuts.ini';
  DEV_CLASSFOLDERS_FILE = 'classfolders.ini';  //useless
  DEV_WEBMIRRORS_FILE = 'webmirrors.ini';   //useless


  // make stuff
  DEV_MAKE_FILE = 'Makefile.mk';

  // themes
  DEV_GNOME_THEME = 'Gnome';
  DEV_NEWLOOK_THEME = 'Outline';
  DEV_MODERM_THEME = 'Modern';
  DEV_INTERNAL_THEME = 'Modern';

  LANGUAGE_DIR = 'Lang' + pd;
  ICON_DIR = 'Icons' + pd;
  HELP_DIR = 'Help' + pd;
  TEMPLATE_DIR = 'Templates' + pd;
  THEME_DIR = 'Themes' + pd;
  PACKAGES_DIR = 'Packages' + pd;

  // file extensions
  LIB_EXT = '.a';
  OBJ_EXT = '.o';
  DLL_EXT = '.dll';
  EXE_EXT = '.exe';
  DEV_EXT = '.dev';
  HTML_EXT = '.html';
  RTF_EXT = '.rtf';
  TEX_EXT = '.tex';
  INI_EXT = '.ini';
  TEMPLATE_EXT = '.devt';
  COLORS_EXT = '.colors';
  C_EXT = '.c';
  CPP_EXT = '.cpp';
  CC_EXT = '.cc';
  CXX_EXT = '.cxx';
  CP2_EXT = '.c++';
  CP_EXT = '.cp';
  H_EXT = '.h';
  HPP_EXT = '.hpp';
  RC_EXT = '.rc';
  RES_EXT = '.res';
  RH_EXT = '.rh';
  GCH_EXT = '.gch'; // precompiled header
  DEF_EXT = '.def'; // definitions file

  // program defaults
  {$IFDEF MSWINDOWS}
  MAKE_PROGRAM = 'mingw32-make.exe';
  GCC_PROGRAM = 'gcc.exe';
  GPP_PROGRAM = 'g++.exe';
  GDB_PROGRAM = 'gdb.exe';
  GDB32_PROGRAM = 'gdb32.exe';
  WINDRES_PROGRAM = 'windres.exe';
  GPROF_PROGRAM = 'gprof.exe';
  PACKMAN_PROGRAM = 'packman.exe';
  CLEAN_PROGRAM = 'del /q'; // delete file in quiet mode
  {$ELSE}
  // On Linux/macOS the tools ship without the .exe suffix.
  MAKE_PROGRAM = 'make';
  GCC_PROGRAM = 'gcc';
  GPP_PROGRAM = 'g++';
  GDB_PROGRAM = 'gdb';
  GDB32_PROGRAM = 'gdb32';   // 32-bit gdb is rarely present off Windows
  WINDRES_PROGRAM = 'windres';
  GPROF_PROGRAM = 'gprof';
  PACKMAN_PROGRAM = 'packman'; // MinGW package manager; irrelevant off Windows
  CLEAN_PROGRAM = 'rm -f';     // delete file in quiet mode
  {$ENDIF}

  // File dialog filters
  FLT_ALLFILES = 'All files (*.*)|*.*|';
  FLT_TEXTS = 'Text files (*.txt)|*.txt';
  FLT_LIBRARIES = 'Libraries (*.lib;*.a)|*.lib;*.a';
  FLT_PROJECTS = 'Dev-C++ project (*.dev)|*.dev';
  FLT_HEADS = 'Header files (*.h;*.hpp;*.rh;*.hh)|*.h;*.hpp;*.rh;*.hh';
  FLT_CS = 'C source files (*.c)|*.c';
  FLT_CPPS = 'C++ source files (*.cpp;*.cc;*.cxx;*.c++;*.cp)|*.cpp;*.cc;*.cxx;*.c++;*.cp';
  FLT_RES = 'Resource scripts (*.rc)|*.rc';
  FLT_MSVCPROJECTS = 'MS Visual C++ projects (*.dsp)|*.dsp';
  FLT_CBPROJECTS = 'Code::Blocks projects (*.cbp)|*.cbp';
  FLT_FORTRAN = 'FORTRAN files(*.f90;*.f95;*f77;*.for;*.f)|*.f90;*.f95;*.f77;*.for;*.f';

  // GPROF commands and displays
  GPROF_CHECKFILE = 'gmon.out';
  GPROF_CMD_GENFLAT = '-p';
  GPROF_CMD_GENMAP = '-q';

implementation

end.

