
/*------------------------------------------------------------------------
    File        : WallesterApi
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : vsink_000
    Created     : Tue May 11 12:44:52 EEST 2021
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.

interface wallester.WallesterApi:  
    
  {wallester/ttAccount.i}
  {wallester/ttAccountLimits.i}
  {wallester/ttAccountRequest.i}
  {wallester/ttCard.i}
  {wallester/ttCardLimits.i}
  {wallester/ttPerson.i}
  
  method public logical createPerson(input-output table ttPerson, pcAuditUser as char).
  method public logical getPersonById (pcPersonID as char, pcAuditUser as char, output table ttPerson).
  method public logical getPersonByExternalId (pcExternalId as char, pcAuditUser as char, output table ttPerson).
  method public logical updatePerson(input-output table ttPerson, pcAuditUser as char).
  method public logical getPersonAccounts(pcPersonId as char, pcAuditUser as char, output table ttAccount).
  method public logical activateCard (pcPersonId as char, pcLastFourDigits as char, pcAuditUser as char, output table ttCard).
  method public logical getPersonCards (pcPersonId as char, pcAuditUser as char, output table ttCard).
  method public logical createAccount(input table ttAccountRequest, pcAuditUser as char, output table ttAccount).
  method public logical getAccountById(pcAccountId as char, pcAuditUser as char, output table ttAccount).
  method public logical getAccountByExternalId(pcExternalId as char, pcAuditUser as char, output table ttAccount).
  method public logical adjustAccountBalance(pcAccountId as char, pcExternalId as char, pdAmount as dec, pcDescription as char, pcAuditUser as char, output table ttAccount).
  method public logical getAccountCards(pcAccountId as char, pcAuditUser as char, output table ttCard).
  method public logical updateAccountCreditLimit(pcAccountId as char, pdNewLimit as dec, pdDescription as char, pcAuditUser as char, output table ttAccount).
  method public logical updateAccountLimits(pcAccountId as char, input table ttAccountLimits, pcAuditUser as char, output table ttAccount).
  method public logical updateAccountName(pcAccountId as char, pcNewName as char, pcAuditUser as char, output table ttAccount).
  method public char    ping(pcMessage as char).
  
/*  
    {smart4oe/domain/ttActionLog.i}
  {smart4oe/domain/ttCardLimit.i}
  {smart4oe/domain/dsStatement.i}
  {smart4oe/domain/ttCHolderResp.i}
  {smart4oe/domain/ttCHolder4create.i} 
  {smart4oe/domain/ttCHolder4update.i}
  {smart4oe/domain/ttCHolder4another.i} 
  {smart4oe/domain/ttToken.i}
  {smart4oe/domain/ttCardDet.i}
  {smart4oe/domain/ttCredentialsEmailReq.i}

    define public property descriptionDelimiter as character no-undo
    get.
    set. 

    method public logical activateCard (pcToken as char, pcReason as char, poItemSource as ItemSourceEnum, poSmsBalance as SmsBalanceEnum).
    method public char createAnotherCard(input table ttCHolder4another, pcCardFourthLineText as char).
    method public char callPinFunction( pcToken as char, poFunction as PinFunctionEnum, poSmsRequired as SmsRequiredEnum, pcNewPin as char).
    method public char getCardPin( pcToken as char, poSmsRequired as SmsRequiredEnum).
    method public char changePin( pcToken as char, poSmsRequired as SmsRequiredEnum, pcNewPin as char, pcCurrPin as char).
    method public char generatePin( pcToken as char ).
    method public char sendPin( pcToken as character ).
    method public logical changeCardStatus( pcToken as char, pcNewStatus as char, pcReason as char, poSmsRequired as SmsRequiredEnum).
    method public logical readStatement (pcToken as char, ptStartDate as date, ptEndDate as date, poFilter as TransactionFilterEnum, output dataset dsStatement).
    method public logical findCardsByReference( pcReference as char, output table ttToken).
    method public logical readCardDetails( pcToken as char, output table ttCardDet).
    
    method public logical readCreditLimit( pcToken as char, output pdLimit as decimal).
    method public logical readCreditLimits(input-output table ttCardLimit).
    method public logical increaseCreditLimit( pcToken as char, pdLimitChange as decimal).

    method public logical readCardHolderById (piCardHolderID as int64, output table ttCHolderResp).
    method public logical readCardHolderByToken (pcToken as char, output table ttCHolderResp).
    method public logical createCardHolder (input table ttCHolder4create, output table ttCHolderResp).
    method public logical updateCardHolder (input table ttCHolder4update, output table ttCHolderResp).
    method public logical createCardHolder (input-output table ttCHolderResp).
    method public logical updateCardHolder (input-output table ttCHolderResp).
    
    method public int readActionLogs(piPage as int, piSize as int, output table ttActionLog).
    method public logical readActionLog( input logId as int64, output TABLE for ttActionLog).
    
    method public logical sendCredentialsEmail( input pcReference as char, input plSendUsername as log, input plSendPassword as log, input pcOptionalEmail as char ).
 */ 
end interface.