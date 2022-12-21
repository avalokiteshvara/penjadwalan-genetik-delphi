unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, JPEG, BackgroundWorker;

const
  ThumbnailWidth = 100;
  ThumbnailHeight = 100;

type
  TMainForm = class(TForm)
    Toolbar: TPanel;
    lblFolder: TLabel;
    edFolder: TEdit;
    btnBrowse: TButton;
    BackgroundWorker: TBackgroundWorker;
    StatusBar: TStatusBar;
    lbThumbnails: TListBox;
    procedure btnBrowseClick(Sender: TObject);
    procedure BackgroundWorkerWork(Worker: TBackgroundWorker);
    procedure BackgroundWorkerWorkComplete(Worker: TBackgroundWorker;
      Cancelled: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BackgroundWorkerWorkFeedback(Worker: TBackgroundWorker;
      FeedbackID, FeedbackValue: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure lbThumbnailsDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure lbThumbnailsDblClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    GraphicFileMasks: TStringList;
    procedure ClearThumbnails;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  FileCtrl, ShellAPI;

procedure TMainForm.ClearThumbnails;
var
  I: Integer;
begin
  for I := 0 to lbThumbnails.Count - 1 do
    lbThumbnails.Items.Objects[I].Free;    // release the attached bitmap
  lbThumbnails.Items.Clear;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  // provide list of supported image file masks
  GraphicFileMasks := TStringList.Create;
  GraphicFileMasks.Sorted := True;             // for quick lookup
  GraphicFileMasks.CaseSensitive := false;     
  GraphicFileMasks.Delimiter := ';';
  GraphicFileMasks.DelimitedText := GraphicFileMask(TGraphic);
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  // release list of supported image file masks
  GraphicFileMasks.Free;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // if worker thread is still processing the directrory
  if BackgroundWorker.IsWorking then
  begin
    // inform user we are cancelling the last operation
    StatusBar.SimpleText := 'Cancelling...';
    // cancel the operation
    BackgroundWorker.Cancel;
    // and wait for worker to stop
    BackgroundWorker.WaitFor;
  end;
  // clear thumbnail list and its attached bitmaps
  ClearThumbnails;
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
  // set dimension of each item
  lbThumbnails.Columns := lbThumbnails.ClientWidth div (ThumbnailWidth + 8);
  lbThumbnails.ItemHeight := ThumbnailHeight + 12 + lbThumbnails.Canvas.TextHeight('H');
end;

procedure TMainForm.btnBrowseClick(Sender: TObject);
var
  Directory: String;
begin
  Directory := edFolder.Text;
  if SelectDirectory('Select folder of images:', '', Directory) then
  begin
    // if worker thread is still processing the old directrory
    if BackgroundWorker.IsWorking then
    begin
      // inform user we are cancelling the last operation
      StatusBar.SimpleText := 'Cancelling...';
      // cancel the operation
      BackgroundWorker.Cancel;
      // and wait for worker to stop
      BackgroundWorker.WaitFor;
    end;
    // display the new folder
    edFolder.Text := Directory;
    // clear the old thumbnails
    ClearThumbnails;
    // inform user we are working
    StatusBar.SimpleText := 'Creating thumbnails...';
    // create new thumbnails
    BackgroundWorker.Execute;
  end;
end;

procedure TMainForm.BackgroundWorkerWorkComplete(Worker: TBackgroundWorker;
  Cancelled: Boolean);
begin
  if Cancelled then
    StatusBar.SimpleText := 'Cancelled'
  else
    StatusBar.SimpleText := Format('%d images', [lbThumbnails.Items.Count]);
end;

procedure TMainForm.BackgroundWorkerWork(Worker: TBackgroundWorker);
var
  Path: String;
  SR: TSearchRec;
  Picture: TPicture;
  ThumbWidth, ThumbHeight: Integer;
  Thumbnail: TBitmap;
  ImageName: PChar;
begin
  Path := IncludeTrailingPathDelimiter(edFolder.Text);
  // create an object to hold the loaded image
  Picture := TPicture.Create;
  try
    // search for all files in the folder
    if FindFirst(Path + '*.*', faAnyFile and not faDirectory, SR) = 0 then
      repeat
        // if user has requested a cancellation
        if Worker.CancellationPending then
        begin
          // accept the cancellation
          Worker.AcceptCancellation;
          // and stop
          Break;
        end;
        // if the file is a supported image file
        if GraphicFileMasks.IndexOf('*' + ExtractFileExt(SR.Name)) >= 0 then
        begin
          try
            // load the image from file
            Picture.LoadFromFile(Path + SR.Name);
          except
            // the file could be corrupted, continue with the next file
            Continue;
          end;
          // calculate propertional size of the image
          if Picture.Width > Picture.Height then
          begin
            ThumbWidth := ThumbnailWidth;
            ThumbHeight := MulDiv(Picture.Height, ThumbWidth, Picture.Width);
          end
          else
          begin
            ThumbHeight := ThumbnailHeight;
            ThumbWidth := MulDiv(Picture.Width, ThumbHeight, Picture.Height);
          end;
          // create the thumbnail bitmap
          Thumbnail := TBitmap.Create;
          Thumbnail.Width := ThumbWidth;
          Thumbnail.Height := ThumbHeight;
          Thumbnail.Canvas.StretchDraw(Rect(0, 0, ThumbWidth, ThumbHeight), Picture.Graphic);
          // create a copy of filename
          ImageName := StrNew(PChar(SR.Name));
          // send filename and bitmap to the main VCL thread
          // later the main VCL thread releases thumbnail and memory allocated for filename
          Worker.ReportFeedback(Integer(ImageName), Integer(Thumbnail));
        end;
      until FindNext(SR) <> 0;
    FindClose(SR);
  finally
    // clean up
    Picture.Free;
  end;
end;

procedure TMainForm.BackgroundWorkerWorkFeedback(Worker: TBackgroundWorker;
  FeedbackID, FeedbackValue: Integer);
var
  ImageName: PChar;
  Thumbnail: TBitmap;
begin
  // get reported values by the worker thread
  ImageName := PChar(FeedbackID);
  Thumbnail := TBitmap(FeedbackValue);
  // add thumbnail to the list
  lbThumbnails.Items.AddObject(ImageName, Thumbnail);
  // release memory used for the name
  // we release the thumbnail bitmap during clearing the list
  StrDispose(ImageName);
  // update the status
  StatusBar.SimpleText := Format('%d images so far...', [lbThumbnails.Items.Count]);
end;

procedure TMainForm.lbThumbnailsDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  ImageName: String;
  Thumbnail: TBitmap;
  X, Y: Integer;
begin
  // get the data
  ImageName := lbThumbnails.Items.Strings[Index];
  Thumbnail := TBitmap(lbThumbnails.Items.Objects[Index]);
  // fill the background
  if odSelected in State then
  begin
    lbThumbnails.Canvas.Brush.Color := clHighlight;
    lbThumbnails.Canvas.Font.Color := clHighlightText;
  end
  else
  begin
    lbThumbnails.Canvas.Brush.Color := lbThumbnails.Color;
    lbThumbnails.Canvas.Font.Color := lbThumbnails.Font.Color;
  end;
  lbThumbnails.Canvas.FillRect(Rect);
  InflateRect(Rect, -4, -4);
  // draw thumbnail
  X := (Rect.Left + Rect.Right - Thumbnail.Width) div 2;
  Y := Rect.Top + (ThumbnailHeight - Thumbnail.Height) div 2;
  lbThumbnails.Canvas.Draw(X, Y, Thumbnail);
  // draw image's name
  Inc(Rect.Top, ThumbnailHeight + 4);
  DrawText(lbThumbnails.Canvas.Handle, PChar(ImageName), Length(ImageName),
    Rect, DT_VCENTER or DT_CENTER or DT_NOPREFIX or DT_END_ELLIPSIS);
end;

procedure TMainForm.lbThumbnailsDblClick(Sender: TObject);
var
  FileName: String;
begin
  if lbThumbnails.ItemIndex >= 0 then
  begin
    // get the full path to the image file
    FileName := IncludeTrailingPathDelimiter(edFolder.Text)
              + lbThumbnails.Items[lbThumbnails.ItemIndex];
    // open the image with the default viewer
    ShellExecute(Handle, 'open', PChar(FileName), nil, nil, SW_NORMAL);
  end;
end;

end.
