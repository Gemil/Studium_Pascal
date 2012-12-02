{
 Programmname: Befreiungsaufgabe
 Befreiungsaufgabe PS1 WS 2012

 Minesweeper in Pascal ohne GUI, nur Textausgabe.

 Author: Gerrit Paepcke
 Erstelldatum: 9.11.2012
 Bisherige Änderungen: keine
}

program befreiungsaufgabe;

uses
  SysUtils, crt, Ulogic, Udisplay;

type
  Screen = (Index,Settings,Highscore,Game);
  Key = (left,right,up,down,enter,space,back);

var
  gamescore : array[0..2] of Score; // Highscore, 0 = 1. Platz, 1 = 2. Platz,2 = 3. Platz

  // Generelle Variablen zur Programmsteuerung
  current_screen : Screen = Index; // Derzeitige Anzeige
  selected_index : Byte = 1; // Index zur Menüauswahl
  exit : boolean = false; // Prüf Var zum Programmexit
  input : char; // Letzter Eingabetaste
  pressed_key : Key; // Ausgewertete Eingabe
  x,y,i : integer; // Zählvariablen für Schleifen

  // Variablen für den Spielbetrieb
  bomb_count, flagged_fields : Word; // Anzahl der Bomben/Flaggen auf dem Spielfeld
  bomb_percentage : Byte = 16; // (10 Bomben bei 8x8 Spielfeld, Standartwert für Schwierigkeit "Leicht" im normalen Minesweeper)
  curser_x,curser_y : Byte; // Aktuelle Position des Cursers im Spielfeld
  highscore_name : String[50]; // Inputwert für den Highscore


  // Variablen zur Zeitmessung
  gamestart_time,gameend_time,gameduration : double; // in sec

begin
  Udisplay.showIndexScreen(selected_index);

  // Initialisierung der Highscore mit Standartwerten
  gamescore[0].Name:='Unknown';
  gamescore[0].Time:=999999.99;
  gamescore[1].Name:='Unknown';
  gamescore[1].Time:=999999.99;
  gamescore[2].Name:='Unknown';
  gamescore[2].Time:=999999.99;


  repeat
    // Eingabe Auswertung
    input := ReadKey;
    case input of
      #0:
        begin
           input := ReadKey;
           case input of
             'H': pressed_key:=up;
             'P': pressed_key:=down;
             'K': pressed_key:=left;
             'M': pressed_key:=right;
           end;
         end;
      #8: pressed_key:=back;
      'b': pressed_key:=back;
      #13: pressed_key:=enter;
      ' ': pressed_key:=space;

      // Keys für Geräte ohne Pfeiltasten
      'w': pressed_key:=up;
      'a': pressed_key:=left;
      's': pressed_key:=down;
      'd': pressed_key:=right;
    end;

    // Wohin soll die Eingabe geleitet werden
    case current_screen of
       Index:
         begin
           case pressed_key of
              enter: // Auswahl bestätigen
                begin
                  case selected_index of
                     1: // Neues Spiel
                       begin
                         bomb_count := Round((((Ulogic.CMax_X-Ulogic.CMin_X+1)*(Ulogic.CMax_Y-Ulogic.CMin_Y+1))/100)*bomb_percentage);
                         Ulogic.generateSpielfeld(bomb_count);
                         flagged_fields := 0;
                         gamestart_time := Ulogic.getTimeInSec();
                         curser_x := Ulogic.CMin_X;
                         curser_y := Ulogic.CMin_Y;

                         Udisplay.showGameScreen(curser_x,curser_y,bomb_count,flagged_fields,Ulogic.getTimeInSec()-gamestart_time);
                         current_screen := Game;
                       end;
                     2: // Highscore anzeigen
                       begin
                         Udisplay.showHighscoreScreen(gamescore);
                         current_screen := Highscore;
                       end;
                     3: // Einstellungen
                       begin
                         selected_index := 1;
                         Udisplay.showSettingsScreen(selected_index, bomb_percentage);
                         current_screen := Settings;
                       end;
                     4: // Programm schliessen
                       begin
                         exit := true;
                       end;
                  end;
                end;
              up: // Auswahl nach oben
                begin
                  if selected_index-1 > 0 then
                    selected_index := selected_index -1;
                  Udisplay.showIndexScreen(selected_index);
                end;
              down: // Auswahl nach unten
                begin
                  if selected_index+1 < 5 then
                    selected_index := selected_index +1;
                  Udisplay.showIndexScreen(selected_index);
                end;
           end;
         end;
       Settings:
         begin
           case pressed_key of
              left: // Ändern der Settings nach links
                begin
                  case selected_index of
                     1:
                       begin
                         if (bomb_percentage-1 > 0) then
                           bomb_percentage := bomb_percentage-1;
                       end;
                  end;
                  Udisplay.showSettingsScreen(selected_index, bomb_percentage);
                end;
              right: // Ändern der Settings nach rechts
                begin
                  case selected_index of
                     1:
                       begin
                         if (bomb_percentage+1 <= 100) then
                           bomb_percentage := bomb_percentage+1;
                       end;
                  end;
                  Udisplay.showSettingsScreen(selected_index, bomb_percentage);
                end;
              up: // Auswahl nach oben
                begin
                  if selected_index-1 > 0 then
                    selected_index := selected_index -1;
                  Udisplay.showSettingsScreen(selected_index, bomb_percentage);
                end;
              down: // Auswahl nach unten
                begin
                  if selected_index+1 < 2 then
                    selected_index := selected_index +1;
                  Udisplay.showSettingsScreen(selected_index, bomb_percentage);
                end;
              back: // Zurück zum Hauptmenü
                begin
                  Udisplay.showIndexScreen(selected_index);
                  current_screen := Index;
                end;
           end;
         end;
       Highscore:
         begin
           case pressed_key of
              back: // Zurück zum Hauptmenü
                begin
                  Udisplay.showIndexScreen(selected_index);
                  current_screen := Index;
                end;
           end;
         end;
       Game:
         begin
           case pressed_key of
              space: // Feld aufdecken
                begin
                  case Spielfeld[curser_x,curser_y] of
                    fdBombe: // Bombe wurde gefunden
                      begin
                        gameend_time := Ulogic.getTimeInSec();
                        gameduration := gameend_time - gamestart_time;


                        UDisplay.showGameScreen(curser_x,curser_y,bomb_count,flagged_fields,gameduration,true);
                        gotoxy(1,2);
                        writeln('Verloren! Deine Zeit: '+FloatToStrF(gameduration,ffFixed,10,2)+'s');
                        writeln('Bitte druecke Enter, um zum Hauptmenu zurueckzukehren');
                        readln;
                        current_screen := Index;
                        Udisplay.showIndexScreen(selected_index);
                      end;
                    fdFlagge_mBombe: // Flagge entfernen
                      begin
                        Ulogic.Spielfeld[curser_x,curser_y] := fdBombe;
                        flagged_fields := flagged_fields-1;
                        Udisplay.showGameScreen(curser_x,curser_y,bomb_count,flagged_fields,Ulogic.getTimeInSec()-gamestart_time);
                      end;
                    fdFlagge_oBombe: //Flagge entfernen
                      begin
                        Ulogic.Spielfeld[curser_x,curser_y] := fdVerborgen;
                        flagged_fields := flagged_fields-1;
                        Udisplay.showGameScreen(curser_x,curser_y,bomb_count,flagged_fields,Ulogic.getTimeInSec()-gamestart_time);
                      end;
                    fdVerborgen: // Feld aufdecken
                      begin
                        Ulogic.unhideField(curser_x,curser_y);
                        Udisplay.showGameScreen(curser_x,curser_y,bomb_count,flagged_fields,Ulogic.getTimeInSec()-gamestart_time);

                        // Prüfung auf Spielgewinn
                        i := 0;
                        for x:=Ulogic.CMin_X to Ulogic.CMax_X do
                        begin
                          for y:=Ulogic.CMin_Y to Ulogic.CMax_Y do
                          begin
                            if (Ulogic.Spielfeld[x,y] = fdVerborgen) or (Ulogic.Spielfeld[x,y] = fdFlagge_oBombe) then
                            begin
                              i := i+1;
                            end;
                          end;
                        end;

                        if (i = 0) then
                        begin
                          gameend_time := Ulogic.getTimeInSec();
                          gameduration := gameend_time - gamestart_time;

                          Udisplay.showStandartHeader();
                          writeln('Gewonnen! Deine Zeit: '+FloatToStrF(gameduration,ffFixed,10,2)+'s');
                          // Wurde die Highscore geschlagen?
                          if (gamescore[0].Time > time) then
                          begin
                            writeln;
                            writeln('Du hast die Highscore geschlagen und bist nun auf Platz 1!');
                            write('Gebe daher nun deinen Namen ein: ');
                            readln(highscore_name);

                            gamescore[2] := gamescore[1];
                            gamescore[1] := gamescore[0];
                            gamescore[0].Name := highscore_name;
                            gamescore[0].Time:= gameduration;
                          end
                          else if (gamescore[1].Time > time) then
                          begin
                            writeln;
                            writeln('Du hast die Highscore geschlagen und bist nun auf Platz 2!');
                            write('Gebe daher nun deinen Namen ein: ');
                            readln(highscore_name);

                            gamescore[2] := gamescore[1];
                            gamescore[1].Name := highscore_name;
                            gamescore[1].Time:= gameduration;
                          end
                          else if (gamescore[2].Time > time) then
                          begin
                            writeln;
                            writeln('Du hast die Highscore geschlagen und bist nun auf Platz 3!');
                            write('Gebe daher nun deinen Namen ein: ');
                            readln(highscore_name);

                            gamescore[2].Name := highscore_name;
                            gamescore[2].Time:= gameduration;
                          end;
                          writeln;
                          writeln('Bitte druecke Enter, um zum Hauptmenu zurueckzukehren');
                          readln();

                          current_screen := Index;
                          Udisplay.showIndexScreen(selected_index);
                        end;
                      end;
                  end;
                end;
              enter: // Feld markieren
                begin
                  case Ulogic.Spielfeld[curser_x,curser_y] of
                     fdBombe: {Flagge setzen}
                       begin
                         Spielfeld[curser_x,curser_y] := fdFlagge_mBombe;
                         flagged_fields := flagged_fields+1;
                         Udisplay.showGameScreen(curser_x,curser_y,bomb_count,flagged_fields,Ulogic.getTimeInSec()-gamestart_time);
                       end;
                     fdVerborgen: {Flagge setzen}
                       begin
                         Ulogic.Spielfeld[curser_x,curser_y] := fdFlagge_oBombe;
                         flagged_fields := flagged_fields+1;
                         Udisplay.showGameScreen(curser_x,curser_y,bomb_count,flagged_fields,Ulogic.getTimeInSec()-gamestart_time);
                       end;
                     fdFlagge_mBombe: {Flagge entfernen}
                       begin
                         Ulogic.Spielfeld[curser_x,curser_y] := fdBombe;
                         flagged_fields := flagged_fields-1;
                         Udisplay.showGameScreen(curser_x,curser_y,bomb_count,flagged_fields,Ulogic.getTimeInSec()-gamestart_time);
                       end;
                     fdFlagge_oBombe: {Flagge entfernen}
                       begin
                         Ulogic.Spielfeld[curser_x,curser_y] := fdVerborgen;
                         flagged_fields := flagged_fields-1;
                         Udisplay.showGameScreen(curser_x,curser_y,bomb_count,flagged_fields,Ulogic.getTimeInSec()-gamestart_time);
                       end;
                  end;
                end;
              up: // Auswahl nach oben
                begin
                  if curser_y > CMin_Y then
                    curser_y := curser_y -1;
                  Udisplay.showGameScreen(curser_x,curser_y,bomb_count,flagged_fields,Ulogic.getTimeInSec()-gamestart_time);
                end;
              down: // Auswahl nach unten
                begin
                  if curser_y < CMax_Y then
                    curser_y := curser_y +1;
                  Udisplay.showGameScreen(curser_x,curser_y,bomb_count,flagged_fields,Ulogic.getTimeInSec()-gamestart_time);
                end;
              left: // Auswahl nach links
                begin
                  if curser_x > CMin_X then
                    curser_x := curser_x -1;
                  Udisplay.showGameScreen(curser_x,curser_y,bomb_count,flagged_fields,Ulogic.getTimeInSec()-gamestart_time);
                end;
              right: // Auswahl nach rechts
                begin
                  if curser_x < CMax_X then
                    curser_x := curser_x +1;
                  Udisplay.showGameScreen(curser_x,curser_y,bomb_count,flagged_fields,Ulogic.getTimeInSec()-gamestart_time);
                end;
              back: // Spiel abbrechen - zurück zum Hauptmenü
                begin
                  Udisplay.showIndexScreen(selected_index);
                  current_screen := Index;
                end;
           end;
         end;
    end;
  until exit = true

end.

