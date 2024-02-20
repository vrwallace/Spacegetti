unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Windows, Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Menus, fphttpclient, registry, shlobj, INIFiles, dateutils,
  BGRABitmap, BGRABitmapTypes, BGRAGradients, fpjson, BGRATextFX,
  jsonparser, uniqueinstanceraw, LCLIntf, Spin, unit3, crt, strutils, Math,opensslsockets;

type
  TShowStatusEvent = procedure(Status: string) of object;

  TMyThread = class(TThread)
    function getlatestimagedate(groupname, jsonurl: string): string;
    procedure logit(message: string);
    procedure DumpExceptionCallStack(E: Exception);
    procedure setdesktop(sWallpaperBMPPath: string);
    function getsetpath(): string;
    function htmlgetvalue(sourceurl, startvalue: string): string;
    function constructstarmapurl: string;
    function getlatlon: string;
  private
    fStatusText: string;
    FOnShowStatus: TShowStatusEvent;
    procedure ShowStatus;

  protected
    procedure Execute; override;
  public
    constructor Create(CreateSuspended: boolean);
    property OnShowStatus: TShowStatusEvent read FOnShowStatus write FOnShowStatus;
  end;


type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    CheckBoxmap: TCheckBox;
    CheckBoxresize: TCheckBox;
    ComboBoxsource: TComboBox;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    Label1: TLabel;
    Memo1: TMemo;
    Memolog: TMemo;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    PopupMenu1: TPopupMenu;
    refreshinterval: TSpinEdit;
    Timer1: TTimer;
    TrayIcon1: TTrayIcon;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);

    procedure FormDestroy(Sender: TObject);

    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);

    procedure FormWindowStateChange(Sender: TObject);


    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);

    procedure DumpExceptionCallStack(E: Exception; how: string);

    procedure mainp;

    procedure savesettings(Sender: TObject);
    procedure loadsettings(Sender: TObject);
    procedure logit(message: string);
    function getsetpath(): string;
    procedure Timer1Timer(Sender: TObject);
    procedure TrimAppMemorySize;


  private
    { private declarations }
    MyThread: TMyThread;
    procedure ShowStatus(Status: string);
  public
    { public declarations }
  end;


var
  Form1: TForm1;


implementation

{$R *.lfm}

{uses
  LSUtils;}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);

begin
  TrimAppMemorySize;
  MyThread := TMyThread.Create(True);
  MyThread.OnShowStatus := @ShowStatus;
  MyThread.Start;

end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  ShowMessage('Email: vonwallace@yahoo.com');
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  Reply, BoxStyle: integer;
begin

  try
    BoxStyle := MB_ICONQUESTION + MB_YESNO;
    Reply := Application.MessageBox(
      'Donate to keep me motivated, to say thanks. (PayPal)', 'Donate?', BoxStyle);
    if Reply = idYes then
      openurl('https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=BKC45VFP27NHN');
  except
    on E: Exception do
      DumpExceptionCallStack(E, 'log');

  end;

end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  form2.WindowState := wsnormal;
  form2.Show;
end;

procedure TForm1.FormActivate(Sender: TObject);
var
  cnv: TControlCanvas;
  w: integer;
  s: string;

begin
  w := 0;
  cnv := TControlCanvas.Create;
  try
    cnv.Control := Comboboxsource;
    cnv.Font.Assign(Comboboxsource.Font);
    for s in Comboboxsource.Items do
      w := max(w, cnv.TextWidth(s));
    Comboboxsource.ItemWidth := w + 30;
  finally
    cnv.Free;
  end;
end;




procedure TForm1.FormDestroy(Sender: TObject);
begin
  //MyThread.Terminate;

  // FreeOnTerminate is true so we should not write:
  // MyThread.Free;
  inherited;
end;

procedure TForm1.ShowStatus(Status: string);
begin
  logit(status);

end;


procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: boolean);
var
  Reply, BoxStyle: integer;

begin

  BoxStyle := MB_ICONQUESTION + MB_YESNO;
  Reply := Application.MessageBox(
    'EXIT? Are you sure, the images will no longer refresh on your Wallpaper?',
    'Exit?', BoxStyle);
  if Reply = idYes then
    canclose := True
  else
    canclose := False;

end;



procedure TForm1.FormWindowStateChange(Sender: TObject);
begin
  if Form1.WindowState = wsMinimized then
  begin
    form1.WindowState := wsNormal;
    form1.Hide;
    Form1.ShowInTaskBar := stNever;

  end;
end;




procedure TForm1.MenuItem1Click(Sender: TObject);
begin
  form1.windowstate := wsnormal;
  form1.Show;

end;

procedure TForm1.MenuItem2Click(Sender: TObject);
var
  Reply, BoxStyle: integer;

begin

  BoxStyle := MB_ICONQUESTION + MB_YESNO;
  Reply := Application.MessageBox(
    'EXIT? Are you sure, the images will no longer refresh on your Wallpaper?',
    'Exit?', BoxStyle);
  if Reply = idYes then
    halt;

end;

procedure TForm1.DumpExceptionCallStack(E: Exception; how: string);
var

  Report: string;
begin
  report := '';
  if E <> nil then
  begin
    Report := 'Exception class: ' + E.ClassName + ' | Message: ' + E.Message;

    if how = 'showmessage' then
    begin
      ShowMessage(Report);
      halt;
    end
    else
    begin

      logit(trim(FormatDateTime('h:nn:ss AM/PM', now) + ' ' +
        FormatDateTime('MM/DD/YYYY', now)) + ' ERROR: ' + report);

    end;
  end;

end;




procedure tform1.mainp;

begin

  MyThread := TMyThread.Create(True);
  MyThread.OnShowStatus := @ShowStatus;
  MyThread.Start;
  timer1.Enabled := True;

end;



procedure tform1.savesettings(Sender: TObject);
var

  filepath: string;
  INI: TINIFile;

begin

  try


    filepath := getsetpath;

    INI := TINIFile.Create(filepath + 'spacegetti.ini');
    try

      ini.Writeinteger('config', 'source', comboboxsource.ItemIndex);
      ini.Writebool('config', 'resize', checkboxresize.Checked);
      ini.Writebool('config', 'earthmap', checkboxmap.Checked);
      ini.Writeinteger('config', 'refreshinterval', refreshinterval.Value);
      timer1.interval := refreshinterval.Value * 60000;

    finally
      Ini.Free;
    end;

    comboboxsource.hint := comboboxsource.Text;
    //comboboxsource.ShowHint:=true;

  except
    on E: Exception do
    begin
      DumpExceptionCallStack(E, 'showmessage');
    end;

  end;

end;

procedure tform1.loadsettings(Sender: TObject);
var

  filepath: string;
  INI: TINIFile;

begin

  if (InstanceRunning) then
  begin
    ShowMessage('Spacegetti is already running, check the Task Bar or System Tray (Earth Icon)');
    halt;
  end;



  try



    filepath := getsetpath;


    INI := TINIFile.Create(filepath + 'spacegetti.ini');
    try
      comboboxsource.ItemIndex := ini.readinteger('config', 'source', 0);
      checkboxresize.Checked := ini.readbool('config', 'resize', False);
      checkboxmap.Checked := ini.readbool('config', 'earthmap', False);
      refreshinterval.Value := ini.readinteger('config', 'refreshinterval', 15);
      timer1.interval := refreshinterval.Value * 60000;

    finally
      Ini.Free;
    end;

    comboboxsource.hint := comboboxsource.Text;
    comboboxsource.ShowHint := True;


  except
    on E: Exception do
    begin
      DumpExceptionCallStack(E, 'showmessage');
    end;

  end;
  mainp;
end;

procedure tform1.logit(message: string);
begin

  if (memolog.Lines.Count > 50) then
    memolog.Lines.Delete(0);


  memolog.Lines.Add(message);

end;

function tform1.getsetpath(): string;
var
  PersonalPath: array[0..MaxPathLen] of char; //Allocate memory
  filepath: string;

begin

  try
    PersonalPath := '';
    SHGetSpecialFolderPath(0, PersonalPath, CSIDL_LOCAL_APPDATA, False);

    filepath := PersonalPath + '\Spacegetti\';
    if not directoryexists(filepath) then
      createdir(filepath);
    Result := filepath;
  except
    on E: Exception do
      DumpExceptionCallStack(E, 'showmessage');

  end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  inherited;
  TrimAppMemorySize;
  MyThread := TMyThread.Create(True);
  MyThread.OnShowStatus := @ShowStatus;
  MyThread.Start;
end;




constructor TMyThread.Create(CreateSuspended: boolean);
begin
  FreeOnTerminate := True;
  inherited Create(CreateSuspended);
end;

procedure TMyThread.ShowStatus;
// this method is executed by the mainthread and can therefore access all GUI elements.
begin
  if Assigned(FOnShowStatus) then
  begin
    FOnShowStatus(fStatusText);
  end;
end;

procedure TMyThread.Execute;
var

  datestring: string;
  bmp, map: TBGRABitmap;
  dm: tDEVMODE;
  Source, Sourcemap: string;
  AStream: tstream;
  productpath, mappath, filepath: string;
  c: TBGRAPixel;
  s, smap: string;
  jsonstring: string;
  jsondatestring, jsondatestringmap: string;
  sourceindex: integer;
  sourcetext: string;
  mapchecked: bool;
  resizechecked: bool;
  my_array: array[0..20] of string;
  sat: string;
  ratio, ratiox, ratioy: double;
  newwidth, newheight,year,month,day: integer;
  renderer: TBGRATextEffectFontRenderer;
  locationname: string;
begin

  logit(trim(FormatDateTime('h:nn:ss AM/PM', now) + ' ' +
    FormatDateTime('MM/DD/YYYY', now)) + ' GET: Thread Start');

  my_array[0] := 'full_disk/natural_color/:full_disk:goes-16';
  my_array[1] := 'full_disk/geocolor/:full_disk:goes-16';
  my_array[2] := 'full_disk/band_13/:full_disk:goes-16';
  my_array[3] := 'conus/natural_color/:conus:goes-16';
  my_array[4] := 'conus/geocolor/:conus:goes-16';
  my_array[5] := 'conus/band_13/:conus:goes-16';

 // my_array[6] := 'full_disk/natural_color/:full_disk:goes-17';
  //my_array[7] := 'full_disk/geocolor/:full_disk:goes-17';
  //my_array[8] := 'full_disk/band_13/:full_disk:goes-17';
  //my_array[9] := 'conus/natural_color/:conus:goes-17';
  //my_array[10] := 'conus/geocolor/:conus:goes-17';
  //my_array[11] := 'conus/band_13/:conus:goes-17';


  my_array[6] := 'full_disk/natural_color/:full_disk:himawari';
  my_array[7] := 'full_disk/geocolor/:full_disk:himawari';
  my_array[8] := 'full_disk/band_13/:full_disk:himawari';


  my_array[9] := 'northern_hemisphere/eumetsat_natural_color/:northern_hemisphere:jpss';
  my_array[10] := 'northern_hemisphere/cira_geocolor/:northern_hemisphere:jpss';
  my_array[11] := 'northern_hemisphere/band_m15/:northern_hemisphere:jpss';

  my_array[12] := 'southern_hemisphere/eumetsat_natural_color/:southern_hemisphere:jpss';
  my_array[13] := 'southern_hemisphere/cira_geocolor/:southern_hemisphere:jpss';
  my_array[14] := 'southern_hemisphere/band_m15/:southern_hemisphere:jpss';



  try

    //[here goes the code of the main thread loop]




    with TFPHttpClient.Create(nil) do
    begin

      IOtimeout := 120000;
      AllowRedirect := True;

      try
        try
          sourceindex := form1.comboboxsource.ItemIndex;
          sourcetext := form1.ComboBoxsource.Text;
          mapchecked := form1.CheckBoxmap.Checked;
          resizechecked := form1.checkboxresize.Checked;


          if ((sourceindex > -1) and (sourceindex < 30)) then
          begin
            if ((sourceindex > -1) and (sourceindex < 15)) then
            begin

              productpath := ExtractDelimited(1, my_array[sourceindex], [#58]);


              mappath := ExtractDelimited(2, my_array[sourceindex], [#58]);

              sat := ExtractDelimited(3, my_array[sourceindex], [#58]);

            {datestring := FormatDateTime('YYYYMMDD',
              IncMinute(Now, GetLocalTimeOffset));}


              jsonstring :=
                'https://rammb-slider.cira.colostate.edu/data/json/' +
                sat + '/' + productpath + 'available_dates.json';
              datestring := getlatestimagedate('dates_int', jsonstring);
              if (trim(datestring) = '') then
                exit;



              jsonstring :=
                'https://rammb-slider.cira.colostate.edu/data/json/' +
                sat + '/' + productpath + datestring + '_by_hour.json';
              jsondatestring := getlatestimagedate('timestamps_int', jsonstring);
              if (trim(jsondatestring) = '') then
                exit;

               // Extract year, month, and day components from the datestring
  year := StrToInt(Copy(datestring, 1, 4));
  month := StrToInt(Copy(datestring, 5, 2));
  day := StrToInt(Copy(datestring, 7, 2));

  // Create a TDateTime value from the extracted components
  datestring := FormatDateTime('yyyy/mm/dd', EncodeDate(year, month, day));


              Source := 'https://rammb-slider.cira.colostate.edu/data/imagery/' +
                datestring + '/' + sat + '---' + productpath +
                jsondatestring + '/00/000_000.png';

            end
            else
            begin

              case sourceindex of
                19:
                begin
                  Source := htmlgetvalue('https://apod.nasa.gov/apod/astropix.html',
                    '<IMG SRC="');
                  Source := 'https://apod.nasa.gov/apod/' + Source;

                  //thumbnails only
                  {Source := htmlgetvalue('https://apod.nasa.gov/apod.rss',
                    '&#60;img src="');}
                end;
                {14: Source := htmlgetvalue(
                    'https://earthobservatory.nasa.gov/IOTD/index.php', '<img src="');}

                20: Source := htmlgetvalue(
                    'https://earthobservatory.nasa.gov/feeds/image-of-the-day.rss',
                    'src="');


                21: Source := htmlgetvalue(
                    'https://www.nasa.gov/rss/dyn/lg_image_of_the_day.rss',
                    '<enclosure url="');

                22:
                begin
                  Source := ExtractDelimited(1, constructstarmapurl, [#124]);
                  locationname := ExtractDelimited(2, constructstarmapurl, [#124]);
                end;
                23: Source := htmlgetvalue(
                    'https://www.heartlight.org/cgi-shl/todaysverse.cgi',
                    '<h4>Illustration</h4><img src="');
                else
                  Source := 'https://sdo.gsfc.nasa.gov/assets/img/latest/latest_' +
                    rightstr(sourcetext, (length(sourcetext) -
                    pos(':', sourcetext)) - 1) + '_0193.jpg';

              end;
            end;

            filepath := getsetpath;


            logit(trim(FormatDateTime('h:nn:ss AM/PM', now) + ' ' +
              FormatDateTime('MM/DD/YYYY', now)) + ' GET: ' + Source);

            s := get(Source);

            if (ResponseStatusCode = 200) then
            begin

              bmp := TBGRABitmap.Create;
              try
                AStream := TStringStream.Create(s);
                try

                  bmp.LoadFromStream(astream);

                finally
                  AStream.Free;
                end;

                if ((sourceindex > -1) and (sourceindex < 15) and
                  (mapchecked)) then
                begin
                  //start




                  jsonstring :=
                    'https://rammb-slider.cira.colostate.edu/data/json/' +
                    sat + '/' + mappath + '/maps/borders/white/latest_times_all.json';
                  jsondatestringmap :=
                    getlatestimagedate('timestamps_int_map', jsonstring);
                  if (trim(jsondatestringmap) = '') then
                    exit;

                  //https://rammb-slider.cira.colostate.edu/data/maps/goes-16/full_disk/borders/white/20171201010000/00/000_000.png

                  sourcemap :=
                    'https://rammb-slider.cira.colostate.edu/data/maps/' +
                    sat + '/' + mappath + '/borders/white/' + jsondatestringmap +
                    '/00/000_000.png';
                     // https://rammb-slider.cira.colostate.edu/data/json/goes-16/full_disk/maps/borders/white/latest_times_all.json
                  logit(trim(FormatDateTime('h:nn:ss AM/PM', now) +
                    ' ' + FormatDateTime('MM/DD/YYYY', now)) + ' GET: ' + Sourcemap);
                  smap := get(sourcemap);
                  if (ResponseStatusCode <> 200) then
                  begin
                    logit(trim(FormatDateTime('h:nn:ss AM/PM', now) +
                      ' ' + FormatDateTime('MM/DD/YYYY', now)) +
                      ' ERROR - Reponse Code: ' + IntToStr(responsestatuscode));
                    exit;
                  end;




                  AStream := TStringStream.Create(smap);
                  try
                    map := TBGRABitmap.Create;
                    try
                      map.LoadFromStream(astream);
                      bmp.PutImage(0, 0, map, dmDrawWithTransparency);
                    finally

                      map.Free;
                    end;
                  finally
                    astream.Free;

                  end;

                end;

                if (resizechecked) then
                begin

                  FillChar(dm, SizeOf(dm), #0);
                  dm.dmSize := sizeof(dm);
                  EnumDisplaySettings(nil, ENUM_REGISTRY_SETTINGS, @dm);
                  // ENUM_REGISTRY_SETTINGS
                  //ENUM_CURRENT_SETTINGS
                  // showmessage(inttostr(dm.dmPelsHeight));
                  // showmessage(inttostr(dm.dmPelsWidth));


                  ratioX := dm.dmPelsWidth / bmp.Width;
                  ratioY := dm.dmPelsHeight / bmp.Height;
                  ratio := Min(ratioX, ratioY);

                  newWidth := trunc(bmp.Width * ratio);
                  newHeight := trunc(bmp.Height * ratio);

                  bmp.ResampleFilter := rfBestQuality;
                  // bmp.ResampleFilter := rfLanczos3;
                  BGRAReplace(BMP, bmp.resample(newwidth, newheight) as
                    TBGRABitmap);

                end;

                c := ColorToBGRA(ColorToRGB(cllime));
                renderer := TBGRATextEffectFontRenderer.Create;
                //try
                bmp.FontRenderer := renderer;

                renderer.ShadowVisible := True;
                renderer.OutlineVisible := True;
                renderer.OutlineColor := BGRABlack;
                renderer.OuterOutlineOnly := True;

                //bmp.FontQuality:= fqFineAntialiasing;

                bmp.FontHeight := 25;
                bmp.FontAntialias := False;
                bmp.FontStyle := [fsBold];



                if (sourceindex < 15) then
                  bmp.TextRect(rect(0, 0, 400, bmp.Height), ' UTC: ' + jsondatestring,
                    taLeftJustify, tltop, c);
                if (sourceindex = 22) then
                  bmp.TextRect(rect(0, 0, 400, bmp.Height), locationname,
                    taLeftJustify, tltop, c);

                // bmp.TextOut(bmp.Width, bmp.Height - bmp.FontFullHeight
                bmp.TextOut(bmp.Width, 0,
                  'God Is Love - 1 John 4:7-21', c, taRightJustify);

                bmp.SaveToFile(filepath + 'source.bmp');
                setdesktop(filepath + 'source.bmp');
                // finally
                //  renderer.free;
                //end;
              finally

                bmp.Free;
              end;

            end
            else
            begin

              logit(trim(FormatDateTime('h:nn:ss AM/PM', now) +
                ' ' + FormatDateTime('MM/DD/YYYY', now)) +
                ' ERROR - Reponse Code: ' + IntToStr(responsestatuscode));

            end;
          end;


        except
          on E: Exception do
            DumpExceptionCallStack(E);

        end;

      finally
        Free;

      end;
    end;


  finally

    logit(trim(FormatDateTime('h:nn:ss AM/PM', now) + ' ' +
      FormatDateTime('MM/DD/YYYY', now)) + ' GET: Thread Complete');

  end;
end;


function TMyThread.getlatestimagedate(groupname, jsonurl: string): string;
var
  s: string;
  jData: TJSONData;
  jArray: TJSONArray;
  groupprocess: integer;
begin
  with TFPHttpClient.Create(nil) do
  begin

    IOtimeout := 120000;
    AllowRedirect := True;

    try

      try

        if groupname = 'timestamps_int' then
          groupprocess := 1;
        if groupname = 'timestamps_int_map' then
        begin
          groupprocess := 2;
          groupname := 'timestamps_int';
        end;
        if groupname = 'dates_int' then
          groupprocess := 2;

        logit(trim(FormatDateTime('h:nn:ss AM/PM', now) + ' ' +
          FormatDateTime('MM/DD/YYYY', now)) + ' GET: ' + jsonurl);

        s := get(jsonurl);




        //https://rammb-slider.cira.colostate.edu/data/json/goes-16/full_disk/maps/borders/white/latest_times_all.json
        if (ResponseStatusCode = 200) then
        begin
          // try
          try
            jData := GetJSON(s);
            jArray := TJSONArray(jData.FindPath(groupname));
            if groupprocess = 1 then
              Result := trim(jarray.Arrays[0].Strings[0]);
            if groupprocess = 2 then
              Result := trim(jarray.Strings[0]);
          finally
            jarray.Free;

          end;
          {except
            on E: Exception do
            begin
              Result := '';
              DumpExceptionCallStack(E);
            end;

          end;}
        end
        else
        begin
          Result := '';
          logit(trim(FormatDateTime('h:nn:ss AM/PM', now) + ' ' +
            FormatDateTime('MM/DD/YYYY', now)) + ' ERROR - Reponse Code: ' +
            IntToStr(responsestatuscode));
        end;

      except
        on E: Exception do
        begin
          Result := '';
          DumpExceptionCallStack(E);

        end;
      end;


    finally
      Free;
    end;

  end;
end;

procedure TMyThread.logit(message: string);
begin

  fStatusText := message + ' (TID : ' + IntToStr(ThreadID) + ')';

  Synchronize(@Showstatus);

end;

procedure TMyThread.DumpExceptionCallStack(E: Exception);
var

  Report: string;
begin
  report := '';
  if E <> nil then
  begin
    Report := 'Exception class: ' + E.ClassName + ' | Message: ' + E.Message;
    logit(trim(FormatDateTime('h:nn:ss AM/PM', now) + ' ' +
      FormatDateTime('MM/DD/YYYY', now)) + ' ERROR: ' + report);

  end;
end;

procedure TMyThread.setdesktop(sWallpaperBMPPath: string);
var
  reg: TRegistry;
begin
  try

    reg := TRegistry.Create;
    try
      reg.RootKey := hkey_current_user;

      if reg.OpenKey('Control Panel\Desktop', True) then
      begin
        reg.WriteString('WallpaperStyle', IntToStr(0));

        SystemParametersInfo(SPI_SETDESKWALLPAPER, 0, PChar(sWallpaperBMPPath),
          SPIF_UPDATEINIFILE);
      end;

    finally
      reg.Free;
    end;
  except
    on E: Exception do
      DumpExceptionCallStack(E);

  end;

end;

function TMyThread.getsetpath(): string;
var
  PersonalPath: array[0..MaxPathLen] of char; //Allocate memory
  filepath: string;

begin

  try
    PersonalPath := '';
    SHGetSpecialFolderPath(0, PersonalPath, CSIDL_LOCAL_APPDATA, False);

    filepath := PersonalPath + '\Spacegetti\';
    if not directoryexists(filepath) then
      createdir(filepath);
    Result := filepath;
  except
    on E: Exception do
      DumpExceptionCallStack(E);

  end;
end;


function TMyThread.htmlgetvalue(sourceurl, startvalue: string): string;
var
  s: string;
  imageurl: string;
  imageurltemp: string;
begin
  with TFPHttpClient.Create(nil) do
  begin

    IOtimeout := 120000;
    AllowRedirect := True;



    try

      try


        logit(trim(FormatDateTime('h:nn:ss AM/PM', now) + ' ' +
          FormatDateTime('MM/DD/YYYY', now)) + ' GET: ' + sourceurl);

        s := get(sourceurl);

        if (ResponseStatusCode = 200) then
        begin
          //try
          begin

            imageurltemp := rightstr(s, (length(s) - pos(startvalue, s)) -
              length(startvalue) + 1);
            imageurl := leftstr(imageurltemp, pos('"', imageurltemp) - 1);

            Result := imageurl;
          end;
          {except
            on E: Exception do
            begin
              Result := '';
              DumpExceptionCallStack(E);
            end;

          end;}
        end
        else
        begin
          Result := '';
          logit(trim(FormatDateTime('h:nn:ss AM/PM', now) + ' ' +
            FormatDateTime('MM/DD/YYYY', now)) + ' ERROR - Reponse Code: ' +
            IntToStr(responsestatuscode));
        end;

      except
        on E: Exception do
        begin
          Result := '';
          DumpExceptionCallStack(E);

        end;
      end;


    finally
      Free;
    end;

  end;
end;

function TMyThread.constructstarmapurl: string;
var
  s: string;

  sourceurl: string;
  fieldlatandlong, fieldtime, fieldtimefix, fieldlat, fieldlong: string;
  startvalue, valtemp: string;
  yearval, monthval, dayval, hourval, minval, secval: string;
  rbase: integer;
  locationnameval: string;
begin
  with TFPHttpClient.Create(nil) do
  begin

    IOtimeout := 120000;
    AllowRedirect := True;



    try

      try

        fieldlatandlong := getlatlon;
        fieldlat := ExtractDelimited(1, fieldlatandlong, [#58]);
        fieldlong := ExtractDelimited(2, fieldlatandlong, [#58]);
        locationnameval := ExtractDelimited(3, fieldlatandlong, [#58]) +
          #13#10 + 'Lat: ' + fieldlat + #13#10 + 'Long: ' + fieldlong;


        sourceurl := 'https://www.skymaponline.net/default.aspx';

        logit(trim(FormatDateTime('h:nn:ss AM/PM', now) + ' ' +
          FormatDateTime('MM/DD/YYYY', now)) + ' GET: ' + sourceurl);

        s := get(sourceurl);

        if (ResponseStatusCode = 200) then
        begin
          //try
          begin

            startvalue :=
              '<input type="hidden" name="HiddenFieldTime" id="HiddenFieldTime" value="';
            valtemp := rightstr(s, (length(s) - pos(startvalue, s)) -
              length(startvalue) + 1);
            fieldtime := leftstr(valtemp, pos('"', valtemp) - 1);

            yearval := ExtractDelimited(1, fieldtime, [#44]);
            monthval := ExtractDelimited(2, fieldtime, [#44]);
            if length(monthval) = 1 then
              monthval := '0' + monthval;
            dayval := ExtractDelimited(3, fieldtime, [#44]);
            if length(dayval) = 1 then
              dayval := '0' + dayval;
            hourval := ExtractDelimited(4, fieldtime, [#44]);
            if length(hourval) = 1 then
              hourval := '0' + hourval;
            minval := ExtractDelimited(5, fieldtime, [#44]);
            if length(minval) = 1 then
              minval := '0' + minval;
            secval := ExtractDelimited(6, fieldtime, [#44]);
            if length(secval) = 1 then
              secval := '0' + secval;

            fieldtimefix := yearval + monthval + dayval + hourval + minval + secval;

            {  startvalue:='<input type="hidden" name="HiddenFieldLatitude" id="HiddenFieldLatitude" value="';
             valtemp := rightstr(s, (length(s) - pos(startvalue, s)) -
              length(startvalue) + 1);
            fieldlat := leftstr(valtemp, pos('"', valtemp) - 1);

             startvalue:='<input type="hidden" name="HiddenFieldLongitude" id="HiddenFieldLongitude" value="';
             valtemp := rightstr(s, (length(s) - pos(startvalue, s)) -
              length(startvalue) + 1);
            fieldlong := leftstr(valtemp, pos('"', valtemp) - 1);}

            rbase := min(screen.Height, screen.Width);
            Result := 'https://www.skymaponline.net/Handler1.ashx?r=' +
              IntToStr((rbase div 2) - 15) + '&x=' + IntToStr(
              (rbase div 2) - 15) + '&y=' + IntToStr((rbase div 2) - 15) +
              '&lat=%20' + trim(fieldlat) + '&long=' + trim(fieldlong) + '&time=' +
              fieldtimefix + '&rotation=90&w=' + IntToStr(rbase) +
             '&h=' + IntToStr(rbase) + '|' + locationnameval;

          end;
          {except
            on E: Exception do
            begin
              Result := '';
              DumpExceptionCallStack(E);
            end;

          end;}
        end
        else
        begin
          Result := '|';
          logit(trim(FormatDateTime('h:nn:ss AM/PM', now) + ' ' +
            FormatDateTime('MM/DD/YYYY', now)) + ' ERROR - Reponse Code: ' +
            IntToStr(responsestatuscode));
        end;

      except
        on E: Exception do
        begin
          Result := '|';
          DumpExceptionCallStack(E);

        end;
      end;


    finally
      Free;
    end;

  end;
end;

function TMyThread.getlatlon: string;
var
  s: string;

  valtemp: string;
  startvalue, sourceurl: string;
  latval, longval: string;
  cityval, regionval, countryval: string;
begin
  with TFPHttpClient.Create(nil) do
  begin

    IOtimeout := 120000;
    AllowRedirect := True;



    try

      try

        sourceurl :=
          'https://api.ipstack.com/check?access_key=keygoeshere';

        logit(trim(FormatDateTime('h:nn:ss AM/PM', now) + ' ' +
          FormatDateTime('MM/DD/YYYY', now)) + ' GET: ' + sourceurl);

        s := get(sourceurl);

        // s := '{"ip":"2605:6000:151e:8211:7887:379e:497:5a7d","country_code":"","country_name":"United States","region_code":"","region_name":"Texas","city":"","zip_code":"75002","time_zone":"America/Chicago","latitude":33.0856,"longitude":-96.6116,"metro_code":623}';


        if (ResponseStatusCode = 200) then
        begin
          //try
          begin

            startvalue := '"latitude":';
            valtemp := rightstr(s, (length(s) - pos(startvalue, s)) -
              length(startvalue) + 1);
            latval := leftstr(valtemp, pos(',', valtemp) - 1);

            startvalue := '"longitude":';
            valtemp := rightstr(s, (length(s) - pos(startvalue, s)) -
              length(startvalue) + 1);
            longval := leftstr(valtemp, pos(',', valtemp) - 1);


            startvalue := '"city": "';
            valtemp := rightstr(s, (length(s) - pos(startvalue, s)) -
              length(startvalue) + 1);
            cityval := leftstr(valtemp, pos('"', valtemp) - 1);

            startvalue := '"region_code": "';
            valtemp := rightstr(s, (length(s) - pos(startvalue, s)) -
              length(startvalue) + 1);
            regionval := leftstr(valtemp, pos('"', valtemp) - 1);

            startvalue := '"country_code": "';
            valtemp := rightstr(s, (length(s) - pos(startvalue, s)) -
              length(startvalue) + 1);
            countryval := leftstr(valtemp, pos('"', valtemp) - 1);


            Result := latval + ':' + longval + ':' +
              trim(cityval + ' ' + regionval + ' ' + countryval);

          end;
          {except
            on E: Exception do
            begin
              Result := '';
              DumpExceptionCallStack(E);
            end;

          end;}
        end
        else
        begin
          Result := '::';
          logit(trim(FormatDateTime('h:nn:ss AM/PM', now) + ' ' +
            FormatDateTime('MM/DD/YYYY', now)) + ' ERROR - Reponse Code: ' +
            IntToStr(responsestatuscode));
        end;

      except
        on E: Exception do
        begin
          Result := '::';
          DumpExceptionCallStack(E);

        end;
      end;


    finally
      Free;
    end;

  end;
end;

 procedure tform1.TrimAppMemorySize;
 var
   MainHandle : THandle;
 begin
   try
     MainHandle := OpenProcess(PROCESS_ALL_ACCESS, false, GetCurrentProcessID) ;
     SetProcessWorkingSetSize(MainHandle, $FFFFFFFF, $FFFFFFFF) ;
     CloseHandle(MainHandle) ;
   except
   end;
   Application.ProcessMessages;
 end;
end.
