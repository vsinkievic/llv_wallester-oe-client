 
 /*------------------------------------------------------------------------
    File        : WallesterApiClient
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : vsink_000
    Created     : Mon Apr 26 09:37:55 EEST 2021
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.Net.HTTP.IHttpRequest from propath.
using OpenEdge.Net.HTTP.IHttpResponse from propath.
using common.types.String from propath.
using Progress.Json.ObjectModel.JsonObject from propath.
using OpenEdge.Net.HTTP.RequestBuilder from propath.
using OpenEdge.Net.HTTP.ClientBuilder from propath.
using OpenEdge.Net.HTTP.HttpHeader from propath.
using OpenEdge.Net.HTTP.HttpHeaderBuilder from propath.
using jwtoe.Jwt from propath.
using wallester.api.WallesterApi from propath.
using Progress.Json.ObjectModel.JsonArray from propath.
using common.jwt.JwtTokenConverter from propath.
using wallester.api.CardBlockType from propath.
using wallester.api.CardCloseReason from propath.
using common.helpers.Files from propath.
using common.helpers.Converter from propath.

block-level on error undo, throw.

class wallester.api.WallesterApiClient implements WallesterApi: 

  {wallester/api/dsStatement.i}  
  {wallester/api/ttAccount.i}
  {wallester/api/ttAccountLimits.i}
  {wallester/api/ttAccountRequest.i}
  {wallester/api/ttCard.i}
  {wallester/api/ttCardLimits.i}
  {wallester/api/ttCardRequest.i}
  {wallester/api/ttFile.i}
  {wallester/api/ttPerson.i}
  {wallester/api/ttStatementRequestParams.i}
  {wallester/api/ttStmt.i}
    
    def protected var mcDumpDirectory as char no-undo init "".
    def protected var moSourceTypeHeader as HttpHeader no-undo.
    def protected var moProductCodeHeader as HttpHeader no-undo.
    def protected var mlDumpDirectoryExistsAndIsWritable as logical no-undo init ?.
  
      
    define public property wallesterUrl as char no-undo init "https://api-sandbox.wallester.eu"
    public get.
    protected set.
    
    define protected property latekoSecret as char no-undo init "xxxx"
    get.
    set.
    
    define public property issuerId as char no-undo init "iiiii"
    get.
    set.
    
    define public property audienceId as char no-undo init "aaaaaa"
    get.
    set.
    
    define public property productCode as char no-undo init "ppppppp"
    get.
    set.
    
    define public property auditSourceType as char no-undo init "Backend" // valid values: Backend or SelfService
    get.
    set.
    
    define public property dumpDirectory as character no-undo 
    get():
        if mcDumpDirectory > "" 
        then return mcDumpDirectory.
        else return session:temp-directory.
    end get.
    set (pcValue as char):
       mcDumpDirectory = pcValue.
    end. 

    define public property dumpEndpoints as char no-undo init ""
    get.
    set (pcValue as char):
        dumpEndpoints = trim(pcValue).
    end.
    
    
    
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
        
    constructor public WallesterApiClient ( pcApiUrl as char, pcSecret as char ):
        super ().
        
        this-object:wallesterUrl = pcApiUrl.
        this-object:latekoSecret = pcSecret.
        
    end constructor.
    
    method protected logical _isDumpEnabledFor (pcEndpointName as char):
        
        if mlDumpDirectoryExistsAndIsWritable = ?
        then do:
            if this-object:dumpDirectory = ? or this-object:dumpDirectory = ""
            then do:
                mlDumpDirectoryExistsAndIsWritable = false.
                return false.
            end.
            Files:makeDirectory(this-object:dumpDirectory).
            
            mlDumpDirectoryExistsAndIsWritable = Files:directoryExists(this-object:dumpDirectory) and Files:isWritable(this-object:dumpDirectory). 
        end.
        
        if not mlDumpDirectoryExistsAndIsWritable
        then return false.
        
        if pcEndpointName > "" and (this-object:dumpEndpoints = "all" or this-object:dumpEndpoints = "*" or lookup(pcEndpointName, this-object:dumpEndpoints) > 0)
        then return true.
        else return false.    
                
    end method.
    
    method protected void _dump(pcEndpointName as char, pcDumpType as char, poJson as JsonObject):
        if not valid-object(poJson)
        then return.
        
        poJson:WriteFile(subst("&1/&2_&3_&4.json", dumpDirectory, _getTS(), pcEndpointName, pcDumpType), true).
    end method.
    
    method protected char _getTS():
        def var tNow as datetime no-undo.
        tNow = now. 
        return replace(replace(replace(replace(iso-date(tNow), ".", "_"), "T", "_"), "-", ""), ":", "").
    end.
    
    method public logical activateCard( input pcPersonId as character, input pcLastFourDigits as character, input pcAuditUser as character, output TABLE for ttCard ):
        def var oRequestJson as JsonObject no-undo.
        def var oResponseJson as JsonObject no-undo.
        def var oResponse as IHttpResponse no-undo.
        def var lDumpEnabled as log no-undo init false.
        def var cEndpointName as char no-undo init "activateCard".
        
        oRequestJson = new JsonObject().
        oRequestJson:add("last_four_digits",   pcLastFourDigits).
        empty temp-table ttCard.        
        
        lDumpEnabled = _isDumpEnabledFor(cEndpointName).
        
        if lDumpEnabled then _dump(cEndpointName, "request", oRequestJson).
        oResponse = _executeRequest("PATCH", subst("/v1/persons/&1/activate-card", pcPersonId), pcAuditUser, oRequestJson).

        if type-of(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject")
        then do:
            oResponseJson = cast(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject").
            if lDumpEnabled then _dump(cEndpointName, "response", oResponseJson).

            _parseCard(oResponseJson:GetJsonObject("card")).
            return true.
        end.
        undo, throw new AppError(subst("Failed to activateCard card: unsupported response type: &1", oResponse:entity:getclass ():typeName)).

        finally:
            if valid-object(oRequestJson)   then delete object oRequestJson.
            if valid-object(oResponseJson)  then delete object oResponseJson.
            if valid-object(oResponse)      then delete object oResponse.            
        end finally.
    end method.

    method public logical activateCard( input pcCardId as character, input pcAuditUser as character, output TABLE for ttCard ):
        def var oRequestJson as JsonObject no-undo.
        def var oResponseJson as JsonObject no-undo.
        def var oResponse as IHttpResponse no-undo.
        def var lDumpEnabled as log no-undo init false.
        def var cEndpointName as char no-undo init "activateCard".
        
        oRequestJson = new JsonObject().
        empty temp-table ttCard.        
        lDumpEnabled = _isDumpEnabledFor(cEndpointName).
        
        if lDumpEnabled then _dump(cEndpointName, "request", oRequestJson).
        oResponse = _executeRequest("PATCH", subst("/v1/cards/&1/activate", pcCardId), pcAuditUser, oRequestJson).

        if type-of(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject")
        then do:
            oResponseJson = cast(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject").
            if lDumpEnabled then _dump(cEndpointName, "response", oResponseJson).
            
            _parseCard(oResponseJson:GetJsonObject("card")).
            return true.
        end.
        undo, throw new AppError(subst("Failed to activateCard card: unsupported response type: &1", oResponse:entity:getclass ():typeName)).

        finally:
            if valid-object(oRequestJson)   then delete object oRequestJson.
            if valid-object(oResponseJson)  then delete object oResponseJson.
            if valid-object(oResponse)      then delete object oResponse.            
        end finally.
    end method.

    method public logical adjustAccountBalance( input pcAccountId as character, input pcExternalId as character, input pdAmount as decimal, input pcDescription as character, input pcAuditUser as character, output TABLE for ttAccount ):
        def var oRequestJson as JsonObject no-undo.
        def var oResponseJson as JsonObject no-undo.
        def var oResponse as IHttpResponse no-undo.
        def var lDumpEnabled as log no-undo init false.
        def var cEndpointName as char no-undo init "adjustAccountBalance".
        
        oRequestJson = new JsonObject().
        oRequestJson:add("external_id", pcExternalId).
        oRequestJson:add("amount",      pdAmount).
        oRequestJson:add("description", pcDescription).
        empty temp-table ttAccount.        
        
        lDumpEnabled = _isDumpEnabledFor(cEndpointName).
        if lDumpEnabled then _dump(cEndpointName, "request", oRequestJson).
        oResponse = _executeRequest("PATCH", subst("/v1/accounts/&1/balance", pcAccountId), pcAuditUser, oRequestJson).

        if type-of(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject")
        then do:
            oResponseJson = cast(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject").
            if lDumpEnabled then _dump(cEndpointName, "response", oResponseJson).

            _parseAccount(oResponseJson:GetJsonObject("account")).
            return true.
        end.
        undo, throw new AppError(subst("Failed to adjustAccountBalance: unsupported response type: &1", oResponse:entity:getclass ():typeName)).

        finally:
            if valid-object(oRequestJson)   then delete object oRequestJson.
            if valid-object(oResponseJson)  then delete object oResponseJson.
            if valid-object(oResponse)      then delete object oResponse.            
        end finally.
    end method.

    method public logical blockCard( input pcCardId as character, input peBlockType as CardBlockType, input pcAuditUser as character, output TABLE for ttCard ):
        def var oRequestJson as JsonObject no-undo.
        def var oResponseJson as JsonObject no-undo.
        def var oResponse as IHttpResponse no-undo.
        def var lDumpEnabled as log no-undo init false.
        def var cEndpointName as char no-undo init "blockCard".
        
        oRequestJson = new JsonObject().
        oRequestJson:add("block_type",   peBlockType:ToString()).
        empty temp-table ttCard.        
        
        lDumpEnabled = _isDumpEnabledFor(cEndpointName).
        if lDumpEnabled then _dump(cEndpointName, "request", oRequestJson).
        oResponse = _executeRequest("PATCH", subst("/v1/cards/&1/block", pcCardId), pcAuditUser, oRequestJson).

        if type-of(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject")
        then do:
            oResponseJson = cast(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject").
            if lDumpEnabled then _dump(cEndpointName, "response", oResponseJson).

            _parseCard(oResponseJson:GetJsonObject("card")).
            return true.
        end.
        undo, throw new AppError(subst("Failed to blockCard: unsupported response type: &1", oResponse:entity:getclass ():typeName)).

        finally:
            if valid-object(oRequestJson)   then delete object oRequestJson.
            if valid-object(oResponseJson)  then delete object oResponseJson.
            if valid-object(oResponse)      then delete object oResponse.            
        end finally.
    end method.


    method public logical changePin( input pcCardId as character, input pcNewPin as character, input pcAuditUser as character, output TABLE for ttCard ):
        def var oRequestJson as JsonObject no-undo.
        def var oResponseJson as JsonObject no-undo.
        def var oResponse as IHttpResponse no-undo.
        def var cEncodedPin as char no-undo.
        def var lDumpEnabled as log no-undo init false.
        def var cEndpointName as char no-undo init "changePin".
        
        cEncodedPin = _toBase64(pcNewPin).
        
        oRequestJson = new JsonObject().
        oRequestJson:add("encrypted_pin", cEncodedPin).
        empty temp-table ttCard.        
        
        lDumpEnabled = _isDumpEnabledFor(cEndpointName).
        if lDumpEnabled then _dump(cEndpointName, "request", oRequestJson).
        oResponse = _executeRequest("PATCH", subst("/v1/cards/&1/pin", pcCardId), pcAuditUser, oRequestJson).

        if type-of(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject")
        then do:
            oResponseJson = cast(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject").
            if lDumpEnabled then _dump(cEndpointName, "response", oResponseJson).

            _parseCard(oResponseJson:GetJsonObject("card")).
            return true.
        end.
        undo, throw new AppError(subst("Failed to changePin: unsupported response type: &1", oResponse:entity:getclass ():typeName)).

        finally:
            if valid-object(oRequestJson)   then delete object oRequestJson.
            if valid-object(oResponseJson)  then delete object oResponseJson.
            if valid-object(oResponse)      then delete object oResponse.            
        end finally.
    end method.

    method public logical closeCard( input pcCardId as character, input peCloseReason as CardCloseReason, input pcAuditUser as character, output TABLE for ttCard ):
        def var oRequestJson as JsonObject no-undo.
        def var oResponseJson as JsonObject no-undo.
        def var oResponse as IHttpResponse no-undo.
        def var lDumpEnabled as log no-undo init false.
        def var cEndpointName as char no-undo init "closeCard".
        
        oRequestJson = new JsonObject().
        oRequestJson:add("close_reason",   peCloseReason:ToString()).
        empty temp-table ttCard.        
        
        lDumpEnabled = _isDumpEnabledFor(cEndpointName).
        if lDumpEnabled then _dump(cEndpointName, "request", oRequestJson).
        oResponse = _executeRequest("PATCH", subst("/v1/cards/&1/close", pcCardId), pcAuditUser, oRequestJson).

        if type-of(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject")
        then do:
            oResponseJson = cast(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject").
            if lDumpEnabled then _dump(cEndpointName, "response", oResponseJson).

            _parseCard(oResponseJson:GetJsonObject("card")).

            return true.
        end.
        undo, throw new AppError(subst("Failed to closeCard: unsupported response type: &1", oResponse:entity:getclass ():typeName)).

        finally:
            if valid-object(oRequestJson)   then delete object oRequestJson.
            if valid-object(oResponseJson)  then delete object oResponseJson.
            if valid-object(oResponse)      then delete object oResponse.            
        end finally.
    end method.

    method public logical createAccount( input TABLE for ttAccountRequest, input pcAuditUser as character, output TABLE for ttAccount ):
        def var oRequestJson as JsonObject no-undo.
        def var oLimitsJson  as JsonObject no-undo.
        def var oResponseJson as JsonObject no-undo.
        def var oResponse as IHttpResponse no-undo.
        def var lDumpEnabled as log no-undo init false.
        def var cEndpointName as char no-undo init "createAccount".
        
        find ttAccountRequest no-error.
        if not available ttAccountRequest
        then undo, throw new AppError("Provide ttAccountRequest record!", 0).
        
        oRequestJson = new JsonObject().
        oRequestJson:add("person_id",                   ttAccountRequest.person_id).
        oRequestJson:add("external_id",                 ttAccountRequest.external_id).
        oRequestJson:add("name",                        ttAccountRequest.account_name).
        oRequestJson:add("currency_code",               ttAccountRequest.currency_code).
        oRequestJson:add("credit_limit",                ttAccountRequest.credit_limit).
        oRequestJson:add("used_credit",                 ttAccountRequest.used_credit).
        
        if _anyLimitFieldHasValue()
        then do:
            oLimitsJson = new JsonObject().
            oLimitsJson:add("daily_purchase",               ttAccountRequest.lim_daily_purchase).
            oLimitsJson:add("daily_withdrawal",             ttAccountRequest.lim_daily_withdrawal).
            oLimitsJson:add("daily_internet_purchase",      ttAccountRequest.lim_daily_internet_purchase).
            oLimitsJson:add("daily_contactless_purchase",   ttAccountRequest.lim_daily_contactless_purchase).
            oLimitsJson:add("monthly_purchase",             ttAccountRequest.lim_monthly_purchase).
            oLimitsJson:add("monthly_withdrawal",           ttAccountRequest.lim_monthly_withdrawal).
            oLimitsJson:add("monthly_internet_purchase",    ttAccountRequest.lim_monthly_internet_purchase).
            oLimitsJson:add("monthly_contactless_purchase", ttAccountRequest.lim_monthly_contactless_purchase).
            oRequestJson:add("limits", oLimitsJson).
        end.
        empty temp-table ttAccountRequest.
        empty temp-table ttAccount.        
        
        lDumpEnabled = _isDumpEnabledFor(cEndpointName).
        if lDumpEnabled then _dump(cEndpointName, "request", oRequestJson).
        oResponse = _executeRequest("POST", "/v1/accounts", pcAuditUser, oRequestJson).

        if type-of(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject")
        then do:
            oResponseJson = cast(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject").
            if lDumpEnabled then _dump(cEndpointName, "response", oResponseJson).

            _parseAccount(oResponseJson:GetJsonObject("account")).
            return true.
        end.
        undo, throw new AppError(subst("Failed to create account: unsupported response type: &1", oResponse:entity:getclass ():typeName)).

        finally:
            if valid-object(oLimitsJson)    then delete object oLimitsJson.
            if valid-object(oRequestJson)   then delete object oRequestJson.
            if valid-object(oResponseJson)  then delete object oResponseJson.
            if valid-object(oResponse)      then delete object oResponse.            
        end finally.
    end method.
    
    method protected logical _anyLimitFieldHasValue():
        if available ttAccountRequest
        then do:
            if      ttAccountRequest.lim_daily_purchase = ?
                and ttAccountRequest.lim_daily_withdrawal = ?
                and ttAccountRequest.lim_daily_internet_purchase = ?
                and ttAccountRequest.lim_daily_contactless_purchase = ?
                and ttAccountRequest.lim_monthly_purchase = ?
                and ttAccountRequest.lim_monthly_withdrawal = ?
                and ttAccountRequest.lim_monthly_internet_purchase = ?
                and ttAccountRequest.lim_monthly_contactless_purchase = ?
            then return false.
            else return true.
        end.
        else if available ttCardRequest
        then do:
            if  ttCardRequest.lim_daily_purchase = ?
            and ttCardRequest.lim_daily_withdrawal = ?
            and ttCardRequest.lim_daily_internet_purchase = ?
            and ttCardRequest.lim_daily_contactless_purchase = ?
            and ttCardRequest.lim_monthly_purchase = ?
            and ttCardRequest.lim_monthly_withdrawal = ?
            and ttCardRequest.lim_monthly_internet_purchase = ?
            and ttCardRequest.lim_monthly_contactless_purchase = ?
            and ttCardRequest.lim_trn_purchase = ?
            and ttCardRequest.lim_trn_withdrawal = ?
            and ttCardRequest.lim_trn_internet_purchase = ?
            and ttCardRequest.lim_trn_contactless_purchase = ?
            then return false.
            else return true.
        end.
        else return false.    
    end method.

    method public logical createAccountAdjustment( input pcAccountId as character, input pcExternalId as character, input pdAmount as decimal, input pcDescription as character, input pcAuditUser as character, output TABLE for ttAdj ):
        def var oRequestJson as JsonObject no-undo.
        def var oResponseJson as JsonObject no-undo.
        def var oResponse as IHttpResponse no-undo.
        def var lDumpEnabled as log no-undo init false.
        def var cEndpointName as char no-undo init "createAccountAdjustment".
        
        oRequestJson = new JsonObject().
        oRequestJson:add("account_id",  pcAccountId).
        oRequestJson:add("external_id", pcExternalId).
        oRequestJson:add("amount",      pdAmount).
        oRequestJson:add("description", pcDescription).
        empty temp-table ttAdj.        
        
        lDumpEnabled = _isDumpEnabledFor(cEndpointName).
        if lDumpEnabled then _dump(cEndpointName, "request", oRequestJson).
        oResponse = _executeRequest("POST", "/v1/account-adjustments", pcAuditUser, oRequestJson).

        if type-of(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject")
        then do:
            oResponseJson = cast(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject").
            if lDumpEnabled then _dump(cEndpointName, "response", oResponseJson).

            _parseAccountAdjustment(oResponseJson:GetJsonObject("account_adjustment")).
            return true.
        end.
        undo, throw new AppError(subst("Failed to createAccountAdjustment: unsupported response type: &1", oResponse:entity:getclass ():typeName)).

        finally:
            if valid-object(oRequestJson)   then delete object oRequestJson.
            if valid-object(oResponseJson)  then delete object oResponseJson.
            if valid-object(oResponse)      then delete object oResponse.            
        end finally.
    end method.

    method public logical createCard( input TABLE for ttCardRequest, input pcAuditUser as character, output TABLE for ttCard ):
        def var oRequestJson as JsonObject no-undo.
        def var oSecurityJson as JsonObject no-undo.
        def var o3dsJson      as JsonObject no-undo.
        def var oDeliveryJson as JsonObject no-undo.
        def var oLimitsJson  as JsonObject no-undo.
        def var oResponseJson as JsonObject no-undo.
        def var oResponse as IHttpResponse no-undo.
        def var lDumpEnabled as log no-undo init false.
        def var cEndpointName as char no-undo init "createCard".
        
        find ttCardRequest no-error.
        if not available ttCardRequest
        then undo, throw new AppError("Provide ttCardRequest record!", 0).
        
        if not ttCardRequest.card_type > ""
        then undo, throw new AppError("Provide card_type!", 0).
        if not ttCardRequest.sec_3ds_mobile > ""
        then undo, throw new AppError("Provide sec_3ds_mobile!", 0).
        if not ttCardRequest.sec_3ds_password > ""
        then undo, throw new AppError("Provide sec_3ds_password!", 0).
        
        oRequestJson = new JsonObject().
        if (ttCardRequest.predecessor_card_id > "predecessor_card_id")
        then oRequestJson:add("predecessor_card_id",    ttCardRequest.predecessor_card_id).
        oRequestJson:add("account_id",                  ttCardRequest.account_id).
        if (ttCardRequest.person_id > "")
        then oRequestJson:add("person_id",              ttCardRequest.person_id).
        if (ttCardRequest.external_id > "")
        then oRequestJson:add("external_id",            ttCardRequest.external_id).
        oRequestJson:add("type",                        ttCardRequest.card_type).
        if ttCardRequest.card_name > ""
        then oRequestJson:add("name",                   ttCardRequest.card_name).
        
        if ttCardRequest.embossing_name > ""
        then oRequestJson:add("embossing_name",         ttCardRequest.embossing_name).
        
        if (ttCardRequest.is_disposable <> ?)
        then oRequestJson:add("is_disposable",          ttCardRequest.is_disposable).

        oSecurityJson = new JsonObject().
        oSecurityJson:Add("contactless_enabled", ttCardRequest.sec_contactless_enabled).
        oSecurityJson:Add("withdrawal_enabled", ttCardRequest.sec_withdrawal_enabled).
        oSecurityJson:Add("internet_purchase_enabled", ttCardRequest.sec_internet_purchase_enabled).
        oRequestJson:add("security", oSecurityJson).
        
        o3dsJson = new JsonObject().
        o3dsJson:add("type", ttCardRequest.sec_3ds_type).
        o3dsJson:add("mobile", ttCardRequest.sec_3ds_mobile).
        o3dsJson:add("language_code", ttCardRequest.sec_3ds_language_code).
        o3dsJson:add("password", ttCardRequest.sec_3ds_password).
        oRequestJson:add("3d_secure_settings", o3dsJson).
        
        if ttCardRequest.card_type > "" and ttCardRequest.card_type = "Virtual"
        then do:
            oRequestJson:addNull("delivery_address").
        end.
        else do:    
            oDeliveryJson = new JsonObject().
            if (ttCardRequest.delivery_company_name > "")
            then oDeliveryJson:add("company_name",    ttCardRequest.delivery_company_name).
            if ttCardRequest.delivery_address1 > ""
            then oDeliveryJson:add("address1",        ttCardRequest.delivery_address1).
            if ttCardRequest.delivery_address2 > ""
            then oDeliveryJson:add("address2",        ttCardRequest.delivery_address2).
            if ttCardRequest.delivery_postal_code > ""
            then oDeliveryJson:add("postal_code",     ttCardRequest.delivery_postal_code).
            if ttCardRequest.delivery_city > ""
            then oDeliveryJson:add("city",            ttCardRequest.delivery_city).
            if ttCardRequest.delivery_country_code > ""
            then oDeliveryJson:add("country_code",    ttCardRequest.delivery_country_code).
            if ttCardRequest.delivery_dispatch_method > ""
            then oDeliveryJson:add("dispatch_method", ttCardRequest.delivery_dispatch_method).
            if ttCardRequest.delivery_phone > ""
            then oDeliveryJson:add("phone",           ttCardRequest.delivery_phone).
            oRequestJson:add("delivery_address", oDeliveryJson).
        end.
        
        if _anyLimitFieldHasValue()
        then do:
            oLimitsJson = new JsonObject().
            oLimitsJson:add("daily_purchase",               ttCardRequest.lim_daily_purchase).
            oLimitsJson:add("daily_withdrawal",             ttCardRequest.lim_daily_withdrawal).
            oLimitsJson:add("daily_internet_purchase",      ttCardRequest.lim_daily_internet_purchase).
            oLimitsJson:add("daily_contactless_purchase",   ttCardRequest.lim_daily_contactless_purchase).
            oLimitsJson:add("monthly_purchase",             ttCardRequest.lim_monthly_purchase).
            oLimitsJson:add("monthly_withdrawal",           ttCardRequest.lim_monthly_withdrawal).
            oLimitsJson:add("monthly_internet_purchase",    ttCardRequest.lim_monthly_internet_purchase).
            oLimitsJson:add("monthly_contactless_purchase", ttCardRequest.lim_monthly_contactless_purchase).
            oLimitsJson:add("transaction_purchase",             ttCardRequest.lim_trn_purchase).
            oLimitsJson:add("transaction_withdrawal",           ttCardRequest.lim_trn_withdrawal).
            oLimitsJson:add("transaction_internet_purchase",    ttCardRequest.lim_trn_internet_purchase).
            oLimitsJson:add("transaction_contactless_purchase", ttCardRequest.lim_trn_contactless_purchase).
            oRequestJson:add("limits", oLimitsJson).
        end.
        
        if ttCardRequest.personalization_product_code > ""
        then oRequestJson:add("personalization_product_code", personalization_product_code).
        oRequestJson:add("expiry_days",                     ttCardRequest.expiry_days).
        oRequestJson:add("expiry_days_round",               ttCardRequest.expiry_days_round).
        if ttCardRequest.encrypted_pin > ""
        then oRequestJson:add("encrypted_pin",                   ttCardRequest.encrypted_pin).
        
        empty temp-table ttCardRequest.
        empty temp-table ttCard.        
        
        lDumpEnabled = _isDumpEnabledFor(cEndpointName).
        if lDumpEnabled then _dump(cEndpointName, "request", oRequestJson).
        oResponse = _executeRequest("POST", "/v1/cards", pcAuditUser, oRequestJson).

        if type-of(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject")
        then do:
            oResponseJson = cast(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject").
            if lDumpEnabled then _dump(cEndpointName, "response", oResponseJson).

            _parseCard(oResponseJson:GetJsonObject("card")).
            return true.
        end.
        undo, throw new AppError(subst("Failed to create card: unsupported response type: &1", oResponse:entity:getclass ():typeName)).

        finally:
            if valid-object(oSecurityJson)    then delete object oSecurityJson.
            if valid-object(o3dsJson)    then delete object o3dsJson.
            if valid-object(oDeliveryJson)    then delete object oDeliveryJson.
            if valid-object(oLimitsJson)    then delete object oLimitsJson.
            if valid-object(oRequestJson)   then delete object oRequestJson.
            if valid-object(oResponseJson)  then delete object oResponseJson.
            if valid-object(oResponse)      then delete object oResponse.            
        end finally.
    end method.

    method public logical createPerson( input-output TABLE for ttPerson, input pcAuditUser as character ):
        def var oRequestJson as JsonObject no-undo.
        def var oPersonJson as JsonObject no-undo.
        def var oResponseJson as JsonObject no-undo.
        def var oResponse as IHttpResponse no-undo.
        def var lDumpEnabled as log no-undo init false.
        def var cEndpointName as char no-undo init "createPerson".
        
        find ttPerson no-error.
        if not available ttPerson
        then undo, throw new AppError("Provide ttPerson record!", 0).
        
        oPersonJson = new JsonObject().
        oPersonJson:add("personal_number",        ttPerson.personal_number).
        oPersonJson:add("personal_number_issuer", ttPerson.personal_number_issuer).
        oPersonJson:add("title",                  ttPerson.title_name).
        oPersonJson:add("first_name",             ttPerson.first_name).
        oPersonJson:add("middle_name",            ttPerson.middle_name).
        oPersonJson:add("last_name",              ttPerson.last_name).
        oPersonJson:add("birth_date",             ttPerson.birth_date).
        oPersonJson:add("birth_country_code",     ttPerson.birth_country_code).
        oPersonJson:add("gender",                 caps(ttPerson.gender)).
        oPersonJson:add("mobile",                 ttPerson.mobile).
        oPersonJson:add("email",                  ttPerson.email).
        oPersonJson:add("external_id",            ttPerson.external_id).
        oPersonJson:add("residence_country_code", ttPerson.residence_country_code).
        oPersonJson:add("is_represented_by_someone_else", ttPerson.is_represented_by_someone_else).
        oPersonJson:add("is_beneficial_owner",   ttPerson.is_beneficial_owner).
        oPersonJson:add("is_politically_exposed_person", ttPerson.is_pep).
        oPersonJson:add("is_sanctions_related",          ttPerson.is_sanctions_related).
        oPersonJson:add("is_adverse_media_involved",     ttPerson.is_adverse_media_involved).
        oPersonJson:add("politically_exposed_person_explanation", ttPerson.pep_explanation).
        oPersonJson:add("business_relationship_purpose", ttPerson.business_relationship_purpose).
        oPersonJson:add("risk_profile",           ttPerson.risk_profile).
        oPersonJson:add("loyalty_number",         ttPerson.loyalty_number).
        oRequestJson = new JsonObject().
        oRequestJson:add("person", oPersonJson).
        empty temp-table ttPerson.        
        
        lDumpEnabled = _isDumpEnabledFor(cEndpointName).
        if lDumpEnabled then _dump(cEndpointName, "request", oRequestJson).
        oResponse = _executeRequest("POST", "/v1/persons", pcAuditUser, oRequestJson).

        if type-of(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject")
        then do:
            oResponseJson = cast(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject").
            if lDumpEnabled then _dump(cEndpointName, "response", oResponseJson).

            _parsePerson(oResponseJson:GetJsonObject("person")).
            return true.
        end.
        undo, throw new AppError(subst("Failed to create person: unsupported response type: &1", oResponse:entity:getclass ():typeName)).

        finally:
            if valid-object(oPersonJson)    then delete object oPersonJson.
            if valid-object(oRequestJson)   then delete object oRequestJson.
            if valid-object(oResponseJson)  then delete object oResponseJson.
            if valid-object(oResponse)      then delete object oResponse.            
        end finally.
    end method.
    
    method protected void _parsePerson (poJson as JsonObject):

        if not valid-object(poJson)
        then return.

        create ttPerson.
        ttPerson.id = poJson:GetCharacter("id").
        if poJson:has("personal_number")
        then ttPerson.personal_number = poJson:GetCharacter("personal_number").
        if poJson:has("personal_number_issuer")
        then ttPerson.personal_number_issuer = poJson:getCharacter("personal_number_issuer").
        if poJson:has("title")
        then ttPerson.title_name             = poJson:getCharacter("title").
        ttPerson.first_name             = poJson:getCharacter("first_name").
        if poJson:has("middle_name")
        then ttPerson.middle_name            = poJson:getCharacter("middle_name").
        ttPerson.last_name              = poJson:getCharacter("last_name").
        if poJson:has("birth_date")
        then ttPerson.birth_date             = poJson:GetDate("birth_date").
        if poJson:has("birth_country_code")
        then ttPerson.birth_country_code     = poJson:GetCharacter("birth_country_code").
        if poJson:has("gender")
        then ttPerson.gender                 = poJson:getCharacter("gender").
        ttPerson.mobile                 = poJson:getCharacter("mobile").
        if poJson:has("email")
        then ttPerson.email                  = poJson:getCharacter("email").
        if poJson:has("external_id")
        then ttPerson.external_id            = poJson:getCharacter("external_id").
        ttPerson.residence_country_code = poJson:getCharacter("residence_country_code").
        ttPerson.is_represented_by_someone_else = poJson:GetLogical("is_represented_by_someone_else").
        ttPerson.is_beneficial_owner    = poJson:GetLogical("is_beneficial_owner").
        ttPerson.is_sanctions_related   = poJson:getLogical("is_sanctions_related").
        ttPerson.is_adverse_media_involved = poJson:getLogical("is_adverse_media_involved").
        ttPerson.is_pep                 = poJson:getLogical("is_politically_exposed_person").
        if poJson:has("politically_exposed_person_explanation")
        then ttPerson.pep_explanation        = poJson:getCharacter("politically_exposed_person_explanation").
        if poJson:has("business_relationship_purpose")
        then ttPerson.business_relationship_purpose = poJson:getCharacter("business_relationship_purpose").
        ttPerson.risk_profile           = poJson:getCharacter("risk_profile").
        if poJson:has("loyalty_number")
        then ttPerson.loyalty_number         = poJson:getCharacter("loyalty_number").
        ttPerson.created_at             = poJson:GetDatetime("created_at").
        if poJson:has("updated_at")
        then ttPerson.updated_at             = poJson:getDatetime("updated_at").
        if poJson:has("deactivated_at")
        then ttPerson.deactivated_at         = poJson:getDatetime("deactivated_at").
        
        finally:
            if valid-object(poJson) then delete object poJson.            
        end finally.
    end method.

    method protected void _parseAccount (poJson as JsonObject):
        def var oLimitsJson as JsonObject no-undo.

        if not valid-object(poJson)
        then return.
        
        create ttAccount.
        ttAccount.id                  = poJson:GetCharacter("id").
        ttAccount.person_id           = poJson:GetCharacter("person_id").
        if poJson:has("external_id")
        then ttAccount.external_id         = poJson:getCharacter("external_id").
        if poJson:has("name")
        then ttAccount.account_name        = poJson:getCharacter("name").
        ttAccount.currency_code       = poJson:getCharacter("currency_code").
        ttAccount.account_status      = poJson:GetCharacter("status").      
          
        ttAccount.credit_limit        = poJson:getDecimal("credit_limit").
        ttAccount.used_credit         = poJson:getDecimal("used_credit").
        ttAccount.balance             = poJson:getDecimal("balance").
        ttAccount.available_amount    = poJson:getDecimal("available_amount").
        ttAccount.blocked_amount      = poJson:getDecimal("blocked_amount").
        
        ttAccount.created_at          = poJson:GetDatetime("created_at").
        if poJson:has("updated_at")
        then ttAccount.updated_at     = poJson:getDatetime("updated_at").
        if poJson:has("closed_at")
        then ttAccount.closed_at      = poJson:getDatetime("closed_at").
        if poJson:has("closed_by")
        then ttAccount.closed_by      = poJson:GetCharacter("closed_by").
        if poJson:has("close_reason")
        then ttAccount.close_reason   = poJson:getCharacter("close_reason").
        
        if poJson:has("limits")
        then do:
            oLimitsJson = poJson:GetJsonObject("limits").
            ttAccount.lim_daily_purchase               = oLimitsJson:getDecimal("daily_purchase").
            ttAccount.lim_daily_withdrawal             = oLimitsJson:getDecimal("daily_withdrawal").
            ttAccount.lim_daily_internet_purchase      = oLimitsJson:getDecimal("daily_internet_purchase").
            ttAccount.lim_daily_contactless_purchase   = oLimitsJson:getDecimal("daily_contactless_purchase").
            ttAccount.lim_monthly_purchase             = oLimitsJson:getDecimal("monthly_purchase").
            ttAccount.lim_monthly_withdrawal           = oLimitsJson:getDecimal("monthly_withdrawal").
            ttAccount.lim_monthly_internet_purchase    = oLimitsJson:getDecimal("monthly_internet_purchase").
            ttAccount.lim_monthly_contactless_purchase = oLimitsJson:getDecimal("monthly_contactless_purchase").
        end.

        finally:
            if valid-object(poJson)      then delete object poJson.   
            if valid-object(oLimitsJson) then delete object oLimitsJson.         
        end finally.
    end method.

    method protected void _parsePersons (poJson as JsonArray):
        def var oPersonJson as JsonObject no-undo.
        def var i as int no-undo.

        if not valid-object(poJson)
        then return.
        
        do i = 1 to poJson:Length:
            oPersonJson = poJson:GetJsonObject(i).
            _parsePerson(oPersonJson).
        end.
        
        finally:
            if valid-object(poJson)      then delete object poJson.   
            if valid-object(oPersonJson) then delete object oPersonJson.         
        end finally.
    end method.

    method protected void _parseDirectoryList (poJson as JsonArray):
        def var i as int no-undo.

        if not valid-object(poJson)
        then return.
        
        do i = 1 to poJson:Length:
            create ttFile.
            ttFile.name = poJson:GetCharacter(i).
        end.
        
        finally:
            if valid-object(poJson)      then delete object poJson.   
        end finally.
    end method.

    method protected void _parseFileList (poJson as JsonArray):
        def var i as int no-undo.
        def var oFile as JsonObject no-undo.

        if not valid-object(poJson)
        then return.
        
        do i = 1 to poJson:Length:
            oFile = poJson:GetJsonObject(i).
            if valid-object (oFile)
            then do: 
                create ttFile.
                ttFile.name = oFile:GetCharacter("name").
                
                delete object oFile.
            end.
        end.
        
        finally:
            if valid-object(poJson)      then delete object poJson.
            if valid-object(oFile)       then delete object oFile.   
        end finally.
    end method.


    method protected void _parseAccounts (poJson as JsonArray):
        def var oAccountJson as JsonObject no-undo.
        def var i as int no-undo.

        if not valid-object(poJson)
        then return.
        
        do i = 1 to poJson:Length:
            oAccountJson = poJson:GetJsonObject(i).
            _parseAccount(oAccountJson).
        end.
        
        finally:
            if valid-object(poJson)      then delete object poJson.   
            if valid-object(oAccountJson) then delete object oAccountJson.         
        end finally.
    end method.

    method protected void _parseTransaction (poJson as JsonObject):
        if not valid-object(poJson)
        then return.
        
        create ttTrn.
        ttTrn.id                              = poJson:GetCharacter("id").
        if poJson:has("card_id")              
        then ttTrn.card_id                    = poJson:getCharacter("card_id").
        if poJson:has("purchase_date")
        then ttTrn.purchase_date              = poJson:GetDatetimeTZ("purchase_date").
        if poJson:has("group")                
        then ttTrn.tx_group                   = poJson:getCharacter("group").
        if poJson:has("transaction_amount")
        then ttTrn.transaction_amount         = poJson:getDecimal("transaction_amount").
        if poJson:has("transaction_currency_code")
        then ttTrn.transaction_currency_code  = poJson:getCharacter("transaction_currency_code").
        if poJson:has("account_amount")
        then ttTrn.account_amount             = poJson:getDecimal("account_amount").
        if poJson:has("account_currency_code")
        then ttTrn.account_currency_code      = poJson:getCharacter("account_currency_code").
        if poJson:has("foreign_exchange_fee")
        then ttTrn.foreign_exchange_fee       = poJson:getDecimal("foreign_exchange_fee").

        if poJson:has("is_failed")
        then ttTrn.is_failed                  = poJson:getLogical("is_failed").
        if poJson:has("merchant_category_code")
        then ttTrn.merchant_category_code     = poJson:getCharacter("merchant_category_code").
        if poJson:has("merchant_id")
        then ttTrn.merchant_id                = poJson:getCharacter("merchant_id").
        if poJson:has("terminal_id")           
        then ttTrn.terminal_id                = poJson:getCharacter("terminal_id").
        if poJson:has("merchant_name")         
        then ttTrn.merchant_name              = poJson:getCharacter("merchant_name").
        if poJson:has("merchant_city")         
        then ttTrn.merchant_city              = poJson:getCharacter("merchant_city").
        if poJson:has("merchant_country_code")
        then ttTrn.merchant_country_code      = poJson:getCharacter("merchant_country_code").

        if poJson:has("acquirer_reference_number")         
        then ttTrn.acquirer_reference_number  = poJson:getCharacter("acquirer_reference_number").
        if poJson:has("acquirer_business_id")
        then ttTrn.acquirer_business_id       = poJson:getCharacter("acquirer_business_id").


        if poJson:has("transaction_code")         
        then ttTrn.transaction_code            = poJson:getCharacter("transaction_code").
        if poJson:has("transaction_identifier")
        then ttTrn.transaction_identifier      = poJson:getCharacter("transaction_identifier").

        if poJson:has("authorization_id")
        then ttTrn.authorization_id            = poJson:getCharacter("authorization_id").

        if poJson:has("marked_for_dispute_at")
        then ttTrn.marked_for_dispute_at       = poJson:GetDatetime("marked_for_dispute_at").
        if poJson:has("marked_for_dispute_by")
        then ttTrn.marked_for_dispute_by       = poJson:getCharacter("marked_for_dispute_by").

        if poJson:has("created_at")
        then ttTrn.created_at                  = poJson:GetDatetimeTZ("created_at").
        if poJson:has("processed_at")
        then ttTrn.processed_at                = poJson:GetDatetimeTZ("processed_at").
        if poJson:has("central_processing_date")
        then ttTrn.central_processing_date     = poJson:GetDatetimeTZ("central_processing_date").

        finally:
            if valid-object(poJson)      then delete object poJson.   
        end finally.
    end method.
    
    
    method protected void _parseAccountStatement (pcAccountId as char, poJson as JsonArray):
        def var oStatementJson as JsonObject no-undo.
        def var i as int no-undo.

        if not valid-object(poJson)
        then return.

   //     poJson:WriteFile("target/statement_response.json", true).
        
        do i = 1 to poJson:Length:
            oStatementJson = poJson:GetJsonObject(i).
            _parseStatementRecord(pcAccountId, oStatementJson).
        end.
        
        finally:
            if valid-object(poJson)         then delete object poJson.   
            if valid-object(oStatementJson) then delete object oStatementJson.         
        end finally.
    end method.

    method protected void _parseStatementRecord (pcAccountId as char, poJson as JsonObject):
        if not valid-object(poJson)
        then return.
        
        create ttStmt.
        ttStmt.id                              = poJson:GetCharacter("id").
        ttStmt.account_id                      = pcAccountId.
        if poJson:has("card_id")              
        then ttStmt.card_id                    = poJson:getCharacter("card_id").
        if poJson:has("type")                 
        then ttStmt.type                       = poJson:getCharacter("type").
        if poJson:has("group")                
        then ttStmt.tx_group                   = poJson:getCharacter("group").
        if poJson:has("date")                 
        then ttStmt.date                       = poJson:GetDatetime("date").
        if poJson:has("transaction_amount")
        then ttStmt.transaction_amount         = poJson:getDecimal("transaction_amount").
        if poJson:has("transaction_currency_code")
        then ttStmt.transaction_currency_code  = poJson:getCharacter("transaction_currency_code").
        if poJson:has("account_amount")
        then ttStmt.account_amount             = poJson:getDecimal("account_amount").
        if poJson:has("account_currency_code")
        then ttStmt.account_currency_code      = poJson:getCharacter("account_currency_code").

        if poJson:has("merchant_category_code")
        then ttStmt.merchant_category_code     = poJson:getCharacter("merchant_category_code").
        if poJson:has("merchant_id")
        then ttStmt.merchant_id                = poJson:getCharacter("merchant_id").
        if poJson:has("terminal_id")           
        then ttStmt.terminal_id                = poJson:getCharacter("terminal_id").
        if poJson:has("merchant_name")         
        then ttStmt.merchant_name              = poJson:getCharacter("merchant_name").
        if poJson:has("merchant_city")         
        then ttStmt.merchant_city              = poJson:getCharacter("merchant_city").
        if poJson:has("merchant_country_code")
        then ttStmt.merchant_country_code      = poJson:getCharacter("merchant_country_code").
        if poJson:has("description")
        then ttStmt.description                = poJson:getCharacter("description").
        if poJson:has("original_authorization_id")
        then ttStmt.original_authorization_id  = poJson:getCharacter("original_authorization_id").

        if poJson:has("is_reversal")
        then ttStmt.is_reversal                = poJson:GetLogical("is_reversal").
        if poJson:has("is_declined")          
        then ttStmt.is_declined                = poJson:GetLogical("is_declined").
        if poJson:has("is_cleared")           
        then ttStmt.is_cleared                 = poJson:GetLogical("is_cleared").

        if poJson:has("marked_for_dispute_at")
        then ttStmt.marked_for_dispute_at      = poJson:GetDatetime("marked_for_dispute_at").
        if poJson:has("marked_for_dispute_by")
        then ttStmt.marked_for_dispute_by      = poJson:getCharacter("marked_for_dispute_by").
        
        if poJson:has("status")
        then ttStmt.rec_status      = poJson:getCharacter("status").
        if poJson:has("response")
        then ttStmt.response      = poJson:getCharacter("response").

        finally:
            if valid-object(poJson)      then delete object poJson.   
        end finally.
    end method.

    method protected void _parseAccountAdjustment (poJson as JsonObject):
        if not valid-object(poJson)
        then return.
        
        create ttAdj.
        ttAdj.id                     = poJson:GetCharacter("id").
        if poJson:has("account_id")
        then ttAdj.account_id        = poJson:getCharacter("account_id").
        if poJson:has("external_id")
        then ttAdj.external_id       = poJson:getCharacter("external_id").
        if poJson:has("created_at")                 
        then ttAdj.created_at        = poJson:GetDatetime("created_at").
        if poJson:has("amount")
        then ttAdj.amount            = poJson:getDecimal("amount").
        if poJson:has("description")
        then ttAdj.description       = poJson:getCharacter("description").

        finally:
            if valid-object(poJson)      then delete object poJson.   
        end finally.
    end method.

    method protected void _parseCard (poJson as JsonObject):
        def var oLimitsJson as JsonObject no-undo.
        def var o3DsecureJson as JsonObject no-undo.
        def var oDeliveryJson as JsonObject no-undo.
        def var oSecurityJson as JsonObject no-undo.
        
        if not valid-object(poJson)
        then return.
        
        create ttCard.
        ttCard.id                  = poJson:GetCharacter("id").
        if poJson:has("predecessor_card_id")
        then ttCard.predecessor_card_id = poJson:GetCharacter("predecessor_card_id").
        if poJson:has("account_id")
        then ttCard.account_id     = poJson:getCharacter("account_id").
        if poJson:has("person_id")
        then ttCard.person_id           = poJson:GetCharacter("person_id").
        if poJson:has("external_id")
        then ttCard.external_id    = poJson:getCharacter("external_id").
        ttCard.card_type           = poJson:getCharacter("type").
        if poJson:has("name")
        then ttCard.card_name           = poJson:getCharacter("name").
        ttCard.masked_card_number  = poJson:getCharacter("masked_card_number").
        if (poJson:has("reference_number"))
        then ttCard.reference_number    = poJson:getCharacter("reference_number").
        ttCard.expiry_date         = poJson:GetDatetime("expiry_date").
        ttCard.card_status         = poJson:GetCharacter("status").    
        ttCard.embossing_name      = poJson:GetCharacter("embossing_name").
        if poJson:has("is_disposable")
        then ttCard.is_disposable = poJson:getLogical("is_disposable").
        if poJson:has("is_enrolled_for_3d_secure")
        then ttCard.is_enrolled_for_3ds = poJson:getLogical("is_enrolled_for_3d_secure").
        if poJson:has("is_card_3d_secure_activated")
        then ttCard.is_3ds_activated    = poJson:getLogical("is_card_3d_secure_activated").
        if poJson:has("renew_automatically")
        then ttCard.renew_automatically = poJson:getLogical("renew_automatically").
        
        if poJson:has("personalization_product_code")
        then ttCard.personalization_product_code = poJson:getCharacter("personalization_product_code").  
        if poJson:has("card_metadata_profile_id")
        then ttCard.card_metadata_profile_id = poJson:getCharacter("card_metadata_profile_id").  
        if poJson:has("block_type")
        then ttCard.block_type     = poJson:getCharacter("block_type").
        if poJson:has("blocked_at")
        then ttCard.blocked_at     = poJson:GetDatetime("blocked_at").
        ttCard.created_at          = poJson:GetDatetime("created_at").
        if poJson:has("activated_at")
        then ttCard.activated_at   = poJson:getDatetime("activated_at").
        if poJson:has("updated_at")
        then ttCard.updated_at     = poJson:getDatetime("updated_at").
        if poJson:has("closed_at")
        then ttCard.closed_at      = poJson:getDatetime("closed_at").
        if poJson:has("closed_by")
        then ttCard.closed_by      = poJson:GetCharacter("closed_by").
        if poJson:has("close_reason")
        then ttCard.close_reason   = poJson:getCharacter("close_reason").
        
        if poJson:has("limits")
        then do:
            oLimitsJson = poJson:GetJsonObject("limits").
            if valid-object(oLimitsJson)
            then do:
                ttCard.lim_daily_purchase               = oLimitsJson:getDecimal("daily_purchase").
                ttCard.lim_daily_withdrawal             = oLimitsJson:getDecimal("daily_withdrawal").
                ttCard.lim_daily_internet_purchase      = oLimitsJson:getDecimal("daily_internet_purchase").
                ttCard.lim_daily_contactless_purchase   = oLimitsJson:getDecimal("daily_contactless_purchase").
                ttCard.lim_monthly_purchase             = oLimitsJson:getDecimal("monthly_purchase").
                ttCard.lim_monthly_withdrawal           = oLimitsJson:getDecimal("monthly_withdrawal").
                ttCard.lim_monthly_internet_purchase    = oLimitsJson:getDecimal("monthly_internet_purchase").
                ttCard.lim_monthly_contactless_purchase = oLimitsJson:getDecimal("monthly_contactless_purchase").
                ttCard.lim_trn_purchase                 = oLimitsJson:getDecimal("transaction_purchase").
                ttCard.lim_trn_withdrawal               = oLimitsJson:getDecimal("transaction_withdrawal").
                ttCard.lim_trn_internet_purchase        = oLimitsJson:getDecimal("transaction_internet_purchase").
                ttCard.lim_trn_contactless_purchase     = oLimitsJson:getDecimal("transaction_contactless_purchase").
            end.
        end.

        if poJson:has("3d_secure_settings")
        then do:
            o3DsecureJson = poJson:GetJsonObject("3d_secure_settings").
            if valid-object(o3DsecureJson)
            then do:
                ttCard.sec_3ds_type          = o3DsecureJson:GetCharacter("type").
                ttCard.sec_3ds_mobile        = o3DsecureJson:GetCharacter("mobile").
                ttCard.sec_3ds_language_code = o3DsecureJson:GetCharacter("language_code").
                ttCard.sec_3ds_password      = o3DsecureJson:GetCharacter("password").
            end.
        end.

        if poJson:has("delivery_address")
        then do:
            oDeliveryJson = poJson:GetJsonObject("delivery_address").
            if valid-object(oDeliveryJson)
            then do:
                if oDeliveryJson:has("first_name")
                then ttCard.delivery_first_name      = oDeliveryJson:GetCharacter("first_name").
                if oDeliveryJson:has("last_name")
                then ttCard.delivery_last_name       = oDeliveryJson:GetCharacter("last_name").
                if oDeliveryJson:has("company_name")
                then ttCard.delivery_company_name    = oDeliveryJson:GetCharacter("company_name").
                if oDeliveryJson:has("address1")
                then ttCard.delivery_address1        = oDeliveryJson:GetCharacter("address1").
                if oDeliveryJson:has("address2")
                then ttCard.delivery_address2        = oDeliveryJson:GetCharacter("address2").
                if oDeliveryJson:has("postal_code")
                then ttCard.delivery_postal_code     = oDeliveryJson:GetCharacter("postal_code").
                if oDeliveryJson:has("city")
                then ttCard.delivery_city            = oDeliveryJson:GetCharacter("city").
                if oDeliveryJson:has("country_code")
                then ttCard.delivery_country_code    = oDeliveryJson:GetCharacter("country_code").
                if oDeliveryJson:has("dispatch_method")
                then ttCard.delivery_dispatch_method = oDeliveryJson:GetCharacter("dispatch_method").
                if oDeliveryJson:has("phone")
                then ttCard.delivery_phone           = oDeliveryJson:GetCharacter("phone").
            end.
        end.

        if poJson:has("security")
        then do:
            oSecurityJson = poJson:GetJsonObject("security").
            if valid-object(oSecurityJson)
            then do:
                ttCard.sec_contactless_enabled       = oSecurityJson:getLogical("contactless_enabled").
                ttCard.sec_withdrawal_enabled        = oSecurityJson:getLogical("withdrawal_enabled").
                ttCard.sec_internet_purchase_enabled = oSecurityJson:getLogical("internet_purchase_enabled").
            end.
        end.

        finally:
            if valid-object(poJson)        then delete object poJson.   
            if valid-object(oLimitsJson)   then delete object oLimitsJson.         
            if valid-object(o3DsecureJson) then delete object o3DsecureJson.         
            if valid-object(oDeliveryJson) then delete object oDeliveryJson.         
            if valid-object(oSecurityJson) then delete object oSecurityJson.         
        end finally.
    end method.

    method protected void _parseCards (poJson as JsonArray):
        def var oCardJson as JsonObject no-undo.
        def var i as int no-undo.
        
        if not valid-object(poJson)
        then return.
        
        do i = 1 to poJson:Length:
            oCardJson = poJson:GetJsonObject(i).
            _parseCard(oCardJson).
        end.
        
        finally:
            if valid-object(poJson)    then delete object poJson.   
            if valid-object(oCardJson) then delete object oCardJson.         
        end finally.
    end method.

    METHOD PUBLIC LOGICAL downloadFile( INPUT pcDirectoryName AS CHARACTER, INPUT pcFileName AS CHARACTER, INPUT pcSaveInDirectory AS CHARACTER, INPUT pcAuditUser AS CHARACTER ):
        def var oResponse as IHttpResponse no-undo.
        def var lDumpEnabled as log no-undo init false.
        def var cEndpointName as char no-undo init "downloadFile".
        def var oResponseString as OpenEdge.Core.String no-undo.
        def var cFileContent as longchar no-undo.
        
        empty temp-table ttAccount.        
        
        lDumpEnabled = _isDumpEnabledFor(cEndpointName).
//        if lDumpEnabled then _dump(cEndpointName, "request", oRequestJson).
        oResponse = _executeRequest("GET", subst("/v1/extract-files/&1/&2", pcDirectoryName, pcFileName), pcAuditUser).

        if type-of(oResponse:Entity, "OpenEdge.Core.String")
        then do:
            oResponseString = cast(oResponse:Entity, "OpenEdge.Core.String").
            
            cFileContent = oResponseString:Value.
            copy-lob cFileContent to file subst("&1/&2", pcSaveInDirectory, pcFileName).
            
            return true.
        end.
        undo, throw new AppError(subst("Failed to download file &1/&2: unsupported response type: &3", pcDirectoryName, pcFileName, oResponse:entity:getclass ():typeName)).

        finally:
            if valid-object(oResponseString) then delete object oResponseString.
            if valid-object(oResponse)       then delete object oResponse.            
        end finally.
    END METHOD.

    method public logical enrolCardFor3Dsecure( input pcCardId as character, input pcAuditUser as character, output TABLE for ttCard ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED", 0).

    end method.

    method public logical getAccountAuthorizations( input pcAccountId as character, input ptFromDate as datetime, input ptTillDate as datetime, input piFromRecord as int64, input piCount as integer, input pcAuditUser as character, output TABLE for ttAuth ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED", 0).

    end method.

    method public logical getAccountByExternalId( input pcExternalId as character, input pcAuditUser as character, output TABLE for ttAccount ):
        def var oResponseJson as JsonObject no-undo.
        def var oResponse as IHttpResponse no-undo.
        def var lDumpEnabled as log no-undo init false.
        def var cEndpointName as char no-undo init "getAccountByExternalId".
        
        empty temp-table ttAccount.        
        
        lDumpEnabled = _isDumpEnabledFor(cEndpointName).
//        if lDumpEnabled then _dump(cEndpointName, "request", oRequestJson).
        oResponse = _executeRequest("GET", "/v1/accounts-by-external-id/" + pcExternalId, pcAuditUser).

        if type-of(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject")
        then do:
            oResponseJson = cast(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject").
            if lDumpEnabled then _dump(cEndpointName, "response", oResponseJson).

            _parseAccount(oResponseJson:GetJsonObject("account")).
            return true.
        end.
        undo, throw new AppError(subst("Failed to get account by external ID: unsupported response type: &1", oResponse:entity:getclass ():typeName)).

        finally:
            if valid-object(oResponseJson)  then delete object oResponseJson.
            if valid-object(oResponse)      then delete object oResponse.            
        end finally.
    end method.

    method public logical getAccountById( input pcAccountId as character, input pcAuditUser as character, output TABLE for ttAccount ):
        def var oResponseJson as JsonObject no-undo.
        def var oResponse as IHttpResponse no-undo.
        def var lDumpEnabled as log no-undo init false.
        def var cEndpointName as char no-undo init "getAccountById".
        
        empty temp-table ttAccount.        
        
        lDumpEnabled = _isDumpEnabledFor(cEndpointName).
//        if lDumpEnabled then _dump(cEndpointName, "request", oRequestJson).
        oResponse = _executeRequest("GET", "/v1/accounts/" + pcAccountId, pcAuditUser).

        if type-of(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject")
        then do:
            oResponseJson = cast(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject").
            if lDumpEnabled then _dump(cEndpointName, "response", oResponseJson).

            _parseAccount(oResponseJson:GetJsonObject("account")).
            return true.
        end.
        undo, throw new AppError(subst("Failed to get account by ID: unsupported response type: &1", oResponse:entity:getclass ():typeName)).

        finally:
            if valid-object(oResponseJson)  then delete object oResponseJson.
            if valid-object(oResponse)      then delete object oResponse.            
        end finally.
    end method.

    method public logical getAccountCards( input pcAccountId as character, input pcAuditUser as character, output TABLE for ttCard ):
        def var oResponseJson as JsonObject no-undo.
        def var oResponse as IHttpResponse no-undo.
        def var lDumpEnabled as log no-undo init false.
        def var cEndpointName as char no-undo init "getAccountById".
        
        empty temp-table ttCard.        
        
        lDumpEnabled = _isDumpEnabledFor(cEndpointName).
//        if lDumpEnabled then _dump(cEndpointName, "request", oRequestJson).
        oResponse = _executeRequest("GET", subst("/v1/accounts/&1/cards", pcAccountId), pcAuditUser).

        if type-of(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject")
        then do:
            oResponseJson = cast(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject").
            if lDumpEnabled then _dump(cEndpointName, "response", oResponseJson).

            _parseCards(oResponseJson:GetJsonArray("cards")).
            return true.
        end.
        undo, throw new AppError(subst("Failed to get account cards: unsupported response type: &1", oResponse:entity:getclass ():typeName)).

        finally:
            if valid-object(oResponseJson)  then delete object oResponseJson.
            if valid-object(oResponse)      then delete object oResponse.            
        end finally.
    end method.

    method public logical getAccounts( input-output TABLE for ttAccount, input pcAuditUser as character ):
        def var oRequestJson  as JsonObject no-undo.
        def var oIdsJson      as JsonArray no-undo.
        def var oResponseJson as JsonObject no-undo.
        def var oResponse as IHttpResponse no-undo.
        def var lDumpEnabled as log no-undo init false.
        def var cEndpointName as char no-undo init "getAccounts".
        
        if not can-find(first ttAccount)
        then return true. // there is nothing to do.
        
        oIdsJson = new JsonArray().
        for each ttAccount: 
            oIdsJson:add(ttAccount.id).
        end.
        oRequestJson = new JsonObject().
        oRequestJson:add("ids", oIdsJson).
        
        empty temp-table ttAccount.        
        
        lDumpEnabled = _isDumpEnabledFor(cEndpointName).
        if lDumpEnabled then _dump(cEndpointName, "request", oRequestJson).
        oResponse = _executeRequest("POST", "/v1/accounts-by-ids", pcAuditUser, oRequestJson).

        if type-of(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject")
        then do:
            oResponseJson = cast(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject").
            if lDumpEnabled then _dump(cEndpointName, "response", oResponseJson).

            _parseAccounts(oResponseJson:GetJsonArray("accounts")).
            return true.
        end.
        undo, throw new AppError(subst("Failed to get accounts: unsupported response type: &1", oResponse:entity:getclass ():typeName)).

        finally:
            if valid-object(oRequestJson)   then delete object oRequestJson.
            if valid-object(oIdsJson)       then delete object oIdsJson.
            if valid-object(oResponseJson)  then delete object oResponseJson.
            if valid-object(oResponse)      then delete object oResponse.            
        end finally.
    end method.

    method public logical getAccountStatement( input pcAccountId as character, input piFromRecord as int64, input piCount as integer, input TABLE for ttStatementRequestParams, input pcAuditUser as character, output TABLE for ttStmt ):
        def var oResponseJson as JsonObject no-undo.
        def var oResponse as IHttpResponse no-undo.
        def var lDumpEnabled as log no-undo init false.
        def var cEndpointName as char no-undo init "getAccountStatement".
        
        empty temp-table ttStmt.        
        
        lDumpEnabled = _isDumpEnabledFor(cEndpointName).
        oResponse = _executeRequest("GET", subst("/v1/accounts/&1/statement?from_record=&2&&records_count=&3&4", pcAccountId, piFromRecord, piCount, _getRequestParams()), pcAuditUser).

        if type-of(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject")
        then do:
            oResponseJson = cast(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject").
            if lDumpEnabled then _dump(cEndpointName, "response", oResponseJson).

            _parseAccountStatement(pcAccountId, oResponseJson:GetJsonArray("records")).
            return true.
        end.
        undo, throw new AppError(subst("Failed to get accounts: unsupported response type: &1", oResponse:entity:getclass ():typeName)).

        finally:
            if valid-object(oResponseJson)  then delete object oResponseJson.
            if valid-object(oResponse)      then delete object oResponse.            
        end finally.

    end method.
    
    method protected character _getRequestParams(): 
        def var i as int no-undo.
        def var cFieldName as char no-undo.
        def var cFieldType as char no-undo.
        def var hField     as handle no-undo.
        def var cParams    as char no-undo.
        
        find ttStatementRequestParams no-error.
        if not available ttStatementRequestParams
        then create ttStatementRequestParams.
        
        do i=1 to buffer ttStatementRequestParams:num-fields: 
            hField     = buffer ttStatementRequestParams:buffer-field (i).
            if hField:buffer-value = ?
            then next.
            
            cFieldName = hField:name.            
            cFieldType = hField:data-type.
            
            case cFieldType:
                when "DATETIME"
                then do:
                    cParams = subst("&1&&&2=&3", cParams, cFieldName, Converter:formatDatetime(add-interval(hField:buffer-value, - timezone, "minutes"), "YYYY-MM-DDTHH:mm:ssZ")).
                end.
                 
                when "LOGICAL"
                then do: 
                    cParams = subst("&1&&&2=&3", cParams, cFieldName, if hField:buffer-value then "true" else "false").        
                end.
                
                otherwise do: 
                    undo, throw new AppError(subst("Datatype &1 is not supported in _getRequestParams yet!", cFieldType), 0).
                end.
            end.
        end.
        
//        message cParams view-as alert-box.
        return cParams.
        
    end method.

    method public logical getAccountTransactions( input pcAccountId as character, input ptFromDate as datetime, input ptTillDate as datetime, input piFromRecord as int64, input piCount as integer, input pcAuditUser as character, output TABLE for ttAuth ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED", 0).

    end method.

    method public logical getAllAccounts( input piFromRecord as int64, input piCount as integer, input pcAuditUser as character, output TABLE for ttAccount ):
        def var oResponseJson as JsonObject no-undo.
        def var oResponse as IHttpResponse no-undo.
        def var lDumpEnabled as log no-undo init false.
        def var cEndpointName as char no-undo init "getAllAccounts".
        
        empty temp-table ttAccount.        
        
        lDumpEnabled = _isDumpEnabledFor(cEndpointName).
//        if lDumpEnabled then _dump(cEndpointName, "request", oRequestJson).
        oResponse = _executeRequest("GET", subst("/v1/accounts?from_record=&1&&records_count=&2&&order_direction=desc&&order_field=updated_at", piFromRecord, piCount), pcAuditUser).

        if type-of(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject")
        then do:
            oResponseJson = cast(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject").
            if lDumpEnabled then _dump(cEndpointName, "response", oResponseJson).

            _parseAccounts(oResponseJson:GetJsonArray("accounts")).
            return true.
        end.
        undo, throw new AppError(subst("Failed to get all accounts: unsupported response type: &1", oResponse:entity:getclass ():typeName)).

        finally:
            if valid-object(oResponseJson)  then delete object oResponseJson.
            if valid-object(oResponse)      then delete object oResponse.            
        end finally.
    end method.

    method public logical getAllAuthorizations( input piFromRecord as int64, input piCount as integer, input pcAuditUser as character, output TABLE for ttAuth ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED", 0).

    end method.

    method public logical getAllTransactions( input piFromRecord as int64, input piCount as integer, input pcAuditUser as character, output TABLE for ttAuth ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED", 0).

    end method.

    method public logical getCardAuthorizations( input pcCardId as character, input ptFromDate as datetime, input ptTillDate as datetime, input piFromRecord as int64, input piCount as integer, input pcAuditUser as character, output TABLE for ttAuth ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED", 0).

    end method.

    method public logical getCardByExternalId( input pcCardExternalId as character, input pcAuditUser as character, output TABLE for ttCard ):
        def var oResponseJson as JsonObject no-undo.
        def var oResponse as IHttpResponse no-undo.
        def var lDumpEnabled as log no-undo init false.
        def var cEndpointName as char no-undo init "getCardByExternalId".
        
        empty temp-table ttAccount.        
        
        lDumpEnabled = _isDumpEnabledFor(cEndpointName).
//        if lDumpEnabled then _dump(cEndpointName, "request", oRequestJson).
        oResponse = _executeRequest("GET", "/v1/cards-by-external-id/" + pcCardExternalId, pcAuditUser).

        if type-of(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject")
        then do:
            oResponseJson = cast(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject").
            if lDumpEnabled then _dump(cEndpointName, "response", oResponseJson).

            _parseCard(oResponseJson:GetJsonObject("card")).
            return true.
        end.
        undo, throw new AppError(subst("Failed to get card by external ID: unsupported response type: &1", oResponse:entity:getclass ():typeName)).

        finally:
            if valid-object(oResponseJson)  then delete object oResponseJson.
            if valid-object(oResponse)      then delete object oResponse.            
        end finally.
    end method.

    method public logical getCardById( input pcCardId as character, input pcAuditUser as character, output TABLE for ttCard ):
        def var oResponseJson as JsonObject no-undo.
        def var oResponse as IHttpResponse no-undo.
        def var lDumpEnabled as log no-undo init false.
        def var cEndpointName as char no-undo init "getCardById".
        
        empty temp-table ttAccount.        
        
        lDumpEnabled = _isDumpEnabledFor(cEndpointName).
//        if lDumpEnabled then _dump(cEndpointName, "request", oRequestJson).
        oResponse = _executeRequest("GET", "/v1/cards/" + pcCardId, pcAuditUser).

        if type-of(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject")
        then do:
            oResponseJson = cast(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject").
            if lDumpEnabled then _dump(cEndpointName, "response", oResponseJson).

            _parseCard(oResponseJson:GetJsonObject("card")).
            return true.
        end.
        undo, throw new AppError(subst("Failed to get card by ID: unsupported response type: &1", oResponse:entity:getclass ():typeName)).

        finally:
            if valid-object(oResponseJson)  then delete object oResponseJson.
            if valid-object(oResponse)      then delete object oResponse.            
        end finally.
    end method.

    method public logical getAllCards(piFromRecord as int64, piCount as int, input pcAuditUser as character, output TABLE for ttCard ):
        def var oResponseJson as JsonObject no-undo.
        def var oResponse as IHttpResponse no-undo.
        def var lDumpEnabled as log no-undo init false.
        def var cEndpointName as char no-undo init "getAllCards".
        
        empty temp-table ttCard.        
        
        lDumpEnabled = _isDumpEnabledFor(cEndpointName).
//        if lDumpEnabled then _dump(cEndpointName, "request", oRequestJson).
        oResponse = _executeRequest("GET", subst("/v1/product-cards?from_record=&1&&records_count=&2&&order_field=updated_at&&order_direction=desc", piFromRecord, piCount), pcAuditUser).

        if type-of(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject")
        then do:
            oResponseJson = cast(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject").
            if lDumpEnabled then _dump(cEndpointName, "response", oResponseJson).

            _parseCards(oResponseJson:GetJsonArray("cards")).
            return true.
        end.
        undo, throw new AppError(subst("Failed to get all cards: unsupported response type: &1", oResponse:entity:getclass ():typeName)).

        finally:
            if valid-object(oResponseJson)  then delete object oResponseJson.
            if valid-object(oResponse)      then delete object oResponse.            
        end finally.
    end method.

    method public logical getCardTransactions( input pcCardId as character, input ptFromDate as datetime, input ptTillDate as datetime, input piFromRecord as int64, input piCount as integer, input pcAuditUser as character, output TABLE for ttAuth ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED", 0).

    end method.

    METHOD PUBLIC LOGICAL getDirectoryIndex( INPUT pcDirectoryName AS CHARACTER, INPUT pcAuditUser AS CHARACTER, OUTPUT TABLE FOR ttFile ):
        def var oResponseJson as JsonObject no-undo.
        def var oResponse as IHttpResponse no-undo.
        def var lDumpEnabled as log no-undo init false.
        def var cEndpointName as char no-undo init "getDirectoryIndex".
        
        empty temp-table ttFile.        
        
        lDumpEnabled = _isDumpEnabledFor(cEndpointName).
//        if lDumpEnabled then _dump(cEndpointName, "request", oRequestJson).
        oResponse = _executeRequest("GET", subst("/v1/extract-files/&1", pcDirectoryName), pcAuditUser).

        if type-of(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject")
        then do:
            oResponseJson = cast(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject").
            if lDumpEnabled then _dump(cEndpointName, "response", oResponseJson).

            _parseFileList(oResponseJson:GetJsonArray("files")).
            return true.
        end.
        undo, throw new AppError(subst("Failed to get list of directory &1: unsupported response type: &2", pcDirectoryName, oResponse:entity:getclass ():typeName)).

        finally:
            if valid-object(oResponseJson)  then delete object oResponseJson.
            if valid-object(oResponse)      then delete object oResponse.      
        end finally.
    END METHOD.

    METHOD PUBLIC CHARACTER getEncryptedCard3dsPassword( INPUT pcCardId AS CHARACTER, INPUT pcPublicKey AS CHARACTER, INPUT pcAuditUser AS CHARACTER ):
        def var oRequestJson as JsonObject no-undo.
        def var oResponseJson as JsonObject no-undo.
        def var oResponse as IHttpResponse no-undo.
        def var lDumpEnabled as log no-undo init false.
        def var cEndpointName as char no-undo init "getEncryptedCard3dsPassword".
        
        empty temp-table ttAccount.        
        
        lDumpEnabled = _isDumpEnabledFor(cEndpointName).
        
        oRequestJson = new JsonObject().
        oRequestJson:add("public_key", pcPublicKey).
        
        lDumpEnabled = _isDumpEnabledFor(cEndpointName).
        if lDumpEnabled then _dump(cEndpointName, "request", oRequestJson).
        oResponse = _executeRequest("POST", subst("/v1/cards/&1/encrypted-3ds-password", pcCardId), pcAuditUser, oRequestJson).

        if type-of(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject")
        then do:
            oResponseJson = cast(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject").
            if lDumpEnabled then _dump(cEndpointName, "response", oResponseJson).

            if (oResponseJson:Has("encrypted_3ds_password"))
            then return oResponseJson:GetCharacter("encrypted_3ds_password").
            else return "".
        end.
        undo, throw new AppError(subst("Failed to getEncryptedCard3dsPassword: unsupported response type: &1", oResponse:entity:getclass ():typeName)).

        finally:
            if valid-object(oRequestJson)   then delete object oRequestJson.
            if valid-object(oResponseJson)  then delete object oResponseJson.
            if valid-object(oResponse)      then delete object oResponse.            
        end finally.    
    END METHOD.

    METHOD PUBLIC CHARACTER getEncryptedCardCvv2( INPUT pcCardId AS CHARACTER, INPUT pcPublicKey AS CHARACTER, INPUT pcAuditUser AS CHARACTER ):
        def var oRequestJson as JsonObject no-undo.
        def var oResponseJson as JsonObject no-undo.
        def var oResponse as IHttpResponse no-undo.
        def var lDumpEnabled as log no-undo init false.
        def var cEndpointName as char no-undo init "getEncryptedCardCvv2".
        
        empty temp-table ttAccount.        
        
        lDumpEnabled = _isDumpEnabledFor(cEndpointName).
        
        oRequestJson = new JsonObject().
        oRequestJson:add("public_key", pcPublicKey).
        
        lDumpEnabled = _isDumpEnabledFor(cEndpointName).
        if lDumpEnabled then _dump(cEndpointName, "request", oRequestJson).
        oResponse = _executeRequest("POST", subst("/v1/cards/&1/encrypted-cvv2", pcCardId), pcAuditUser, oRequestJson).

        if type-of(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject")
        then do:
            oResponseJson = cast(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject").
            if lDumpEnabled then _dump(cEndpointName, "response", oResponseJson).

            if (oResponseJson:Has("encrypted_cvv2"))
            then return oResponseJson:GetCharacter("encrypted_cvv2").
            else return "".
        end.
        undo, throw new AppError(subst("Failed to getEncryptedCardCvv2: unsupported response type: &1", oResponse:entity:getclass ():typeName)).

        finally:
            if valid-object(oRequestJson)   then delete object oRequestJson.
            if valid-object(oResponseJson)  then delete object oResponseJson.
            if valid-object(oResponse)      then delete object oResponse.            
        end finally.
    END METHOD.

    METHOD PUBLIC CHARACTER getEncryptedCardNumber( INPUT pcCardId AS CHARACTER, INPUT pcPublicKey AS CHARACTER, pcAuditUser as char ):
        def var oRequestJson as JsonObject no-undo.
        def var oResponseJson as JsonObject no-undo.
        def var oResponse as IHttpResponse no-undo.
        def var lDumpEnabled as log no-undo init false.
        def var cEndpointName as char no-undo init "getEncryptedCardNumber".
        
        empty temp-table ttAccount.        
        
        lDumpEnabled = _isDumpEnabledFor(cEndpointName).
        
        oRequestJson = new JsonObject().
        oRequestJson:add("public_key", pcPublicKey).
        
        lDumpEnabled = _isDumpEnabledFor(cEndpointName).
        if lDumpEnabled then _dump(cEndpointName, "request", oRequestJson).
        oResponse = _executeRequest("POST", subst("/v1/cards/&1/encrypted-card-number", pcCardId), pcAuditUser, oRequestJson).

        if type-of(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject")
        then do:
            oResponseJson = cast(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject").
            if lDumpEnabled then _dump(cEndpointName, "response", oResponseJson).

            if (oResponseJson:Has("encrypted_card_number"))
            then return oResponseJson:GetCharacter("encrypted_card_number").
            else return "".
        end.
        undo, throw new AppError(subst("Failed to getEncryptedCardNumber: unsupported response type: &1", oResponse:entity:getclass ():typeName)).

        finally:
            if valid-object(oRequestJson)   then delete object oRequestJson.
            if valid-object(oResponseJson)  then delete object oResponseJson.
            if valid-object(oResponse)      then delete object oResponse.            
        end finally.
    END METHOD.

    METHOD PUBLIC CHARACTER getEncryptedCardPin( INPUT pcCardId AS CHARACTER, INPUT pcPublicKey AS CHARACTER, INPUT pcAuditUser AS CHARACTER ):
        def var oRequestJson as JsonObject no-undo.
        def var oResponseJson as JsonObject no-undo.
        def var oResponse as IHttpResponse no-undo.
        def var lDumpEnabled as log no-undo init false.
        def var cEndpointName as char no-undo init "getEncryptedCardPin".
        
        empty temp-table ttAccount.        
        
        lDumpEnabled = _isDumpEnabledFor(cEndpointName).
        
        oRequestJson = new JsonObject().
        oRequestJson:add("public_key", pcPublicKey).
        
        lDumpEnabled = _isDumpEnabledFor(cEndpointName).
        if lDumpEnabled then _dump(cEndpointName, "request", oRequestJson).
        oResponse = _executeRequest("POST", subst("/v1/cards/&1/encrypted-pin", pcCardId), pcAuditUser, oRequestJson).

        if type-of(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject")
        then do:
            oResponseJson = cast(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject").
            if lDumpEnabled then _dump(cEndpointName, "response", oResponseJson).

            if (oResponseJson:Has("encrypted_pin"))
            then return oResponseJson:GetCharacter("encrypted_pin").
            else return "".
        end.
        undo, throw new AppError(subst("Failed to getEncryptedCardPin: unsupported response type: &1", oResponse:entity:getclass ():typeName)).

        finally:
            if valid-object(oRequestJson)   then delete object oRequestJson.
            if valid-object(oResponseJson)  then delete object oResponseJson.
            if valid-object(oResponse)      then delete object oResponse.            
        end finally.    END METHOD.

    METHOD PUBLIC LOGICAL getListOfDirectories( INPUT pcAuditUser AS CHARACTER, OUTPUT TABLE FOR ttFile ):
        def var oResponseJson as JsonObject no-undo.
        def var oResponse as IHttpResponse no-undo.
        def var lDumpEnabled as log no-undo init false.
        def var cEndpointName as char no-undo init "getListOfDirectories".
        
        empty temp-table ttFile.        
        
        lDumpEnabled = _isDumpEnabledFor(cEndpointName).
//        if lDumpEnabled then _dump(cEndpointName, "request", oRequestJson).
        oResponse = _executeRequest("GET", "/v1/extract-files", pcAuditUser).

        if type-of(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject")
        then do:
            oResponseJson = cast(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject").
            if lDumpEnabled then _dump(cEndpointName, "response", oResponseJson).

            _parseDirectoryList(oResponseJson:GetJsonArray("directories")).
            return true.
        end.
        undo, throw new AppError(subst("Failed to get list of directories: unsupported response type: &1", oResponse:entity:getclass ():typeName)).

        finally:
            if valid-object(oResponseJson)  then delete object oResponseJson.
            if valid-object(oResponse)      then delete object oResponse.      
        end finally.
    END METHOD.

    method public logical getPersonAccounts( input pcPersonId as character, input pcAuditUser as character, output TABLE for ttAccount ):
        def var oResponseJson as JsonObject no-undo.
        def var oResponse as IHttpResponse no-undo.
        def var lDumpEnabled as log no-undo init false.
        def var cEndpointName as char no-undo init "getPersonAccounts".
        
        empty temp-table ttAccount.        
        
        lDumpEnabled = _isDumpEnabledFor(cEndpointName).
//        if lDumpEnabled then _dump(cEndpointName, "request", oRequestJson).
        oResponse = _executeRequest("GET", subst("/v1/persons/&1/accounts", pcPersonId), pcAuditUser).

        if type-of(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject")
        then do:
            oResponseJson = cast(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject").
            if lDumpEnabled then _dump(cEndpointName, "response", oResponseJson).

            _parseAccounts(oResponseJson:GetJsonArray("accounts")).
            return true.
        end.
        undo, throw new AppError(subst("Failed to get account by external ID: unsupported response type: &1", oResponse:entity:getclass ():typeName)).

        finally:
            if valid-object(oResponseJson)  then delete object oResponseJson.
            if valid-object(oResponse)      then delete object oResponse.            
        end finally.
    end method.

    method public logical getPersonByExternalId( input pcExternalId as character, input pcAuditUser as character, output TABLE for ttPerson ):
        def var oResponseJson as JsonObject no-undo.
        def var oResponse as IHttpResponse no-undo.
        def var lDumpEnabled as log no-undo init false.
        def var cEndpointName as char no-undo init "getPersonByExternalId".
        
        empty temp-table ttPerson.        
        
        lDumpEnabled = _isDumpEnabledFor(cEndpointName).
//        if lDumpEnabled then _dump(cEndpointName, "request", oRequestJson).
        oResponse = _executeRequest("GET", "/v1/persons-by-external-id/" + pcExternalId, pcAuditUser).

        if type-of(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject")
        then do:
            oResponseJson = cast(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject").
            if lDumpEnabled then _dump(cEndpointName, "response", oResponseJson).

            _parsePerson(oResponseJson:GetJsonObject("person")).
            return true.
        end.
        undo, throw new AppError(subst("Failed to get person by external ID: unsupported response type: &1", oResponse:entity:getclass ():typeName)).

        finally:
            if valid-object(oResponseJson)  then delete object oResponseJson.
            if valid-object(oResponse)      then delete object oResponse.            
        end finally.
    end method.

    method public logical getPersonById( input pcPersonID as character, input pcAuditUser as character, output TABLE for ttPerson ):
        def var oResponseJson as JsonObject no-undo.
        def var oResponse as IHttpResponse no-undo.
        def var lDumpEnabled as log no-undo init false.
        def var cEndpointName as char no-undo init "getPersonById".
        
        empty temp-table ttPerson.        
        
        lDumpEnabled = _isDumpEnabledFor(cEndpointName).
//        if lDumpEnabled then _dump(cEndpointName, "request", oRequestJson).
        oResponse = _executeRequest("GET", "/v1/persons/" + pcPersonID, pcAuditUser).

        if type-of(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject")
        then do:
            oResponseJson = cast(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject").
            if lDumpEnabled then _dump(cEndpointName, "response", oResponseJson).

            _parsePerson(oResponseJson:GetJsonObject("person")).
            return true.
        end.
        undo, throw new AppError(subst("Failed to get person by ID: unsupported response type: &1", oResponse:entity:getclass ():typeName)).

        finally:
            if valid-object(oResponseJson)  then delete object oResponseJson.
            if valid-object(oResponse)      then delete object oResponse.            
        end finally.
    end method.

    method public logical getPersonsByPersonalNumber( input pcPersonalNumber as character, input pcAuditUser as character, output TABLE for ttPerson ):
        def var oResponseJson as JsonObject no-undo.
        def var oResponse as IHttpResponse no-undo.
        def var lDumpEnabled as log no-undo init false.
        def var cEndpointName as char no-undo init "getPersonByPersonalNumber".
        
        empty temp-table ttPerson.        
        
        lDumpEnabled = _isDumpEnabledFor(cEndpointName).
//        if lDumpEnabled then _dump(cEndpointName, "request", oRequestJson).
        oResponse = _executeRequest("GET", subst("/v1/persons?personal_number=&1&&from_record=0&&records_count=1000", pcPersonalNumber), pcAuditUser).

        if type-of(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject")
        then do:
            oResponseJson = cast(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject").
            if lDumpEnabled then _dump(cEndpointName, "response", oResponseJson).

            _parsePersons(oResponseJson:GetJsonArray("persons")).
            return can-find(first ttPerson).
        end.
        undo, throw new AppError(subst("Failed to get person by personalNumber: unsupported response type: &1", oResponse:entity:getclass ():typeName)).

        finally:
            if valid-object(oResponseJson)  then delete object oResponseJson.
            if valid-object(oResponse)      then delete object oResponse.            
        end finally.
    end method.

    method public logical getPersonCards( input pcPersonId as character, input pcAuditUser as character, output TABLE for ttCard ):
        def var oResponseJson as JsonObject no-undo.
        def var oResponse as IHttpResponse no-undo.
        def var lDumpEnabled as log no-undo init false.
        def var cEndpointName as char no-undo init "getPersonCards".
        
        empty temp-table ttCard.        
        
        lDumpEnabled = _isDumpEnabledFor(cEndpointName).
//        if lDumpEnabled then _dump(cEndpointName, "request", oRequestJson).
        oResponse = _executeRequest("GET", subst("/v1/persons/&1/cards", pcPersonId), pcAuditUser).

        if type-of(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject")
        then do:
            oResponseJson = cast(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject").
            if lDumpEnabled then _dump(cEndpointName, "response", oResponseJson).

            _parseCards(oResponseJson:GetJsonArray("cards")).
            return true.
        end.
        undo, throw new AppError(subst("Failed to get person cards: unsupported response type: &1", oResponse:entity:getclass ():typeName)).

        finally:
            if valid-object(oResponseJson)  then delete object oResponseJson.
            if valid-object(oResponse)      then delete object oResponse.            
        end finally.
    end method.

    METHOD PUBLIC LOGICAL getTransactionById( INPUT pcTransactionId AS CHARACTER, INPUT pcAuditUser AS CHARACTER, OUTPUT TABLE FOR ttTrn ):
        def var oResponseJson as JsonObject no-undo.
        def var oResponse as IHttpResponse no-undo.
        def var lDumpEnabled as log no-undo init false.
        def var cEndpointName as char no-undo init "getTransaction".
        
        empty temp-table ttTrn.        
        
        lDumpEnabled = _isDumpEnabledFor(cEndpointName).
        oResponse = _executeRequest("GET", subst("/v1/transactions/&1", pcTransactionId), pcAuditUser).

        if type-of(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject")
        then do:
            oResponseJson = cast(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject").
            if lDumpEnabled then _dump(cEndpointName, "response", oResponseJson).

            _parseTransaction(oResponseJson:GetJsonObject("transaction")).
            return true.
        end.
        undo, throw new AppError(subst("Failed to get transaction: unsupported response type: &1", oResponse:entity:getclass ():typeName)).

        finally:
            if valid-object(oResponseJson)  then delete object oResponseJson.
            if valid-object(oResponse)      then delete object oResponse.            
        end finally.
    END METHOD.

    method public logical linkCardToAccount( input pcCardId as character, input pcAccountId as character, input pcAuditUser as character, output TABLE for ttCard ):
        def var oRequestJson as JsonObject no-undo.
        def var oResponseJson as JsonObject no-undo.
        def var oResponse as IHttpResponse no-undo.
        def var lDumpEnabled as log no-undo init false.
        def var cEndpointName as char no-undo init "linkCardToAccount".
        
        oRequestJson = new JsonObject().
        empty temp-table ttCard.        
        
        lDumpEnabled = _isDumpEnabledFor(cEndpointName).
        if lDumpEnabled then _dump(cEndpointName, "request", oRequestJson).
        oResponse = _executeRequest("PATCH", subst("/v1/cards/&1/link-to-account/&2", pcCardId, pcAccountId), pcAuditUser, oRequestJson).

        if type-of(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject")
        then do:
            oResponseJson = cast(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject").
            if lDumpEnabled then _dump(cEndpointName, "response", oResponseJson).

            _parseCard(oResponseJson:GetJsonObject("card")).

            return true.
        end.
        undo, throw new AppError(subst("Failed to linkCardToAccount: unsupported response type: &1", oResponse:entity:getclass ():typeName)).

        finally:
            if valid-object(oRequestJson)   then delete object oRequestJson.
            if valid-object(oResponseJson)  then delete object oResponseJson.
            if valid-object(oResponse)      then delete object oResponse.            
        end finally.
    end method.

    method public char ping(pcMessage as char):
        
        DEFINE VARIABLE oResponse AS IHttpResponse NO-UNDO.        
        def var oResponseJson as JsonObject no-undo.
        def var oRequestJson as JsonObject no-undo.
        
        oRequestJson = new JsonObject().
        oRequestJson:Add("message", pcMessage).
        
        oResponse = _executeRequest("POST", "/v1/test/ping", "testUser", oRequestJson).
            if type-of(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject")
            then do:
                oResponseJson = cast(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject").

                if oResponseJson:has("message")
                then return oResponseJson:GetCharacter("message").
                else undo, throw new AppError(subst("ping received wrong response JSON! &1", _string(oResponseJson)), 0).
                
// for debug only
//                def var cResponseString as longchar no-undo.
//               oResponseJson:Write(cResponseString, true).
         //       copy-lob from cResponseString to file "c:/temp/response-card-activate.json".
//                if oJsonObject:Has("actionCode") 
//                    and oJsonObject:GetType("actionCode") = 1 
//                    and oJsonObject:GetCharacter("actionCode") = "000" 
//                        then return true. 
//                        else return false.
//                return cResponseString.
            end.
            
        undo, throw new AppError("ping received wrong response entity!", 0).
        finally:
            if valid-object(oRequestJson)
            then delete object oRequestJson.
            if valid-object(oResponseJson)
            then delete object oResponseJson.
            if valid-object(oResponse)
            then delete object oResponse.           
        end finally.
        
        
    end method.
    
    method protected char _string( poJson as JsonObject):
       def var cJson as longchar no-undo.
       cJson = poJson:GetJsonText().
       
       if length(cJson) > 32000
       then return string(substr(cJson, 1, 30000)).
       else return string(cJson). 
        
    end method.
    
    method protected IHttpResponse _executeRequest(pcRequestType as char, pcEndpointUrl as char, pcAuditUser as char, poRequestJson as JsonObject): 
        def var oRequest as IHttpRequest no-undo.
        def var oResponse as IHttpResponse no-undo.        
        def var oJsonObject as JsonObject no-undo.
        def var oJsonReqObject as JsonObject no-undo.
        def var oRequestAuthHeader as HttpHeader no-undo.
        def var oRequestUserHeader as HttpHeader no-undo.
        def var oResponseAuthHeader as HttpHeader no-undo.
        def var cRequestBody as longchar no-undo.
        def var cJwtToken as char no-undo.
        def var oResponseClaims as JsonObject no-undo.
        
//        message wallesterUrl + pcEndpointUrl view-as alert-box.
        case pcRequestType:
            when "PATCH" 
            then oRequest = RequestBuilder:Patch(wallesterUrl + pcEndpointUrl, poRequestJson):AcceptJson()
                                          :ContentType("application/json; charset=UTF-8")
                                          :Request.

            when "POST" 
            then oRequest = RequestBuilder:Post(wallesterUrl + pcEndpointUrl, poRequestJson):AcceptJson()
                                          :ContentType("application/json; charset=UTF-8")
                                          :Request.
            when "PUT"  
            then oRequest = RequestBuilder:Put(wallesterUrl + pcEndpointUrl, poRequestJson):AcceptJson()
                                          :ContentType("application/json; charset=UTF-8")
                                          :Request.
            
            otherwise undo, throw new AppError(subst("Unsupported requestType=&1 for &2", pcRequestType, pcEndpointUrl), 0).
        end case.
        
        cRequestBody = poRequestJson:getJsonText().
    //    message string(cRequestBody) view-as alert-box title "Request JSON".
        cJwtToken = Jwt:builder()
                       :setIssuer(this-object:issuerId)
                       :setAudience(this-object:audienceId)
                       :setExpiresInSeconds(60)
                       :setSubject("api-request")
                       :setClaim("rbh", _calcRequestBodyHash(cRequestBody))
                       :signWithHS256Key(this-object:latekoSecret)
                       :compact()
                       .
        if not valid-object(moSourceTypeHeader)
        then moSourceTypeHeader = HttpHeaderBuilder:Build('X-Audit-Source-Type'):Value(this-object:auditSourceType):Header.
        oRequest:setHeader(moSourceTypeHeader).
        if not valid-object(moProductCodeHeader)
        then moProductCodeHeader = HttpHeaderBuilder:Build('X-Product-Code'):Value(this-object:productCode):Header.
        oRequest:setHeader(moProductCodeHeader).
     
        oRequestAuthHeader = HttpHeaderBuilder:Build('Authorization'):Value(substitute("Bearer &1", cJwtToken)):Header.
        oRequest:SetHeader(oRequestAuthHeader).
        oRequestUserHeader = HttpHeaderBuilder:Build('X-Audit-User-Id'):Value(pcAuditUser):Header.
        oRequest:SetHeader(oRequestUserHeader).
        
        oResponse = ClientBuilder:Build():Client:Execute(oRequest).

        if oResponse:statusCode = 401
        then undo, throw new AppError("Unauthorized!", 0).
        if oResponse:StatusCode >= 200 and oResponse:StatusCode < 300 and valid-object(oResponse:entity)
        then do:
            def var cReceivedToken as char no-undo.
            oResponseAuthHeader = oResponse:GetHeader("Authorization").
            if oResponseAuthHeader:value begins "Bearer "
            then do: 
                cReceivedToken = entry(2, oResponseAuthHeader:Value, " ").
                oResponseClaims = Jwt:parseBuilder()
                                     :setSigningKeyHS256(this-object:latekoSecret)
                                     :parseClaimsJws(cReceivedToken).
            end.
        end.
        else undo, throw new AppError(subst("&1 (&2 &3 FAILED - status: &4)",_extractErrorMessage(oResponse:Entity), pcRequestType, pcEndpointUrl, oResponse:StatusCode), 1).
        
        return oResponse.
        
        finally:
            if valid-object(poRequestJson)           then delete object poRequestJson.
            if valid-object(oRequest)                then delete object oRequest.
            if valid-object(oRequestAuthHeader)      then delete object oRequestAuthHeader.
            if valid-object(oRequestUserHeader)      then delete object oRequestUserHeader.
            if valid-object(oResponseAuthHeader)     then delete object oResponseAuthHeader.
            if valid-object(oResponseClaims)         then delete object oResponseClaims.
        end finally.
    end method.

    method protected IHttpResponse _executeRequest(pcRequestType as char, pcEndpointUrl as char, pcAuditUser as char): 
        def var oRequest as IHttpRequest no-undo.
        def var oResponse as IHttpResponse no-undo.        
        def var oJsonObject as JsonObject no-undo.
        def var oJsonReqObject as JsonObject no-undo.
        def var oRequestAuthHeader as HttpHeader no-undo.
        def var oRequestUserHeader as HttpHeader no-undo.
        def var oResponseAuthHeader as HttpHeader no-undo.
        def var cJwtToken as char no-undo.
        def var oResponseClaims as JsonObject no-undo.
        
 //       message wallesterUrl + pcEndpointUrl view-as alert-box.
        case pcRequestType:
            when "GET" 
            then oRequest = RequestBuilder:Get(wallesterUrl + pcEndpointUrl):AcceptJson()
                                          :ContentType("application/json; charset=UTF-8")
                                          :Request.

            otherwise undo, throw new AppError(subst("Unsupported requestType=&1 for &2", pcRequestType, pcEndpointUrl), 0).
        end case.
        
        cJwtToken = Jwt:builder()
                       :setIssuer(this-object:issuerId)
                       :setAudience(this-object:audienceId)
                       :setExpiresInSeconds(60)
                       :setSubject("api-request")
             //          :setClaim("rbh", _calcRequestBodyHash(""))
                       :signWithHS256Key(this-object:latekoSecret)
                       :compact()
                       .
        if not valid-object(moSourceTypeHeader)
        then moSourceTypeHeader = HttpHeaderBuilder:Build('X-Audit-Source-Type'):Value(this-object:auditSourceType):Header.
        oRequest:setHeader(moSourceTypeHeader).
        if not valid-object(moProductCodeHeader)
        then moProductCodeHeader = HttpHeaderBuilder:Build('X-Product-Code'):Value(this-object:productCode):Header.
        oRequest:setHeader(moProductCodeHeader).
     
        oRequestAuthHeader = HttpHeaderBuilder:Build('Authorization'):Value(substitute("Bearer &1", cJwtToken)):Header.
        oRequest:SetHeader(oRequestAuthHeader).
        oRequestUserHeader = HttpHeaderBuilder:Build('X-Audit-User-Id'):Value(pcAuditUser):Header.
        oRequest:SetHeader(oRequestUserHeader).
        
        oResponse = ClientBuilder:Build():Client:Execute(oRequest).

        if oResponse:statusCode = 401
        then undo, throw new AppError("Unauthorized!", 0).
        if oResponse:StatusCode >= 200 and oResponse:StatusCode < 300 and valid-object(oResponse:entity)
        then do:
            def var cReceivedToken as char no-undo.
            oResponseAuthHeader = oResponse:GetHeader("Authorization").
            if oResponseAuthHeader:value begins "Bearer "
            then do: 
                cReceivedToken = entry(2, oResponseAuthHeader:Value, " ").
                oResponseClaims = Jwt:parseBuilder()
                                     :setSigningKeyHS256(this-object:latekoSecret)
                                     :parseClaimsJws(cReceivedToken).
            end.
        end.
        else undo, throw new AppError(subst("&1 (&2 &3 FAILED - status: &4)",_extractErrorMessage(oResponse:Entity), pcRequestType, pcEndpointUrl, oResponse:StatusCode), 1).
        
        return oResponse.
        
        finally:
            if valid-object(oRequest)                then delete object oRequest.
            if valid-object(oRequestAuthHeader)      then delete object oRequestAuthHeader.
            if valid-object(oRequestUserHeader)      then delete object oRequestUserHeader.
            if valid-object(oResponseAuthHeader)     then delete object oResponseAuthHeader.
            if valid-object(oResponseClaims)         then delete object oResponseClaims.
        end finally.
    end method.
    

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method public char _extractErrorMessage( poEntity as Object ):
        def var oJsonObject as JsonObject no-undo.
        def var oBody as JsonObject no-undo.
        def var oPath as JsonObject no-undo.
        def var cNames as char extent no-undo.
        
        if valid-object(poEntity) 
        then do: 
//            message poEntity:GetClass():TypeName view-as alert-box.
            if type-of(poEntity, "Progress.Json.ObjectModel.JsonObject")
            then do:
                oJsonObject = cast(poEntity, "Progress.Json.ObjectModel.JsonObject").
    
                if oJsonObject:Has("body")  
                then do:
                    oBody = oJsonObject:GetJsonObject("body").
                    if valid-object(oBody)
                    then do:
                        cNames = oBody:GetNames().
                        return oBody:getCharacter(cNames[1]).
                    end.
                end.
                
                if oJsonObject:has("error_text")
                then return oJsonObject:getCharacter("error_text").

                if oJsonObject:has("path")
                then do:
                    oPath = oJsonObject:GetJsonObject("path").
                    cNames = oPath:GetNames().
                    return oPath:getCharacter(cNames[1]).
                end.
                
                if oJsonObject:has("message")
                then return oJsonObject:getCharacter("message").
                
                message string(oJsonObject:GetJsonText()) view-as alert-box.
                
            end.
        end.
        return "".
        
        finally:
            if valid-object(oJsonObject) then delete object oJsonObject.
            if valid-object(oBody)       then delete object oBody.            
            if valid-object(oPath)       then delete object oPath.            
        end finally.
    end method.

    method protected char _calcRequestBodyHash(pcBody as longchar): 
        def var rawHashCode as raw no-undo.
        def var cHashCode as char no-undo.
        rawHashCode = MESSAGE-DIGEST("SHA-256", pcBody).
        cHashCode = string(rawHashCode).
        cHashCode = substr(cHashCode, 7).
        return string(cHashCode).
    end method.

    method public logical unblockCard( input pcCardId as character, input pcAuditUser as character, output TABLE for ttCard ):
        def var oRequestJson as JsonObject no-undo.
        def var oResponseJson as JsonObject no-undo.
        def var oResponse as IHttpResponse no-undo.
        def var lDumpEnabled as log no-undo init false.
        def var cEndpointName as char no-undo init "unblockCard".
        
        oRequestJson = new JsonObject().
        empty temp-table ttCard.        
        
        lDumpEnabled = _isDumpEnabledFor(cEndpointName).
        if lDumpEnabled then _dump(cEndpointName, "request", oRequestJson).
        oResponse = _executeRequest("PATCH", subst("/v1/cards/&1/unblock", pcCardId), pcAuditUser, oRequestJson).

        if type-of(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject")
        then do:
            oResponseJson = cast(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject").
            if lDumpEnabled then _dump(cEndpointName, "response", oResponseJson).

            _parseCard(oResponseJson:GetJsonObject("card")).
            return true.
        end.
        undo, throw new AppError(subst("Failed to unblockCard: unsupported response type: &1", oResponse:entity:getclass ():typeName)).

        finally:
            if valid-object(oRequestJson)   then delete object oRequestJson.
            if valid-object(oResponseJson)  then delete object oResponseJson.
            if valid-object(oResponse)      then delete object oResponse.            
        end finally.
    end method.

    method public logical unenrolCardFrom3Dsecure( input pcCardId as character, input pcAuditUser as character, output TABLE for ttCard ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED", 0).

    end method.

    method public logical update3DsecuritySettings( input pcCardId as character, input pcType as character, input pcMobile as character, input pcLanguageCode as character, input pcPassword as character, input pcAuditUser as character, output TABLE for ttCard ):
        def var oRequestJson as JsonObject no-undo.
        def var oResponseJson as JsonObject no-undo.
        def var oResponse as IHttpResponse no-undo.
        def var lDumpEnabled as log no-undo init false.
        def var cEndpointName as char no-undo init "update3DsecuritySettings".
        
        if not pcCardId > ""
        then undo, throw new AppError("Provide card_id!", 0).
        if not pcType > ""
        then undo, throw new AppError("Provide sec_3ds_type!", 0).
        if not pcMobile > ""
        then undo, throw new AppError("Provide sec_3ds_mobile!", 0).
        if not pcPassword > ""
        then undo, throw new AppError("Provide sec_3ds_password!", 0).
        if not pcLanguageCode > ""
        then undo, throw new AppError("Provide sec_3ds_language_code!", 0).
        
        oRequestJson = new JsonObject().
        oRequestJson:add("type", pcType).
        oRequestJson:add("mobile", pcMobile).
        oRequestJson:add("language_code", pcLanguageCode).
        oRequestJson:add("password", pcPassword).
        
        empty temp-table ttCardRequest.
        empty temp-table ttCard.        
        
        lDumpEnabled = _isDumpEnabledFor(cEndpointName).
        if lDumpEnabled then _dump(cEndpointName, "request", oRequestJson).
        oResponse = _executeRequest("PATCH", subst("/v1/cards/&1/3d-secure", pcCardId), pcAuditUser, oRequestJson).

        if type-of(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject")
        then do:
            oResponseJson = cast(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject").
            if lDumpEnabled then _dump(cEndpointName, "response", oResponseJson).

            _parseCard(oResponseJson:GetJsonObject("card")).
            return true.
        end.
        undo, throw new AppError(subst("Failed to update3DsecuritySettings: unsupported response type: &1", oResponse:entity:getclass ():typeName)).

        finally:
            if valid-object(oRequestJson)   then delete object oRequestJson.
            if valid-object(oResponseJson)  then delete object oResponseJson.
            if valid-object(oResponse)      then delete object oResponse.            
        end finally.
    end method.

    method public logical updateAccountCreditLimit( input pcAccountId as character, input pdNewLimit as decimal, input pdDescription as character, input pcAuditUser as character, output TABLE for ttAccount ):
        def var oRequestJson as JsonObject no-undo.
        def var oResponseJson as JsonObject no-undo.
        def var oResponse as IHttpResponse no-undo.
        def var lDumpEnabled as log no-undo init false.
        def var cEndpointName as char no-undo init "updateAccountCreditLimit".
       
        oRequestJson = new JsonObject().
        oRequestJson:Add("credit_limit", pdNewLimit).
        oRequestJson:Add("description",  pdDescription).
        empty temp-table ttCard.        
        
        lDumpEnabled = _isDumpEnabledFor(cEndpointName).
        if lDumpEnabled then _dump(cEndpointName, "request", oRequestJson).
        oResponse = _executeRequest("PATCH", subst("/v1/accounts/&1/credit-limit", pcAccountId), pcAuditUser, oRequestJson).

        if type-of(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject")
        then do:
            oResponseJson = cast(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject").
            if lDumpEnabled then _dump(cEndpointName, "response", oResponseJson).

            _parseAccount(oResponseJson:GetJsonObject("account")).
            return true.
        end.
        undo, throw new AppError(subst("Failed to updateAccountCreditLimit: unsupported response type: &1", oResponse:entity:getclass ():typeName)).

        finally:
            if valid-object(oRequestJson)   then delete object oRequestJson.
            if valid-object(oResponseJson)  then delete object oResponseJson.
            if valid-object(oResponse)      then delete object oResponse.            
        end finally.
    end method.

    method public logical updateAccountLimits( input pcAccountId as character, input TABLE for ttAccountLimits, input pcAuditUser as character, output TABLE for ttAccount ):
        def var oRequestJson as JsonObject no-undo.
        def var oLimitsJson  as JsonObject no-undo.
        def var oResponseJson as JsonObject no-undo.
        def var oResponse as IHttpResponse no-undo.
        def var lDumpEnabled as log no-undo init false.
        def var cEndpointName as char no-undo init "updateAccountLimits".
        
        find ttAccountLimits no-error.
        if not available ttAccountLimits
        then undo, throw new AppError("Provide ttAccountLimits record!", 0).
        
        oRequestJson = new JsonObject().
        oLimitsJson = new JsonObject().
        oLimitsJson:add("daily_purchase",               ttAccountLimits.lim_daily_purchase).
        oLimitsJson:add("daily_withdrawal",             ttAccountLimits.lim_daily_withdrawal).
        oLimitsJson:add("daily_internet_purchase",      ttAccountLimits.lim_daily_internet_purchase).
        oLimitsJson:add("daily_contactless_purchase",   ttAccountLimits.lim_daily_contactless_purchase).
        oLimitsJson:add("monthly_purchase",             ttAccountLimits.lim_monthly_purchase).
        oLimitsJson:add("monthly_withdrawal",           ttAccountLimits.lim_monthly_withdrawal).
        oLimitsJson:add("monthly_internet_purchase",    ttAccountLimits.lim_monthly_internet_purchase).
        oLimitsJson:add("monthly_contactless_purchase", ttAccountLimits.lim_monthly_contactless_purchase).
        oRequestJson:add("limits", oLimitsJson).
        empty temp-table ttAccountRequest.
        empty temp-table ttAccount.        
        
        lDumpEnabled = _isDumpEnabledFor(cEndpointName).
        if lDumpEnabled then _dump(cEndpointName, "request", oRequestJson).
        oResponse = _executeRequest("PATCH", subst("/v1/accounts/&1/limits", pcAccountId), pcAuditUser, oRequestJson).

        if type-of(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject")
        then do:
            oResponseJson = cast(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject").
            if lDumpEnabled then _dump(cEndpointName, "response", oResponseJson).

            _parseAccount(oResponseJson:GetJsonObject("account")).
            return true.
        end.
        undo, throw new AppError(subst("Failed to updateAccountLimits: unsupported response type: &1", oResponse:entity:getclass ():typeName)).

        finally:
            if valid-object(oLimitsJson)    then delete object oLimitsJson.
            if valid-object(oRequestJson)   then delete object oRequestJson.
            if valid-object(oResponseJson)  then delete object oResponseJson.
            if valid-object(oResponse)      then delete object oResponse.            
        end finally.
    end method.

    method public logical updateAccountName( input pcAccountId as character, input pcNewName as character, input pcAuditUser as character, output TABLE for ttAccount ):
        def var oRequestJson as JsonObject no-undo.
        def var oResponseJson as JsonObject no-undo.
        def var oResponse as IHttpResponse no-undo.
        def var lDumpEnabled as log no-undo init false.
        def var cEndpointName as char no-undo init "updateAccountName".
        
        oRequestJson = new JsonObject().
        oRequestJson:Add("name",       pcNewName).
        empty temp-table ttCard.        
        
        lDumpEnabled = _isDumpEnabledFor(cEndpointName).
        if lDumpEnabled then _dump(cEndpointName, "request", oRequestJson).
        oResponse = _executeRequest("PATCH", subst("/v1/accounts/&1/name", pcAccountId), pcAuditUser, oRequestJson).

        if type-of(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject")
        then do:
            oResponseJson = cast(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject").
            if lDumpEnabled then _dump(cEndpointName, "response", oResponseJson).

            _parseAccount(oResponseJson:GetJsonObject("account")).
            return true.
        end.
        undo, throw new AppError(subst("Failed to updateAccountName: unsupported response type: &1", oResponse:entity:getclass ():typeName)).

        finally:
            if valid-object(oRequestJson)   then delete object oRequestJson.
            if valid-object(oResponseJson)  then delete object oResponseJson.
            if valid-object(oResponse)      then delete object oResponse.            
        end finally.
    end method.

    method public logical updateCardLimits( input pcCardId as character, input TABLE for ttCardLimits, input pcAuditUser as character, output TABLE for ttCard ):
        def var oRequestJson as JsonObject no-undo.
        def var oLimitsJson  as JsonObject no-undo.
        def var oResponseJson as JsonObject no-undo.
        def var oResponse as IHttpResponse no-undo.
        def var lDumpEnabled as log no-undo init false.
        def var cEndpointName as char no-undo init "updateCardLimits".
        
        find ttCardLimits no-error.
        if not available ttCardLimits
        then undo, throw new AppError("Provide ttCardLimits record!", 0).
        
        oRequestJson = new JsonObject().
        oLimitsJson = new JsonObject().
        oLimitsJson:add("daily_purchase",                   ttCardLimits.lim_daily_purchase).
        oLimitsJson:add("daily_withdrawal",                 ttCardLimits.lim_daily_withdrawal).
        oLimitsJson:add("daily_internet_purchase",          ttCardLimits.lim_daily_internet_purchase).
        oLimitsJson:add("daily_contactless_purchase",       ttCardLimits.lim_daily_contactless_purchase).
        oLimitsJson:add("monthly_purchase",                 ttCardLimits.lim_monthly_purchase).
        oLimitsJson:add("monthly_withdrawal",               ttCardLimits.lim_monthly_withdrawal).
        oLimitsJson:add("monthly_internet_purchase",        ttCardLimits.lim_monthly_internet_purchase).
        oLimitsJson:add("monthly_contactless_purchase",     ttCardLimits.lim_monthly_contactless_purchase).
        oLimitsJson:add("transaction_purchase",             ttCardLimits.lim_trn_purchase).
        oLimitsJson:add("transaction_withdrawal",           ttCardLimits.lim_trn_withdrawal).
        oLimitsJson:add("transaction_internet_purchase",    ttCardLimits.lim_trn_internet_purchase).
        oLimitsJson:add("transaction_contactless_purchase", ttCardLimits.lim_trn_contactless_purchase).
        oRequestJson:add("limits", oLimitsJson).
        
        empty temp-table ttCardLimits.
        empty temp-table ttCard.        
        
        lDumpEnabled = _isDumpEnabledFor(cEndpointName).
        if lDumpEnabled then _dump(cEndpointName, "request", oRequestJson).
        oResponse = _executeRequest("PATCH", subst("/v1/cards/&1/limits", pcCardId), pcAuditUser, oRequestJson).

        if type-of(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject")
        then do:
            oResponseJson = cast(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject").
            if lDumpEnabled then _dump(cEndpointName, "response", oResponseJson).

            _parseCard(oResponseJson:GetJsonObject("card")).
            return true.
        end.
        undo, throw new AppError(subst("Failed to updateCardLimits: unsupported response type: &1", oResponse:entity:getclass ():typeName)).

        finally:
            if valid-object(oLimitsJson)    then delete object oLimitsJson.
            if valid-object(oRequestJson)   then delete object oRequestJson.
            if valid-object(oResponseJson)  then delete object oResponseJson.
            if valid-object(oResponse)      then delete object oResponse.            
        end finally.
    end method.

    method public logical updateCardName( input pcCardId as character, input pcCardName as character, input pcAuditUser as character, output TABLE for ttCard ):
        def var oRequestJson as JsonObject no-undo.
        def var oResponseJson as JsonObject no-undo.
        def var oResponse as IHttpResponse no-undo.
        def var lDumpEnabled as log no-undo init false.
        def var cEndpointName as char no-undo init "updateCardName".
        
        oRequestJson = new JsonObject().
        oRequestJson:Add("name",       pcCardName).
        empty temp-table ttCard.        
        
        lDumpEnabled = _isDumpEnabledFor(cEndpointName).
        if lDumpEnabled then _dump(cEndpointName, "request", oRequestJson).
        oResponse = _executeRequest("PATCH", subst("/v1/cards/&1/name", pcCardId), pcAuditUser, oRequestJson).

        if type-of(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject")
        then do:
            oResponseJson = cast(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject").
            if lDumpEnabled then _dump(cEndpointName, "response", oResponseJson).

            _parseCard(oResponseJson:GetJsonObject("card")).
            return true.
        end.
        undo, throw new AppError(subst("Failed to updateCardName: unsupported response type: &1", oResponse:entity:getclass ():typeName)).

        finally:
            if valid-object(oRequestJson)   then delete object oRequestJson.
            if valid-object(oResponseJson)  then delete object oResponseJson.
            if valid-object(oResponse)      then delete object oResponse.            
        end finally.
    end method.

    method public logical updateCardSecurity( input pcCardId as character, input plContactlessEnabled as logical, input plWithdrawalEnabled as logical, input plInternetPurchaseEnabled as logical, input pcAuditUser as character, output TABLE for ttCard ):
        def var oRequestJson as JsonObject no-undo.
        def var oResponseJson as JsonObject no-undo.
        def var oResponse as IHttpResponse no-undo.
        def var lDumpEnabled as log no-undo init false.
        def var cEndpointName as char no-undo init "updateCardSecurity".
        
        oRequestJson = new JsonObject().
        oRequestJson:Add("contactless_enabled",       plContactlessEnabled).
        oRequestJson:Add("withdrawal_enabled",        plWithdrawalEnabled).
        oRequestJson:Add("internet_purchase_enabled", plInternetPurchaseEnabled).
        
        empty temp-table ttCard.        
        
        lDumpEnabled = _isDumpEnabledFor(cEndpointName).
        if lDumpEnabled then _dump(cEndpointName, "request", oRequestJson).
        oResponse = _executeRequest("PATCH", subst("/v1/cards/&1/security", pcCardId), pcAuditUser, oRequestJson).

        if type-of(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject")
        then do:
            oResponseJson = cast(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject").
            if lDumpEnabled then _dump(cEndpointName, "response", oResponseJson).

            _parseCard(oResponseJson:GetJsonObject("card")).
            return true.
        end.
        undo, throw new AppError(subst("Failed to updateCardSecurity: unsupported response type: &1", oResponse:entity:getclass ():typeName)).

        finally:
            if valid-object(oRequestJson)   then delete object oRequestJson.
            if valid-object(oResponseJson)  then delete object oResponseJson.
            if valid-object(oResponse)      then delete object oResponse.            
        end finally.
    end method.

    method public logical updatePerson( input-output TABLE for ttPerson, input pcAuditUser as character ):
        def var oRequestJson as JsonObject no-undo.
        def var oPersonJson as JsonObject no-undo.
        def var oResponseJson as JsonObject no-undo.
        def var oResponse as IHttpResponse no-undo.
        def var lDumpEnabled as log no-undo init false.
        def var cEndpointName as char no-undo init "updatePerson".
        
        find ttPerson no-error.
        if not available ttPerson
        then undo, throw new AppError("Provide ttPerson record!", 0).
        
        if ttPerson.id =? or ttPerson.id = ""
        then undo, throw new AppError("Provide personID!", 0).
        
        oPersonJson = new JsonObject().
        oPersonJson:add("id",                     ttPerson.id).
        oPersonJson:add("personal_number",        ttPerson.personal_number).
        oPersonJson:add("personal_number_issuer", ttPerson.personal_number_issuer).
        oPersonJson:add("title",                  ttPerson.title_name).
        oPersonJson:add("first_name",             ttPerson.first_name).
        oPersonJson:add("middle_name",            ttPerson.middle_name).
        oPersonJson:add("last_name",              ttPerson.last_name).
        oPersonJson:add("birth_date",             ttPerson.birth_date).
        oPersonJson:add("birth_country_code",     ttPerson.birth_country_code).
        oPersonJson:add("gender",                 caps(ttPerson.gender)).
        oPersonJson:add("mobile",                 ttPerson.mobile).
        oPersonJson:add("email",                  ttPerson.email).
        oPersonJson:add("external_id",            ttPerson.external_id).
        oPersonJson:add("residence_country_code", ttPerson.residence_country_code).
        oPersonJson:add("is_represented_by_someone_else", ttPerson.is_represented_by_someone_else).
        oPersonJson:add("is_beneficial_owner",   ttPerson.is_beneficial_owner).
        oPersonJson:add("is_politically_exposed_person", ttPerson.is_pep).
        oPersonJson:add("is_sanctions_related",          ttPerson.is_sanctions_related).
        oPersonJson:add("is_adverse_media_involved",     ttPerson.is_adverse_media_involved).
        oPersonJson:add("politically_exposed_person_explanation", ttPerson.pep_explanation).
        oPersonJson:add("business_relationship_purpose", ttPerson.business_relationship_purpose).
        oPersonJson:add("risk_profile",           ttPerson.risk_profile).
        oPersonJson:add("loyalty_number",         ttPerson.loyalty_number).
        oRequestJson = new JsonObject().
        oRequestJson:add("person", oPersonJson).
        
        lDumpEnabled = _isDumpEnabledFor(cEndpointName).
        if lDumpEnabled then _dump(cEndpointName, "request", oRequestJson).
        oResponse = _executeRequest("PUT", "/v1/persons/" + ttPerson.id, pcAuditUser, oRequestJson).
        empty temp-table ttPerson.        

        if type-of(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject")
        then do:
            oResponseJson = cast(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject").
            if lDumpEnabled then _dump(cEndpointName, "response", oResponseJson).

            _parsePerson(oResponseJson:GetJsonObject("person")).
            return true.
        end.
        undo, throw new AppError(subst("Failed to update person: unsupported response type: &1", oResponse:entity:getclass ():typeName)).

        finally:
            if valid-object(oPersonJson)    then delete object oPersonJson.
            if valid-object(oRequestJson)   then delete object oRequestJson.
            if valid-object(oResponseJson)  then delete object oResponseJson.
            if valid-object(oResponse)      then delete object oResponse.            
        end finally.
    end method.


    method protected character _toBase64(pcString as longchar):
        DEF VAR cEncoded AS char NO-UNDO.
        DEF VAR mAuth AS memptr NO-UNDO.
        
        copy-lob from pcString to mAuth.
        cEncoded = BASE64-ENCODE(mAuth).
        
        return cEncoded.
        
        finally:
            set-size(mAuth) = 0.            
        end finally.
    end method.

end class.