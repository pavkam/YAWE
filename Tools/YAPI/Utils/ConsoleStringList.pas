{
  This file is a part of YAWE Project. (c) 2006 YAWE Project.
  You can redestribute it under GPLv2 License.

  Initial Developer: Pavkam
}

unit ConsoleStringList;
interface
uses
  Classes;
  
type
 TConsoleStringList = class(TStringList)
  public
    function Add(const S: string): Integer; override;
  end;

implementation

{ ConsoleStringList }

function TConsoleStringList.Add(const S: string): Integer;
begin
 Result := inherited Add(S);
 WriteLn(S);
end;

end.
