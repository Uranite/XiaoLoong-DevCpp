unit devShortcuts;

interface

uses
{$IFDEF MSWINDOWS}
  Windows, Messages,
{$ENDIF}
  SysUtils, Classes, Menus, Controls, IniFiles, Graphics, ActnList;



implementation

{
procedure Register;
begin
  RegisterComponents('Dev-C++', [TdevShortcuts]);
end;
}

end.
