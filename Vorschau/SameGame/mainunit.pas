unit MainUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs;

type
  // Hilfsdatentyp
  TSpielfeld = array [ 0..19, 0..14 ] of Byte;

  { TMainForm }

  TMainForm = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormPaint(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
    Spielfeld : TSpielfeld;

    procedure NeuesSpiel();
    procedure Render();

    function LoescheFeld( X, Y : Byte; var Feld : TSpielfeld ) : Integer;
    procedure Komprimiere();
  public
    { public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  NeuesSpiel();
end;

procedure TMainForm.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  FeldX, FeldY : Byte;
  TmpFeld : TSpielfeld;
begin
  // Sicherstellen, dass kein Bug auftritt!
  if ( X > 639 ) or ( X < 0 ) then Exit;
  if ( Y > 479 ) or ( Y < 0 ) then Exit;

  FeldX := X div 32;
  FeldY := Y div 32;

  TmpFeld := Spielfeld;

  if LoescheFeld( FeldX, FeldY, TmpFeld ) < 2 then Exit;

  LoescheFeld( FeldX, FeldY, Spielfeld );
  Komprimiere();
  Refresh();
end;

procedure TMainForm.FormPaint(Sender: TObject);
begin
  Render();
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  Render();
end;

procedure TMainForm.NeuesSpiel();
var
  X, Y : Byte;
begin
  Randomize(); // Zufallsgenerator starten

  for X := 0 to 19 do
  begin
    for Y := 0 to 14 do
    begin
      Spielfeld[ X, Y ] := Random( 3 ) + 1; // Eine Zahl zwischen 1 und 3 erzeugen
    end;
  end;
end;

procedure TMainForm.Render();
var
  X, Y : Byte;
begin
  for Y := 0 to 14 do
  begin
    for X := 0 to 19 do
    begin
      // Anhand des Spielfeldes ein Feld zeichnen
      case Spielfeld[ X, Y ] of
        0:
        begin
          Canvas.Pen.Color := clBtnFace;
          Canvas.Brush.Color := clBtnFace;
        end;

        1:
        begin
          Canvas.Pen.Color := clBlack;
          Canvas.Brush.Color := clRed;
        end;

        2:
        begin
          Canvas.Pen.Color := clBlack;
          Canvas.Brush.Color := clBlue;
        end;

        3:
        begin
          Canvas.Pen.Color := clBlack;
          Canvas.Brush.Color := clLime;
        end;
      end;

      Canvas.Rectangle( X * 32, Y * 32, X * 32 + 32, Y * 32 + 32 );
    end;
  end;
end;

function TMainForm.LoescheFeld( X, Y : Byte; var Feld : TSpielfeld ) : Integer;
var
  Wert : Byte;
begin
  Result := 0;

  // Wert des zu löschenden Feldes speichern
  Wert := Feld[ X, Y ];

  // Das Feld löschen
  Feld[ X, Y ] := 0;

  // Ist der Wert gültig? (Endlosschleife vermeiden!)
  if Wert = 0 then Exit;

  // Es wurde ein gültiges Feld gefunden.
  Result := 1;

  // Ist es möglich ein Feld nach Rechts zu gehen? Und stimmt das Feld überein?
  if ( X < 19 ) and ( Feld[ X + 1, Y ] = Wert ) then
  begin
    // Jopp. Suche von dort aus weiter ...
    Result := Result + LoescheFeld( X + 1, Y, Feld );
  end;

  // Ist es möglich ein Feld nach Links zu gehen? Und stimmt das Feld überein?
  if ( X > 0 ) and ( Feld[ X - 1, Y ] = Wert ) then
  begin
    // Jopp. Suche von dort aus weiter ...
    Result := Result + LoescheFeld( X - 1, Y, Feld );
  end;

  // Ist es möglich ein Feld nach Unten zu gehen? Und stimmt das Feld überein?
  if ( Y < 19 ) and ( Feld[ X, Y + 1 ] = Wert ) then
  begin
    // Jopp. Suche von dort aus weiter ...
    Result := Result + LoescheFeld( X, Y + 1, Feld );
  end;

  // Ist es möglich ein Feld nach Oben zu gehen? Und stimmt das Feld überein?
  if ( Y > 0 ) and ( Feld[ X, Y - 1 ] = Wert ) then
  begin
    // Jopp. Suche von dort aus weiter ...
    Result := Result + LoescheFeld( X, Y - 1, Feld );
  end;
end;

procedure TMainForm.Komprimiere();
var
  X, Y : Byte;
  Fertig : Boolean;
begin
  // Erstmal alle Steine nach unten bewegen ...
  Fertig := False;
  while not Fertig do
  begin
    // Tun wir mal so, als würde ein Durchlauf reichen ...
    Fertig := True;

    // Unten links anfangen zu suchen ...
    for Y := 14 downto 1 do
    begin
      for X := 0 to 19 do
      begin

        // Ist das Feld frei, während direkt darüber ein Feld besetzt ist?
        if ( Spielfeld[ X, Y ] = 0 ) and ( Spielfeld[ X, Y - 1 ] <> 0 ) then
        begin
          // Verschiebe das Feld nach unten
          Spielfeld[ X, Y ] := Spielfeld[ X, Y - 1 ];
          Spielfeld[ X, Y - 1 ] := 0;
          Fertig := False;
        end;
      end;
    end;

    // Kurz warten, damit der Spieler das auch sehen kann ...
    Refresh();
    Sleep( 100 );
  end;

  // Nun alle freien Spalten nach links bewegen ...
  Fertig := False;
  while not Fertig do
  begin
    // Tun wir mal so, als würde ein Durchlauf reichen ...
    Fertig := True;

    // Unten links anfangen zu suchen ...
    for X := 0 to 18 do
    begin
      // Ist das Feld frei, während direkt daneben ein Feld besetzt ist?
      if ( Spielfeld[ X, 14 ] = 0 ) and ( Spielfeld[ X + 1, 14 ] <> 0 ) then
      begin

        // Verschiebe die Spalte nach links
        for Y := 0 to 14 do
        begin
          Spielfeld[ X, Y ] := Spielfeld[ X + 1, Y ];
          Spielfeld[ X + 1, Y ] := 0;
          Fertig := False;
        end;
      end;
    end;

    // Kurz warten, damit der Spieler das auch sehen kann ...
    Refresh();
    Sleep( 100 );
  end;
end;

end.

