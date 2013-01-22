// LpBattery
// Version: 0.4
// Author: Str@y
//
// Version history
// 0.4 - ported to Lazarus
// 0.3 - fixed bug with PopupMenu
// 0.2 - added settings
// 0.1 - first version

program LpBattery;

uses
  Forms, Interfaces,
  Unit1 in 'Unit1.pas' {Form1},
  frmSettings in 'frmSettings.pas' {Form2},
  uSettings in 'uSettings.pas';

{$R *.res}
{$R LpBatteryResource.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := False;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
