{
 Programmname: Befreiungsaufgabe
 Befreiungsaufgabe PS1 WS 2012

 Minesweeper in Pascal ohne GUI, nur Textausgabe.

 Author: Gerrit Paepcke
 Erstelldatum: 9.11.2012
 Bisherige Änderungen: keine
}

unit Ulogic;

interface
  function countNearBombs(x:Byte;y:Byte):Byte;
  function getTimeInSec:Double;
  procedure generateSpielfeld(bomb_count:Word);
  procedure unhideField(x:Byte;y:Byte);

  const
    CMin_X = 1; // Darf nicht Negativ sein und muss < CMax_X sein
    CMax_X = 8; // Getestetes Maximum = 35 (Führt sonst zu Darstellungsfehlern)
    CMin_Y = 1; // Darf nicht Negativ sein und muss < CMax_Y sein
    CMax_Y = 8; // Getestetes Maximum = 20 (Führt sonst zu Darstellungsfehlern)

  type
    TGroesse_X = CMin_X..CMax_X;
    TGroesse_Y = CMin_Y..CMax_Y;
    TFelddefinitionen = (fdFlagge_mBombe, fdFlagge_oBombe, fdBombe, fdAufgedeckt, fdVerborgen);
    // Original Definition musste angepasst werden, damit Flaggen wieder an- und abwählbar sind.
    // Mit der Definition aus der Aufgabenstellung konnte keine Unterscheidung stattfinden
    // zwischen Flaggen mit (fdFlagge_mBombe) und ohne Bombe (fdFlagge_oBombe).
    // Damit konnte der Originalzustand nicht wiederhergestellt werden beim abwählen der Flagge.

    TSpielfeld = array [TGroesse_X, TGroesse_Y] of TFelddefinitionen;

  var
    Spielfeld : TSpielfeld;

implementation

  uses
    SysUtils, Dos;

  function countNearBombs(x:Byte;y:Byte) : Byte;
  // Gibt die Anzahl an benachbarten Bomben des Feldes (x,y) zurück
  // param x : Byte = X Koordinate des Ursprungsfeldes
  // param y : Byte = Y Koordinate des Ursprungsfeldes
  // return Byte = Anzahl der Bomben

  begin
    countNearBombs := 0;

    if (x > CMin_X) and (y > CMin_Y) then
    begin
      if (Spielfeld[x-1,y-1] = fdBombe) or (Spielfeld[x-1,y-1] = fdFlagge_mBombe) then countNearBombs := countNearBombs+1;
    end;
    if (y > CMin_Y) then
    begin
      if (Spielfeld[x,y-1] = fdBombe) or (Spielfeld[x,y-1] = fdFlagge_mBombe) then countNearBombs := countNearBombs+1;
    end;
    if (x < CMax_X) and (y > CMin_Y) then
    begin
      if (Spielfeld[x+1,y-1] = fdBombe) or (Spielfeld[x+1,y-1] = fdFlagge_mBombe) then countNearBombs := countNearBombs+1;
    end;
    if (x < CMax_X) then
    begin
      if (Spielfeld[x+1,y] = fdBombe) or (Spielfeld[x+1,y] = fdFlagge_mBombe) then countNearBombs := countNearBombs+1;
    end;
    if (x < CMax_X) and (y < CMax_Y) then
    begin
      if (Spielfeld[x+1,y+1] = fdBombe) or (Spielfeld[x+1,y+1] = fdFlagge_mBombe) then countNearBombs := countNearBombs+1;
    end;
    if (y < CMax_Y) then
    begin
      if (Spielfeld[x,y+1] = fdBombe) or (Spielfeld[x,y+1] = fdFlagge_mBombe) then countNearBombs := countNearBombs+1;
    end;
    if (x > CMin_X) and (y < CMax_Y) then
    begin
      if (Spielfeld[x-1,y+1] = fdBombe) or (Spielfeld[x-1,y+1] = fdFlagge_mBombe) then countNearBombs := countNearBombs+1;
    end;
    if (x > CMin_X) then
    begin
      if (Spielfeld[x-1,y] = fdBombe) or (Spielfeld[x-1,y] = fdFlagge_mBombe) then countNearBombs := countNearBombs+1;
    end;
  end;

  function getTimeInSec() : Double;
  // Ermitteln des jetzigen Zeitpunktes
  // return Double = Gibt den Zeitpunkt in Sekunden zurück

  var
    hour,min,sec,ms:word;
  begin
    hour := 0;
    min := 0;
    sec := 0;
    ms := 0;

    gettime(hour,min,sec,ms);
    getTimeInSec := ((hour*3600.0+min*60.0+sec)*100.0+1.0*ms)/100;
  end;

  procedure generateSpielfeld(bomb_count:Word);
  // Erzeugen eines zufälligen Spielfeldes
  // param bomb_count : Word = Gibt an wie viele Bomben sich im Spielfeld befinden sollen
  // global Spielfeld[] = Wird hier initialisiert und zufällig mit Bomben bestückt

  var
    x,y,i : integer;
  begin
    Randomize;
    for x:=CMin_X to CMax_X do
    begin
      for y :=CMin_Y to CMax_Y do
      begin
        Spielfeld[x,y] := fdVerborgen;
      end;
    end;

    for i:=1 to bomb_count do
    begin
      repeat
        x := random(CMax_X)+CMin_X;
        y := random(CMax_Y)+CMin_Y;
      until Spielfeld[x,y] <> fdBombe; // Damit nicht zwei Bomben auf dem gleichen Feld platziert werden
      Spielfeld[x,y] := fdBombe;
    end;
  end;

  procedure unhideField(x:Byte;y:Byte);
  // Prüft den Inhalt eines Feldes. Wenn ein Feld = fdVergorgen oder fdFlagge_oBombe
  // wird rekursiv die Nachbarschaft abgefragt und aufgedeckt
  // Sofern ein Feld Bomben als Nachbarn hat, wird keine rekursive Abfrage gemacht.
  // param x : Byte = X Koordinate des Ursprungsfeldes
  // param y : Byte = Y Koordinate des Ursprungsfeldes

  var
    foundbomb : integer;
  begin
    if (Spielfeld[x,y] = fdVerborgen) or (Spielfeld[x,y] = fdFlagge_oBombe) then
    begin
      foundbomb := countNearBombs(x,y);
      Spielfeld[x,y] := fdAufgedeckt;

      if foundbomb = 0 then
      begin
        // Rekursiver Check der umliegenden Felder

        if (y > CMin_Y) then unhideField(x,y-1);
        if (y < CMax_Y) then unhideField(x,y+1);
        if (x < CMax_X) then unhideField(x+1,y);
        if (x > CMin_X) then unhideField(x-1,y);
        if (x < CMax_X) and (y < CMax_Y) then unhideField(x+1,y+1);
        if (x < CMax_X) and (y > CMin_Y) then unhideField(x+1,y-1);
        if (x > CMin_X) and (y < CMax_Y) then unhideField(x-1,y+1);
        if (x > CMin_X) and (y > CMin_Y) then unhideField(x-1,y-1);

      end;
    end;
  end;

end.

