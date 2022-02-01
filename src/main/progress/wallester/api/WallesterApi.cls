
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
using wallester.api.CardBlockType from propath.
using wallester.api.CardCloseReason from propath.

interface wallester.api.WallesterApi:  
  
  {wallester/api/dsStatement.i}  
  {wallester/api/ttAccount.i}
  {wallester/api/ttAccountLimits.i}
  {wallester/api/ttAccountRequest.i}
  {wallester/api/ttCard.i}
  {wallester/api/ttCardLimits.i}
  {wallester/api/ttCardRequest.i}
  {wallester/api/ttPerson.i}
  {wallester/api/ttStatementRequestParams.i}
  {wallester/api/ttStmt.i}
  
  method public logical createPerson(input-output table ttPerson, pcAuditUser as char).
  method public logical getPersonById (pcPersonID as char, pcAuditUser as char, output table ttPerson).
  method public logical getPersonByExternalId (pcExternalId as char, pcAuditUser as char, output table ttPerson).
  method public logical getPersonsByPersonalNumber (pcPersonalNumber as char, pcAuditUser as char, output table ttPerson).
  method public logical updatePerson(input-output table ttPerson, pcAuditUser as char).
  method public logical getPersonAccounts(pcPersonId as char, pcAuditUser as char, output table ttAccount).
  method public logical getPersonCards (pcPersonId as char, pcAuditUser as char, output table ttCard).

  method public logical createAccount(input table ttAccountRequest, pcAuditUser as char, output table ttAccount).
  method public logical getAccountById(pcAccountId as char, pcAuditUser as char, output table ttAccount).
  method public logical getAccountByExternalId(pcExternalId as char, pcAuditUser as char, output table ttAccount).
  method public logical getAccounts(input-output table ttAccount, pcAuditUser as char).
  method public logical adjustAccountBalance(pcAccountId as char, pcExternalId as char, pdAmount as dec, pcDescription as char, pcAuditUser as char, output table ttAccount).
  method public logical getAccountCards(pcAccountId as char, pcAuditUser as char, output table ttCard).
  method public logical updateAccountCreditLimit(pcAccountId as char, pdNewLimit as dec, pdDescription as char, pcAuditUser as char, output table ttAccount).
  method public logical updateAccountLimits(pcAccountId as char, input table ttAccountLimits, pcAuditUser as char, output table ttAccount).
  method public logical updateAccountName(pcAccountId as char, pcNewName as char, pcAuditUser as char, output table ttAccount).
  method public logical getAllAccounts (piFromRecord as int64, piCount as int, pcAuditUser as char, output table ttAccount).

  method public logical activateCard (pcPersonId as char, pcLastFourDigits as char, pcAuditUser as char, output table ttCard).
  method public logical activateCard (pcCardId as char, pcAuditUser as char, output table ttCard).
  method public logical createCard (table ttCardRequest, pcAuditUser as char, output table ttCard).
  method public logical getCardById (pcCardId as char, pcAuditUser as char, output table ttCard).
  method public logical getCardByExternalId (pcCardId as char, pcAuditUser as char, output table ttCard).
  method public logical blockCard (pcCardId as char, peBlockType as CardBlockType, pcAuditUser as char, output table ttCard).
  method public logical closeCard (pcCardId as char, peCloseReason as CardCloseReason, pcAuditUser as char, output table ttCard).
  method public logical updateCardLimits (pcCardId as char, input table ttCardLimits, pcAuditUser as char, output table ttCard).
  method public logical linkCardToAccount (pcCardId as char, pcAccountId as char, pcAuditUser as char, output table ttCard).
  method public logical updateCardName (pcCardId as char, pcCardName as char, pcAuditUser as char, output table ttCard).
  method public logical changePin (pcCardId as char, pcNewPin as char, pcAuditUser as char, output table ttCard).
  method public logical unblockCard (pcCardId as char, pcAuditUser as char, output table ttCard).
  method public logical updateCardSecurity (pcCardId as char, plContactlessEnabled as logical, plWithdrawalEnabled as logical, plInternetPurchaseEnabled as logical, pcAuditUser as char, output table ttCard).
  method public logical getAllCards (piFromRecord as int64, piCount as int, pcAuditUser as char, output table ttCard).
  method public logical enrolCardFor3Dsecure (pcCardId as char, pcAuditUser as char, output table ttCard).
  method public logical update3DsecuritySettings (pcCardId as char, pcType as char, pcMobile as char, pcLanguageCode as char, pcPassword as char, pcAuditUser as char, output table ttCard). 
  method public logical unenrolCardFrom3Dsecure (pcCardId as char, pcAuditUser as char, output table ttCard).
  
  method public logical createAccountAdjustment (pcAccountId as char, pcExternalId as char, pdAmount as dec, pcDescription as char, pcAuditUser as char, output table ttAdj).
  method public logical getAllAuthorizations (piFromRecord as int64, piCount as int, pcAuditUser as char, output table ttAuth).
  method public logical getAccountAuthorizations (pcAccountId as char, ptFromDate as datetime, ptTillDate as datetime, piFromRecord as int64, piCount as int, pcAuditUser as char, output table ttAuth).
  method public logical getCardAuthorizations (pcCardId as char, ptFromDate as datetime, ptTillDate as datetime, piFromRecord as int64, piCount as int, pcAuditUser as char, output table ttAuth).

  method public logical getAllTransactions (piFromRecord as int64, piCount as int, pcAuditUser as char, output table ttAuth).
  method public logical getAccountTransactions (pcAccountId as char, ptFromDate as datetime, ptTillDate as datetime, piFromRecord as int64, piCount as int, pcAuditUser as char, output table ttAuth).
  method public logical getCardTransactions (pcCardId as char, ptFromDate as datetime, ptTillDate as datetime, piFromRecord as int64, piCount as int, pcAuditUser as char, output table ttAuth).
  
  method public logical getAccountStatement (pcAccountId as char, piFromRecord as int64, piCount as int, input table ttStatementRequestParams, pcAuditUser as char, output table ttStmt).    
  
  method public char    getEncryptedCardNumber (pcCardId as char, pcPublicKey as char, pcAuditUser as char).
  method public char    getEncryptedCardPin (pcCardId as char, pcPublicKey as char, pcAuditUser as char).
  method public char    getEncryptedCardCvv2 (pcCardId as char, pcPublicKey as char, pcAuditUser as char).
  method public char    getEncryptedCard3dsPassword (pcCardId as char, pcPublicKey as char, pcAuditUser as char).
  
  method public char    ping(pcMessage as char).
  
end interface.