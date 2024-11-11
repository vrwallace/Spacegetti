program spacegetti;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX} {$IFDEF UseCThreads}
  cthreads, {$ENDIF} {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  Unit1,
  Unit3 { you can add units after this };

  {$R *.res}

begin
  Application.Scaled := True;
  Application.Title := 'Spacegetti';
  RequireDerivedFormResource := True;
  Application.Initialize;
  //Application.ShowMainForm := False;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
