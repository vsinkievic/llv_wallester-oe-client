 
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

block-level on error undo, throw.

class wallester.WallesterApiClient implements WallesterApi: 

  {wallester/ttAccount.i}
  {wallester/ttAccountLimits.i}
  {wallester/ttAccountRequest.i}
  {wallester/ttCard.i}
  {wallester/ttCardLimits.i}
  {wallester/ttPerson.i}
  
//  def temp-table ttPersonCreateRequest no-undo 
////    field id                                     as char
//    field personal_number                        as char
//    field personal_number_issuer                 as char
//    field title_name                             as char serialize-name "title" // Miss
//    field first_name                             as char
//    field middle_name                            as char
//    field last_name                              as char
//    field birth_date                             as date
//    field birth_country_code                     as char
//    field gender                                 as char // MALE / FEMALE
//    field mobile                                 as char
//    field email                                  as char
//    field external_id                            as char
//    field residence_country_code                 as char
//    field is_represented_by_someone_else         as logical
//    field is_beneficial_owner                    as logical
//    field is_pep                                 as logical serialize-name "is_politically_exposed_person"
//    field pep_explanation                        as char    serialize-name "politically_exposed_person_explanation"
//    field business_relationship_purpose          as char
//    field risk_profile                           as char // High
//    field loyalty_number                         as char
////    field created_at                             as datetime
////    field updated_at                             as datetime
////    field deactivated_at                         as datetime
//    .
      
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
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED", 0).

    end method.

    method public logical createAccount( input TABLE for ttAccountRequest, input pcAuditUser as character, output TABLE for ttAccount ):
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
//        create ttPersonCreateRequest.
//        buffer-copy ttPerson to ttPersonCreateRequest.
        
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
    //    oPersonJson:Read(buffer ttPersonCreateRequest:handle).
        oRequestJson = new JsonObject().
        oRequestJson:add("person", oPersonJson).
        empty temp-table ttPerson.        
        
        oResponse = _executeRequest("POST", "/v1/persons", pcAuditUser, oRequestJson).

        if type-of(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject")
        then do:
            oResponseJson = cast(oResponse:Entity, "Progress.Json.ObjectModel.JsonObject").
            _parsePerson(oResponseJson:GetJsonObject("person")).

// for debug only
                def var cResponseString as longchar no-undo.                                    
                oResponseJson:Write(cResponseString, true).                                       
                copy-lob from cResponseString to file "target/createPerson-response.json".
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
        ttPerson.title_name             = poJson:getCharacter("title").
        ttPerson.first_name             = poJson:getCharacter("first_name").
        ttPerson.middle_name            = poJson:getCharacter("middle_name").
        ttPerson.last_name              = poJson:getCharacter("last_name").
        ttPerson.birth_date             = poJson:GetDate("birth_date").
        ttPerson.birth_country_code     = poJson:GetCharacter("birth_country_code").
        ttPerson.gender                 = poJson:getCharacter("gender").
        ttPerson.mobile                 = poJson:getCharacter("mobile").
        ttPerson.email                  = poJson:getCharacter("email").
        ttPerson.external_id            = poJson:getCharacter("external_id").
        ttPerson.residence_country_code = poJson:getCharacter("residence_country_code").
        ttPerson.is_represented_by_someone_else = poJson:GetLogical("is_represented_by_someone_else").
        ttPerson.is_beneficial_owner    = poJson:GetLogical("is_beneficiary_owner").
        ttPerson.is_pep                 = poJson:getLogical("is_politically_exposed_person").
        ttPerson.pep_explanation        = poJson:getCharacter("politically_exposed_person_explanation").
        ttPerson.business_relationship_purpose = poJson:getCharacter("business_relationship_purpose").
        ttPerson.risk_profile           = poJson:getCharacter("risk_profile").
        ttPerson.loyalty_number         = poJson:getCharacter("loyalty_number").
        ttPerson.created_at             = poJson:GetDatetime("created_at").
        ttPerson.updated_at             = poJson:getDatetime("updated_at").
        ttPerson.deactivated_at         = poJson:getDatetime("deactivated_at").
        
        finally:
            if valid-object(poJson) then delete object poJson.            
        end finally.
    end method.

    method public logical getAccountByExternalId( input pcExternalId as character, input pcAuditUser as character, output TABLE for ttAccount ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED", 0).

    end method.

    method public logical getAccountById( input pcAccountId as character, input pcAuditUser as character, output TABLE for ttAccount ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED", 0).

    end method.

    method public logical getAccountCards( input pcAccountId as character, input pcAuditUser as character, output TABLE for ttCard ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED", 0).

    end method.

    method public logical getPersonAccounts( input pcPersonId as character, input pcAuditUser as character, output TABLE for ttAccount ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED", 0).

    end method.

    method public logical getPersonByExternalId( input pcExternalId as character, input pcAuditUser as character, output TABLE for ttPerson ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED", 0).

    end method.

    method public logical getPersonById( input pcPersonID as character, input pcAuditUser as character, output TABLE for ttPerson ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED", 0).

    end method.

    method public logical getPersonCards( input pcPersonId as character, input pcAuditUser as character, output TABLE for ttCard ):
        
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
        
 //       message wallesterUrl + pcEndpointUrl view-as alert-box.
        case pcRequestType:
            when "POST" 
            then oRequest = RequestBuilder:Post(wallesterUrl + pcEndpointUrl, poRequestJson):AcceptJson()
                                          :ContentType("application/json; charset=UTF-8")
                                          :Request.
            when "PUT"  
            then oRequest = RequestBuilder:Put(wallesterUrl + pcEndpointUrl, poRequestJson):AcceptJson()
                                          :ContentType("application/json; charset=UTF-8")
                                          :Request.
            
            otherwise undo, throw new AppError(subst("Unsupported requestType=&1 for &2", poRequestJson, pcEndpointUrl), 0).
        end case.
        
        cRequestBody = poRequestJson:getJsonText().
        message string(cRequestBody) view-as alert-box title "Request JSON".
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
            end.
        end.
        else return "".
        
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

    method public logical updateAccountCreditLimit( input pcAccountId as character, input pdNewLimit as decimal, input pdDescription as character, input pcAuditUser as character, output TABLE for ttAccount ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED", 0).

    end method.

    method public logical updateAccountLimits( input pcAccountId as character, input TABLE for ttAccountLimits, input pcAuditUser as character, output TABLE for ttAccount ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED", 0).

    end method.

    method public logical updateAccountName( input pcAccountId as character, input pcNewName as character, input pcAuditUser as character, output TABLE for ttAccount ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED", 0).

    end method.

    method public logical updatePerson( input-output TABLE for ttPerson, input pcAuditUser as character ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED", 0).

    end method.

end class.