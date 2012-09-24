with graph2d, iio, random, math_lib, text_io, fio;
use  graph2d, iio, random, math_lib, text_io, fio;

procedure ifsload is
----------------  Record's, Konstanten und Variablen definition

-- Mittelpunkt Record
type mittelpunkt is record
   x, y : float;
end record;

-- Filenamen array
type rec_ifsfiles is record
   beschr   : string(1..30);   -- IFS-Beschreibung
   blaenge  : integer;         -- Beschreibungsstring Laenge
   filename : string(1..30);   -- Filename des IFS-Files
   flaenge  : integer;         -- Laenge des Filenamens
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
wahl_file    : string(1..30);
wahl_flaenge : integer;
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
      nr   : integer := ifs.total;
   begin
      for i in 1..ifs.total loop
         if ( rand <= ifs.p(i) ) then
            nr := i;
            exit;
         end if;
      end loop;
      return nr;
   end Get_Nr;

   procedure calc_points ( x : float; y : float; ort: integer ) is
      x_new, y_new : float;
   begin
      for i in 1..ifs.total loop
         x_new := ifs.a(i)*x + ifs.b(i)*y + ifs.e(i);
         y_new := ifs.c(i)*x + ifs.d(i)*y + ifs.f(i);
         set_point ( x_new, y_new );
         debug := debug + 1;
         if ( ort <= ((max_points)/ifs.total) ) then
            calc_points ( x_new, y_new, ort*ifs.total );
         end if;
      end loop;
   end calc_points;


   procedure ifs_load is
      h : file_type;
   begin
      open ( h, in_file, wahl_file(1..wahl_flaenge) );
      get ( h, ifs.total );
      for i in 1..ifs.total loop
         get ( h, ifs.a(i) ); get ( h, ifs.b(i) ); get ( h, ifs.c(i) );
         get ( h, ifs.d(i) ); get ( h, ifs.e(i) ); get ( h, ifs.f(i) );
         get ( h, ifs.p(i) );
      end loop;
      get ( h, ifs.breite ); get ( h, ifs.hoehe );
      get ( h, ifs.mp.x );   get ( h, ifs.mp.y );
      close ( h );
   end ifs_load;   
   
   procedure ifs_wahl is
      config : constant string := "config.ifs";
      handle : file_type;
      anz    : integer;
   begin
      open ( handle, in_file, config );
      get ( handle, anz );
      -- Die naechste Zeile hat keine Programmfunktion nur provisorisch 
      get_line ( handle, wahl_file, wahl_flaenge );
      
      put_line ( " Auswahl der IFS-Fractalart" );
      
      declare
         ifsfiles : array(1..anz) of rec_ifsfiles;
         wahl     : integer;
      begin
         for i in 1..anz loop
            get_line ( handle, ifsfiles(i).beschr, ifsfiles(i).blaenge );
            put ( "  " ); put ( i, width=>2 );
            put ( " -> " );
            put_line ( ifsfiles(i).beschr(1..ifsfiles(i).blaenge) );
            get_line ( handle, ifsfiles(i).filename, ifsfiles(i).flaenge );
         end loop;
         new_line; 
         put ( " Bitte waehlen: " ); 
         loop
            get ( wahl );
            if ( wahl >= 1 and wahl <= anz ) then
               exit;
            end if;
            new_line;
            put ( " Bitte nochmals: " );
         end loop;
         new_line;
         wahl_file(1..ifsfiles(wahl).flaenge) :=
                          ifsfiles(wahl).filename(1..ifsfiles(wahl).flaenge);
         wahl_flaenge := ifsfiles(wahl).flaenge;
      end;
      close ( handle );
   end ifs_wahl;      
     
----------------------- Hauptprogramm -------------------------------
begin
   initialize ( 1 );

   new_line;
   put_line ( "Fraktal-Print Programm" );
   put_line ( "----------------------" ); new_line;
   new_line;

   ifs_wahl;
   
   ifs_load;

--   put_line ( " Bitte Rechnungart eingeben: " );
--   put_line ( "    1 -> Diterminante" );
--   put_line ( "    2 -> Random" );
--   new_line;
--   new_line;

--   loop
--      get ( rechnen );
--      if ( rechnen >= 1 and rechnen <= 2 ) then
--         exit;
--      end if;
--      new_line;
--      put ( " Bitte nochmals: " );
--   end loop;
--   new_line;

   rechnen := 2;

   put ( " Bitte max. Punkte eingeben: " );
   get ( max_points );
   skip_line;

   set_graphmode ( black, white );
   clear_screen;
   set_display_rect ( ifs.mp.x, ifs.mp.y,
                      ifs.breite, ifs.hoehe );

   x := 0.0;
   y := 0.0;

   if ( rechnen = 1 ) then
      calc_points ( x, y, ifs.total );
   else 
      for i in 1..max_points loop
         set_point ( x, y );
         zeile := Get_Nr;

      x_new := x * ifs.a(zeile) + 
               y * ifs.b(zeile) + 
               ifs.e(zeile);

      y_new := x * ifs.c(zeile) + 
               y * ifs.d(zeile) + 
               ifs.f(zeile);

         x := x_new;
         y := y_new;
      end loop;
   end if;

   skip_line;
   end_graphmode;

   new_line; new_line;
end;
