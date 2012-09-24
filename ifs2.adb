with graph2dp, iio, random, math_lib, text_io;
use  graph2dp, iio, random, math_lib, text_io;

procedure ifs2 is
----------------  Record's, Konstanten und Variablen definition

-- Mittelpunkt Record
type mittelpunkt is record
   x, y : float;
end record;

type fracarray is array(1..5) of float;
type prozarray is array(1..5) of integer;

-- IFS Record mit Fraktaldaten
type ifs_type is record
   total  : integer;
   a      : fracarray;    --\
   b      : fracarray;    -- \
   c      : fracarray;    --  \- Nicht existierende Daten sind 0.0
   d      : fracarray;    --  /
   e      : fracarray;    -- /
   f      : fracarray;    --/
   p      : prozarray;  -- Warscheindlichkeit in Prozent
   hoehe  : float;        -- Fensterhoehe
   breite : float;        -- Fensterbreite
   mp     : mittelpunkt;  -- Mittelpunkt des Fensters
   hg     : integer;      -- Hintergrundfarbe
   vg     : integer;      -- Penfarbe
end record;

-- Variablen
ifs          : ifs_type;
wahl         : integer;
max_points   : integer;
zeile        : integer;    -- Welche Zeile von Tabelle benuetzen
x, y         : float;
debug        : integer := 0;
rechnen      : integer;
x_new, y_new : float;

   -- Gibt eine Zufallszahl im bereich 1..100 aus (integer)
   function Get_Random100 return integer is
      rand : integer := INTEGER(next_number*100.0);
   begin
      if ( rand = 0 ) then
         rand := 100;
      end if;
      return rand;
   end Get_Random100;

   -- Sucht mit Zufallszahl die richtige Reihennummer
   function Get_Nr return integer is
      rand : integer := Get_Random100;
      nr   : integer := ifs(wahl).total;
   begin
      for i in 1..ifs(wahl).total loop
         if ( rand <= ifs(wahl).p(i) ) then
            nr := i;
            exit;
         end if;
      end loop;
      return nr;
   end Get_Nr;

   -- Farn-IFS Daten initialisieren
   procedure Init_Farn is
   begin
      ifs.a      := ( 0.0, 0.85, 0.2, -0.15, 0.0 );
      ifs.b      := ( 0.0, 0.04, -0.26, 0.28, 0.0 );
      ifs.c      := ( 0.0, -0.04, 0.23, 0.26, 0.0 );
      ifs.d      := ( 0.16, 0.85, 0.22, 0.24, 0.0 ); 
      ifs.e      := ( 0.0, 0.0, 0.0, 0.0, 0.0 );
      ifs.f      := ( 0.0, 1.6, 1.6, 0.44, 0.0 );
      ifs.p      := ( 1, 86, 93, 100, 0 );
      ifs.breite := 16.0;
      ifs.hoehe  := 11.0;
      ifs.mp.x   := 0.0;
      ifs.mp.y   := 5.5;
      ifs.hg     := blue;
      ifs.vg     := yellow;
      ifs.total  := 4;
   end Init_Farn;

   -- Sierpinski-IFS Daten initialisieren
   procedure Init_Sierp ( nr : integer ) is
   begin
      ifs(nr).a      := ( 0.5, 0.5, 0.5, 0.0, 0.0 );
      ifs(nr).b      := ( 0.0, 0.0, 0.0, 0.0, 0.0 );
      ifs(nr).c      := ( 0.0, 0.0, 0.0, 0.0, 0.0 );
      ifs(nr).d      := ( 0.5, 0.5, 0.5, 0.0, 0.0 ); 
      ifs(nr).e      := ( 0.0, 0.0, 0.5, 0.0, 0.0 );
      ifs(nr).f      := ( 0.0, 0.5, 0.5, 0.0, 0.0 );
      ifs(nr).p      := ( 33, 66, 100, 0, 0 );
      ifs(nr).breite := 2.0;
      ifs(nr).hoehe  := 1.3;
      ifs(nr).mp.x   := 1.0;
      ifs(nr).mp.y   := 0.65;
      ifs(nr).hg     := blue;
      ifs(nr).vg     := yellow;
      ifs(nr).total  := 3;
   end Init_Sierp;

   -- Binary-IFS Daten initialisieren
   procedure Init_Binary ( nr : integer ) is
   begin
      ifs(nr).a      := ( 0.5, 0.5, 0.0, 0.0, 0.0 );
      ifs(nr).b      := ( 0.0, 0.0, -0.5, 0.0, 0.0 );
      ifs(nr).c      := ( 0.0, 0.0, 0.5, 0.0, 0.0 );
      ifs(nr).d      := ( 0.5, 0.5, 0.0, 0.0, 0.0 ); 
      ifs(nr).e      := ( -2.563477, 2.436544, 4.873085, 0.0, 0.0 );
      ifs(nr).f      := ( -0.000003, -0.000003, 7.563492, 0.0, 0.0 );
      ifs(nr).p      := ( 33, 66, 100, 0, 0 );
      ifs(nr).breite := 2.0;
      ifs(nr).hoehe  := 1.3;
      ifs(nr).mp.x   := 1.0;
      ifs(nr).mp.y   := 0.65;
      ifs(nr).hg     := blue;
      ifs(nr).vg     := yellow;
      ifs(nr).total  := 3;
   end Init_Binary;

   -- Ahorn-IFS Daten initialisieren
   procedure Init_Ahorn ( nr : integer ) is
   begin
      ifs(nr).a      := ( 0.0, 0.5, 0.353, 0.353, 0.7 );
      ifs(nr).b      := ( 0.0, 0.0, 0.353, -0.353, 0.0 );
      ifs(nr).c      := ( 0.0, 0.0, -0.353, 0.353, 0.0 );
      ifs(nr).d      := ( 0.55, 0.5, 0.353, 0.353, 0.7 ); 
      ifs(nr).e      := ( 0.0, 0.0, 0.3, -0.3, 0.0 );
      ifs(nr).f      := ( 0.0, 0.7, 0.3, 0.3, 0.0 );
      ifs(nr).p      := ( 2, 38, 59, 80, 100 );
      ifs(nr).breite := 2.52;
      ifs(nr).hoehe  := 1.71;
      ifs(nr).mp.x   := 0.0;
      ifs(nr).mp.y   := 0.795;
      ifs(nr).hg     := blue;
      ifs(nr).vg     := yellow;
      ifs(nr).total  := 5;
   end Init_Ahorn;

   -- Spiralen-IFS Daten initialisieren
   procedure Init_Spiralen ( nr : integer ) is
   begin
      ifs(nr).a      := ( 0.7879, -0.1212, 0.1819, 0.0, 0.0 );
      ifs(nr).b      := ( -0.4242, 0.2576, -0.1364, 0.0, 0.0 );
      ifs(nr).c      := ( 0.2424, 0.1515, 0.0909, 0.0, 0.0 );
      ifs(nr).d      := ( 0.8598, 0.053, 0.1819, 0.0, 0.0 ); 
      ifs(nr).e      := ( 1.7586, -6.7217, 6.0861, 0.0, 0.0 );
      ifs(nr).f      := ( 1.4081, 1.3772, 1.568, 0.0, 0.0 );
      ifs(nr).p      := ( 90, 95, 100, 0, 0 );
      ifs(nr).breite := 15.2;
      ifs(nr).hoehe  := 10.33;
      ifs(nr).mp.x   := 0.0;
      ifs(nr).mp.y   := 4.835;
      ifs(nr).hg     := blue;
      ifs(nr).vg     := yellow;
      ifs(nr).total  := 3;
   end Init_Spiralen;

   procedure calc_points ( x : float; y : float; ort: integer ) is
      x_new, y_new : float;
   begin
      for i in 1..ifs(wahl).total loop
         x_new := ifs(wahl).a(i)*x + ifs(wahl).b(i)*y + ifs(wahl).e(i);
         y_new := ifs(wahl).c(i)*x + ifs(wahl).d(i)*y + ifs(wahl).f(i);
         set_point ( x_new, y_new );
         debug := debug + 1;
         if ( ort <= ((max_points)/ifs(wahl).total) ) then
            calc_points ( x_new, y_new, ort*ifs(wahl).total );
         end if;
      end loop;
   end calc_points;

----------------------- Hauptprogramm -------------------------------
begin
   initialize ( 1 );

   Init_Farn     ( 1 );
   Init_Sierp    ( 2 );
   Init_Ahorn    ( 3 );
   Init_Spiralen ( 4 );

   new_line;
   put_line ( "Fraktal-Print Programm" );
   put_line ( "----------------------" ); new_line;

   put_line ( " Fraktaltypenauswahl:" ); new_line;
   put_line ( "   1 -> Farn-IFS" );
   put_line ( "   2 -> Sierpinski-IFS" );
   put_line ( "   3 -> Ahorn-IFS" );
   put_line ( "   4 -> Spiralen-IFS" ); new_line;
   put ( " Bitte waehlen: " );

   loop
      get ( wahl );
      if ( wahl >= 1 and wahl <= 4 ) then
         exit;
      end if;
      new_line;
      put ( " Bitte nochmals: " );
   end loop;
   new_line;

   put_line ( " Bitte Rechnungart eingeben: " );
   put_line ( "    1 -> Diterminante" );
   put_line ( "    2 -> Random" );
   new_line;
   new_line;

   loop
      get ( rechnen );
      if ( rechnen >= 1 and rechnen <= 2 ) then
         exit;
      end if;
      new_line;
      put ( " Bitte nochmals: " );
   end loop;
   new_line;

   put ( " Bitte max. Punkte eingeben: " );
   get ( max_points );
   skip_line;

   set_graphmode ( black, red );
   clear_screen;
   set_display_rect ( ifs(wahl).mp.x, ifs(wahl).mp.y,
                      ifs(wahl).breite, ifs(wahl).hoehe );

   x := 0.0;
   y := 0.0;

   if ( rechnen = 1 ) then
      calc_points ( x, y, ifs(wahl).total );
   else 
      for i in 1..max_points loop
         set_point ( x, y );
         zeile := Get_Nr;

      x_new := x * ifs(wahl).a(zeile) + 
               y * ifs(wahl).b(zeile) + 
               ifs(wahl).e(zeile);

      y_new := x * ifs(wahl).c(zeile) + 
               y * ifs(wahl).d(zeile) + 
               ifs(wahl).f(zeile);

         x := x_new;
         y := y_new;
      end loop;
   end if;

   skip_line;
   end_graphmode;
   put ( "Total Punkte: " );
   put ( debug );
   new_line; new_line;
end;
