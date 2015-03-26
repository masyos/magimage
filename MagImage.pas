(***********************************************************************
 *  MAG Image classes
 *              Copyright (c)1997,1999, 2012, 2015 YOSHIDA, Masahiro.
 *              https://github.com/masyos/magimage
 *
 *  1997.01.13  first.(Delphi 2 and Uncomress only)
 *  1999.06.26  Delphi 4 only. But uncompress speed up.
 *  1999.06.30  Compress support.
 *  1999.08.26  ...
 *  1999.10.20  DIBNeeded bug fix.
 *  2012.07.13  Mag.pas + MagType.pas => MagImage.pas
 *  2015.03.26  to Delphi XE2.
 *--------------------------------------------------------------------*
 *  classes
 ***********************************************************************)

unit MagImage;

interface

uses
  Windows, SysUtils, Classes, Graphics;

(*--------------------------------------------------------------------*)
(* Mag comments *)
const
  MagID : array [0..7] of AnsiChar = 'MAKI02  ';
  MagCommentEnd : AnsiChar = #$1A;
  MagMachineDefault  = $00;(* 98/68 その他多く *)
  MagMachineMsx    = $03;(* msx  （Meron版) *)
  MagMachine88     = $88;(* 88    (Argon版) *)
  MagMachine68     = $68;(* PST68 (Kenna) *)
  MagMachineEse    = $FF;(* 似非キース (Hironon) *)

  (* table *)
  MagBTableX : array [0..15] of Byte = (
    0, 2, 4, 8, 0, 2, 0, 2, 4, 0, 2, 4, 0, 2, 4, 0
  );
  MagBTableY : array [0..15] of Byte = (
    0, 0, 0, 0, 1, 1, 2, 2, 2, 4, 4, 4, 8, 8, 8,16
  );
  MagEncodeSearch : array [0..15] of Byte = 
    ( 0, 1, 4, 5, 6, 7, 9,10, 2, 8,11,12,13,14, 3,15 ) ;


(*--------------------------------------------------------------------*)
type
  TMagScreens = (
    msHalfHeight,  ms8Colors,    msDigitalColor,  msReserved1,
    msReserved2,  msReserved3,  msReserved4,  ms256Colors
  );
  TMagScreenFlag = set of TMagScreens;

  (* Mag file header *)
  PMagID = ^TMagID;
  TMagID = packed record
    ID     : array [0..7] of AnsiChar;
    Machine: array [0..3] of AnsiChar;
    User   : array [0..19] of AnsiChar;
  end;(*record*)

  PMagHeader = ^TMagHeader;
  TMagHeader = packed record
    Head      : Byte;        (* ヘッダの先頭 = $00 *)
    Machine   : Byte;        (* 機種コード *)
    MachineFlag: Byte;       (* 機種依存フラグ *)
    ScreenMode: TMagScreenFlag;(* スクリーンモード *)
    BeginX    : Word;        (* 表示開始位置Ｘ *)
    BeginY    : Word;        (* 表示開始位置Ｙ *)
    EndX      : Word;        (* 表示終了位置Ｘ *)
    EndY      : Word;        (* 表示終了位置Ｙ *)
    FlagAOfs  : Cardinal;    (* フラグＡのオフセット *)
    FlagBOfs  : Cardinal;    (* フラグＢのオフセット *)
    FlagBSize : Cardinal;    (* フラグＢのサイズ *)
    PixelOfs  : Cardinal;    (* ピクセルのオフセット *)
    PixelSize : Cardinal;    (* ピクセルのサイズ *)
  end;(*record*)

  PMagPalette = ^TMagPalette;
  TMagPalette = packed record
    Green, Red, Blue : Byte;
  end;(*record*)
  PMagPalette16 = ^TMagPalette16;
  TMagPalette16 = packed array [0..15] of TMagPalette;
  PMagPalette256 = ^TMagPalette256;
  TMagPalette256 = packed array [0..255] of TMagPalette;


  (* MAG pixel format *)
  TMagPixelFormat = (mpf4Bit, mpf8Bit);

  (* Exception *)
  EMagError = class(Exception);
  (* Exception *)
  EInvalidMagOperation = class(EInvalidGraphicOperation);

  (* Raw data *)
  TMagData = class(TSharedImage)
  private
    FData    : TMemoryStream;
    FID      : TMagID;
    FHeader    : TMagHeader;
    FWidth, 
    FHeight    : Integer;
  protected
    procedure FreeHandle; override;
  public
    destructor Destroy; override;
  end;

  (* Image *)
  TMAGImage = class(TGraphic)
  private
    FImage    : TMagData;
    FBitmap    : TBitmap;
    FPixelFormat: TMagPixelFormat;
    FPalette  : HPALETTE;
    FUser,
    FComment  : AnsiString;
    FHalfHeight  : Boolean;
    FTop, FLeft  : Word;
    (* new *)
    procedure CompressPixel(FlagA: PByte; FlagB, Pixel: TStream);
    function GetBitmap: TBitmap;
    procedure SetPixelFormat(value: TMagPixelFormat);
    procedure SetComment(value: AnsiString);
    procedure SetUser(value: AnsiString);
    procedure SetHalfHeight(value: Boolean);
    procedure SetTop(value: Word);
    procedure SetLeft(value: Word);

  protected
    (* abstract *)
    procedure Draw(ACanvas: TCanvas; const Rect: TRect); override;
    function GetEmpty: Boolean; override;
    function GetHeight: Integer; override;
    function GetWidth: Integer; override;
    procedure SetHeight(Value: Integer); override;
    procedure SetWidth(Value: Integer); override;
    (* override *)
    procedure AssignTo(Dest: TPersistent); override;
    function Equals(Graphic: TGraphic): Boolean; override;
    function GetPalette: HPALETTE; override;
    procedure SetPalette(value: HPALETTE); override;
    procedure ReadData(Stream: TStream); override;
    procedure WriteData(Stream: TStream); override;
    (* new *)
    (* init *)
    procedure SetDefaultData; virtual;
    (* free palette *)
    procedure FreePalette;
    (* free bitmap *)
    procedure FreeBitmap;
    (* new bitmap *)
    procedure NewBitmap;
    (* new Raw data *)
    procedure NewImage;
    (* reader *)
    procedure ReadStream(Size: Integer; Stream: TStream);
    (* decode *)
    procedure LoadPalette;
    procedure Uncompress;

    (* bitmap *)
    property Bitmap: TBitmap read GetBitmap;

  public
    constructor Create; override;
    destructor Destroy; override;
    (* abstract *)
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    procedure LoadFromClipboardFormat(AFormat: Word; AData: THandle;
        APalette: HPALETTE); override;
    procedure SaveToClipboardFormat(var AFormat: Word; var AData: THandle;
        var APalette: HPALETTE); override;
    (* override *)
    procedure Assign(Source: TPersistent); override;

    (* new *)
    (* encode *)
    procedure Compress;
    (* make MAG *)
    procedure MAGNeeded;
    (* make DIB *)
    procedure DIBNeeded;

  (* property *)
    (* pixel format *)
    property PixelFormat: TMagPixelFormat read FPixelFormat Write SetPixelFormat;
    (* aspect h 1/2 *)
    property HalfHeight: Boolean read FHalfHeight Write SetHalfHeight;
    (* user name *)
    property User: AnsiString read FUser Write SetUser;
    (* comment *)
    property Comment: AnsiString read FComment Write SetComment;
    (* position top *)
    property Top: Word read FTop Write SetTop;
    (* position left *)
    property Left: Word read FLeft Write SetLeft;
  end;

(* use design *)
procedure Register;

(***********************************************************************)
implementation

(*====================================================================*)
type
  PByteArray = ^TByteArray;
  TByteArray = array [0..MaxInt-1] of Byte;

const
  MagCommentDefault :AnsiString = 'mas''s TMAGImage Ver 1.10';
  MagUserDefault    :array [0..19] of AnsiChar = '>??<';
  MagMachine        :array [0..3] of AnsiChar = 'masP';

procedure MagError(msg: String) ;
begin
  raise EMagError.Create('MAG image error:' + msg) ;
end ;

procedure MagInvaild(msg: String);
begin
  raise EInvalidMagOperation.Create('MAG invaild operation:' + msg);
end;


//##HPaletteToMagPalette
procedure HPaletteToMagPalette(const header: TMagHeader; hp: HPALETTE; pal : PMagPalette);
var
  p, p2 : PPaletteEntry;
  Num, i : Integer;
begin
  if ms256Colors in header.ScreenMode then
    Num := 256
  else
    Num := 16;

  GetMem(p, SizeOf(TPaletteEntry) * Num);
  GetPaletteEntries(hp, 0, Num, p^);
  p2 := p;
  for i := 0 to Num-1 do
  begin
    pal^.Green := p2^.peGreen;
    pal^.Red := p2^.peRed;
    pal^.Blue := p2^.peBlue;
    Inc(p2);
    Inc(pal);
  end;
  FreeMem(p);
end;

{$IFDEF  OLDMAG}
procedure MagPalette16Load(var pal : TMagPalette16);
var
  i : Integer;
begin
  for i := 0 to 15 do
  begin
    pal[i].Green := (pal[i].Green shr 4) * $11;
    pal[i].Red   := (pal[i].Red   shr 4) * $11;
    pal[i].Blue  := (pal[i].Blue  shr 4) * $11;
  end;
end;
{$ENDIF}

//##MagPaletteToHPalette
function MagPaletteToHPalette(const header: TMagHeader; pal: PMagPalette): HPALETTE;
var
  p : PLogPalette;
  i, Num : Integer;
begin
  if ms256Colors in header.ScreenMode then
    Num := 256
  else
    Num := 16;

  GetMem(p, SizeOf(TLogPalette) + SizeOf(TPaletteEntry) * Num);
  p^.palVersion := $0300;
  p^.palNumEntries := Num;
  for i := 0 to Num-1 do
  begin
    p^.palPalEntry[i].peRed   := pal^.Red;
    p^.palPalEntry[i].peGreen := pal^.Green;
    p^.palPalEntry[i].peBlue  := pal^.Blue;
    p^.palPalEntry[i].peFlags := 0;
    Inc(pal);
  end;
  Result := CreatePalette(p^);
  FreeMem(p);
end;

(*--------------------------------------------------------------------*)
//##MagReadHeader
function MagGetHeader(data: POINTER; var id: TMagID; var comment: AnsiString): PMagHeader;
var
  ch, tmp : PAnsiChar;
  i : Integer;
begin
  Result := nil;

  Move(data^, id, SizeOf(TMagID));
  if CompareMem(@id.ID, @MagID, 8) = FALSE then
    Exit;
  ch := data;
  Inc(ch , SizeOf(TMagID));

  i := 0;
  tmp := ch;
  while tmp^ <> MagCommentEnd do
  begin
    Inc(tmp);
    Inc(i);
  end;
  SetLength(comment, i);
  Move(ch^, comment[1], i);
  ch := tmp;
  Inc(ch);
  Result := PMagHeader(ch);
end;

(*--------------------------------------------------------------------*)
//##MagReadPalette
function MagReadPalette(data : POINTER; const header: TMagHeader; pal : PMagPalette): POINTER;
var
  Num : Integer;
begin
  if ms256Colors in header.ScreenMode then
    Num := 256
  else
    Num := 16;

  Move(data^, pal^, SizeOf(TMagPalette)*Num);
{$IFDEF OLDMAG}
  (* 古い MAG 形式なら 12bits なので必要だが、新しいものは不要 *)
  if (Num = 16) then
    MagPalette16Load(PMagPalette16(pal)^);
{$ENDIF}
  Inc(PByte(data), SizeOf(TMagPalette)*Num);
  Result := data;
end;

(*--------------------------------------------------------------------*)
function MagImageWidth(const header: TMagHeader): Integer;
var
  i: Integer;
begin
  if ms256Colors in header.ScreenMode then
    i := 4
  else
    i := 8;

  Result := (header.EndX - (header.EndX mod i)+(i-1)) -
      (header.BeginX - (header.BeginX mod i)) +1 ;
end;

function MagImageHeight(const header: TMagHeader): Integer;
begin
  Result := header.EndY - header.BeginY +1 ;
end;

function MagImageSize(const header: TMagHeader): Integer;
begin
  Result := MagImageHeight(header) * MagImageWidth(header) ;

  if not(ms256Colors in header.ScreenMode) then
    Result := Result div 2;
end;





(*--------------------------------------------------------------------*)
procedure NormalBitmap(Bitmap: TBitmap);
begin
  if Bitmap = nil then  Exit;

  (* 利用できない Palette を変更 *)
  case Bitmap.PixelFormat of
    pf1Bit  : Bitmap.PixelFormat := pf4Bit;
    pf4Bit, pf8Bit: ;
    else
      Bitmap.PixelFormat := pf8Bit;
  end;
  (* 幅の調整 *)
  case Bitmap.PixelFormat of
    pf4Bit  :   Bitmap.Width := (Bitmap.Width + 7) and (not 7);
    pf8Bit  :   Bitmap.Width := (Bitmap.Width + 3) and (not 3);
  end;
end;

(*--------------------------------------------------------------------*)
//{###TMagData
destructor TMagData.Destroy; (*is*)
begin
  FData.Free;
  inherited Destroy;
end;

procedure TMagData.FreeHandle; (*is*)
begin
end;

(*====================================================================*)
(*--------------------------------------------------------------------*)
constructor TMAGImage.Create;
begin
  inherited Create;
  NewImage;
  SetDefaultData;
{
  FPixelFormat := mpf4Bit;
  FComment := MagCommentDefault;
  FUser := MagUserDefault;
  FHalfHeight := FALSE;
}
end;

destructor TMAGImage.Destroy;
begin
  if FPalette <> 0 then
    DeleteObject(FPalette);
  FBitmap.Free;
  FImage.Release;
  inherited Destroy;
end;

(*--------------------------------------------------------------------*)
procedure TMAGImage.Draw(ACanvas: TCanvas; const Rect: TRect); 
begin
  ACanvas.StretchDraw(Rect, Bitmap);
end;

(*--------------------------------------------------------------------*)
function TMAGImage.GetEmpty: Boolean;
begin
  Result := (FImage.FData = nil) and FBitmap.Empty;
end;

function TMAGImage.Equals(Graphic: TGraphic): Boolean;
begin
  Result := (Graphic is TMAGImage) and 
    (FImage = TMAGImage(Graphic).FImage);
end;

(*--------------------------------------------------------------------*)
function TMAGImage.GetHeight: Integer;
begin
  if FBitmap <> nil then
    Result := FBitmap.Height 
  else
    Result := FImage.FHeight;
end;

function TMAGImage.GetWidth: Integer;
begin
  if FBitmap <> nil then
    Result := FBitmap.Width 
  else
    Result := FImage.FWidth;
end;

procedure TMAGImage.SetHeight(Value: Integer);
begin
  if (FTop + Value) > $FFFF then
    MagInvaild('range over');
  Bitmap.Height := Value;
  Changed(Self);
end;

procedure TMAGImage.SetWidth(Value: Integer);
begin
  case FPixelFormat of
    mpf4Bit  :   Value := (Value + 7) and (not 7);
    mpf8Bit  :   Value := (Value + 3) and (not 3);
  end;
  if (FLeft + Value) > $FFFF then
    MagInvaild('range over');
  Bitmap.Width := Value ;
  Changed(Self);
end;

(*--------------------------------------------------------------------*)

function TMAGImage.GetPalette: HPALETTE;
begin
  if FBitmap <> nil then
    Result := FBitmap.Palette 
  else
    Result := FPalette;
end;

procedure TMAGImage.SetPalette(value: HPALETTE);
begin
  Bitmap.Palette := value;
  PaletteModified := TRUE;
  Changed(Self);
end;
(*--------------------------------------------------------------------*)
procedure TMAGImage.SetDefaultData;
begin
  FPixelFormat := mpf4Bit;
  FComment := MagCommentDefault;
  FUser := MagUserDefault;
  FHalfHeight := FALSE;
  FTop := 0;
  FLEft := 0;
end;

function TMAGImage.GetBitmap: TBitmap;
begin
  if FBitmap = nil then
  begin
    NewBitmap;
    if FImage.FData <> nil then
      Uncompress;
  end;
  Result := FBitmap;
end;

procedure TMAGImage.SetPixelFormat(value: TMagPixelFormat);
begin
  if FPixelFormat = value then  Exit;
  FPixelFormat := value;
  case value of
    mpf4Bit  : FBitmap.PixelFormat := pf4Bit;
    mpf8Bit  : FBitmap.PixelFormat := pf8Bit;
  end;
  Changed(Self);
end;

procedure TMAGImage.SetComment(value: AnsiString);
begin
  FComment := value;
  Changed(Self);
end;

procedure TMAGImage.SetUser(value: AnsiString);
begin
  FUser := Copy(value, 1, 18);
  Changed(Self);
end;

procedure TMAGImage.SetHalfHeight(value: Boolean);
begin
  if FHalfHeight = value then  Exit;
  FHalfHeight := value;
  Changed(Self);
end;

procedure TMAGImage.SetTop(value: Word);
begin
  if (FTop + Height) > $FFFF then
    MagInvaild('range over');
  FTop := value;
  Changed(Self);
end;

procedure TMAGImage.SetLeft(value: Word);
begin
  case FPixelFormat of
    mpf4Bit  :   Value := Value and (not 7);
    mpf8Bit  :   Value := Value and (not 3);
  end;
  if (FLeft + Width) > $FFFF then
    MagInvaild('range over');
  FLeft := value;
  Changed(Self);
end;

(*--------------------------------------------------------------------*)
(* desined *)
procedure TMAGImage.ReadData(Stream: TStream);
var
  Size  : LongInt;
begin
  Stream.Read(Size, SizeOf(Size));
  ReadStream(Size, Stream);
end;

procedure TMAGImage.WriteData(Stream: TStream);
var
  Size  : LongInt;
begin
  if (FImage.FData = nil) or (Modified) then
    Compress;
  Size := FImage.FData.Size;
  Stream.Write(Size, SizeOf(Size));
  FImage.FData.SaveToStream(Stream);
end;

(*--------------------------------------------------------------------*)
procedure TMAGImage.LoadFromStream(Stream: TStream);
begin
  ReadStream(Stream.Size - Stream.Position, Stream);
end;

procedure TMAGImage.SaveToStream(Stream: TStream);
begin
  if (FImage.FData = nil) or (Modified) then
    Compress;
  FImage.FData.SaveToStream(Stream);
end;

procedure TMAGImage.LoadFromClipboardFormat(AFormat: Word; 
    AData: THandle; APalette: HPALETTE);
begin
  Bitmap.LoadFromClipboardFormat(AFormat, AData, APalette);
end;

procedure TMAGImage.SaveToClipboardFormat(var AFormat: Word; 
    var AData: THandle; var APalette: HPALETTE);
begin
  Bitmap.SaveToClipboardFormat(AFormat, AData, APalette);
end;

(*--------------------------------------------------------------------*)
procedure TMAGImage.AssignTo(Dest: TPersistent);
begin
  if (Dest is TGraphic) then
  begin
    Dest.Assign(Bitmap);
  end
  else
    inherited AssignTo(Dest);
end;

procedure TMAGImage.Assign(Source: TPersistent);
begin
  if (Source is TMAGImage) then
  begin
    FImage.Release;
    FImage := TMAGImage(Source).FImage;
    FImage.Reference;
    FComment := TMAGImage(Source).FComment;
    FUser := TMAGImage(Source).FUser;
    FPixelFormat := TMAGImage(Source).FPixelFormat;
    FHalfHeight := TMAGImage(Source).FHalfHeight;
    FTop := TMAGImage(Source).FTop;
    FLeft := TMAGImage(Source).FLeft;

    FreePalette;
    if TMAGImage(Source).FPalette <> 0 then
      FPalette := CopyPalette(TMAGImage(Source).FPalette);

    if TMAGImage(Source).FBitmap <> nil then
    begin
      (* Has Bitmap *)
      NewBitmap;
      FBitmap.Assign( TMAGImage(Source).FBitmap );
    end;
    PaletteModified := TRUE;
    Changed(Self);
  end
  else if Source is TGraphic then
  begin
    (* Bitmap *)
    NewImage;
    NewBitmap;
    FreePalette;
    FBitmap.Assign(Source);
    (* 微調整 *)
    SetDefaultData;
    NormalBitmap(FBitmap);
    case FBitmap.PixelFormat of
      pf4Bit  :   FPixelFormat := mpf4Bit;
      pf8Bit  :   FPixelFormat := mpf8Bit;
    end;
    PaletteModified := TRUE;
    Changed(Self);
  end
  else
    inherited Assign(Source);
end;

(*--------------------------------------------------------------------*)
procedure TMAGImage.FreePalette;
begin
  if FPalette <> 0 then
  begin
    DeleteObject(FPalette);
    FPalette := 0;
  end;
end;

procedure TMAGImage.FreeBitmap;
begin
  FBitmap.Free;
  FBitmap := nil;
end;

procedure TMAGImage.NewBitmap;
begin
  FBitmap.Free;
  FBitmap := TBitmap.Create;
  FBitmap.PixelFormat := pf4Bit;
  FBitmap.Width := 8;
end;

procedure TMAGImage.NewImage;
begin
  if FImage <> nil then FImage.Release;
  FImage := TMAGData.Create;
  FImage.Reference;

  with FImage do
  begin
    FillChar(FID, SizeOf(FID), $20);
    Move(MagID, FID.ID, SizeOf(FID.ID));
    Move(MagMachine, FID.Machine, SizeOf(FID.Machine));
  end;
end;

(*--------------------------------------------------------------------*)
procedure TMAGImage.MAGNeeded;
begin
  if FImage.FData = nil then
    Compress;
end;

procedure TMAGImage.DIBNeeded;
begin
  GetBitmap;
end;

(*--------------------------------------------------------------------*)
procedure TMAGImage.ReadStream(Size: Integer; Stream: TStream);
var
  p    : PAnsiChar;
begin
  NewImage;
  FreePalette;
  NewBitmap;
  with FImage do
  begin
    FData.Free ;
    FData := TMemoryStream.Create ;
    FData.Size := Size;
    Stream.ReadBuffer(FData.Memory^, Size);

    (* header + size *)
    p := PAnsiChar( MagGetHeader(FData.Memory, FID, FComment) );
    if p = nil then
      MagError( 'is not MAG.' ) ;
    Move(p^, FHeader, SizeOf(TMagHeader));

    SetLength(FUser, 18);
    Move(FID.User[1], FUser[1], 18);
    FHalfHeight := msHalfHeight in FHeader.ScreenMode;
    FTop := FHeader.BeginY;
    FLeft:= FHeader.BeginX;
    FWidth := MagImageWidth(FHeader);
    FHeight := MagImageHeight(FHeader);

    if (ms256Colors in FHeader.ScreenMode) then
    begin
      FPixelFormat := mpf8Bit;
      FLeft := FLeft and (not 3);
    end
    else
    begin
      FPixelFormat := mpf4Bit;
      FLeft := FLeft and (not 7);
    end;
  end;

  Uncompress;
end;

(*--------------------------------------------------------------------*)
const
  MagBTableXW : array [0..15] of Byte = 
    ( 0, 1, 2, 4, 0, 1, 0, 1, 2, 0, 1, 2, 0, 1, 2, 0 ) ;

procedure TMAGImage.LoadPalette;
var
  p    : PAnsiChar;
  mpal  : TMagPalette256;
begin
  FreePalette;

  p := FImage.FData.Memory;
  while p^ <> #$00 do
  begin
    Inc(p);
  end;
  Inc(p, SizeOf(TMagHeader));

  MagReadPalette(p, FImage.FHeader, @mpal);
  FPalette := MagPaletteToHPalette(FImage.FHeader, @mpal);

  PaletteModified := True;
end;

procedure TMAGImage.Uncompress;
var
  Lines    : array of Pointer;//PPointerList;
  pP, pPic  : PWORD;
  y      : Integer;

  procedure PutPixel(flag: Byte; xx: Integer);
  var
    p: PWORD;
  begin
    if flag = 0 then 
    begin
      pPic^ := pP^;
      Inc(pP);
    end
    else
    begin
      p := Lines[ y - MagBTableY[flag] ];//^[ y - MagBTableY[flag] ];
      Inc(p, xx - MagBTableXW[flag] );
      pPic^ := p^;
    end;
  end;

var
  pA, pB  : PByte;
  Mask  : Byte;
  Buff  : PByteArray;
  x, w  : Integer;
begin
  (* init bitmap *)
  FBitmap.Width := FImage.FWidth;
  FBitmap.Height := FImage.FHeight;
  if (ms256Colors in FImage.FHeader.ScreenMode) then
    FBitmap.PixelFormat := pf8bit
  else
    FBitmap.PixelFormat := pf4bit;
  LoadPalette;
  FBitmap.Palette := CopyPalette(FPalette);

  (* init *)
  pA := PByte( StrEnd( PAnsiChar(FImage.FData.Memory) ) );
  pB := pA;
  pP := PWORD(pA);
  Inc(pA, FImage.FHeader.FlagAOfs );
  Inc(pB, FImage.FHeader.FlagBOfs ) ;
  Inc(PByte(pP), FImage.FHeader.PixelOfs ) ;
  Mask := $80;

  w := FImage.FWidth div 4;
  if FPixelFormat = mpf4Bit then
    w := w div 2;
  Buff := AllocMem(w);
  try
    SetLength(Lines, FImage.FHeight); //Lines := AllocMem(SizeOf(POINTER) * FImage.FHeight);
    try
      (* アクセス速度を上げるため、あらかじめラインの先頭アドレスを設定 *)
      (*  ScanLine 呼び出しごとにラインの先頭アドレスが変わるのも回避する *)
      pPic := FBitmap.ScanLine[FImage.FHeight-1];
      for y := FImage.FHeight-1 downto 0 do
      begin
        Lines[y] := pPic;//Lines^[y] := pPic;
        Inc(pPic, w*2);
      end;

      (* pixel *)
      for y := 0 to FImage.FHeight-1 do
      begin
        pPic := Lines[y];//^[y];
        for x := 0 to w-1 do
        begin
          if (pA^ and Mask)<>0 then
          begin
            Buff^[x] := Buff^[x] xor pB^;
            Inc(pB) ;
          end ;

          Mask := Mask shr 1;
          if Mask = $00 then
          begin
            Mask := $80 ;
            Inc(pA) ;
          end ;

          PutPixel(Buff^[x] shr 4, x*2);//LoNibble(Buff^[x]), x*2);
          Inc(pPic);
          PutPixel(Buff^[x] and $0F, x*2+1);//HiNibble(Buff^[x]), x*2+1);
          Inc(pPic);
        end ;
      end ;
    finally
      //FreeMem(Lines);
    end;
  finally
    FreeMem(Buff);
  end;
  Changed(Self);
end;

(*--------------------------------------------------------------------*)
(*--------------------------------------------------------------------*)
procedure TMAGImage.CompressPixel(FlagA: PByte; FlagB, Pixel: TStream);
var
  Lines  : array of Pointer;//PPointerList;
  y    : Integer;
  pPic  : PWORD;

  function SearchPixel(x: Integer; upper: Byte): Byte;
  var
    p  : PWORD;
  begin
    (* 真上のフラグと同じのほうが圧縮率がよい *)
    Result := upper;
    if (Result <> 0) and ((y - MagBTableY[Result]) >= 0) and ((x - MagBTableXW[Result]) >= 0) then
    begin
      p := Lines[ y - MagBTableY[Result] ];
      Inc(p, x - MagBTableXW[Result] );
      if pPic^ = p^ then  Exit;
    end;

    for Result := 1 to 15 do
    begin
      if ((y - MagBTableY[Result]) >= 0) and ((x - MagBTableXW[Result]) >= 0) then
      begin
        p := Lines[ y - MagBTableY[Result] ];
        Inc(p, x - MagBTableXW[Result] );
        if pPic^ = p^ then  Exit;
      end;
    end;
    Result := 0;
  end;

var
  Buff  : PByteArray;
  x, w  : Integer;
  bh, bl  : Byte;
  Mask, b  : Byte;
begin
  Mask := $80;
  w := FBitmap.Width div 4;
  if FPixelFormat = mpf4Bit then
    w := w div 2;

  Buff := AllocMem(w);
  try
    SetLength(Lines, FBitmap.Height);
    try
      (* アクセス速度を上げるため、あらかじめラインの先頭アドレスを設定 *)
      (*  ScanLine 呼び出しごとにラインの先頭アドレスが変わるのも回避する *)
      pPic := FBitmap.ScanLine[FBitmap.Height-1];
      for y := FBitmap.Height-1 downto 0 do
      begin
        Lines[y] := pPic;
        Inc(pPic, w*2);
      end;

      (* pixel *)
      for y := 0 to FBitmap.Height-1 do
      begin
        pPic := Lines[y];
        for x := 0 to w-1 do
        begin
          bl := SearchPixel(x*2, Buff^[x] shr 4);
          if bl = 0 then    Pixel.WriteBuffer(pPic^, SizeOf(Word));
          Inc(pPic);
          bh := SearchPixel(x*2+1, Buff^[x] and $0F);
          if bh = 0 then    Pixel.WriteBuffer(pPic^, SizeOf(Word));
          Inc(pPic);

          (* １ライン上のフラグと xor なのだ *)
          b := Buff^[x] xor ((bl shl 4) or bh);
          Buff^[x] := (bl shl 4) or bh;
          if b <> $00 then
          begin
            FlagA^ := FlagA^ or Mask;
            FlagB.WriteBuffer(b, SizeOf(Byte));
          end;

          Mask := Mask shr 1;
          if Mask = $00 then
          begin
            Mask := $80 ;
            Inc(FlagA);
          end;
        end;
      end ;
    finally
      //FreeMem(Lines);
    end;
  finally
    FreeMem(Buff);
  end;

  (* 正規化 *)
  b := $00;
  if (FlagB.Size mod 2) = 1 then
    FlagB.WriteBuffer(b, SizeOf(Byte));
end;


(*--------------------------------------------------------------------*)
procedure TMAGImage.Compress;
var
  A    : PByte;
  B, P  : TMemoryStream;
  pal    : TMagPalette256;
  ASize  : Integer;
  colors  : Integer;
begin
  if FBitmap = nil then
    MagInvaild('not have DIB');

  NewImage;
  colors := 256;

  ASize := ((FBitmap.Width div 4) * FBitmap.Height) div 8;
  if FPixelFormat = mpf4Bit then
  begin
    ASize := ASize div 2;//((FBitmap.Width div 8) * FBitmap.Height) div 8;
    colors := 16;
  end;
  (* 正規化 *)
  if (ASize mod 2) = 1 then  Inc(ASize);

  with FImage do
  begin
    FData.Free;
    FData := TMemoryStream.Create;

    Move(FUser[1], FID.User[1], Length(FUser));
    FWidth := FBitmap.Width;
    FHeight := FBitmap.Height;

    (* set Header *)
    FillChar(FHeader, SizeOf(FHeader), $00);
    FHeader.BeginX := FLeft;
    FHeader.BeginY := FTop;
    FHeader.EndX := FLeft + FBitmap.Width-1;
    FHeader.EndY := FTop + FBitmap.Height-1;
    if FPixelFormat = mpf8Bit then
      Include(FHeader.ScreenMode, ms256Colors);
    if FHalfHeight then
      Include(FHeader.ScreenMode, msHalfHeight);

    FHeader.FlagAOfs := (SizeOf(TMagPalette) * colors) + SizeOf(FHeader);
    FHeader.FlagBOfs := FHeader.FlagAOfs + ASize;

    HPaletteToMagPalette(FHeader, FBitmap.Palette, @pal);

    (* コメント部を先に書き出しておく *)
    FData.WriteBuffer(FID, SizeOf(FID));
    if (Length(FComment) mod 2) = 0 then
      FComment := FComment + ' ';
    FData.WriteBuffer(FComment[1], Length(FComment));
    FData.WriteBuffer(MagCommentEnd, 1);

    P := TMemoryStream.Create;
    try
      B := TMemoryStream.Create;
      try
        A := AllocMem(ASize);
        try
          (* 圧縮 *)
          CompressPixel(A, B, P);

          FHeader.FlagBSize := B.Size;
          FHeader.PixelOfs := FHeader.FlagBOfs + B.Size;
          FHeader.PixelSize := P.Size;

          (* 書き出し *)
          FData.WriteBuffer(FHeader, SizeOf(FHeader));
          FData.WriteBuffer(pal, SizeOf(TMagPalette)*colors);
          FData.WriteBuffer(A^, ASize);
          FData.CopyFrom(B, 0);
          FData.CopyFrom(P, 0);
        finally
          FreeMem(A);
        end;
      finally
        B.Free;
      end;
    finally
      P.Free;
    end;
  end;  (* with FImage *)
  Modified := FALSE;
end;


(**********************************************************************
//{###init & final
 **********************************************************************)
(* use design *)
procedure Register;
begin
end;

initialization
  TPicture.RegisterFileFormat('MAG', 'MAki chan Graphic format', TMAGImage);

finalization
  TPicture.UnregisterGraphicClass(TMAGImage);

(***********************************************************************)
end.
