unit uSaveToXL;

interface
uses ExcelXP, DB, Forms, Dialogs, Variants, Graphics, SysUtils;

function ExportToExcel(oDataSet: TDataSet; sFile: string): Boolean;
implementation

function ExportToExcel(oDataSet: TDataSet; sFile: string): Boolean;
var
  iCol, iRow: Integer;

  oExcel: TExcelApplication;
  oWorkbook: TExcelWorkbook;
  oSheet: TExcelWorksheet;
  //xxx: string;
begin
  //iCol := 0;
  iRow := 1;
  result := True;

  oExcel := TExcelApplication.Create(Application);
  oWorkbook := TExcelWorkbook.Create(Application);
  oSheet := TExcelWorksheet.Create(Application);

  try
    oExcel.Visible[0] := False;
    oExcel.Connect;
  except
    result := False;
    MessageDlg('Excel may not be installed', mtError, [mbOk], 0);
    exit;
  end;

  oExcel.Visible[0] := False;
  oExcel.Caption := 'Report Export';
  oExcel.Workbooks.Add(Null, 0);

  oWorkbook.ConnectTo(oExcel.Workbooks[1]);
  oSheet.ConnectTo(oWorkbook.Worksheets[1] as _Worksheet);

  //header
  for iCol := 1 to oDataSet.FieldCount do
  begin
    oSheet.Cells.Item[1, iCol] := oDataSet.FieldDefs.Items[iCol - 1].Name;
  end;

  //Change the wprksheet name.
  oSheet.Name := 'Report';

  //Change the font properties of all columns.
  oSheet.Columns.Font.Color := clPurple;
  oSheet.Columns.Font.FontStyle := fsBold;
  oSheet.Columns.Font.Size := 10;

  //Change the font properties of a row.
  oSheet.Range['A1', 'A1'].EntireRow.Font.Color := clNavy;
  oSheet.Range['A1', 'A1'].EntireRow.Font.Size := 16;
  oSheet.Range['A1', 'A1'].EntireRow.Font.FontStyle := fsBold;
  oSheet.Range['A1', 'A1'].EntireRow.Font.Name := 'Arabic Transparent';

  oDataSet.Open;
  while not oDataSet.Eof do
  begin
    Inc(iRow);
    //xxx  := oDataSet.FieldDefs.Items[1].Name;
    for iCol := 1 to oDataSet.FieldCount do
    begin
      oSheet.Cells.Item[iRow, iCol] := oDataSet.Fields[iCol - 1].AsString;

      //Change the font properties of a row.
      oSheet.Range['A' + IntToStr(iRow), 'A' + IntToStr(iRow)].EntireRow.Font.Color := clBlue;
      oSheet.Range['A' + IntToStr(iRow), 'A' + IntToStr(iRow)].EntireRow.Font.Size := 12;
      oSheet.Range['A' + IntToStr(iRow), 'A' + IntToStr(iRow)].EntireRow.Font.FontStyle := fsBold;
      oSheet.Range['A' + IntToStr(iRow), 'A' + IntToStr(iRow)].EntireRow.Font.Name := 'Arabic Transparent';
      oSheet.Range['A' + IntToStr(iRow), 'A' + IntToStr(iRow)].HorizontalAlignment := xlHAlignCenter;
    end;

    oDataSet.Next;
  end;

  //Auto fit all columns.
  oSheet.Columns.AutoFit;

  DeleteFile(sFile);

  Sleep(2000);

  oSheet.SaveAs(sFile);
  oSheet.Disconnect;
  oSheet.Free;

  oWorkbook.Disconnect;
  oWorkbook.Free;

  oExcel.Quit;
  oExcel.Disconnect;
  oExcel.Free;
end;
end.

