
/*------------------------------------------------------------------------
    File        : CardBlockType
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : vsink_000
    Created     : Wed May 12 17:52:35 EEST 2021
    Notes       : 
  ----------------------------------------------------------------------*/

enum wallester.CardBlockType :  
    define enum
    BlockedByCardholder
    BlockedByCardholderViaPhone
    BlockedByClient
    BlockedByIssuer
    Counterfeit
    Fraudulent
    Lost
    MaxInvalitTriesCVV2
    MaxInvalidTriesPIN
    NotDelivered
    Stolen.

end enum.