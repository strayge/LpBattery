unit uSettings;

interface

uses IniFiles;

var
  path: string;
  fileSettings: String='settings.ini';
  alpha,x,y,width,height,battery_minimum: Integer;
  ini: TIniFile;
  sound1enable: Integer;
  sound1percent:Integer;
  sound1file:   string;
  showText:Boolean;
  showMainWindow: Boolean;

procedure LoadSettings();
procedure SaveSettings();

implementation

procedure LoadSettings();
begin
  ini:=TIniFile.Create(path+fileSettings);
  alpha:=ini.ReadInteger('main','alpha',200);
  x:=ini.ReadInteger('main','x',400);
  y:=ini.ReadInteger('main','y',200);
  width:=ini.ReadInteger('main','width',121);
  height:=ini.ReadInteger('main','height',13);
  battery_minimum:=ini.ReadInteger('main','battery_minimum',0);
  showMainWindow:=ini.ReadBool('main','show',true);

  sound1enable:=ini.ReadInteger('sound1','sound1enable',0);
  sound1percent:=ini.ReadInteger('sound1','sound1percent',30);
  sound1file:=ini.ReadString('sound1','sound1file','');

  showText:=ini.ReadBool('text','show',true);

  ini.Free;
end;

procedure SaveSettings();
begin
  ini:=TIniFile.Create(path+fileSettings);
  ini.WriteInteger('main','alpha',alpha);
  ini.WriteInteger('main','x',x);
  ini.WriteInteger('main','y',y);
  ini.WriteInteger('main','width',width);
  ini.WriteInteger('main','height',height);
  ini.WriteInteger('main','battery_minimum',battery_minimum);
  ini.WriteBool('main','show',showMainWindow);

  ini.WriteInteger('sound1','sound1enable',sound1enable);
  ini.WriteInteger('sound1','sound1percent',sound1percent);
  ini.WriteString('sound1','sound1file',sound1file);

  ini.WriteBool('text','show',showText);

  ini.Free;
end;

end.
