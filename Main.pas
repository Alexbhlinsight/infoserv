unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.ActiveX, System.SysUtils, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.SvcMgr, Vcl.Dialogs, XMLIntf, XMLDoc, XSBuiltIns, URLMon, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, IdSSLOpenSSL, IdURI,
  AccountCreate, Variants, glComponentUtil, WinSvc{, FolderMon}, //Cromis.DirectoryWatch ,
  System.IOUtils, Data.DB, Uni, DBAccess, MemDS, OracleUniProvider, UniProvider,
  ShlObj, ComObj,ShellApi, Vcl.ExtCtrls;

const
// macro
  C_MACRO_USERHOME      = '[USERHOME]';
  C_MACRO_NMATTER       = '[NMATTER]';
  C_MACRO_FILEID        = '[FILEID]';
  C_MACRO_TEMPDIR       = '[TEMPDIR]';
  C_MACRO_TEMPFILE      = '[TEMPFILE]';
  C_MACRO_DATE          = '[DATE]';
  C_MACRO_TIME          = '[TIME]';
  C_MACRO_DATETIME      = '[DATETIME]';
  C_WORKFLOW            = 'WORKFLOW';
  C_WKF                 = 'WKF';
  C_MERGETYPE           = 'MERGETYPE';
  C_MACRO_CLIENTID      = '[CLIENTID]';
  C_MACRO_AUTHOR        = '[AUTHOR]';
  C_MACRO_USERINITIALS  = '[USERINITIALS]';
  C_MACRO_DOCSEQUENCE   = '[DOCSEQUENCE]';
  C_MACRO_DOCID         = '[DOCID]';
  C_MACRO_DOCDESCR      = '[DOCDESCR]';

  C_VERSION             =  '1.1.2';

type
  TInsightiTrackWatcher = class(TService)
    qryMatterAttachment: TUniQuery;
    qrySearches: TUniQuery;
    qryTmp: TUniQuery;
    qrySysFile: TUniQuery;
    qryGetDocSeq: TUniQuery;
    uniInsight: TUniConnection;
    procTemp: TUniStoredProc;
    qrySeqnums: TUniQuery;
    qryCharts: TUniQuery;
    qryExpenseAllocations: TUniQuery;
    qryEmps: TUniQuery;
    qryTransItemInsert: TUniQuery;
    OracleUniProvider1: TOracleUniProvider;
    qrySearchesUpdatexx: TUniQuery;
    qrySearchID: TUniQuery;
    qrySearchesUpdate: TUniSQL;
    tmrScan: TTimer;
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure qryMatterAttachmentNewRecord(DataSet: TDataSet);
    procedure ServiceCreate(Sender: TObject);
    procedure ServiceDestroy(Sender: TObject);
    procedure tmrScanTimer(Sender: TObject);
  private
    { Private declarations }
    FDocID: integer;
    FUserID: string;
    FEntity: string;
    glComponentReg : TglComponentSetup;

    FDataModule: TDataModule;
    fDebugFile: string;
    FFileName: string;
    slFileFound: TStringList;
    slPathFound: TStringList;
    LogFile: string;
    fServicePath: string;
    iFileCount: integer;
    iTimer: cardinal;
    bLogit: boolean;
    fServer: string;

//    FFolderMon: TFolderMon;
    //FDirectoryWatch: TDirectoryWatch;

    //procedure OnNotify(const Sender: TObject;
    //                   const Action: TWatchAction;
    //                   const FileName: string);

//    procedure HandleFolderChange(ASender: TFolderMon; AFolderItem: TFolderItemInfo);

//    procedure HandleFolderMonActivated(ASender: TObject);
//    procedure HandleFolderMonDeactivated(ASender: TObject);

    procedure SaveSearchFromXML(AFileName: string);
    function InfoTrackLogin(const Url: string; TargetFileName, User, Pass: string; ANMatter: integer): boolean;
    procedure SaveDocument(ACreated: TDateTime; AFileID, AAuthor, AFileName, AKeyword, ASearch: string;
                         AImageIndex: integer = 5);
    function SystemString(sField: string): string;
    function SystemInteger(sField: string): integer;
    function CleanFileName(AFileName: string; ANewChar: char = ' '): string;
    function ParseMacros(AFileName: String; ANMatter: Integer = -1; ADocID: Integer = -1; ADocDescr: string = ''): String;
    function ProcString(Proc: string; LookupValue: integer): string;
    function GetServiceExecutablePath(strMachine: string; strServiceName: string): String;
    function AppendDocID(AFileName: String): String;
    function CopyFileIFileOperationForceDirectories(const srcFile,
      destFile: string; DeleteOrigDoc: boolean): boolean;
    procedure GetNewDocID;
    function GetUniqueXMLFileName(AFilename: String): String;
    function IsFileInUse(FileName: TFileName): Boolean;
    procedure MoveDocument(FileName: string);
    function MoveMatterDoc(var ANewDocName: string; AOldDocName: string;
      DeleteOrigDoc, DisplayMsg: boolean): boolean;
    procedure ProcessDirectory(sDirectory: String);
    function RecycleDelete(inpath: string): integer;
    procedure ReadSettingsIni;

  public
    started: boolean;

    property Entity: string read FEntity write FEntity;
    property DocID: integer read FDocID write FDocID;
    property UserID: string read FUserID write FUserID;

    function TableInteger(Table, LookupField, LookupValue, ReturnField: string): integer;
    function MatterString(iFile: integer; sField: string): string;
    function TableString(Table, LookupField, LookupValue, ReturnField: string): string;
    function GetSeqnum(sField: string): integer;
    function ValidLedger(sEntity, sLedger: string): boolean;
    procedure PostLedger(dtDate: TDateTime; cAmount: currency; cTax: Currency;
                         sRefno: string; sOwnerCode: string; iOwner: int64; sDesc: string;
                         sLedger: string; sAuthor: string; iInvoice: int64;
                         CreditorCode: string; sTaxCode : String; bJournalSplit : Boolean = FALSE;
                         sParentChart : String = '0'; nAlloc: int64 = 0; nMatter: int64 = 0;
                         nAccount: int64 = 0; UseRvDate: Boolean = FALSE; nTrans: integer = 0;
                         cBAS_Tax: currency = 0);
    function GetSubchart(sEntity: string; sMainChart: string; sEmp: string): string;
    procedure SaveLedger(dtDate: TDateTime; cAmount: currency; cTax: Currency;
                         sRefno, sOwnerCode: string; iOwner: integer; sDesc,
                         sFullLedger, sAuthor: string; iInvoice: Integer;
                         CreditorCode, sTaxCode, sParentChart: String; nAlloc: integer = 0; nMatter: int64 = 0;
                         nAccount: integer = 0; UseRvDate: Boolean = FALSE; nTrans: integer = 0;
                         cBAS_Tax: currency = 0);
    function IsActiveLedger(sEntity : String; sFullLedger : String) : Boolean;
    procedure ParamsNullify(parClear: TParams);
    function getGlComponents : TglComponentSetup;
    procedure loadGlComponent;

    function TableStringEntity(aTable, aLookupField: string; aLookupValue: Integer; aReturnField: string; aEntity: string): string;
    function GetServiceController: TServiceController; override;
    function IndexPath(PathText, PathLoc: string): string;
    function TokenizePath(var s,w:string):boolean;
    function IsValidFileID(sFileId: string): boolean;
    function FileSearch(const PathName, FileName : string): integer;
    function DoLoadUp(const APathName: string): integer;
    function DoFileScan(const APathName: string): integer;
    procedure WriteLog(const AMessage: string);
    { Public declarations }
  end;

var
  InsightiTrackWatcher: TInsightiTrackWatcher;

implementation

{$R *.DFM}
uses
    System.IniFiles;

type
  TFileSystemBindData = class (TInterfacedObject, IFileSystemBindData)
    fw32fd: TWin32FindData;

    function SetFindData(var w32fd: TWin32FindData): HRESULT; stdcall;
    function GetFindData(var w32fd: TWin32FindData): HRESULT; stdcall;
  end;


// AES 06/09/2018
function TFileSystemBindData.GetFindData(var w32fd: TWin32FindData): HRESULT;
begin
  w32fd:= fw32fd;
  Result := S_OK;
end;

function TFileSystemBindData.SetFindData(var w32fd: TWin32FindData): HRESULT;
begin
  fw32fd := w32fd;
  Result := S_OK;
end;


var
   GHomePath,
   GTempPath,
   InfotrackFolder: String;


procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  InsightiTrackWatcher.Controller(CtrlCode);
end;

function TInsightiTrackWatcher.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TInsightiTrackWatcher.SaveSearchFromXML(AFileName: string);
var
   LDocument: IXMLDocument;
   AOrderNode: IXMLNode;
   ASequenceNumber,
   AOrderId,
   LFileLoc,
   NewDocPath,
   NewDocName,
   AParsedDocName,
   ADownloadURL,
   LFileID,
   FileHash,
   lsMatter,
   InfoTrackUser,
   InfoTrackPwd,
   AOnlineURL,
   AParentOrderId,
   AStatus: String;
   xsDateTime: TXSDateTime;
   bDupeSearch,
   bUpdateSearch: Boolean;
   liMatter,
   liSearch_ID,
   ADBSequenceNumber: integer;
begin
   try
      ASequenceNumber := '';
      AOrderId := '';
      FileHash := '';
      AParentOrderId := '';
      AStatus := '';
      ADBSequenceNumber := 0;
      liSearch_ID := 0;
      lsMatter := '';
      LFileID := '';
      LFileLoc := '';
      NewDocPath := '';
      NewDocName := '';
      AParsedDocName := '';
      ADownloadURL := '';
      FileHash := '';
      InfoTrackUser := '';
      InfoTrackPwd := '';
      AOnlineURL := '';
      AParentOrderId := '';
      AStatus := '';
      LFileLoc := InfotrackFolder + AFileName;
      if FileExists(LFileLoc) then
      begin
         LDocument := TXMLDocument.Create(nil);
         try
            AOrderNode := nil;
            LDocument.LoadFromFile(LFileLoc);

            AOrderNode := LDocument.ChildNodes.FindNode('Order');

            if (AOrderNode <> nil) then
            begin
               try
                  if uniInsight.Intransaction then
                     uniInsight.commit;
                  uniInsight.StartTransaction;
                  ASequenceNumber := AOrderNode.ChildNodes['SequenceNumber'].Text;
                  AOrderId := AOrderNode.ChildNodes['OrderId'].Text;
                  FileHash := AOrderNode.ChildNodes['FileHash'].Text;
                  AParentOrderId := AOrderNode.ChildNodes['ParentOrderId'].Text;
                  AStatus := AOrderNode.ChildNodes['Status'].Text;
                  with qryTmp do
                  begin
                    // bDupeSearch := False;
                     Close;
                     SQL.Text := 'select search_id, SequenceNumber from searches where '+
                                 'OrderId = :OrderId and isbillable = ''true'' ';
//                                 'and nvl(filehash, ''nofilehash'') = nvl(:filehash, ''nofilehash'') ';
//                     if (StrToInt(AParentOrderId) = 0) or (AStatus = 'List') then
                        ParamByName('OrderId').AsString := AOrderId;
//                     else
//                        ParamByName('OrderId').AsString := AParentOrderId;

//                     ParamByName('FileHash').AsString := trim(FileHash);
                     Open;
                     bDupeSearch := (not EOF);
                     ADBSequenceNumber := FieldByName('SequenceNumber').AsInteger;
                     liSearch_ID := FieldByName('SEARCH_ID').AsInteger;
                  end;

{                  if (bDupeSearch = False) then
                  begin
                     with qryTmp do
                     begin
                        bUpdateSearch := False;
                        Close;
                        SQL.Text := 'select 1 from searches where  '+
                                    ' OrderId = :OrderId and isbillable = ''true'' ';
                        ParamByName('OrderId').AsString := OrderId;
                        Open;
                        bUpdateSearch := (not EOF);
                     end;
                  end;   }

                  if (ADBSequenceNumber = 0) or (StrToInt(ASequenceNumber) > ADBSequenceNumber) then
                  begin
                     if (bDupeSearch = False) {and (bUpdateSearch = False)} then
                     begin
                        lsMatter := AOrderNode.ChildNodes['ClientReference'].Text;

                        if (IsValidFileID(lsMatter) = True) then
                        begin
                           LFileID := lsMatter;
                           liMatter := TableInteger('MATTER','FILEID',lsMatter,'NMATTER');
                        end
                        else
                        begin
                           LFileID := TableString('MATTER', 'NMATTER', lsMatter, 'FILEID');
                           liMatter := StrToInt(lsMatter);
                        end;

                        NewDocPath := IncludeTrailingPathDelimiter(SystemString('DRAG_DEFAULT_DIRECTORY'));

                        NewDocName := NewDocPath + CleanFileName(Copy(AOrderNode.ChildNodes['Description'].Text, 1, 200));

//                        NewDocName := NewDocPath + CleanFileName(AOrderNode.ChildNodes['OrderId'].Text, '-');
                        AParsedDocName := ParseMacros(NewDocName, liMatter);
                        if (DirectoryExists(ExtractFilePath(AParsedDocName)) = False) then
                           ForceDirectories(ExtractFilePath(AParsedDocName));

                        ADownloadURL   := AOrderNode.ChildNodes['DownloadUrl'].Text;
                        AOnlineURL     := AOrderNode.ChildNodes['OnlineUrl'].Text;

                        Entity := TableString('MATTER','FILEID',LFileID,'ENTITY');

                        with qryTmp do
                        begin
                           Close;
                           SQL.Clear;
                           SQL.Add('SELECT code, INFOTRACK_USER, INFOTRACK_PASSWORD from EMPLOYEE where INFOTRACK_USER = :name');
                           ParamByName('name').AsString := AOrderNode.ChildNodes['RetailerReference'].Text;
                           Open;
                           FUserID := Fields.Fields[0].AsString;
                           InfoTrackUser := Fields.Fields[1].AsString;
                           InfoTrackPwd  := Fields.Fields[2].AsString;
                           Close;
                        end;

                        with qrySearches do
                        begin
                           Open;
                           Insert;

                           FieldByName('AvailableOnline').AsString := AOrderNode.ChildNodes['AvailableOnline'].Text;
                           FieldByName('ClientReference').AsString := LFileID;  //StrToInt(AOrderNode.ChildNodes['ClientReference'].Text);
                           FieldByName('ClientReference1').AsInteger := liMatter;
                           FieldByName('BillingTypeName').AsString := AOrderNode.ChildNodes['BillingTypeName'].Text;

                           try
                              xsDateTime := TXSDateTime.Create;
                              xsDateTime.XSToNative(AOrderNode.ChildNodes['DateOrdered'].Text);

                              FieldByName('DateOrdered').AsDateTime := xsDateTime.AsDateTime;

                              if (AOrderNode.ChildNodes['DateCompleted'].Text <> '') then
                              begin
                                 xsDateTime.XSToNative(AOrderNode.ChildNodes['DateCompleted'].Text);
                                 FieldByName('DateCompleted').AsDateTime := xsDateTime.AsDateTime;
                              end;
                           finally
                              xsDateTime := nil;
                           end;

                           FieldByName('Description').AsString := AOrderNode.ChildNodes['Description'].Text;
                           FieldByName('OrderId').AsString := AOrderNode.ChildNodes['OrderId'].Text;
                           FieldByName('ParentOrderId').AsString := AOrderNode.ChildNodes['ParentOrderId'].Text;
                           FieldByName('OrderedBy').AsString := AOrderNode.ChildNodes['OrderedBy'].Text;
                           FieldByName('Reference').AsString := AOrderNode.ChildNodes['Reference'].Text;
                           FieldByName('RetailerReference').AsString := AOrderNode.ChildNodes['RetailerReference'].Text;
                           FieldByName('RetailerFee').AsString := AOrderNode.ChildNodes['RetailerFee'].Text;
                           FieldByName('RetailerFeeGST').AsString := AOrderNode.ChildNodes['RetailerFeeGST'].Text;
                           FieldByName('RetailerFeeTotal').AsString := AOrderNode.ChildNodes['RetailerFeeTotal'].Text;
                           FieldByName('SupplierFee').AsString := AOrderNode.ChildNodes['SupplierFee'].Text;
                           FieldByName('SupplierFeeGST').AsString := AOrderNode.ChildNodes['SupplierFeeGST'].Text;
                           FieldByName('SupplierFeeTotal').AsString := AOrderNode.ChildNodes['SupplierFeeTotal'].Text;
                           FieldByName('TotalFee').AsString := AOrderNode.ChildNodes['TotalFee'].Text;
                           FieldByName('TotalFeeGST').AsString := AOrderNode.ChildNodes['TotalFeeGST'].Text;
                           FieldByName('TotalFeeTotal').AsString := AOrderNode.ChildNodes['TotalFeeTotal'].Text;
                           FieldByName('ServiceName').AsString := AOrderNode.ChildNodes['ServiceName'].Text;
                           FieldByName('Status').AsString := AOrderNode.ChildNodes['Status'].Text;
                           FieldByName('StatusMessage').AsString := AOrderNode.ChildNodes['StatusMessage'].Text;
                           FieldByName('FILE_NAME').AsString := AFileName;
                           FieldByName('DownloadUrl').Clear;
                           if (ADownloadURL <> '') then
                           begin
                              FieldByName('DownloadUrl').AsString := ExpandUNCFileName(AParsedDocName)+'.pdf';  //IndexPath(AParsedDocName, 'DOC_SHARE_PATH') +'.pdf';   //AOrderNode.ChildNodes['DownloadUrl'].Text;
                               WriteLog(IndexPath(AParsedDocName, 'DOC_SHARE_PATH') +'.pdf');
                           end;  // 16 Sep 2018 DW to handle in memory issue
                           FieldByName('OnlineUrl').Clear;
                           if (AOnlineURL <> '') then
                              FieldByName('OnlineUrl').AsString := AOrderNode.ChildNodes['OnlineUrl'].Text; // 16 Sep 2018 DW to handle in memory issue

                           FieldByName('IsBillable').AsString := AOrderNode.ChildNodes['IsBillable'].Text;
                           FieldByName('FileHash').AsString := AOrderNode.ChildNodes['FileHash'].Text;
                           FieldByName('Email').AsString := AOrderNode.ChildNodes['Email'].Text;
                           FieldByName('ClientId').AsString := AOrderNode.ChildNodes['ClientId'].Text;
                           FieldByName('SequenceNumber').AsString := AOrderNode.ChildNodes['SequenceNumber'].Text;
                           Post;
                        end;

                        if (AOrderNode.ChildNodes['IsBillable'].Text = 'true') then
                        begin
                           //AES 10/10/17 download if download url exists
                           if ((ADownloadURL <> '') {or (AOnlineURL <> '')}) then
                           begin
                              WriteLog('Getting Login details');
                              if (InfoTrackUser = '') then
                                 InfoTrackUser := SystemString('INFOTRACK_USER');
                              if (InfoTrackPwd = '') then
                                 InfoTrackPwd := SystemString('INFOTRACK_PASSWORD');
                              WriteLog('About to start download');
                              // if download URL exists download file.
                              if (ADownloadURL <> '') then
                              begin
                                 if (InfoTrackLogin(ADownloadURL, AParsedDocName, InfoTrackUser, InfoTrackPwd, liMatter ) = True) then
                                 begin
                                    WriteLog('About to save document');
                                    SaveDocument(now, LFileID, UserID, AParsedDocName+'.pdf','InfoTrack Search',
                                              'InfoTrack Search - ' + copy(qrySearches.FieldByName('Description').AsString, 1,180));
                                 end;
                              end;
                           end;
                           // AES 10/10/17  only create invoice if amount > 0
                           if (qrySearches.FieldByName('TotalFee').AsCurrency <> 0) then
                           begin
                              // create invoice
                              try
                                 if not Assigned(dmAccountCreate) then
                                    Application.CreateForm(TdmAccountCreate, dmAccountCreate);
                                 dmAccountCreate.SaveAccount(liMatter,
                                                          SystemInteger('INFOTRACK_NCREDITOR'),
                                                          qrySearches.FieldByName('OrderID').AsInteger,
                                                          qrySearches.FieldByName('TotalFee').AsCurrency,
                                                          qrySearches.FieldByName('TotalFeeGST').AsCurrency,
                                                          qrySearches.FieldByName('Description').AsString,
                                                          qrySearches.FieldByName('ClientReference').AsString,
                                                          qrySearches.FieldByName('DateOrdered').AsDateTime);
                              finally
                                 FreeAndNil(dmAccountCreate);
                              end;
                           end;
                        end;
                     end
                     else
                     if {(bUpdateSearch = True) and} (bDupeSearch = True) then
                     begin
                        lsMatter := AOrderNode.ChildNodes['ClientReference'].Text;

                        if IsValidFileID(lsMatter) then
                        begin
                           LFileID := lsMatter;
                           liMatter := TableInteger('MATTER','FILEID',lsMatter,'NMATTER');
                        end
                        else
                        begin
                           LFileID := TableString('MATTER', 'NMATTER', lsMatter, 'FILEID');
                           liMatter := StrToInt(lsMatter);
                        end;

                        NewDocPath := IncludeTrailingPathDelimiter(SystemString('DRAG_DEFAULT_DIRECTORY'));
                        NewDocName := NewDocPath + CleanFileName(AOrderNode.ChildNodes['OrderId'].Text, '-');
                        AParsedDocName := ParseMacros(NewDocName, liMatter);
                        if (DirectoryExists(ExtractFilePath(AParsedDocName)) = False) then
                           ForceDirectories(ExtractFilePath(AParsedDocName));

                        ADownloadURL   := AOrderNode.ChildNodes['DownloadUrl'].Text;
                        AOnlineURL     := AOrderNode.ChildNodes['OnlineUrl'].Text;

                        Entity := TableString('MATTER','FILEID',LFileID,'ENTITY');

                        with qryTmp do
                        begin
                           Close;
                           SQL.Clear;
                           SQL.Add('SELECT code, INFOTRACK_USER, INFOTRACK_PASSWORD from EMPLOYEE where INFOTRACK_USER = :name');
                           ParamByName('name').AsString := AOrderNode.ChildNodes['RetailerReference'].Text;
                           Open;
                           FUserID := Fields.Fields[0].AsString;
                           InfoTrackUser := Fields.Fields[1].AsString;
                           InfoTrackPwd  := Fields.Fields[2].AsString;
                           Close;
                        end;

                        with qrySearchesUpdate do
                        begin
                           ParamByName('AvailableOnline').AsString := AOrderNode.ChildNodes['AvailableOnline'].Text;
                           ParamByName('ClientReference').AsString := LFileID;  //StrToInt(AOrderNode.ChildNodes['ClientReference'].Text);
                           ParamByName('BillingTypeName').AsString := AOrderNode.ChildNodes['BillingTypeName'].Text;

                           try
                              xsDateTime := TXSDateTime.Create;
                              xsDateTime.XSToNative(AOrderNode.ChildNodes['DateOrdered'].Text);

                              ParamByName('DateOrdered').AsDateTime := xsDateTime.AsDateTime;

                              if (AOrderNode.ChildNodes['DateCompleted'].Text <> '') then
                              begin
                                 xsDateTime.XSToNative(AOrderNode.ChildNodes['DateCompleted'].Text);
                                 ParamByName('DateCompleted').AsDateTime := xsDateTime.AsDateTime;
                              end;
                           finally
                              xsDateTime := nil;
                           end;

                           ParamByName('Search_Id').AsInteger := liSearch_ID;
                           ParamByName('Description').AsString := AOrderNode.ChildNodes['Description'].Text;
//                           ParamByName('OrderId').AsString := AOrderNode.ChildNodes['OrderId'].Text;
//                           ParamByName('ParentOrderId').AsString := AOrderNode.ChildNodes['ParentOrderId'].Text;
                           ParamByName('OrderedBy').AsString := AOrderNode.ChildNodes['OrderedBy'].Text;
                           ParamByName('Reference').AsString := AOrderNode.ChildNodes['Reference'].Text;
                           ParamByName('RetailerReference').AsString := AOrderNode.ChildNodes['RetailerReference'].Text;

                           if (AOrderNode.ChildNodes['TotalFeeTotal'].Text <> '0.00') then
                           begin
                              ParamByName('RetailerFee').AsString := AOrderNode.ChildNodes['RetailerFee'].Text;
                              ParamByName('RetailerFeeGST').AsString := AOrderNode.ChildNodes['RetailerFeeGST'].Text;
                              ParamByName('RetailerFeeTotal').AsString := AOrderNode.ChildNodes['RetailerFeeTotal'].Text;
                              ParamByName('SupplierFee').AsString := AOrderNode.ChildNodes['SupplierFee'].Text;
                              ParamByName('SupplierFeeGST').AsString := AOrderNode.ChildNodes['SupplierFeeGST'].Text;
                              ParamByName('SupplierFeeTotal').AsString := AOrderNode.ChildNodes['SupplierFeeTotal'].Text;
                              ParamByName('TotalFee').AsString := AOrderNode.ChildNodes['TotalFee'].Text;
                              ParamByName('TotalFeeGST').AsString := AOrderNode.ChildNodes['TotalFeeGST'].Text;
                              ParamByName('TotalFeeTotal').AsString := AOrderNode.ChildNodes['TotalFeeTotal'].Text;
                           end;

                           ParamByName('ServiceName').AsString := AOrderNode.ChildNodes['ServiceName'].Text;
                           ParamByName('Status').AsString := AOrderNode.ChildNodes['Status'].Text;
                           ParamByName('StatusMessage').AsString := AOrderNode.ChildNodes['StatusMessage'].Text;
                            ParamByName('DownloadUrl').Clear;
                           if (ADownloadURL <> '') then
                           begin
                              ParamByName('DownloadUrl').AsString := ExpandUNCFileName(AParsedDocName)+'.pdf';  //IndexPath(AParsedDocName, 'DOC_SHARE_PATH') +'.pdf';   //AOrderNode.ChildNodes['DownloadUrl'].Text;
                              WriteLog(IndexPath(AParsedDocName, 'DOC_SHARE_PATH') +'.pdf');
                           end; // 16 Sep 2018 DW to handle in memory issue
                           ParamByName('OnlineUrl').Clear;
                           if (AOnlineURL <> '') then
                              ParamByName('OnlineUrl').AsString := AOrderNode.ChildNodes['OnlineUrl'].Text; // 16 Sep 2018 DW to handle in memory issue

                           ParamByName('IsBillable').AsString := AOrderNode.ChildNodes['IsBillable'].Text;
                           ParamByName('FileHash').AsString := AOrderNode.ChildNodes['FileHash'].Text;
                           ParamByName('Email').AsString := AOrderNode.ChildNodes['Email'].Text;
                           ParamByName('ClientId').AsString := AOrderNode.ChildNodes['ClientId'].Text;
                           ParamByName('SequenceNumber').AsString := AOrderNode.ChildNodes['SequenceNumber'].Text;
                           Prepare;
                           Execute;
                        end;

                        if (AOrderNode.ChildNodes['IsBillable'].Text = 'true') then
                        begin
                           if ((ADownloadURL <> '') or (AOnlineURL <> '')) then
                           begin
                              qrySearchID.Close;
                              qrySearchID.ParamByName('search_id').AsInteger := liSearch_ID;
                              qrySearchID.Open;
                              if (InfoTrackUser = '') then
                                 InfoTrackUser := SystemString('INFOTRACK_USER');
                              if (InfoTrackPwd = '') then
                                 InfoTrackPwd := SystemString('INFOTRACK_PASSWORD');


                              if (ADownloadURL <> '') then
                              begin
                                 if (InfoTrackLogin(ADownloadURL, AParsedDocName, InfoTrackUser, InfoTrackPwd, liMatter ) = True) then
                                 begin
                                    WriteLog('About to save document');
                                    SaveDocument(now, LFileID, UserID, AParsedDocName+'.pdf','InfoTrack Search',
                                              'InfoTrack Search - ' + copy(AOrderNode.ChildNodes['Description'].Text, 1,180));
                                 end;
                              end;
                              if qrySearchID.Active then
                                 qrySearchID.Close;
                           end;

                           if (StrToCurr(AOrderNode.ChildNodes['TotalFee'].Text) <> 0) then
                           begin
                           // create invoice
                              try
                                 if not Assigned(dmAccountCreate) then
                                    Application.CreateForm(TdmAccountCreate, dmAccountCreate);

                                 qrySearchID.Close;
                                 qrySearchID.ParamByName('search_id').AsInteger := liSearch_ID;
                                 qrySearchID.Open;

                                 dmAccountCreate.SaveAccount(TableInteger('MATTER','FILEID', LFileID, 'NMATTER'),
                                                          SystemInteger('INFOTRACK_NCREDITOR'),
                                                          qrySearchID.FieldByName('OrderID').AsInteger,
                                                          qrySearchID.FieldByName('TotalFee').AsCurrency,
                                                          qrySearchID.FieldByName('TotalFeeGST').AsCurrency,
                                                          qrySearchID.FieldByName('Description').AsString,
                                                          qrySearchID.FieldByName('ClientReference').AsString,
                                                          qrySearchID.FieldByName('DateOrdered').AsDateTime);
                              finally
                                 FreeAndNil(dmAccountCreate);
                              end;
                              if qrySearchID.Active then
                                 qrySearchID.Close;
                           end;
                        end;
                     end;
                     if uniInsight.intransaction then
                        UniInsight.Commit;
                  end
                  else
                  begin
                     if uniInsight.intransaction then
                        uniInsight.Commit;
                  end;
               except
                  if uniInsight.intransaction then
                     uniInsight.Rollback;
               end;
            end;
         except
            //
         end;
      end;
   finally
      LDocument := nil;
   end;
end;


procedure TInsightiTrackWatcher.ServiceCreate(Sender: TObject);
begin
{   FFolderMon := TFolderMon.Create;
   FFolderMon.OnFolderChange := HandleFolderChange; }

   //FDirectoryWatch := TDirectoryWatch.Create;
   //FDirectoryWatch.OnNotify := OnNotify;
end;

procedure TInsightiTrackWatcher.ServiceDestroy(Sender: TObject);
begin
//   FFolderMon.Free;
   //FreeAndNil(FDirectoryWatch);
end;

procedure TInsightiTrackWatcher.ServiceStart(Sender: TService;
  var Started: Boolean);
begin
   FFileName := '';
   try
      fServicePath := ExtractFilePath(GetServiceExecutablePath('','InsightiTrackWatcher'));
      ReadSettingsIni;
      UniInsight.Server := fServer;
      UniInsight.Username := 'axiom';
      UniInsight.Password := 'axiom';
      UniInsight.Connect;
      if (SystemString('INFOTRACK_URL') <> '') then
      begin
         InfotrackFolder := IncludeTrailingPathDelimiter(SystemString('INFOTRACK_STAGING_FLDR'));
         //FDirectoryWatch.Directory := SystemString('INFOTRACK_STAGING_FLDR');
         //FDirectoryWatch.WatchOptions := [woFileName];
         //FDirectoryWatch.WatchSubTree := False;
         //FDirectoryWatch.Start;
      end;
      if (UniInsight.Connected = False) then
           WriteLog('Could not connect to Oracle server' + FServer);
   except
      WriteLog('Could not connect to Oracle server' + FServer);



{      if (SystemString('INFOTRACK_URL') <> '') then
      begin
         FFolderMon.Folder := SystemString('INFOTRACK_STAGING_FLDR');
         vMonitoredChanges := [];
         Include(vMonitoredChanges, ctFileName);

         FFolderMon.MonitoredChanges := vMonitoredChanges;
         FFolderMon.MonitorSubFolders := False;
         FFolderMon.Activate;
      end;   }
   end;

{   fDebugfile := IncludeTrailingPathDelimiter(ExtractFilePath(GetServiceExecutablePath('','InsightiTrackWatcher'))) +  'itrackLogs\debug.txt';
   if not FileExists(fDebugfile) then
      FileHandle  := FileCreate(fDebugfile);
   FileClose(FileHandle); }
end;

procedure TInsightiTrackWatcher.ServiceStop(Sender: TService;
  var Stopped: Boolean);
begin
   UniInsight.Disconnect;
   //if (FDirectoryWatch.Running = True) then
   //  FDirectoryWatch.Stop;
{   if FFolderMon.IsActive then
      FFolderMon.Deactivate;}
   FreeAndNil(FDataModule);
end;

function TInsightiTrackWatcher.InfoTrackLogin(const Url: string; TargetFileName,
                                              User, Pass: string; ANMatter: integer): boolean;
var
   IdHTTP: TIdHTTP;
   Response,
   FullTargetFileName,
   IndexedFullTargetFileName,
   tempFile,
   NewDocPath,
   NewDocName,
   AParsedDocName: string;
   FileStream: TFileStream;
   LHandler: TIdSSLIOHandlerSocketOpenSSL;
   FileHandle: NativeInt;
   numBytes: integer;
   URI: TIdURI;
   bFileError: boolean;
begin
   Result := False;
   bFileError := False;
   if (Url <> '') then
   begin
      try
         IdHTTP := TIdHTTP.Create(nil);
         LHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
         LHandler.SSLOptions.Method := sslvTLSv1;
         try
            FullTargetFileName := TargetFileName + '.pdf';
            IndexedFullTargetFileName := ExpandUNCFileName(FullTargetFileName);

            NewDocPath := IncludeTrailingPathDelimiter(SystemString('INFOTRACK_DEFAULT_DIRECTORY'));
            NewDocName := NewDocPath + CleanFileName(ExtractFileName(FullTargetFileName), '-');
            AParsedDocName := ParseMacros(NewDocName, ANMatter);

            WriteLog('About to start download of ' +IndexedFullTargetFileName );
            If FileExists(AParsedDocName) = False then
            begin
               CreateDir(ExtractFileDir(AParsedDocName));
               FileHandle := NativeInt(FileCreate(AParsedDocName));
               if (FileHandle = -1) then
               begin
                  bFileError := True;
               end;
               FileClose(FileHandle);

               if bFileError = False then
               begin
                  IdHTTP.AllowCookies := True;
                  IdHTTP.HandleRedirects := True;

                  IdHTTP.Request.Username := User;
                  IdHTTP.Request.Password := Pass;
                  IdHTTP.Request.BasicAuthentication := False;
                  IdHTTP.HTTPOptions := [hoInProcessAuth];

                  IdHTTP.Request.ContentType := 'application/x-www-form-urlencoded';
                  IdHTTP.Request.Connection := 'keep-alive';
                  // Download file
                  try
                     IdHTTP.IOHandler:=LHandler;
                     URI := TIdURI.Create(Url);
                     URI.Username := User;
                     URI.Password := Pass;

                     FileStream := TFileStream.Create(AParsedDocName, fmOpenReadWrite);
                     try
                        IdHTTP.Get(URI.GetFullURI([ofAuthInfo]), FileStream);
                        numBytes := IdHTTP.response.contentLength;
                     finally
                        FileStream.Free;
                     end;
                  finally
//                     MoveFile(PChar(tempFile), PChar(AParsedDocName));
                     LHandler.Free;
                     Result := True;
                     IdHTTP.Disconnect;
{                     try
                        Tfile.Move(AParsedDocName, IndexedFullTargetFileName);
                     except
                        //
                     end;  }
                  end;
               end;
            end;
         except
            on E: Exception do
//               ShowMessage(E.Message);
         end;
      finally
         IdHTTP.Free;
         URI.Free;
      end;
   end
   else
      Result := True;
end;

procedure TInsightiTrackWatcher.SaveDocument(ACreated: TDateTime; AFileID, AAuthor, AFileName, AKeyword, ASearch: string;
                                             AImageIndex: integer);
begin
   try
      qryMatterAttachment.Open;
      qryMatterAttachment.Insert;
      qryMatterAttachment.FieldByName('docid').AsInteger := DocID;
      qryMatterAttachment.FieldByName('fileid').AsString := AFileid;
      qryMatterAttachment.FieldByName('nmatter').AsInteger := TableInteger('MATTER','FILEID',AFileID,'nMatter');
      qryMatterAttachment.FieldByName('auth1').AsString := AAuthor;
      qryMatterAttachment.FieldByName('D_CREATE').AsDateTime := Now;

      qryMatterAttachment.FieldByName('IMAGEINDEX').AsInteger := AImageIndex;

      qryMatterAttachment.FieldByName('DESCR').AsString := ExtractFileName(AFileName);
      qryMatterAttachment.FieldByName('SEARCH').AsString := ASearch;
      qryMatterAttachment.FieldByName('FILE_EXTENSION').AsString := Copy(ExtractFileExt(AFileName),2, Length(ExtractFileExt(AFileName)));
      qryMatterAttachment.FieldByName('doc_name').AsString := ASearch;
      qryMatterAttachment.FieldByName('KEYWORDS').AsString := AKeyword;
      qryMatterAttachment.FieldByName('PATH').AsString := ExpandUNCFileName(AFileName);//  IndexPath(AFileName, 'DOC_SHARE_PATH');
		qryMatterAttachment.FieldByName('DISPLAY_PATH').AsString := AFileName;
      qryMatterAttachment.FieldByName('EXTERNAL_ACCESS').AsString := 'N';

      try
         qryMatterAttachment.ApplyUpdates;
      finally
         qryMatterAttachment.CommitUpdates;
      end;
   except
      qryMatterAttachment.CancelUpdates;
   end;
end;

function TInsightiTrackWatcher.SystemString(sField: string): string;
begin
   with qrySysfile do
   begin
      SQL.Text := 'SELECT ' + sField + ' FROM SYSTEMFILE';
      try
         Open;
         SystemString := FieldByName(sField).AsString;
         Close;
      except
      //
      end;
   end;
end;

function TInsightiTrackWatcher.SystemInteger(sField: string): integer;
begin
   with qrySysfile do
   begin
      SQL.Text := 'SELECT ' + sField + ' FROM SYSTEMFILE';
      try
         Open;
         SystemInteger := FieldByName(sField).AsInteger;
         Close;
      except
      //
      end;
   end;
end;

function TInsightiTrackWatcher.CleanFileName(AFileName: string; ANewChar: char = ' '): string;
var
   x: integer;
begin
   // clean up File Name
   for x := 1 to length(AFileName) do
   begin
      if (AFileName[x] in ['\','?','"','<','>','|','*',':',';','/']) then
         AFileName[x] := ANewChar;
   end;
   Result := AFileName;
end;

function TInsightiTrackWatcher.ParseMacros(AFileName: String; ANMatter: Integer; ADocID: Integer; ADocDescr: string): String;
var
  LBfr: Array[0..MAX_PATH] of Char;
begin
  if(GHomePath = '') then
    GHomePath := GetEnvironmentVariable('HOMEDRIVE') + GetEnvironmentVariable('HOMEPATH');

  if(GTempPath = '') then
  begin
    GetTempPath(MAX_PATH,Lbfr);
    GTempPath := String(LBfr);
  end;

  Result := AFileName;

  Result := StringReplace(Result,C_MACRO_USERHOME,GHomePath,[rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result,C_MACRO_TEMPDIR,GTempPath,[rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result,C_MACRO_NMATTER,IntToStr(ANMatter),[rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result,C_MACRO_FILEID, TableString('MATTER','NMATTER',IntToStr(ANMatter),'FILEID'),[rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result,C_MACRO_CLIENTID, TableString('MATTER','NMATTER',IntToStr(ANMatter),'CLIENTID'),[rfReplaceAll, rfIgnoreCase]);

  Result := StringReplace(Result,C_MACRO_DATE,FormatDateTime('dd-mm-yyyy',Now()) ,[rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result,C_MACRO_TIME,FormatDateTime('hh-nn-ss',Now()),[rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result,C_MACRO_DATETIME,FormatDateTime('dd-mm-yyyy-hh-nn-ss',Now()),[rfReplaceAll, rfIgnoreCase]);

  Result := StringReplace(Result,C_MACRO_AUTHOR, TableString('MATTER','NMATTER',IntToStr(ANMatter),'AUTHOR'),[rfReplaceAll, rfIgnoreCase]);
  if (ADocDescr <> '')  then
     Result := StringReplace(Result,C_MACRO_DOCDESCR, ADocDescr ,[rfReplaceAll, rfIgnoreCase]);
  if (pos(C_MACRO_DOCSEQUENCE,UpperCase(Result)) > 0) then
     Result := StringReplace(Result,C_MACRO_DOCSEQUENCE, ProcString('getDocSequence',ANMatter),[rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result,C_MACRO_USERINITIALS, UserID ,[rfReplaceAll, rfIgnoreCase]);
  if ADocID > 0 then
     Result := StringReplace(Result,C_MACRO_DOCID, IntToStr(ADocID),[rfReplaceAll, rfIgnoreCase]);

  if(Pos(C_MACRO_TEMPFILE,Result) > 0) then
  begin
    GetTempFileName(PChar(GTempPath),'axm',0,LBfr);
    Result := StringReplace(Result,C_MACRO_TEMPFILE,String(LBfr),[rfReplaceAll, rfIgnoreCase]);
  end;
end;

function TInsightiTrackWatcher.TableInteger(Table, LookupField, LookupValue,
                                            ReturnField: string): integer;
var
   qryLookup: TUniQuery;
begin
   try
      qryLookup := TUniQuery.Create(nil);
      qryLookup.Connection := uniInsight;
      with qryLookup do
      begin
         SQL.Text := 'SELECT ' + ReturnField + ' FROM ' + Table + ' WHERE ' + LookupField + ' = :' + LookupField;
         Params[0].AsString := LookupValue;
         Open;
         Result := Fields[0].AsInteger;
         Close;
      end;
   finally
      qryLookup.Free;
   end;
end;

function TInsightiTrackWatcher.ProcString(Proc: string; LookupValue: integer): string;
begin
   with procTemp do
   begin
     storedProcName := Proc;
     PrepareSQL;
     Params[1].AsInteger := LookupValue;
     Execute;
     Result := Params[0].AsString;
   end;
end;

function TInsightiTrackWatcher.MatterString(iFile: integer; sField: string): string;
var
  sGetField: string;
  qryThisMatter: TUniQuery;
begin
   Result := '0';
   qryThisMatter := TUniQuery.Create(nil);
   try
      sGetField := sField;

      with qryThisMatter do
      begin
         Connection := uniInsight;
         SQL.Text := 'SELECT ' + sGetField + ' FROM MATTER M WHERE NMATTER = :NMATTER';
         Params[0].AsInteger := iFile;
         Open;
         if not IsEmpty then
            Result := FieldByName(sField).AsString;
         Close;
      end;
   except
      On E:Exception do
//      MsgErr('Error occured accessing Matter field ' + sGetField + #13#13 + E.Message);
   end;
   qryThisMatter.Free;
end;

function TInsightiTrackWatcher.TableString(Table, LookupField, LookupValue, ReturnField: string): string;
var
  qryLookup: TUniQuery;
begin

  if (Table = 'TAXTYPE') AND ((ReturnField = 'LEDGER') OR  (ReturnField = 'OUTPUTLEDGER') OR (ReturnField = 'ADJUSTLEDGER'))
  then
  begin
    qryLookup := TUniQuery.Create(nil);
    qryLookup.Connection := uniInsight;
    with qryLookup do
        begin
        SQL.Text := 'SELECT ' + ReturnField + ' FROM TAXTYPE_LEDGER WHERE ' + LookupField + ' = :' + LookupField + ' and entity = :entity ';
        ParamByName(LookupField).AsString := LookupValue;
        ParamByName('ENTITY').AsString := Entity;
        open;
        Result := Fields[0].AsString;
        Close;
        end;
    exit;
  end;

  qryLookup := TUniQuery.Create(nil);
  qryLookup.Connection := uniInsight;
  with qryLookup do
  begin
    SQL.Text := 'SELECT ' + ReturnField + ' FROM ' + Table + ' WHERE ' + LookupField + ' = :LookupField';
    Params[0].AsString := LookupValue;
    Open;
    Result := Fields[0].AsString;
    Close;
  end;
  qryLookup.Free;
end;

function TInsightiTrackWatcher.GetSeqnum(sField: string): integer;
var
  iTmp: integer;
begin
{ GetSeqnum grabs the Seqnum specified by sField and returns it.
}
  try
    with qrySeqNums do
    begin
      Close;

      SQL.Text := 'SELECT ' + sField + ' FROM SEQNUMS FOR UPDATE';
      Open;
      iTmp := -1;
      if not IsEmpty then
      begin
        iTmp := FieldByName(sField).AsInteger + 1;
        SQL.Text := 'UPDATE SEQNUMS SET ' + sField + ' = ' + IntToStr(iTmp);
        ExecSQL;
        Close;
      end;
      Close;
      Result := iTmp;
    end;
  except
    // Didn't work for some reason
    On E: Exception do
    begin
//      MsgErr('Could not get next sequential number: ' + sField + #13#13 + E.Message);
//      raise;
    end;
  end;
end;

function TInsightiTrackWatcher.TableStringEntity(aTable, aLookupField: string; aLookupValue: integer; aReturnField: string; aEntity: string): string;
var
  qryLookup    : TUniQuery;
  lsEntitySQL  : String;
begin
  if aEntity = '' then
    aEntity:= Entity;

  qryLookup := TUniQuery.Create(nil);
  qryLookup.Connection := uniInsight;

  if (UpperCase(aTable) = 'CHART') then
    lsEntitySQL := ' AND BANK = :ENTITY '
  else
    lsEntitySQL := ' AND ENTITY = :ENTITY ';

  with qryLookup do
  begin
    SQL.Text := 'SELECT ' + aReturnField + ' FROM ' + aTable + ' WHERE ' + aLookupField + ' = :' + aLookupField + lsEntitySQL;
    Params[0].AsInteger := aLookupValue;

    Params[1].AsString := aEntity;

    Open;
    Result := Fields[0].AsString;
    Close;
  end;
  qryLookup.Free;
end;

procedure TInsightiTrackWatcher.tmrScanTimer(Sender: TObject);
begin
     if (ParamCount > 1) then
        WriteLog('Parameter ' + Param[1]);
     tmrScan.Interval := iTimer;
     tmrScan.Enabled := false;
     ProcessDirectory('');
     tmrScan.Enabled := true;
end;

function TInsightiTrackWatcher.ValidLedger(sEntity, sLedger: string): boolean;
begin
   // Make sure that the ledger exists
   try
      with qryCharts do
      begin
         Close;
         SQL.Clear;
         SQL.Add('SELECT CODE');
         SQL.Add('FROM CHART');
         SQL.Add('WHERE BANK = :BANK');
         SQL.Add('  AND COMPONENT_CODE_DISPLAY = :CODE');

         ParamByName('BANK').AsString := sEntity;
         ParamByName('CODE').AsString := sLedger;
         Open;

         if FieldByName('CODE').IsNull then
         begin
            Close;
            SQL.Clear;
            SQL.Add('SELECT CODE');
            SQL.Add('FROM CHART');
            SQL.Add('WHERE BANK = :BANK');
            SQL.Add('  AND CODE = :CODE');
            ParamByName('BANK').AsString := sEntity;
            ParamByName('CODE').AsString := sLedger;
            Open;
            if FieldByName('CODE').IsNull then
               ValidLedger := False
            else
               ValidLedger := True;
         end
         else
            ValidLedger := True;
      end;
   finally
      qryCharts.Close;
   end;
end;

procedure TInsightiTrackWatcher.PostLedger(dtDate: TDateTime; cAmount: currency; cTax: Currency;
                          sRefno: string; sOwnerCode: string; iOwner: int64; sDesc: string;
                          sLedger: string; sAuthor: string; iInvoice: int64;
                          CreditorCode: string; sTaxCode : String; bJournalSplit : Boolean = FALSE;
                          sParentChart : String = '0'; nAlloc: int64 = 0; nMatter: int64 = 0;
                          nAccount: int64 = 0; UseRvDate: Boolean = FALSE; nTrans: integer = 0;
                          cBAS_Tax: currency = 0);
var
  sFullLedger,
  sSubChart,
  sRoundChart : String;
  fPercent,fSubChartAmount,fSubChartAmountTax : currency;
  fTotalPosted,fTotalTaxPosted : currency;
  iNumRound : integer;
  iTotalPercent : double;
begin
   if (sAuthor = '') then
      sFullLedger := sLedger
   else
      sFullLedger := GetSubchart(Entity, sLedger, sAuthor);
   try
      with qryExpenseAllocations do
      begin
         close;
         paramByName('CODE').AsString := sFullLedger;
         paramByName('BANK').AsString := Entity;
         open;
         first;

         if eof then
         begin
            SaveLedger(dtDate, cAmount, cTax, sRefno, sOwnerCode, iOwner, sDesc,
                       sFullLedger, sAuthor, iInvoice, CreditorCode, sTaxCode,
                       sParentChart, nAlloc, nMatter, nAccount,UseRvDate, nTrans, cBAS_Tax);
         end
         else
         begin
            fTotalPosted := 0;
            fTotalTaxPosted := 0;
            iTotalPercent := 0;
            iNumRound := 0;
            while not eof do
            begin
               iTotalPercent := iTotalPercent + fieldByName('percentage').AsFloat;
               if fieldByname('is_rounding').AsString = 'Y' then
               begin
                  sRoundChart := fieldByName('CODE').AsString;
                  inc(iNumRound);
               end
               else
               begin
                  sSubChart := fieldByName('CODE').AsString;
                  fPercent := fieldByName('percentage').AsFloat;
                  fPercent := fPercent / 100;
                  fSubChartAmount := cAmount * fPercent;
                  fSubChartAmountTax := cTax * fPercent;
                  // make sure the amounts round !
                  fSubChartAmount := round(fSubChartAmount*100)/100;
                  fSubChartAmountTax := round(fSubChartAmountTax*100)/100;

                  fTotalPosted := fTotalPosted + fSubChartAmount;
                  fTotalTaxPosted := fTotalTaxPosted + fSubChartAmountTax;

                  SaveLedger(dtDate, fSubChartAmount, fSubChartAmountTax, sRefno, sOwnerCode, iOwner, sDesc,
                             sSubChart, sAuthor, iInvoice, CreditorCode, sTaxCode,
                             sParentChart, nAlloc, nMatter, nAccount,UseRvDate, nTrans, cBAS_Tax);
               end;
               next;
           end;
           {now post the rounding amout}
           if iNumRound <> 1then
//              raise Exception.Create('Error one rounding must exists in expense allocations');

           if round(iTotalPercent*100)/100 <> 100 then
//              raise Exception.Create('Total percentage in expense allocations must be 100%');

           SaveLedger(dtDate, cAmount-fTotalPosted, cTax-fTotalTaxPosted, sRefno, sOwnerCode, iOwner, sDesc,
               sRoundChart, sAuthor, iInvoice, CreditorCode, sTaxCode,
               sParentChart, nAlloc, nMatter, nAccount,UseRvDate, nTrans, cBAS_Tax);
        end;
        close;
      end;
   except
//
  end;
end;

function TInsightiTrackWatcher.GetSubchart(sEntity: string; sMainChart: string; sEmp: String): string;
var
  sTmpLedger: string;
begin
   with qryEmps do
   begin
      Close;
      SQL.Text := 'SELECT CHART_SUFFIX FROM EMPLOYEE WHERE CODE = :CODE';
      Params[0].AsString := sEmp;
      Open;

      if not IsEmpty then
      begin
         sTmpLedger := sMainChart + FieldByName('CHART_SUFFIX').AsString;
         if not ValidLedger(sEntity, sTmpLedger) then
            sTmpLedger := sMainChart;
      end
      else
         sTmpLedger := sMainChart;
   end;

   if not ValidLedger(sEntity, sTmpLedger) then
//    Raise EPostError.Create('Invalid Ledger Code: ' + sMainChart);

   GetSubchart := sTmpLedger;
end;

procedure TInsightiTrackWatcher.SaveLedger(dtDate: TDateTime; cAmount: currency; cTax: Currency;
  sRefno, sOwnerCode: string; iOwner: integer; sDesc, sFullLedger, sAuthor: string;
  iInvoice: Integer; CreditorCode, sTaxCode, sParentChart: String; nAlloc: integer = 0;
  nMatter: int64 = 0; nAccount: integer = 0; UseRvDate: boolean = FALSE; nTrans: integer = 0;
  cBAS_Tax: currency = 0);
var
  Text                 : String;
  TransactionsFilePath : String;
  t                    : TextFile;
begin
   if (not ValidLedger(Entity, sFullLedger)) then
//    Raise EPostError.Create('Invalid Ledger: ' + sFullLedger)
   else
      if (not IsActiveLedger(Entity, sFullLedger)) then
//      Raise EPostError.Create('Inactive Ledger: ' + sFullLedger)
      else
      if (cAmount <> 0) then
      begin

        try
          with qryTransItemInsert do
          begin
            ParamsNullify(Params);

            ParamByName('CREATED').AsDateTime := dtDate;
            ParamByName('ACCT').AsString := Entity;
            ParamByName('AMOUNT').AsFloat := cAmount;
            ParamByName('TAX').AsFloat := cTax;
            ParamByName('REFNO').AsString := sRefno;
            ParamByName('DESCR').AsString := sDesc;
            ParamByName('CHART').AsString := sFullLedger;
            ParamByName('OWNER_CODE').AsString := sOwnerCode;
            ParamByName('NOWNER').AsInteger := iOwner;
            ParamByName('TAXCODE').AsString := sTaxCode;
            ParamByName('PARENT_CHART').AsString := sParentChart;
            if nTrans > 0 then
               ParamByName('NTRANS').AsInteger := nTrans;

            ParamByName('WHO').AsString := UserID;

            if (sOwnerCode = 'CHEQUE') then
              ParamByName('NCHEQUE').AsInteger := iOwner;

            if (iInvoice <> -1) then
            begin
             ParamByName('NINVOICE').AsInteger := iInvoice;
             ParamByName('CREDITORCODE').AsString := CreditorCode;
            end;

            if (sOwnerCode = 'RECEIPT') then
              ParamByName('NRECEIPT').AsInteger := iOwner;

            if (sOwnerCode = 'JOURNAL') then
              ParamByName('NJOURNAL').AsInteger := iOwner;

            if (nAlloc <> 0) then
              ParamByName('NALLOC').AsInteger := nAlloc;

            if (nMatter <> 0) then
              ParamByName('NMATTER').AsInteger := nMatter;

            if (UseRvDate)then
              ParamByName('RVDATE').AsDate := Now;

            ParamByName('VERSION').AsString := C_VERSION;

            ParamByName('BAS_TAX').AsFloat := cTax;
            ExecSQL;
            Close;

//            cLedgerTotal := cLedgerTotal + cAmount;
          end;
        except
          on E : Exception do
          begin
            Raise;
          end;
        end;
      end;
end;

function TInsightiTrackWatcher.IsActiveLedger(sEntity : String; sFullLedger : String) : Boolean;
var
   loQryCharts : TUniQuery;
begin
   loQryCharts := nil;
   try
      loQryCharts := qryCharts;
      loQryCharts.Connection := uniInsight;
      loQryCharts.Close;
      loQryCharts.SQL.Clear;
      loQryCharts.SQL.Add('SELECT ACTIVE');
      loQryCharts.SQL.Add('FROM CHART');
      loQryCharts.SQL.Add('WHERE BANK = :BANK');
      loQryCharts.SQL.Add('  AND CODE = :CODE');
      loQryCharts.Params[0].AsString := sEntity;
      loQryCharts.Params[1].AsString := sFullLedger;
      loQryCharts.Open;

      if (not loQryCharts.IsEmpty) then
      begin
        Result := (loQryCharts.FieldByName('ACTIVE').AsString = 'Y');
      end
      else
         Result := False;
   finally
      loQryCharts.Close;
   end;    //  end try-finally
end;

procedure TInsightiTrackWatcher.ParamsNullify(parClear: TParams);
var
  iCtr: integer;
begin
  for iCtr := 0 to parClear.Count - 1 do
    parClear.Items[iCtr].Value := null;
end;

function TInsightiTrackWatcher.getGlComponents : TglComponentSetup;
begin
   if glComponentReg = nil then
      loadGlComponent;

   getGlComponents := glComponentReg;
end;

procedure TInsightiTrackWatcher.loadGlComponent;
begin
   if glComponentReg <> nil then
      glComponentReg.Free;
   glComponentReg := TglComponentSetup.init(Self.Entity, uniInsight);
end;

function TInsightiTrackWatcher.GetServiceExecutablePath(strMachine: string; strServiceName: string): String;
var
  hSCManager,hSCService: SC_Handle;
  lpServiceConfig: LPQUERY_SERVICE_CONFIG;
  nSize, nBytesNeeded: DWord;
begin
  Result := '';
  hSCManager := OpenSCManager(PChar(strMachine), nil, SC_MANAGER_CONNECT);
  if (hSCManager > 0) then
  begin
    hSCService := OpenService(hSCManager, PChar(strServiceName), SERVICE_QUERY_CONFIG);
    if (hSCService > 0) then
    begin
      QueryServiceConfig(hSCService, nil, 0, nSize);
      lpServiceConfig := AllocMem(nSize);
      try
        if not QueryServiceConfig(hSCService, lpServiceConfig, nSize, nBytesNeeded) Then Exit;
          Result := lpServiceConfig^.lpBinaryPathName;
      finally
        Dispose(lpServiceConfig);
      end;
      CloseServiceHandle(hSCService);
    end;
  end;
end;

{procedure TInsightiTrackWatcher.HandleFolderChange(ASender: TFolderMon;
  AFolderItem: TFolderItemInfo);
begin
   if FOLDER_ACTION_NAMES[AFolderItem.Action] = 'New' then
   begin
      SaveSearchFromXML(AFolderItem.Name);
   end;
end; }

function TInsightiTrackWatcher.IndexPath(PathText, PathLoc: string): string;
var
   iWords, i: integer;
   NewPath, sWord, sNewline, AUNCPath: string;
   LImportFile: array of string;
begin
   AUNCPath := ExpandUNCFileName(PathText);
   if (pos('\',PathLoc) = 0) then
      NewPath := SystemString(PathLoc)
   else
      NewPath := PathLoc;

   if NewPath <> '' then
   begin
      iWords := 0;
      SetLength(LImportFile,length(PathText));
      sNewline := copy(PathText,3,length(PathText));
      while TokenizePath(sNewline ,sWord) do
      begin
         LImportFile[iWords] := sWord;
         inc(iWords);
      end;

      for i := 0 to (length(LImportFile) - 1) do
      begin
         if LImportFile[i] <> '' then
            NewPath := NewPath + '/' + LImportFile[i];
      end;
      Result := NewPath;
   end
   else
      Result := AUNCPath;
end;

function TInsightiTrackWatcher.TokenizePath(var s, w:string):boolean;
{Note that this a "destructive" getword.
  The first word of the input string s is returned in w and
  the word is deleted from the input string}
const
  delims:set of char = ['/','\'];
var
  i:integer;
begin
  w:='';
  if length(s)>0 then
  begin
    i:=1;
    while (i<length(s))  and (s[i] in delims) do inc(i);
    delete(s,1,i-1);
    i:=1;
    while (i<=length(s)) and (not (s[i] in delims)) do inc(i);
    w:=copy(s,1,i-1);
    delete(s,1,i);
  end;
  result := (length(w) >0);
end;

function TInsightiTrackWatcher.IsValidFileID(sFileId: string): boolean;
var
  loQry : TUniQuery;
begin
   try
      loQry := nil;
      try
         loQry := TUniQuery.Create(nil);
         loQry.Connection := uniInsight;

         loQry.Close;
         loQry.SQL.Clear;
         loQry.SQL.Add('SELECT 1 FROM MATTER WHERE FILEID = :sFileId ');
         loQry.ParamByName('sFileId').AsString := sFileId;

         loQry.Open;

         Result := (not loQry.Eof);
      finally
         loQry.Close;
         FreeAndNil(loQry);
    end;    //  end try-finally
    except
       on E : Exception do
       begin
          Raise;
       end;
    end;
end;


{procedure TInsightiTrackWatcher.OnNotify(const Sender: TObject; const Action: TWatchAction;
                               const FileName: string);
begin
   if (Action = waAdded) then
   begin
      FFileName := FileName;
      SaveSearchFromXML( FileName);
   end;
end; }



/////////////////////////////////////////////////////////////
///
procedure TInsightiTrackWatcher.ProcessDirectory(sDirectory: String);
var
   F: TextFile;
   ConnStr: string;
begin
   //btnStop.Enabled := True;
   {if FileExists(fServicePath +  'Insight.INI') then
   begin
      try
          AssignFile(F, fServicePath +  'Insight.INI');
          Reset(F);
          ReadLn(F, ConnStr);
          UniInsight.Server := ConnStr;
          UniInsight.Username := 'axiom';
          UniInsight.Password := 'axiom';
          UniInsight.Connect;
      finally
          CloseFile(F);
      end; }

      if (SystemString('INFOTRACK_URL') <> '') then
      begin
         slFileFound := tstringlist.Create;
         slPathFound := tstringlist.Create;
         InfotrackFolder := IncludeTrailingPathDelimiter(SystemString('INFOTRACK_STAGING_FLDR'));
         DoFileScan(InfotrackFolder);
         DoLoadUp(InfotrackFolder);
         Writelog('Listening on folder ' + SystemString('INFOTRACK_STAGING_FLDR'));
      end;
  { end
   else
   begin
      WriteLog('File: ' + fServicePath +  'Insight.INI' + ' not found');
   end;}
end;

procedure TInsightiTrackWatcher.MoveDocument(FileName: string);
var
   AFileName, AModFileName, NewDocName, ANewDocName: string;
   AFileID, AParsedDocName, NewDocPath, ADocID: string;
   bMoveSuccess,
   bCopyMove,
   attachmentIsInline: boolean;
   AFileExt,
   FileExt,
   EmailSentTo,
   EmailFrom,
   DispName,
   AExt,
   ADispName,
   VarDocName,
   AParsedDir,
   ParsedVarDocName: string;
   ADocumentSaved: boolean;
begin

   try
      AFileName := ExtractFileName(FileName);
      AFileExt := ExtractFileExt(AFileName);
      ANewDocName := AFileName;
      bCopyMove := True;

      NewDocPath := SystemString('INFOTRACK_STAGING_FLDR');
      NewDocName := IncludeTrailingPathDelimiter(NewDocPath) + 'Saved_Searches\' + ANewDocName;

      //if FileExists(NewDocName) = False then
      //begin
            if (FileName = NewDocName) then
               bMoveSuccess := True
            else
            begin
               if (TOSVersion.Name = 'Windows 8') or (TOSVersion.Name = 'Windows Server 2012') then
               begin
                  //bMoveSuccess := CopyFileIFileOperationForceDirectories(FileName, NewDocName, bCopyMove)
                  bMoveSuccess := CopyFileIFileOperationForceDirectories(FileName, GetUniqueXMLFileName(NewDocName), bCopyMove);
               end
               else
                  bMoveSuccess := MoveMatterDoc(AParsedDocName, FileName, bCopyMove, False);
            end;
      //end;
   finally
//      dmAxiom.qryDocDetails.Post;
   end;
end;


function TInsightiTrackWatcher.MoveMatterDoc(var ANewDocName: string; AOldDocName: string; DeleteOrigDoc: boolean; DisplayMsg: boolean): boolean;
var
   ADocumentSaved: boolean;
   AError: integer;
begin
   ADocumentSaved := True;
   try
      // Check if directory exists
      if not DirectoryExists(ExtractFileDir(ANewDocName)) then
         ForceDirectories(ExtractFileDir(ANewDocName));
      // try to copy file
      if FileExists(ANewDocName) then
         ADocumentSaved := False
      else
      begin
         if not CopyFile(PChar(AOldDocName) ,pchar(ANewDocName), true) then
         begin
            AError := GetLastError;
            case AError of
               80: begin
                      //if DisplayMsg = True then
                      //begin
                      //   if MessageDlg('File already exists. Do you want to overwrite it?' , mtConfirmation, [MBYES,MBNO], 0, mbYes) = IDYES then
                      //     ADocumentSaved := CopyFile(PChar(AOldDocName) ,pchar(ANewDocName), false);
                      //end
                      //else
                      //begin
                         WriteLog('File already exists');
                         ADocumentSaved := CopyFile(PChar(AOldDocName) ,pchar(ANewDocName), false);
                      //end;
                   end;
               82: begin
                     //if DisplayMsg = True then
                     //   MessageDlg('There was an error during the saving of the document.  The directory or file could not be created.', mtError , [MBOK], 0, mbOK );
                     WriteLog('There was an error during the saving of the document.  The directory or file could not be created.');
                     ADocumentSaved := False;
                   end;
               5:  begin
                     //if DisplayMsg = True then
                     //   MessageDlg('There was an error during the saving of the document.  Access denied.', mtError, [MBOK], 0, mbOK);
                     WriteLog('There was an error during the saving of the document.  Access denied.');
                     ADocumentSaved := False;
                   end;
               39,112: begin
                     //if DisplayMsg = True then
                     //   MessageDlg('There was an error during the saving of the document.  The disk is full!', mtError, [MBOK], 0, mbOK);
                     Writelog('There was an error during the saving of the document.  The disk is full!');
                     ADocumentSaved := False;
                   end;
               111:begin
                     //if DisplayMsg = True then
                     //   MessageDlg('There was an error during the saving of the document.  The filename is to long!', mtError, [MBOK], 0, mbOK);
                     WriteLog('There was an error during the saving of the document.  The filename is to long!');
                     ADocumentSaved := False;
                   end;
               53,3 :begin
                     //if DisplayMsg = True then
                     //   MessageDlg('There was an error during the saving of the document.  The network path was not found!', mtError, [MBOK], 0, mbOK);
                     WriteLog('There was an error during the saving of the document.  The network path was not found!');
                     ADocumentSaved := False;
                   end;
            else
               //if DisplayMsg = True then
               //   MessageDlg('There was an error during the saving of the document.  The document was not saved. Error: ' + IntTostr(AError),  mtError, [MBOK], 0, mbOK);
               WriteLog('There was an error during the saving of the document.  The document was not saved. Error: ' + IntTostr(AError));
               ADocumentSaved := False;
            end;
         end;
         // delete file if succesfull
         if DeleteOrigDoc and ADocumentSaved then
            RecycleDelete(PChar(AOldDocName));
//         DeleteFile(AOldDocName);
      end;
   except
      on E: Exception do
      begin
         //if DisplayMsg = True then
         //   MessageDlg('There was an Error during the saving of the document.  The document was not saved: ' + E.Message, mtError, [MBOK], 0, mbOK);
         WriteLog('There was an error during the saving of the document.  The document was not saved. Error: '+ E.Message);
         ADocumentSaved := False;
      end;
   end;
   Result := ADocumentSaved;
end;

function TInsightiTrackWatcher.CopyFileIFileOperationForceDirectories(const srcFile, destFile : string; DeleteOrigDoc: boolean) : boolean;
//works on Windows >= Vista and 2008 server
var
  r : HRESULT;
  fileOp: IFileOperation;
  siSrcFile, siDestFile: IShellItem;
  siDestFolder: IShellItem;
  destFileFolder, destFileName : string;
  pbc : IBindCtx;
  w32fd : TWin32FindData;
  ifs : TFileSystemBindData;
begin
   result := false;

   destFileFolder := ExtractFileDir(destFile);
   destFileName := ExtractFileName(destFile);

   //if FileExists(destFile) then
   //   Result := False
   //else
   //begin
      //init com
      r := CoInitializeEx(nil, COINIT_APARTMENTTHREADED or COINIT_DISABLE_OLE1DDE);
      if Succeeded(r) then
      begin
         //create IFileOperation interface
         r := CoCreateInstance(CLSID_FileOperation, nil, CLSCTX_ALL, IFileOperation, fileOp);
         if Succeeded(r) then
         begin
            //set operations flags
            r := fileOp.SetOperationFlags(FOF_NOCONFIRMATION OR FOFX_NOMINIMIZEBOX);
            if Succeeded(r) then
            begin
               //get source shell item
               r := SHCreateItemFromParsingName(PChar(srcFile), nil, IShellItem, siSrcFile);
               if Succeeded(r) then
               begin
                  //create binding context to pretend there is a folder there
                  if NOT DirectoryExists(destFileFolder) then
                  begin
                     ZeroMemory(@w32fd, Sizeof(TWin32FindData));
                     w32fd.dwFileAttributes := FILE_ATTRIBUTE_DIRECTORY;
                     ifs := TFileSystemBindData.Create;
                     ifs.SetFindData(w32fd);
                     CreateBindCtx(0, pbc);
                     pbc.RegisterObjectParam(STR_FILE_SYS_BIND_DATA, ifs);
                  end
                  else
                     pbc := nil;

                  //get destination folder shell item
                  r := SHCreateItemFromParsingName(PChar(destFileFolder), pbc, IShellItem, siDestFolder);

                  if FileExists(destFile) then
                  begin
                     if Succeeded(r) then
                     begin
                          //get destination shell item
                          r := SHCreateItemFromParsingName(PChar(destFile), nil, IShellItem, siDestFile);
                          if Succeeded(r) then
                          begin
                                r := fileOp.DeleteItem(siDestFile, nil);
                          end;
                          if Succeeded(r) then r := fileOp.PerformOperations;
                      end;
                  end;
                  if DeleteOrigDoc = False then  //add copy operation
                  begin
                     if Succeeded(r) then
                        r := fileOp.CopyItem(siSrcFile, siDestFolder, PChar(destFileName), nil);
                  end
                  else   //add move operation
                  begin
                     if Succeeded(r) then
                        r := fileop.MoveItem(siSrcFile, siDestFolder, PChar(destFileName), nil);
                  end;
               end;

               //execute
               if Succeeded(r) then r := fileOp.PerformOperations;

               result := Succeeded(r);

               OleCheck(r);
            end;
         end;
         CoUninitialize;
      end;
   //end;
end;

function TInsightiTrackWatcher.IsFileInUse(FileName: TFileName): Boolean;
var
  HFileRes: HFILE;
begin
  Result := False;
  if not FileExists(FileName) then Exit;
  HFileRes := CreateFile(PChar(FileName),
                         GENERIC_READ or GENERIC_WRITE,
                         0,
                         nil,
                         OPEN_EXISTING,
                         FILE_ATTRIBUTE_NORMAL,
                         0);
  Result := (HFileRes = INVALID_HANDLE_VALUE);
  if not Result then
    CloseHandle(HFileRes);
end;

function TInsightiTrackWatcher.GetUniqueXMLFileName(AFilename: String): String;
var
  NewFileName, BaseFileName: String;
  Directory: String;
  I: Integer;
begin
  WriteLog('GetUniqueXMLFileName: ' + AFileName);

  // This file doesn't exist, we're okay to copy it over. Jump out.
  if not FileExists(AFileName) then
  begin
    Result := AFileName;
    exit;
  end;

  // This is the filename from InfoTrack. It will have no '_N' suffix.
  BaseFileName := TPath.GetFileNameWithoutExtension(AFileName);
  Directory := TPath.GetDirectoryName(AFileName);

  WriteLog('BaseFileName: ' + BaseFileName);

  i := 0;
  repeat
    if i > 0 then
      NewFileName := BaseFileName + '_' + IntToStr(i)
    else
      NewFileName := BaseFileName;
    NewFileName := Directory + '\' + NewFileName + '.xml';
    inc(i);
  WriteLog('Repeating until found: ' + NewFileName);
  until not FileExists(NewFileName);
  Result := NewFileName;
  // Once this loop has finished, the filename is unique in the folder.
end;

function TInsightiTrackWatcher.AppendDocID(AFileName: String): String;
begin
  // Look for the position of the '.', put the Doc ID before it.
  if FDocID = 0 then
    GetNewDocID;

  Result := TPath.GetDirectoryName(AFileName) + '\' +
    TPath.GetFileNameWithoutExtension(AFilename) +
    '_' + IntToStr(FDocID) + TPath.GetExtension(AFileName);
end;

procedure TInsightiTrackWatcher.GetNewDocID;
begin
   qryGetDocSeq.ExecSQL;
   FDocID := qryGetDocSeq.FieldByName('nextdoc').AsInteger
end;

procedure TInsightiTrackWatcher.qryMatterAttachmentNewRecord(DataSet: TDataSet);
begin
   GetNewDocID;
   DataSet.FieldByName('docid').AsInteger := FDocID;
end;

procedure TInsightiTrackWatcher.WriteLog(const AMessage: string);
var
   stream: TFileStream;
   value,
   newName,
   formattedDateTime: string;
   FTextFile : TextFile;
   FileHandle: integer;
   FileSize: DWord;
begin
      if (bLogIt) then
      begin
        try
          if LogFile = '' then
             LogFile := fServicePath + 'INFOWATCH.LOG';
          if (LogFile <> '') then
          begin
             if AMessage = '' then exit;

             try
                //EnterCriticalSection(CS);
                if (DirectoryExists(ExtractFileDir(LogFile)) = False) then
                   CreateDir(ExtractFileDir(LogFile));
                AssignFile(FTextFile, LogFile);
                if (FileExists(LogFile) = True) then
                   Append(FTextFile)
                else
                   Rewrite(FTextFile);

                try
                   value := DateTimeToStr(Now()) + ' - ' + AMessage;
                   WriteLn(FTextFile, value);
                finally
                    CloseFile(FTextFile);
                end;
             finally
                if (IsFileInUse(LogFile) = True) then
                   CloseFile(FTextFile);
                //LeaveCriticalSection(CS);
             end;

             FileHandle := FileOpen(LogFile, fmOpenRead);
             try
                FileSize := GetFileSize(FileHandle, nil);
             finally
                FileClose(FileHandle);
                if (FileSize > 10000) then
                begin
                   DateTimeToString(formattedDateTime, 'ddmmyy_hhnnss', Now());
                   newName := ChangeFileExt(LogFile, formattedDateTime+'.log');
                   RenameFile(LogFile, newName);
    //                  ShowMessage('Unit1.dcu rename failed with error : '+ IntToStr(GetLastError));
                end;
             end;
          end;
        except
         //
        end;
    end;
end;

function TInsightiTrackWatcher.DoLoadUp(const APathName: string): integer;
var
   PathName: string;
   i: integer;
begin
     for i := 0 to slPathFound.Count-1 do
      begin
           SaveSearchFromXML(slFileFound[i]);
           MoveDocument(slPathFound[i]);
      end;
end;

function TInsightiTrackWatcher.DoFileScan(const APathName: string): integer;
var
   PathName: string;
   LRetFileCount: integer;
begin
   try
      LRetFileCount := 0;
      LRetFileCount := FileSearch(APathName,'*.xml');
   finally
      DoFileScan := LRetFileCount;
   end;
end;

function TInsightiTrackWatcher.FileSearch(const PathName, FileName : string): integer;
var
   Rec  : TSearchRec;
   Path : string;
begin
   try
      Path := IncludeTrailingPathDelimiter(PathName);
      try
         if FindFirst(Path + FileName, faAnyFile - faDirectory, Rec) = 0 then
         try
            repeat
                // Only process the file if it's not busy at this moment.
                if not IsFileInUse(Path + Rec.Name) then
                begin
                   slFileFound.Add(Rec.Name);
                   slPathFound.Add(Path + Rec.Name);
                end;
            until FindNext(Rec) <> 0;
         finally
            FindClose(Rec);
         end;
      finally
         Result := iFileCount;
      end;
   except
   //
   end;
end;

procedure TInsightiTrackWatcher.ReadSettingsIni;
var
  IniFile: TIniFile;
begin
     IniFile := TIniFile.Create(fServicePath + 'INFOSERV.INI');
     try
       bLogIt := IniFile.ReadString('SETTINGS','LOG','NO') = 'ON';
       iTimer := IniFile.ReadInteger('SETTINGS','TIMER',300) * 1000;
       fServer := IniFile.ReadString('SETTINGS','SERVER','localhost:1521:XE');
     finally
         IniFile.Free;
     end;
end;

function TInsightiTrackWatcher.RecycleDelete(inpath: string): integer;
{ deletes 'inpath', removing it to the recycle bin.  You can specify a list
 of files, as long as you put #0 between the files, and double-terminate it
  with #0. }
var
  FileOp: TSHFileOpStructA;
  pTmp: PAnsiChar;
begin
   pTmp := PAnsiChar(inpath + #0#0);
   with FileOp do
   begin
      wnd := 0;
      wFunc := FO_DELETE;  //FO_COPY, FO_DELETE, FO_MOVE, FO_RENAME
      pFrom := pTmp;
      fFlags := FOF_ALLOWUNDO or FOF_SILENT or FOF_NOCONFIRMATION;
      fAnyOperationsAborted := false;
      hNameMappings := nil;
      lpszProgressTitle := nil;
   end;
   Result := SHFileOperationA(FileOp);
 { at this point, if you allow confirmation, you can interrogate
   FileOp.fAnyOperationsAborted to determine if the user aborted your operation.
   }
end;



end.
