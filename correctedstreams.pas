{*****************************************************************************

 Author : Frédéric Libaud (http://www.libaudfrederic.fr

 Version : 1.0

 History:
 2017 09 30 - 1.0 - First version
                    Implementation of corrected Position property
                    Implementation of EOF property and
                    GoToStart/GoToEnd method

 *****************************************************************************}
unit correctedstreams;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

const
  soStart  = 0;
  soEnd    = -1;

type
  { TCorrectedFileStream }

  {
    This class is provided for Position property bug correction
    and TFileStream extensions.

    In LCL (Lazarus 1.2.6), property Position doesn't work correctly
    and make bug like SIGSEV.
   }
  TCorrectedFileStream = class(TFileStream)
    private
      function GetPosition: integer;
      procedure SetPosition(const aPosition: integer);
      function GetEOF: boolean;
      procedure SetEOF(const aEOF: boolean);
    public
      procedure GoToStart;
      procedure GoToEnd;
      function MoveTo(const aOffset: Int64; aOrigin: TSeekOrigin): Int64;
      property Position: integer read GetPosition write SetPosition;
      property EOF: boolean read GetEOF write SetEOF;
  end;

  { TCorrectedFileStream }

implementation

{ TCorrectedFileStream }

function TCorrectedFileStream.GetPosition: integer;
begin
  try
    Result:= Seek(0, soCurrent);
  except
    Result:= Size;
  end;
end;

procedure TCorrectedFileStream.SetPosition(const aPosition: integer);
begin
  if aPosition < Size then
    Seek(aPosition, soFromBeginning)
  else
    Seek(0, soFromEnd);
end;

procedure TCorrectedFileStream.GoToStart;
begin
  if Size > 0 then
    Seek(0, soFromBeginning);
end;

procedure TCorrectedFileStream.GoToEnd;
begin
  if Size > 0 then
    Seek(0, soFromEnd);
end;

function TCorrectedFileStream.GetEOF: boolean;
begin
  if Size > 0 then
  begin
  if seek(0, soCurrent) >= Size then
    Result:= true
  else
    Result:= false;
  end
  else
    Result:= true;
end;

procedure TCorrectedFileStream.SetEOF(const aEOF: boolean);
begin
  if aEOF then
    GotoEnd;
end;

function TCorrectedFileStream.MoveTo(const aOffset: Int64; aOrigin: TSeekOrigin): Int64;
var
  _Size: int64;
begin
  _Size:= Size;
  if (aOffset >= 0) and (aOffset <= _Size) then
    Result:= Seek(aOffset, aOrigin)
  else
    Result:= Seek(0, soCurrent);
end;

{ TCorrectedFileStream }

end.

