object InsightiTrackWatcher: TInsightiTrackWatcher
  OldCreateOrder = False
  OnCreate = ServiceCreate
  OnDestroy = ServiceDestroy
  AllowPause = False
  DisplayName = 'InsightiTrackWatcher'
  ServiceStartName = 'NT AUTHORITY\NetworkService'
  OnStart = ServiceStart
  OnStop = ServiceStop
  Height = 300
  Width = 400
  object qryMatterAttachment: TUniQuery
    Connection = uniInsight
    SQL.Strings = (
      'SELECT'
      '  DOC.DOCUMENT,'
      '  DOC.IMAGEINDEX,'
      '  DOC.FILE_EXTENSION,'
      '  DOC.DOC_NAME,'
      '  DOC.SEARCH,'
      '  DOC.DOC_CODE,'
      '  DOC.JURIS,'
      '  DOC.D_CREATE,'
      '  DOC.AUTH1,'
      '  DOC.D_MODIF,'
      '  DOC.AUTH2,'
      '  DOC.PATH,'
      '  DOC.DESCR,'
      '  DOC.FILEID,'
      '  DOC.DOCID,'
      '  DOC.NPRECCATEGORY,'
      '  DOC.NMATTER,'
      '  DOC.PRECEDENT_DETAILS,'
      '  DOC.NPRECCLASSIFICATION,'
      '  DOC.KEYWORDS,'
      '  DOC.DISPLAY_PATH,'
      '  DOC.EXTERNAL_ACCESS,'
      '  DOC.EMAIL_FROM,'
      '  DOC.EMAIL_SENT_TO,'
      '  DOC.NFEE, '
      '  DOC.ROWID'
      'FROM'
      '  DOC'
      'where'
      '  DOCID = :DOCID')
    CachedUpdates = True
    OnNewRecord = qryMatterAttachmentNewRecord
    Left = 41
    Top = 8
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'DOCID'
        Value = nil
      end>
  end
  object qrySearches: TUniQuery
    UpdatingTable = 'SEARCHES'
    KeyFields = 'search_id'
    Connection = uniInsight
    SQL.Strings = (
      'select searches.*, searches.rowid'
      'from searches')
    Left = 113
    Top = 22
  end
  object qryTmp: TUniQuery
    Connection = uniInsight
    SQL.Strings = (
      'SELECT * FROM FEE')
    Left = 159
    Top = 18
  end
  object qrySysFile: TUniQuery
    Connection = uniInsight
    SQL.Strings = (
      'SELECT * FROM SYSTEMFILE')
    Left = 14
    Top = 65
  end
  object qryGetDocSeq: TUniQuery
    Connection = uniInsight
    SQL.Strings = (
      'select DOC_DOCID.nextval as nextdoc from dual')
    Left = 91
    Top = 69
  end
  object uniInsight: TUniConnection
    ProviderName = 'Oracle'
    SpecificOptions.Strings = (
      'Oracle.Direct=True'
      'Oracle.IPVersion=ivIPBoth')
    Options.LocalFailover = True
    PoolingOptions.MaxPoolSize = 50
    PoolingOptions.MinPoolSize = 1
    PoolingOptions.ConnectionLifetime = 10000000
    PoolingOptions.Validate = True
    Username = 'axiom'
    Server = '192.168.0.22:1521:marketing'
    LoginPrompt = False
    Left = 278
    Top = 15
    EncryptedPassword = '9EFF87FF96FF90FF92FF'
  end
  object procTemp: TUniStoredProc
    Connection = uniInsight
    Left = 90
    Top = 127
  end
  object qrySeqnums: TUniQuery
    Connection = uniInsight
    SQL.Strings = (
      'SELECT S.*, S.ROWID FROM SEQNUMS S')
    CachedUpdates = True
    AutoCalcFields = False
    Left = 157
    Top = 77
  end
  object qryCharts: TUniQuery
    Connection = uniInsight
    SQL.Strings = (
      'SELECT * FROM CHART WHERE BANK = :P_Bank AND CODE = :P_Code')
    Left = 221
    Top = 21
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'P_Bank'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'P_Code'
        Value = nil
      end>
  end
  object qryExpenseAllocations: TUniQuery
    Connection = uniInsight
    SQL.Strings = (
      'select *'
      'from gl_expense_allocations gl '
      'where master_code = :code'
      'and master_bank = :bank')
    Left = 171
    Top = 133
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'code'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'bank'
        Value = nil
      end>
  end
  object qryEmps: TUniQuery
    Connection = uniInsight
    SQL.Strings = (
      'SELECT CODE FROM EMPLOYEE')
    Left = 21
    Top = 185
  end
  object qryTransItemInsert: TUniQuery
    Connection = uniInsight
    SQL.Strings = (
      'INSERT INTO transitem'
      
        '            ( /*NACCOUNT, */created, acct, amount, tax, refno, d' +
        'escr, chart,'
      
        '             owner_code, nowner, ncheque, nreceipt, ninvoice, nj' +
        'ournal,'
      
        '             creditorcode, who, taxcode, parent_chart, nalloc, n' +
        'matter,'
      '             rvdate, VERSION, ntrans, bas_tax'
      '            )'
      
        '     VALUES (                                                   ' +
        '  --:NACCOUNT,'
      
        '             :created, :acct, :amount, :tax, :refno, :descr, :ch' +
        'art,'
      
        '             :owner_code, :nowner, :ncheque, :nreceipt, :ninvoic' +
        'e, :njournal,'
      
        '             :creditorcode, :who, :taxcode, :parent_chart, :nall' +
        'oc, :nmatter,'
      '             :rvdate, :VERSION, :ntrans, :bas_tax'
      '            )')
    Left = 96
    Top = 181
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'CREATED'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'ACCT'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'AMOUNT'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'TAX'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'REFNO'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'DESCR'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'CHART'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'OWNER_CODE'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'NOWNER'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'NCHEQUE'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'NRECEIPT'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'NINVOICE'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'NJOURNAL'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'CREDITORCODE'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'WHO'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'TAXCODE'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'PARENT_CHART'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'NALLOC'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'NMATTER'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'RVDATE'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'VERSION'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'NTRANS'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'BAS_TAX'
        Value = nil
      end>
  end
  object OracleUniProvider1: TOracleUniProvider
    Left = 276
    Top = 70
  end
  object qrySearchesUpdatexx: TUniQuery
    UpdatingTable = 'SEARCHES'
    KeyFields = 'search_id'
    Connection = uniInsight
    SQL.Strings = (
      'UPDATE searches'
      '   SET availableonline = :availableonline,'
      '       billingtypename = :billingtypename,'
      '       clientreference1 = :clientreference1,'
      '       comments = :comments,'
      '       dateordered = :dateordered,'
      '       datecompleted = :datecompleted,'
      '       description = :description,'
      '       orderid = :orderid,'
      '       parentorderid = :parentorderid,'
      '       orderedby = :orderedby,'
      '       REFERENCE = :REFERENCE,'
      '       retailerfee = NVL (:retailerfee, retailerfee),'
      '       retailerfeegst = NVL (:retailerfeegst, retailerfeegst),'
      
        '       retailerfeetotal = NVL (:retailerfeetotal, retailerfeetot' +
        'al),'
      '       supplierfee = NVL (:supplierfee, supplierfee),'
      '       supplierfeegst = NVL (:supplierfeegst, supplierfeegst),'
      
        '       supplierfeetotal = NVL (:supplierfeetotal, supplierfeetot' +
        'al),'
      '       totalfee = NVL (:totalfee, totalfee),'
      '       totalfeegst = NVL (:totalfeegst, totalfeegst),'
      '       totalfeetotal = NVL (:totalfeetotal, totalfeetotal),'
      '       servicename = :servicename,'
      '       status = :status,'
      '       statusmessage = :statusmessage,'
      '       downloadurl = :downloadurl,'
      '       onlineurl = :onlineurl,'
      '       isbillable = :isbillable,'
      '       filehash = :filehash,'
      '       email = :email,'
      '       clientid = :clientid,'
      '       sequencenumber = :sequencenumber,'
      '       clientreference = :clientreference,'
      '       retailerreference = :retailerreference'
      ' WHERE search_id = :search_id')
    Left = 280
    Top = 138
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'AVAILABLEONLINE'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'BILLINGTYPENAME'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'CLIENTREFERENCE1'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'COMMENTS'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'DATEORDERED'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'DATECOMPLETED'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'DESCRIPTION'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'ORDERID'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'PARENTORDERID'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'ORDEREDBY'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'REFERENCE'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'RETAILERFEE'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'RETAILERFEEGST'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'RETAILERFEETOTAL'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'SUPPLIERFEE'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'SUPPLIERFEEGST'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'SUPPLIERFEETOTAL'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'TOTALFEE'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'TOTALFEEGST'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'TOTALFEETOTAL'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'SERVICENAME'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'STATUS'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'STATUSMESSAGE'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'DOWNLOADURL'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'ONLINEURL'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'ISBILLABLE'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'FILEHASH'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'EMAIL'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'CLIENTID'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'SEQUENCENUMBER'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'CLIENTREFERENCE'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'RETAILERREFERENCE'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'SEARCH_ID'
        Value = nil
      end>
  end
  object qrySearchID: TUniQuery
    UpdatingTable = 'SEARCHES'
    KeyFields = 'search_id'
    Connection = uniInsight
    SQL.Strings = (
      'select searches.*, searches.rowid'
      'from searches'
      'where'
      'search_id = :search_id')
    Left = 277
    Top = 194
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'search_id'
        Value = nil
      end>
  end
  object qrySearchesUpdate: TUniSQL
    Connection = uniInsight
    SQL.Strings = (
      'UPDATE SEARCHES'
      'SET'
      
        '  AVAILABLEONLINE = :AVAILABLEONLINE, BILLINGTYPENAME = :BILLING' +
        'TYPENAME, '
      
        '  CLIENTREFERENCE1 = :CLIENTREFERENCE1, COMMENTS = :COMMENTS, DA' +
        'TEORDERED = :DATEORDERED, DATECOMPLETED = :DATECOMPLETED, '
      '  DESCRIPTION = :DESCRIPTION, ORDEREDBY = :ORDEREDBY, '
      
        '  REFERENCE = :REFERENCE, RETAILERFEE = :RETAILERFEE, RETAILERFE' +
        'EGST = :RETAILERFEEGST, '
      
        '  RETAILERFEETOTAL = :RETAILERFEETOTAL, SUPPLIERFEE = :SUPPLIERF' +
        'EE, SUPPLIERFEEGST = :SUPPLIERFEEGST, SUPPLIERFEETOTAL = :SUPPLI' +
        'ERFEETOTAL, '
      
        '  TOTALFEE = :TOTALFEE, TOTALFEEGST = :TOTALFEEGST, TOTALFEETOTA' +
        'L = :TOTALFEETOTAL, SERVICENAME = :SERVICENAME, '
      
        '  STATUS = :STATUS, STATUSMESSAGE = :STATUSMESSAGE, DOWNLOADURL ' +
        '= :DOWNLOADURL, ONLINEURL = :ONLINEURL, ISBILLABLE = :ISBILLABLE' +
        ', '
      
        '  FILEHASH = :FILEHASH, EMAIL = :EMAIL, CLIENTID = :CLIENTID, SE' +
        'QUENCENUMBER = :SEQUENCENUMBER, CLIENTREFERENCE = :CLIENTREFEREN' +
        'CE, RETAILERREFERENCE = :RETAILERREFERENCE'
      'WHERE'
      '  SEARCH_ID = :SEARCH_ID')
    Left = 185
    Top = 183
    ParamData = <
      item
        DataType = ftString
        Name = 'AVAILABLEONLINE'
        ParamType = ptInput
        Value = nil
      end
      item
        DataType = ftString
        Name = 'BILLINGTYPENAME'
        ParamType = ptInput
        Value = nil
      end
      item
        DataType = ftString
        Name = 'CLIENTREFERENCE1'
        ParamType = ptInput
        Value = nil
      end
      item
        DataType = ftString
        Name = 'COMMENTS'
        ParamType = ptInput
        Value = nil
      end
      item
        DataType = ftDateTime
        Name = 'DATEORDERED'
        Value = nil
      end
      item
        DataType = ftDateTime
        Name = 'DATECOMPLETED'
        Value = nil
      end
      item
        DataType = ftString
        Name = 'DESCRIPTION'
        Value = nil
      end
      item
        DataType = ftString
        Name = 'ORDEREDBY'
        Value = nil
      end
      item
        DataType = ftString
        Name = 'REFERENCE'
        Value = nil
      end
      item
        DataType = ftString
        Name = 'RETAILERFEE'
        Value = nil
      end
      item
        DataType = ftString
        Name = 'RETAILERFEEGST'
        Value = nil
      end
      item
        DataType = ftString
        Name = 'RETAILERFEETOTAL'
        Value = nil
      end
      item
        DataType = ftString
        Name = 'SUPPLIERFEE'
        Value = nil
      end
      item
        DataType = ftString
        Name = 'SUPPLIERFEEGST'
        Value = nil
      end
      item
        DataType = ftString
        Name = 'SUPPLIERFEETOTAL'
        Value = nil
      end
      item
        DataType = ftString
        Name = 'TOTALFEE'
        Value = nil
      end
      item
        DataType = ftString
        Name = 'TOTALFEEGST'
        Value = nil
      end
      item
        DataType = ftString
        Name = 'TOTALFEETOTAL'
        Value = nil
      end
      item
        DataType = ftString
        Name = 'SERVICENAME'
        Value = nil
      end
      item
        DataType = ftString
        Name = 'STATUS'
        Value = nil
      end
      item
        DataType = ftString
        Name = 'STATUSMESSAGE'
        Value = nil
      end
      item
        DataType = ftString
        Name = 'DOWNLOADURL'
        Value = nil
      end
      item
        DataType = ftString
        Name = 'ONLINEURL'
        Value = nil
      end
      item
        DataType = ftString
        Name = 'ISBILLABLE'
        Value = nil
      end
      item
        DataType = ftString
        Name = 'FILEHASH'
        Value = nil
      end
      item
        DataType = ftString
        Name = 'EMAIL'
        Value = nil
      end
      item
        DataType = ftString
        Name = 'CLIENTID'
        Value = nil
      end
      item
        DataType = ftString
        Name = 'SEQUENCENUMBER'
        Value = nil
      end
      item
        DataType = ftString
        Name = 'CLIENTREFERENCE'
        Value = nil
      end
      item
        DataType = ftString
        Name = 'RETAILERREFERENCE'
        Value = nil
      end
      item
        DataType = ftInteger
        Name = 'SEARCH_ID'
        ParamType = ptInput
        Value = nil
      end>
  end
  object tmrScan: TTimer
    OnTimer = tmrScanTimer
    Left = 176
    Top = 240
  end
end
