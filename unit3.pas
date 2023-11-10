unit Unit3;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls, Math;

type

  { TForm2 }

  TForm2 = class(TForm)
    aperturebox: TEdit;
    apparentfielddrop: TComboBox;
    barlowlensdrop: TComboBox;
    Button1: TButton;
    eyepiecefocallengthbox: TEdit;
    focalratiobox: TEdit;
    focalreducerdrop: TComboBox;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);



    function round_fifth(num: float): float;
    function round_10(num: float): float;
    function round_100(num: float): float;
    function round_1000(num: float): float;
    procedure scope_calc;
    function IsNumericString(const inStr: string): boolean;
    procedure DumpExceptionCallStack(E: Exception; how: string);
    procedure logit(message: string);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.lfm}

{ TForm2 }


procedure tform2.Button1Click(Sender: TObject);
begin
  memo1.Clear;
  scope_calc;
end;





function tform2.round_fifth(num: float): float;
begin
  Result := floor(num / 5 + 0.5) * 5;
end;

function tform2.round_10(num: float): float;
begin
  Result := floor((num + 0.05) * 10) / 10;
end;

function tform2.round_100(num: float): float;
begin
  Result := floor((num + 0.005) * 100) / 100;
end;

function tform2.round_1000(num: float): float;
begin
  Result := floor((num + 0.0005) * 1000) / 1000;
end;

procedure tform2.scope_calc;

var
  eyepiece_apparent_field, eyepiece_focal_length, focal_ratio,
  barlow_factor, focal_reducer, focal_length, magnification, true_field,
  aperture, exit_pupil, resolving_power, m, limiting_magnitude: float;
  inch_or_mm: integer;
  scope_info: string;

begin
  try
  if isnumericstring(aperturebox.Text) then
    aperture := StrToFloat(aperturebox.Text)
  else
  begin
    ShowMessage('Please enter a valid figure for the telescopes aperture.');
    exit;
  end;


  if (isNaN(aperture)) then
  begin
    ShowMessage('Please enter a valid figure for the telescopes aperture.');
    exit;
  end;

  aperturebox.Text := floattostr(aperture);

  inch_or_mm := 1;

  aperture := aperture * inch_or_mm;




  if isnumericstring(focalratiobox.Text) then
    focal_ratio := StrToFloat(focalratiobox.Text)
  else
  begin
    ShowMessage('Please enter a valid figure for the telescope''s focal ratio.');
    exit;
  end;


  if (isNaN(focal_ratio)) then
  begin
    ShowMessage('Please enter a valid figure for the telescope''s focal ratio.');
    exit;
  end;

  focalratiobox.Text := floattostr(focal_ratio);


  if isnumericstring(eyepiecefocallengthbox.Text) then
    eyepiece_focal_length := strtofloat(eyepiecefocallengthbox.Text)
  else
  begin
    ShowMessage('Please enter a valid figure for the eyepiece''s focal length.');
    exit;
  end;




  if (isNaN(eyepiece_focal_length)) then
  begin
    ShowMessage('Please enter a valid figure for the eyepiece''s focal length.');
    exit;
  end;

  eyepiecefocallengthbox.Text := floattostr(eyepiece_focal_length);

  eyepiece_apparent_field := strtofloat(apparentfielddrop.Text);

  //end

  barlow_factor := strtofloat(barlowlensdrop.Text);
  focal_reducer := strtofloat(focalreducerdrop.Text);
  focal_length := aperture * focal_ratio * barlow_factor * focal_reducer;

  focal_ratio := round_10(focal_length / aperture);
  magnification := focal_length / eyepiece_focal_length;
  true_field := round_10(eyepiece_apparent_field / magnification);
  exit_pupil := round_10(aperture / magnification);
  resolving_power := round_100(115.824 / aperture);


  M := magnification;
  if (magnification > (22 * aperture / 25.4)) then
    M := 22 * aperture / 25.4;
  if (magnification > 1200) then
    M := 1200;

  limiting_magnitude := round_10(6.5 + 2.5 * ln(M * aperture / 25.4) / ln(10));

  if (magnification > aperture * 2) then
    ShowMessage(
      'This is a high magnification for such an aperture. Unless you''re primarily a double-star observer, try using an eyepiece with a focal length greater than ' + IntToStr(floor(focal_length / (2 * aperture) + 0.5)) + 'mm.');


  if (exit_pupil > 7) then
    ShowMessage(
      'To ensure that the eyepiece''s exit pupil is fully accommodated by your dark adapted eye, try selecting an eyepiece with a focal length less than ' + IntToStr(floor(7 * focal_ratio)) + 'mm.');


  if ((barlow_factor <> 1) and (focal_reducer <> 1)) then
    ShowMessage('Are you sure that you wish to use a focal reducer and a Barlow lens together?');


  scope_info := 'Focal Length:  ' + floattostr(round_fifth(focal_length)) + 'mm   ';

  if (focal_reducer <> 1.0) then
    scope_info := scope_info + '(You are using a ' + floattostr(focal_reducer) +
      'x focal reducer)';


  if (barlow_factor <> 1.0) then
    scope_info := scope_info + '(You are using a ' + floattostr(barlow_factor) +
      'x Barlow lens)';

  scope_info := scope_info + #13#10;


  scope_info := scope_info + 'Magnification: ' + IntToStr(floor(magnification + 0.5)) +
    'x' + #13#10;

  scope_info := scope_info + 'True Field of View: ' + floattostr(true_field) +
    ' (degree) ';

  if ((true_field >= 3.5) and (true_field < 7)) then
    scope_info := scope_info + '(Orion''s Belt could easily fit into the field of view)'
      +
      #13#10;



  if ((true_field >= 2.8) and (true_field < 3.5)) then
    scope_info := scope_info +
      '(Orion''s Belt would fit snuggly into the field of view)' + #13#10;


  if ((true_field >= 1.5) and (true_field < 2.8)) then
    scope_info := scope_info + '(The Pleiades would easily fit into the field of view)'
      + #13#10;


  if ((true_field >= 1.0) and (true_field < 1.5)) then
    scope_info := scope_info + '(The Pleiades could fit snuggly into the field of view)'
      +
      #13#10;


  if ((true_field >= 0.6) and (true_field < 1.0)) then
    scope_info := scope_info + '(The full Moon would easily fit into the field of view)'
      +
      #13#10;


  if ((true_field >= 0.50) and (true_field < 0.6)) then
    scope_info := scope_info + '(The full Moon could just fit within the field of view)'
      + #13#10;


  if ((true_field >= 0.35) and (true_field < 0.5)) then
    scope_info := scope_info +
      '(The full Moon would not quite fit into the field of view)' + #13#10;

  if ((true_field >= 0.25) and (true_field < 0.35)) then
    scope_info := scope_info +
      '(About half of the full Moon''s disc would fit into the field of view)' + #13#10;

  if (true_field < 0.25) then
    scope_info := scope_info +
      '(Less than half of the full Moon''s disc would fit into the field of view)'
      + #13#10;

  scope_info := scope_info + 'Exit Pupil: ' + floattostr(exit_pupil) + ' mm' + #13#10;

  scope_info := scope_info + 'Theoretical Resolving Power: ' +
    floattostr(resolving_power) + ' arcseconds' + #13#10;

  scope_info := scope_info + 'Approximate Limiting Magnitude of Telescope: +' +
    floattostr(limiting_magnitude) + ' (under dark, moonless skies)';
  memo1.Text := scope_info;
   except
    on E: Exception do
      DumpExceptionCallStack(E, 'showmessage');

  end;
end;

function tform2.IsNumericString(const inStr: string): boolean;
var
  i: extended;
begin
  Result := TryStrToFloat(inStr, i);
end;

 procedure tform2.logit(message: string);
begin

  if (memo1.Lines.Count > 50) then
    memo1.Lines.Delete(0);


  memo1.Lines.Add(message);

end;



procedure TForm2.DumpExceptionCallStack(E: Exception; how: string);
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

    end
    else
    begin

      logit(trim(FormatDateTime('h:nn:ss AM/PM', now) + ' ' +
        FormatDateTime('MM/DD/YYYY', now)) + ' ERROR: ' + report);

    end;
  end;

end;

end.
