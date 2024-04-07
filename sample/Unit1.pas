unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Menus, Vcl.ComCtrls;

type
  TForm1 = class(TForm)
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Open1: TMenuItem;
    SaveAs1: TMenuItem;
    Exit1: TMenuItem;
    N2: TMenuItem;
    Image1: TImage;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    StatusBar1: TStatusBar;
    procedure Open1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure SaveAs1Click(Sender: TObject);
  private
    { Private êÈåæ }
  public
    { Public êÈåæ }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses Jpeg, MagImage;

procedure TForm1.Exit1Click(Sender: TObject);
begin
  Close;
end;

procedure TForm1.Open1Click(Sender: TObject);
VAR
	i : INTEGER;
	s: STRING;
begin
	IF OpenDialog1.Execute THEN
	BEGIN
		FOR i := 0 TO 0 DO
			Image1.Picture.LoadFromFile( OpenDialog1.FileName ) ;

		s := Format('%d * %d ', [Image1.Picture.Width, Image1.Picture.Height]);
		IF Image1.Picture.Graphic IS TMAGImage THEN
		BEGIN
			CASE TMAGImage(Image1.Picture.Graphic).PixelFormat OF
				mpf4Bit : s := s + '* 4';
				mpf8Bit : s := s + '* 8';
			END;
			s := s + ' [';
      s := s + TMAGImage(Image1.Picture.Graphic).User;
      s := s +  '] ';
      s := s + TMAGImage(Image1.Picture.Graphic).Comment;
		END;
		StatusBar1.SimpleText := s;
	END ;
end;

procedure TForm1.SaveAs1Click(Sender: TObject);
var
	grp	: TGraphic;
	ext	: STRING;
begin
	IF SaveDialog1.Execute THEN
	BEGIN
		ext := ExtractFileExt(SaveDialog1.FileName) ;
		IF CompareText(ext, '.bmp') = 0 THEN
			grp := TBitmap.Create
		ELSE IF CompareText(ext, '.mag') = 0 THEN
		BEGIN
			IF (Image1.Picture.Graphic IS TJPEGImage) THEN
				TJPEGImage(Image1.Picture.Graphic).PixelFormat := jf8Bit;
			grp := TMAGImage.Create
		END
		ELSE IF CompareText(ext, '.jpg') = 0 THEN
			grp := TJPEGImage.Create
		ELSE
			Exit;

		TRY
			grp.Assign(Image1.Picture.Graphic);
			grp.SaveToFile(SaveDialog1.FileName);
		FINALLY
			grp.Free;
		END;
	END;
end;

end.
