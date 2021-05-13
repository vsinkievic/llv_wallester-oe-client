 
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
using wallester.WallesterApi from propath.
using Progress.Json.ObjectModel.JsonArray from propath.

block-level on error undo, throw.

class wallester.WallesterApiClient implements WallesterApi: 

  {wallester/ttAccount.i}
  {wallester/ttAccountLimits.i}
  {wallester/ttAccountRequest.i}
  {wallester/ttCard.i}
  {wallester/ttCardLimits.i}
  {wallester/ttCardRequest.i}
  {wallester/ttPerson.i}
  
      
    define protected property wallesterUrl as char no-undo init "https://api-sandbox.wallester.eu"
    get.
    set.
    
    define protected property latekoSecret as char no-undo init "x7BeGHe1uFllio$GcqZbSyjN9oWlM4CTD$2s9@yUXNuI0Cbh6Z674tE0vQb1qiIC"
    get.
    set.
    
    define protected property issuerId as char no-undo init "29a6012b-785e-4579-97a4-38b5ade0064c"
    get.
    set.
    
    define protected property audienceId as char no-undo init "da2b9d46-de76-498e-8746-471e8dd3d120"
    get.
    set.
    
    define protected property productCode as char no-undo init "LATEKOLV"
    get.
    set.
    
    define protected property auditSourceType as char no-undo init "Backend" // valid values: Backend or SelfService
    get.
    set.
    
    def protected var moSourceTypeHeader as HttpHeader no-undo.
    def protected var moProductCodeHeader as HttpHeader no-undo.
    
    method public logical activateCard( input pcPersonId as character, input pcLastFourDigits as character, input pcAuditUser as character, output TABLE for ttCard ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED", 0).

    end method.

    method public logical adjustAccountBalance( input pcAccountId as character, input pcExternalId as character, input pdAmount as decimal, input pcDescription as character, input pcAuditUser as character, output TABLE for ttAccount ):
        def var oRequestJson as JsonObject no-undo.
        def var oResponseJson as JsonObject no-undo.
        def var oResponse as IHttpResponse no-undo.
        
        oRequestJson = new JsonObject().
        oRequestJson:add("external_id", pcExternalId).
        oRequestJson:add("amount",      pdAmount).
        oRequestJson:add("description", pcDescription).
        empty temp-table ttAccount.        
        
        oResponse = _executeRequest("PATCH", subst("/v1/accounts/&1/balance", pcAccountId), pcAuditUser, oRequestJson).

        if type-of(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject")
        then do:
            oResponseJson = cast(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject").
// for debug only
//                def var cResponseString as longchar no-undo.                                    
//                oResponseJson:Write(cResponseString, true).                                       
//                copy-lob from cResponseString to file "target/createAccount-response.json".

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

    method public logical blockCard( input pcCardId as character, input peBlockType as wallester.CardBlockType, input pcAuditUser as character, output TABLE for ttCard ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED", 0).

    end method.

    method public logical changePin( input pcCardId as character, input pcNewEncodedPin as character, input pcAuditUser as character, output TABLE for ttCard ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED", 0).

    end method.

    method public logical closeCard( input pcCardId as character, input peCloseReason as wallester.CardCloseReason, input pcAuditUser as character, output TABLE for ttCard ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED", 0).

    end method.

    method public logical createAccount( input TABLE for ttAccountRequest, input pcAuditUser as character, output TABLE for ttAccount ):
        def var oRequestJson as JsonObject no-undo.
        def var oLimitsJson  as JsonObject no-undo.
        def var oResponseJson as JsonObject no-undo.
        def var oResponse as IHttpResponse no-undo.
        
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
        empty temp-table ttAccountRequest.
        empty temp-table ttAccount.        
        
        oResponse = _executeRequest("POST", "/v1/accounts", pcAuditUser, oRequestJson).

        if type-of(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject")
        then do:
            oResponseJson = cast(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject").
// for debug only
//                def var cResponseString as longchar no-undo.                                    
//                oResponseJson:Write(cResponseString, true).                                       
//                copy-lob from cResponseString to file "target/createAccount-response.json".

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

    method public logical createCard( input TABLE for ttCardRequest, input pcAuditUser as character, output TABLE for ttCard ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED", 0).

    end method.

    method public logical createPerson( input-output TABLE for ttPerson, input pcAuditUser as character ):
        def var oRequestJson as JsonObject no-undo.
        def var oPersonJson as JsonObject no-undo.
        def var oResponseJson as JsonObject no-undo.
        def var oResponse as IHttpResponse no-undo.
        
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
        oPersonJson:add("politically_exposed_person_explanation", ttPerson.pep_explanation).
        oPersonJson:add("business_relationship_purpose", ttPerson.business_relationship_purpose).
        oPersonJson:add("risk_profile",           ttPerson.risk_profile).
        oPersonJson:add("loyalty_number",         ttPerson.loyalty_number).
        oRequestJson = new JsonObject().
        oRequestJson:add("person", oPersonJson).
        empty temp-table ttPerson.        
        
        oResponse = _executeRequest("POST", "/v1/persons", pcAuditUser, oRequestJson).

        if type-of(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject")
        then do:
            oResponseJson = cast(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject").
// for debug only
//                def var cResponseString as longchar no-undo.                                    
//                oResponseJson:Write(cResponseString, true).                                       
//                copy-lob from cResponseString to file "target/createPerson-response.json".

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
        create ttPerson.
        ttPerson.id = poJson:GetCharacter("id").
        ttPerson.personal_number = poJson:GetCharacter("personal_number").
        ttPerson.personal_number_issuer = poJson:getCharacter("personal_number_issuer").
        if poJson:has("title")
        then ttPerson.title_name             = poJson:getCharacter("title").
        ttPerson.first_name             = poJson:getCharacter("first_name").
        if poJson:has("middle_name")
        then ttPerson.middle_name            = poJson:getCharacter("middle_name").
        ttPerson.last_name              = poJson:getCharacter("last_name").
        ttPerson.birth_date             = poJson:GetDate("birth_date").
        ttPerson.birth_country_code     = poJson:GetCharacter("birth_country_code").
        ttPerson.gender                 = poJson:getCharacter("gender").
        ttPerson.mobile                 = poJson:getCharacter("mobile").
        ttPerson.email                  = poJson:getCharacter("email").
        ttPerson.external_id            = poJson:getCharacter("external_id").
        ttPerson.residence_country_code = poJson:getCharacter("residence_country_code").
        ttPerson.is_represented_by_someone_else = poJson:GetLogical("is_represented_by_someone_else").
        ttPerson.is_beneficial_owner    = poJson:GetLogical("is_beneficial_owner").
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
        
        create ttAccount.
        ttAccount.id                  = poJson:GetCharacter("id").
        ttAccount.person_id           = poJson:GetCharacter("person_id").
        ttAccount.external_id         = poJson:getCharacter("external_id").
        ttAccount.account_name        = poJson:getCharacter("name").
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


    method protected void _parseAccounts (poJson as JsonArray):
        def var oAccountJson as JsonObject no-undo.
        def var i as int no-undo.
        
        do i = 1 to poJson:Length:
            oAccountJson = poJson:GetJsonObject(i).
            _parseAccount(oAccountJson).
        end.
        
        finally:
            if valid-object(poJson)      then delete object poJson.   
            if valid-object(oAccountJson) then delete object oAccountJson.         
        end finally.
    end method.

    method protected void _parseCard (poJson as JsonObject):
        def var oLimitsJson as JsonObject no-undo.
        def var o3DsecureJson as JsonObject no-undo.
        def var oDeliveryJson as JsonObject no-undo.
        def var oSecurityJson as JsonObject no-undo.
        
        create ttCard.
        ttCard.id                  = poJson:GetCharacter("id").
        if poJson:has("predecessor_card_id")
        then ttCard.predecessor_card_id = poJson:GetCharacter("predecessor_card_id").
        ttCard.account_id          = poJson:getCharacter("account_id").
        ttCard.person_id           = poJson:GetCharacter("person_id").
        ttCard.external_id         = poJson:getCharacter("external_id").
        ttCard.card_type           = poJson:getCharacter("type").
        ttCard.card_name           = poJson:getCharacter("name").
        ttCard.masked_card_number  = poJson:getCharacter("masked_card_number").
        if (poJson:has("reference_number"))
        then ttCard.reference_number    = poJson:getCharacter("reference_number").
        ttCard.expiry_date         = poJson:GetDatetime("expiry_date").
        ttCard.card_status         = poJson:GetCharacter("status").    
        ttCard.embossing_name      = poJson:GetCharacter("embossing_name").
        ttCard.is_enrolled_for_3ds = poJson:getLogical("is_enrolled_for_3d_secure").
        ttCard.is_3ds_activated    = poJson:getLogical("is_card_3d_secure_activated").
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

        if poJson:has("3d_secure_settings")
        then do:
            o3DsecureJson = poJson:GetJsonObject("3d_secure_settings").
            ttCard.sec_3ds_type          = o3DsecureJson:GetCharacter("type").
            ttCard.sec_3ds_mobile        = o3DsecureJson:GetCharacter("mobile").
            ttCard.sec_3ds_language_code = o3DsecureJson:GetCharacter("language_code").
            ttCard.sec_3ds_password      = o3DsecureJson:GetCharacter("password").
        end.

        if poJson:has("delivery_address")
        then do:
            oDeliveryJson = poJson:GetJsonObject("delivery_address").
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

        if poJson:has("security")
        then do:
            oSecurityJson = poJson:GetJsonObject("security").
            ttCard.sec_contactless_enabled       = oSecurityJson:getLogical("contactless_enabled").
            ttCard.sec_widhdrawal_enabled        = oSecurityJson:getLogical("withdrawal_enabled").
            ttCard.sec_internet_purchase_enabled = oSecurityJson:getLogical("internet_purchase_enabled").
        end.

        finally:
            if valid-object(poJson)        then delete object poJson.   
            if valid-object(oLimitsJson)   then delete object oLimitsJson.         
            if valid-object(o3DsecureJson) then delete object o3DsecureJson.         
            if valid-object(oDeliveryJson) then delete object oDeliveryJson.         
            if valid-object(oSecurityJson) then delete object oSecurityJson.         
        end finally.
    end method.

    method public logical enrolCardFor3Dsecure( input pcCardId as character, input pcAuditUser as character, output TABLE for ttCard ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED", 0).

    end method.

    method public logical getAccountByExternalId( input pcExternalId as character, input pcAuditUser as character, output TABLE for ttAccount ):
        def var oResponseJson as JsonObject no-undo.
        def var oResponse as IHttpResponse no-undo.
        
        empty temp-table ttAccount.        
        
        oResponse = _executeRequest("GET", "/v1/accounts-by-external-id/" + pcExternalId, pcAuditUser).

        if type-of(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject")
        then do:
            oResponseJson = cast(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject").
// for debug only
//                def var cResponseString as longchar no-undo.                                    
//                oResponseJson:Write(cResponseString, true).                                       
//                copy-lob from cResponseString to file "target/getAccountByExternalId-response.json".

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
        
        empty temp-table ttAccount.        
        
        oResponse = _executeRequest("GET", "/v1/accounts/" + pcAccountId, pcAuditUser).

        if type-of(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject")
        then do:
            oResponseJson = cast(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject").
// for debug only
//                def var cResponseString as longchar no-undo.                                    
//                oResponseJson:Write(cResponseString, true).                                       
//                copy-lob from cResponseString to file "target/getAccountById-response.json".

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
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED", 0).

    end method.

    method public logical getAccounts( input-output TABLE for ttAccount, input pcAuditUser as character ):
        def var oRequestJson  as JsonObject no-undo.
        def var oIdsJson      as JsonArray no-undo.
        def var oResponseJson as JsonObject no-undo.
        def var oResponse as IHttpResponse no-undo.
        
        if not can-find(first ttAccount)
        then return true. // there is nothing to do.
        
        oIdsJson = new JsonArray().
        for each ttAccount: 
            oIdsJson:add(ttAccount.id).
        end.
        oRequestJson = new JsonObject().
        oRequestJson:add("ids", oIdsJson).
        
        empty temp-table ttAccount.        
        
        oResponse = _executeRequest("POST", "/v1/accounts-by-ids", pcAuditUser, oRequestJson).

        if type-of(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject")
        then do:
            oResponseJson = cast(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject").
// for debug only
//                def var cResponseString as longchar no-undo.                                    
//                oResponseJson:Write(cResponseString, true).                                       
//                copy-lob from cResponseString to file "target/getAccounts-response.json".

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

    method public logical getCardByExternalId( input pcCardId as character, input pcAuditUser as character, output TABLE for ttCard ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED", 0).

    end method.

    method public logical getCardById( input pcCardId as character, input pcAuditUser as character, output TABLE for ttCard ):
        def var oResponseJson as JsonObject no-undo.
        def var oResponse as IHttpResponse no-undo.
        
        empty temp-table ttAccount.        
        
        oResponse = _executeRequest("GET", "/v1/cards/" + pcCardId, pcAuditUser).

        if type-of(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject")
        then do:
            oResponseJson = cast(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject").
// for debug only
                def var cResponseString as longchar no-undo.                                    
                oResponseJson:Write(cResponseString, true).                                       
                copy-lob from cResponseString to file "target/getCardById-response.json".

            _parseCard(oResponseJson:GetJsonObject("card")).
            return true.
        end.
        undo, throw new AppError(subst("Failed to get card by ID: unsupported response type: &1", oResponse:entity:getclass ():typeName)).

        finally:
            if valid-object(oResponseJson)  then delete object oResponseJson.
            if valid-object(oResponse)      then delete object oResponse.            
        end finally.
    end method.

    method public logical getListOfCards( input pcAuditUser as character, output TABLE for ttCard ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED", 0).

    end method.

    method public logical getPersonAccounts( input pcPersonId as character, input pcAuditUser as character, output TABLE for ttAccount ):
        def var oResponseJson as JsonObject no-undo.
        def var oResponse as IHttpResponse no-undo.
        
        empty temp-table ttAccount.        
        
        oResponse = _executeRequest("GET", subst("/v1/persons/&1/accounts", pcPersonId), pcAuditUser).

        if type-of(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject")
        then do:
            oResponseJson = cast(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject").
// for debug only
//                def var cResponseString as longchar no-undo.                                    
//                oResponseJson:Write(cResponseString, true).                                       
//                copy-lob from cResponseString to file "target/getPersonAccounts-response.json".

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
        
        empty temp-table ttPerson.        
        
        oResponse = _executeRequest("GET", "/v1/persons-by-external-id/" + pcExternalId, pcAuditUser).

        if type-of(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject")
        then do:
            oResponseJson = cast(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject").
// for debug only
//                def var cResponseString as longchar no-undo.                                    
//                oResponseJson:Write(cResponseString, true).                                       
//                copy-lob from cResponseString to file "target/getPersonByExternalId-response.json".

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
        
        empty temp-table ttPerson.        
        
        oResponse = _executeRequest("GET", "/v1/persons/" + pcPersonID, pcAuditUser).

        if type-of(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject")
        then do:
            oResponseJson = cast(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject").
// for debug only
//                def var cResponseString as longchar no-undo.                                    
//                oResponseJson:Write(cResponseString, true).                                       
//                copy-lob from cResponseString to file "target/getPersonById-response.json".

            _parsePerson(oResponseJson:GetJsonObject("person")).
            return true.
        end.
        undo, throw new AppError(subst("Failed to get person by ID: unsupported response type: &1", oResponse:entity:getclass ():typeName)).

        finally:
            if valid-object(oResponseJson)  then delete object oResponseJson.
            if valid-object(oResponse)      then delete object oResponse.            
        end finally.
    end method.

    method public logical getPersonCards( input pcPersonId as character, input pcAuditUser as character, output TABLE for ttCard ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED", 0).

    end method.

    method public logical linkCardToAccount( input pcCardId as character, input pcAccountIs as character, input pcAuditUser as character, output TABLE for ttCard ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED", 0).

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
        def var cNames as char extent no-undo.
        
        if valid-object(poEntity) 
        then do: 
//            message poEntity:GetClass():TypeName view-as alert-box.
            if type-of(poEntity, "Progress.Json.ObjectModel.JsonObject")
            then do:
                oJsonObject = cast(poEntity, "Progress.Json.ObjectModel.JsonObject").
                message string(oJsonObject:GetJsonText()) view-as alert-box.
    
                if oJsonObject:Has("body") 
                then do:
                    oBody = oJsonObject:GetJsonObject("body").
                    cNames = oBody:GetNames().
                    return oBody:getCharacter(cNames[1]).
//                    return oJsonObject:GetCharacter("message").
                end.
                
                if oJsonObject:has("error_text")
                then return oJsonObject:getCharacter("error_text").
                
            end.
        end.
        return "".
        
        finally:
            if valid-object(oJsonObject) then delete object oJsonObject.
            if valid-object(oBody)       then delete object oBody.            
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
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED", 0).

    end method.

    method public logical unenrolCardFrom3Dsecure( input pcCardId as character, input pcAuditUser as character, output TABLE for ttCard ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED", 0).

    end method.

    method public logical update3DsecuritySettings( input pcCardId as character, input pcType as character, input pcMobile as character, input pcLanguageCode as character, input pcPassword as character, input pcAuditUser as character, output TABLE for ttCard ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED", 0).

    end method.

    method public logical updateAccountCreditLimit( input pcAccountId as character, input pdNewLimit as decimal, input pdDescription as character, input pcAuditUser as character, output TABLE for ttAccount ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED", 0).

    end method.

    method public logical updateAccountLimits( input pcAccountId as character, input TABLE for ttAccountLimits, input pcAuditUser as character, output TABLE for ttAccount ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED", 0).

    end method.

    method public logical updateAccountName( input pcAccountId as character, input pcNewName as character, input pcAuditUser as character, output TABLE for ttAccount ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED", 0).

    end method.

    method public logical updateCardLimits( input pcCardId as character, input TABLE for ttCardLimits, input pcAuditUser as character, output TABLE for ttCard ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED", 0).

    end method.

    method public logical updateCardName( input pcCardId as character, input pcCardName as character, input pcAuditUser as character, output TABLE for ttCard ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED", 0).

    end method.

    method public logical updateCardSecurity( input pcCardId as character, input plContactlessEnabled as logical, input plWithdrawalEnabled as logical, input plInternetPurchaseEnabled as logical, input pcAuditUser as character, output TABLE for ttCard ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED", 0).

    end method.

    method public logical updatePerson( input-output TABLE for ttPerson, input pcAuditUser as character ):
        def var oRequestJson as JsonObject no-undo.
        def var oPersonJson as JsonObject no-undo.
        def var oResponseJson as JsonObject no-undo.
        def var oResponse as IHttpResponse no-undo.
        
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
        oPersonJson:add("politically_exposed_person_explanation", ttPerson.pep_explanation).
        oPersonJson:add("business_relationship_purpose", ttPerson.business_relationship_purpose).
        oPersonJson:add("risk_profile",           ttPerson.risk_profile).
        oPersonJson:add("loyalty_number",         ttPerson.loyalty_number).
        oRequestJson = new JsonObject().
        oRequestJson:add("person", oPersonJson).
        
        oResponse = _executeRequest("PUT", "/v1/persons/" + ttPerson.id, pcAuditUser, oRequestJson).
        empty temp-table ttPerson.        

        if type-of(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject")
        then do:
            oResponseJson = cast(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject").
// for debug only
//                def var cResponseString as longchar no-undo.                                    
//                oResponseJson:Write(cResponseString, true).                                       
//                copy-lob from cResponseString to file "target/updatePerson-response.json".

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

end class.