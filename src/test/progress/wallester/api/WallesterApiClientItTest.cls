 
 /*------------------------------------------------------------------------
    File        : WallesterApiClientItTest
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : vsink_000
    Created     : Wed Apr 14 18:45:10 EEST 2021
    Notes       : 
  ----------------------------------------------------------------------*/


block-level on error undo, throw.

using OpenEdge.Core.Assert from propath.
using wallester.api.WallesterApi from propath.
using wallester.api.WallesterApiClient from propath.
using wallester.api.CardBlockType from propath.
using wallester.api.CardCloseReason from propath.
using common.jwt.JwtTokenConverter from propath.

class wallester.api.WallesterApiClientItTest:

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
  {wallester/api/ttReservedBalance.i}
      
    def var api as WallesterApi no-undo.
    def var isOK as log no-undo.
    def var auditUser as char no-undo init "testUser".
    
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
        
    constructor public WallesterApiClientItTest (  ):
        super ().
        
        def var oClient as WallesterApiClient no-undo.
        oClient = new WallesterApiClient("https://api-sandbox.wallester.eu", "x7BeGHe1uFllio$GcqZbSyjN9oWlM4CTD$2s9@yUXNuI0Cbh6Z674tE0vQb1qiIC").   
        oClient:issuerId = "29a6012b-785e-4579-97a4-38b5ade0064c".
        oClient:audienceId = "da2b9d46-de76-498e-8746-471e8dd3d120".
 
//        oClient = new WallesterApiClient("https://api.wallester.eu", "AJfqYNM7Sby+ydD!PgMd=MDELCmuu!LVRxY+#*5aSV@D9jAjGgGK&8uEYPAchDNp").   
//        oClient:issuerId = "7fd38a91-3ea2-41e9-a052-7ae7409112de".
//        oClient:audienceId = "d3326f48-ba65-44c1-860e-6a7bdbc400d8".
 
 
        oClient:productCode = "LATEKOLV".
        oClient:auditSourceType = "Backend".   
        oClient:dumpDirectory = "target/dump".
        oClient:dumpEndpoints = "all".
          
        api = oClient.
    end constructor.

    
    /*------------------------------------------------------------------------------
            Purpose:                                                                        
            Notes:                                                                        
    ------------------------------------------------------------------------------*/

    @Before.
    method public void setUpBeforeClass(  ):
        
        return.

    end method.
    
    @Test.
    method public void dummyTest():
        // do nothing
    end method.
    
    /*------------------------------------------------------------------------------
            Purpose:                                                                        
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
   
    @Setup.
    method public void setUp(  ):
        
        isOk = ?.
        empty temp-table ttPerson.
        empty temp-table ttAccount.
        empty temp-table ttAccountRequest.
        empty temp-table ttCard.
        empty temp-table ttCardLimits.
        empty temp-table ttAccountLimits.
        empty temp-table ttStatementRequestParams.
        empty temp-table ttStmt.
        empty temp-table ttFile.
        dataset dsStatement:empty-dataset ().

    end method.
      
      
     
    

    
//    @Test.
//    method public void findCardsByReferenceAsUser(  ):  
//        def var client as SmartWsClient no-undo.
//        
//        client = new SmartWsClient(SMART_URL, "user", "user").        
//        Assert:IsTrue(client:findCardsByReference("123456789", output table ttToken)).
//        
//        output to "c:/temp/response-cards-by-ref.json" append.
//        for each ttToken: 
//            export ttToken.
//        end.
//        output close.
//    end method.



  //  @Test.
    method public void pingPongTest() :
        // given
        def var cResponse as char no-undo.
        
        // when
        do on error undo, throw:
            cResponse = api:ping("ping").
            
            catch ae as Progress.Lang.AppError :
                message ae:GetMessage(1) view-as alert-box error.        
            end catch.
        end.
        
        // then
        message string(cResponse) view-as alert-box.
    end method.
   
   
//   @Test.
    method public void createPersonTest():
       // given
       create ttPerson.
       ttPerson.personal_number = "AK20240315".
       ttPerson.personal_number_issuer = "LTU".
       ttPerson.title_name = "Ms.".
       ttPerson.first_name = "Testauskas".
       ttPerson.middle_name = "Middle".
       ttPerson.last_name = "Tester".
       ttPerson.birth_date = date(09, 19, 1999).
       ttPerson.birth_country_code = "LTU".
       ttPerson.gender = "MALE".
       ttPerson.mobile = "+37061495615".
       ttPerson.email = "valdemar@bpm-id.com".
       ttPerson.external_id = "person_AK20240315".
       ttPerson.residence_country_code = "LTU".
       ttPerson.is_represented_by_someone_else = false.
       ttPerson.is_beneficial_owner = true.
       ttPerson.is_pep = true.
       ttPerson.pep_explanation = "Testing political explanation".
//       ttPerson.business_relationship_purpose = "our business relation".
       ttPerson.risk_profile = "Medium".
//       ttPerson.loyalty_number = "loyalty_number".
       ttPerson.document_number = "docNr-1234".
       ttPerson.is_sanctions_related = false.
       ttPerson.is_adverse_media_involved = false.
       
       ttPerson.address_line1 = "addr 1".
       ttPerson.address_line2 = "addr 2".
       ttPerson.address_city  = "City".
       ttPerson.address_postal_code = "LT-08415".
       ttPerson.address_country_code = "LTU".
       ttPerson.expected_turnover = "From1501to3000".
       
       // when 
       isOk = api:createPerson(input-output table ttPerson, auditUser).
       
       // then
       Assert:IsTrue(isOk).
       temp-table ttPerson:write-json("file", "target/createPerson.json", true).
    end method.
 
//    @Test.
    method public void updatePersonTest():
       // given
       create ttPerson.
       ttPerson.id = "8682acac-b0d3-4402-8eb0-ebd74a73b3eb".
       ttPerson.personal_number = "AK20240315".
       ttPerson.personal_number_issuer = "LVA".
       ttPerson.title_name = "Ms.".
       ttPerson.first_name = "Testauskas-".
       ttPerson.middle_name = "Middle-".
       ttPerson.last_name = "Tester-".
       ttPerson.birth_date = date(10, 22, 1999).
       ttPerson.birth_country_code = "POL".
       ttPerson.gender = "FEMALE".
       ttPerson.mobile = "+37061411111".
       ttPerson.email = "valdemar_@bpm-id.com".
       ttPerson.external_id = "person_AK20240315-".
       ttPerson.residence_country_code = "CZE".
       ttPerson.is_represented_by_someone_else = false.
       ttPerson.is_beneficial_owner = true.
       ttPerson.is_adverse_media_involved = true.
       ttPerson.is_pep = false.
       ttPerson.pep_explanation = "Testing political explanation-".
//       ttPerson.business_relationship_purpose = "business relation_".
       ttPerson.risk_profile = "Low".
//       ttPerson.loyalty_number = "loyalty_number".
       ttPerson.document_number = "docNr-1234+".
       ttPerson.preferred_language_code = "ENG".
       ttPerson.expected_turnover = "From0to1500".
       
       ttPerson.address_line1 = "Addr 1-".
       ttPerson.address_line2 = "Addr 2-".
       ttPerson.address_city  = "City-".
       ttPerson.address_postal_code = "LT-8415".
       ttPerson.address_country_code = "NOR".
       
       // when 
       isOk = api:updatePerson(input-output table ttPerson, auditUser).
       
       // then
       Assert:IsTrue(isOk).
       temp-table ttPerson:write-json("file", "target/updatePersonTest.json", true).
    end method.
    
    
//    @Test.
    method public void getPersonById():
        // given
        
        // when
        isOk = api:getPersonById("8682acac-b0d3-4402-8eb0-ebd74a73b3eb", auditUser, output table ttPerson).
        
        // then
        Assert:isTrue(isOk).
        temp-table ttPerson:write-json("file", "target/getPersonById.json", true).
        
    end method.
    
//    @Test.
    method public void getEncryptedCardNumber():
        // given
        def var cPublicKey as char.
        cPublicKey = "-----BEGIN PUBLIC KEY-----"
             + "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAx5KYjTuXKSe3bAaYCHhP"
             + "QDVOoNfHyfZ7TLEoC0GVmk1TFHpTcYeJT5PKMp44HwurXugKe4cVsrtl30twZIgR"
             + "oBF/7IUFUsxSDoFOBdmvIHcrk/X1qsjM9VV6Rl3tPu8pdl23IrI1f3NVpZA+Kgm2"
             + "CL/bRQlUoi86jhDzSAa4xE6zNcGGFn0fu/B6MBh+o/vgtap+kHwd0NxTAQSJk9yS"
             + "NAXJlHDeyy/yhrfvGiT1Wb7Bqd48fQJQXVvWrsImex71xreEuFY75mSyzvAJfPFp"
             + "eFqePRVuH7dbuSo55hYVeRLh+nawdoQTvTzitHZPQxVo7xMfdsES+b1lQWzzE3bq"
             + "cwIDAQAB"
             + "-----END PUBLIC KEY-----".
             
        cPublicKey = "LS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS0KTUlJQklqQU5CZ2txaGtpRzl3MEJBUUVGQUFPQ0FROEFNSUlCQ2dLQ0FRRUF4NUtZalR1WEtTZTNiQWFZQ0hoUApRRFZPb05mSHlmWjdUTEVvQzBHVm1rMVRGSHBUY1llSlQ1UEtNcDQ0SHd1clh1Z0tlNGNWc3J0bDMwdHdaSWdSCm9CRi83SVVGVXN4U0RvRk9CZG12SUhjcmsvWDFxc2pNOVZWNlJsM3RQdThwZGwyM0lySTFmM05WcFpBK0tnbTIKQ0wvYlJRbFVvaTg2amhEelNBYTR4RTZ6TmNHR0ZuMGZ1L0I2TUJoK28vdmd0YXAra0h3ZDBOeFRBUVNKazl5UwpOQVhKbEhEZXl5L3locmZ2R2lUMVdiN0JxZDQ4ZlFKUVhWdldyc0ltZXg3MXhyZUV1Rlk3NW1TeXp2QUpmUEZwCmVGcWVQUlZ1SDdkYnVTbzU1aFlWZVJMaCtuYXdkb1FUdlR6aXRIWlBReFZvN3hNZmRzRVMrYjFsUVd6ekUzYnEKY3dJREFRQUIKLS0tLS1FTkQgUFVCTElDIEtFWS0tLS0t".
     //   cPublicKey = "TUlJQklqQU5CZ2txaGtpRzl3MEJBUUVGQUFPQ0FROEFNSUlCQ2dLQ0FRRUF4NUtZalR1WEtTZTNiQWFZQ0hoUApRRFZPb05mSHlmWjdUTEVvQzBHVm1rMVRGSHBUY1llSlQ1UEtNcDQ0SHd1clh1Z0tlNGNWc3J0bDMwdHdaSWdSCm9CRi83SVVGVXN4U0RvRk9CZG12SUhjcmsvWDFxc2pNOVZWNlJsM3RQdThwZGwyM0lySTFmM05WcFpBK0tnbTIKQ0wvYlJRbFVvaTg2amhEelNBYTR4RTZ6TmNHR0ZuMGZ1L0I2TUJoK28vdmd0YXAra0h3ZDBOeFRBUVNKazl5UwpOQVhKbEhEZXl5L3locmZ2R2lUMVdiN0JxZDQ4ZlFKUVhWdldyc0ltZXg3MXhyZUV1Rlk3NW1TeXp2QUpmUEZwCmVGcWVQUlZ1SDdkYnVTbzU1aFlWZVJMaCtuYXdkb1FUdlR6aXRIWlBReFZvN3hNZmRzRVMrYjFsUVd6ekUzYnEKY3dJREFRQUI=".
        def var cEncryptedCardNumber as char no-undo init "".
        
        // when
        cEncryptedCardNumber = api:getEncryptedCardNumber("19757104-e0a3-429d-9d04-a72ef951877a", cPublicKey, auditUser).
        
        // then
        Assert:isTrue(cEncryptedCardNumber > "").
        output to "target/getEncryptedCardNumber.txt".
        put unformatted cEncryptedCardNumber skip.
        output close.
        
        // toliau norint atkoduoti pranešimą reikia įvykdyti komandą
        // cat cardNumberMessage.txt | grep -v MESSAGE | base64 -d | openssl pkeyutl -decrypt -inkey yourPrivateKey.pem -pkeyopt rsa_padding_mode:oaep -pkeyopt rsa_oaep_label:436172644e756d626572 -pkeyopt rsa_oaep_md:sha256
        // here 436172644e756d626572  is hex form of "CardNumber"
        
    end method.

//    @Test.
    method public void getEncryptedCardPin():
        // given
        def var cPublicKey as char.
        cPublicKey = "-----BEGIN PUBLIC KEY-----"
             + "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAx5KYjTuXKSe3bAaYCHhP"
             + "QDVOoNfHyfZ7TLEoC0GVmk1TFHpTcYeJT5PKMp44HwurXugKe4cVsrtl30twZIgR"
             + "oBF/7IUFUsxSDoFOBdmvIHcrk/X1qsjM9VV6Rl3tPu8pdl23IrI1f3NVpZA+Kgm2"
             + "CL/bRQlUoi86jhDzSAa4xE6zNcGGFn0fu/B6MBh+o/vgtap+kHwd0NxTAQSJk9yS"
             + "NAXJlHDeyy/yhrfvGiT1Wb7Bqd48fQJQXVvWrsImex71xreEuFY75mSyzvAJfPFp"
             + "eFqePRVuH7dbuSo55hYVeRLh+nawdoQTvTzitHZPQxVo7xMfdsES+b1lQWzzE3bq"
             + "cwIDAQAB"
             + "-----END PUBLIC KEY-----".
             
        cPublicKey = "LS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS0KTUlJQklqQU5CZ2txaGtpRzl3MEJBUUVGQUFPQ0FROEFNSUlCQ2dLQ0FRRUF4NUtZalR1WEtTZTNiQWFZQ0hoUApRRFZPb05mSHlmWjdUTEVvQzBHVm1rMVRGSHBUY1llSlQ1UEtNcDQ0SHd1clh1Z0tlNGNWc3J0bDMwdHdaSWdSCm9CRi83SVVGVXN4U0RvRk9CZG12SUhjcmsvWDFxc2pNOVZWNlJsM3RQdThwZGwyM0lySTFmM05WcFpBK0tnbTIKQ0wvYlJRbFVvaTg2amhEelNBYTR4RTZ6TmNHR0ZuMGZ1L0I2TUJoK28vdmd0YXAra0h3ZDBOeFRBUVNKazl5UwpOQVhKbEhEZXl5L3locmZ2R2lUMVdiN0JxZDQ4ZlFKUVhWdldyc0ltZXg3MXhyZUV1Rlk3NW1TeXp2QUpmUEZwCmVGcWVQUlZ1SDdkYnVTbzU1aFlWZVJMaCtuYXdkb1FUdlR6aXRIWlBReFZvN3hNZmRzRVMrYjFsUVd6ekUzYnEKY3dJREFRQUIKLS0tLS1FTkQgUFVCTElDIEtFWS0tLS0t".
     //   cPublicKey = "TUlJQklqQU5CZ2txaGtpRzl3MEJBUUVGQUFPQ0FROEFNSUlCQ2dLQ0FRRUF4NUtZalR1WEtTZTNiQWFZQ0hoUApRRFZPb05mSHlmWjdUTEVvQzBHVm1rMVRGSHBUY1llSlQ1UEtNcDQ0SHd1clh1Z0tlNGNWc3J0bDMwdHdaSWdSCm9CRi83SVVGVXN4U0RvRk9CZG12SUhjcmsvWDFxc2pNOVZWNlJsM3RQdThwZGwyM0lySTFmM05WcFpBK0tnbTIKQ0wvYlJRbFVvaTg2amhEelNBYTR4RTZ6TmNHR0ZuMGZ1L0I2TUJoK28vdmd0YXAra0h3ZDBOeFRBUVNKazl5UwpOQVhKbEhEZXl5L3locmZ2R2lUMVdiN0JxZDQ4ZlFKUVhWdldyc0ltZXg3MXhyZUV1Rlk3NW1TeXp2QUpmUEZwCmVGcWVQUlZ1SDdkYnVTbzU1aFlWZVJMaCtuYXdkb1FUdlR6aXRIWlBReFZvN3hNZmRzRVMrYjFsUVd6ekUzYnEKY3dJREFRQUI=".
        def var cEncryptedCardNumber as char no-undo init "".
        
        // when
        cEncryptedCardNumber = api:getEncryptedCardPin("19757104-e0a3-429d-9d04-a72ef951877a", cPublicKey, auditUser).
        
        // then
        Assert:isTrue(cEncryptedCardNumber > "").
        output to "target/getEncryptedCardPin.txt".
        put unformatted cEncryptedCardNumber skip.
        output close.
        
        // toliau norint atkoduoti pranešimą reikia įvykdyti komandą
        // cat cardNumberMessage.txt | grep -v MESSAGE | base64 -d | openssl pkeyutl -decrypt -inkey yourPrivateKey.pem -pkeyopt rsa_padding_mode:oaep -pkeyopt rsa_oaep_label:436172644e756d626572 -pkeyopt rsa_oaep_md:sha256
        // here 436172644e756d626572  is hex form of "CardNumber"
        
    end method.    

//    @Test.
    method public void getEncryptedCardCvv2():
        // given
        def var cPublicKey as char.
        cPublicKey = "-----BEGIN PUBLIC KEY-----"
             + "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAx5KYjTuXKSe3bAaYCHhP"
             + "QDVOoNfHyfZ7TLEoC0GVmk1TFHpTcYeJT5PKMp44HwurXugKe4cVsrtl30twZIgR"
             + "oBF/7IUFUsxSDoFOBdmvIHcrk/X1qsjM9VV6Rl3tPu8pdl23IrI1f3NVpZA+Kgm2"
             + "CL/bRQlUoi86jhDzSAa4xE6zNcGGFn0fu/B6MBh+o/vgtap+kHwd0NxTAQSJk9yS"
             + "NAXJlHDeyy/yhrfvGiT1Wb7Bqd48fQJQXVvWrsImex71xreEuFY75mSyzvAJfPFp"
             + "eFqePRVuH7dbuSo55hYVeRLh+nawdoQTvTzitHZPQxVo7xMfdsES+b1lQWzzE3bq"
             + "cwIDAQAB"
             + "-----END PUBLIC KEY-----".
             
        cPublicKey = "LS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS0KTUlJQklqQU5CZ2txaGtpRzl3MEJBUUVGQUFPQ0FROEFNSUlCQ2dLQ0FRRUF4NUtZalR1WEtTZTNiQWFZQ0hoUApRRFZPb05mSHlmWjdUTEVvQzBHVm1rMVRGSHBUY1llSlQ1UEtNcDQ0SHd1clh1Z0tlNGNWc3J0bDMwdHdaSWdSCm9CRi83SVVGVXN4U0RvRk9CZG12SUhjcmsvWDFxc2pNOVZWNlJsM3RQdThwZGwyM0lySTFmM05WcFpBK0tnbTIKQ0wvYlJRbFVvaTg2amhEelNBYTR4RTZ6TmNHR0ZuMGZ1L0I2TUJoK28vdmd0YXAra0h3ZDBOeFRBUVNKazl5UwpOQVhKbEhEZXl5L3locmZ2R2lUMVdiN0JxZDQ4ZlFKUVhWdldyc0ltZXg3MXhyZUV1Rlk3NW1TeXp2QUpmUEZwCmVGcWVQUlZ1SDdkYnVTbzU1aFlWZVJMaCtuYXdkb1FUdlR6aXRIWlBReFZvN3hNZmRzRVMrYjFsUVd6ekUzYnEKY3dJREFRQUIKLS0tLS1FTkQgUFVCTElDIEtFWS0tLS0t".
     //   cPublicKey = "TUlJQklqQU5CZ2txaGtpRzl3MEJBUUVGQUFPQ0FROEFNSUlCQ2dLQ0FRRUF4NUtZalR1WEtTZTNiQWFZQ0hoUApRRFZPb05mSHlmWjdUTEVvQzBHVm1rMVRGSHBUY1llSlQ1UEtNcDQ0SHd1clh1Z0tlNGNWc3J0bDMwdHdaSWdSCm9CRi83SVVGVXN4U0RvRk9CZG12SUhjcmsvWDFxc2pNOVZWNlJsM3RQdThwZGwyM0lySTFmM05WcFpBK0tnbTIKQ0wvYlJRbFVvaTg2amhEelNBYTR4RTZ6TmNHR0ZuMGZ1L0I2TUJoK28vdmd0YXAra0h3ZDBOeFRBUVNKazl5UwpOQVhKbEhEZXl5L3locmZ2R2lUMVdiN0JxZDQ4ZlFKUVhWdldyc0ltZXg3MXhyZUV1Rlk3NW1TeXp2QUpmUEZwCmVGcWVQUlZ1SDdkYnVTbzU1aFlWZVJMaCtuYXdkb1FUdlR6aXRIWlBReFZvN3hNZmRzRVMrYjFsUVd6ekUzYnEKY3dJREFRQUI=".
        def var cEncryptedCardNumber as char no-undo init "".
        
        // when
        cEncryptedCardNumber = api:getEncryptedCardCvv2("19757104-e0a3-429d-9d04-a72ef951877a", cPublicKey, auditUser).
        
        // then
        Assert:isTrue(cEncryptedCardNumber > "").
        output to "target/getEncryptedCardCvv2.txt".
        put unformatted cEncryptedCardNumber skip.
        output close.
        
        // toliau norint atkoduoti pranešimą reikia įvykdyti komandą
        // cat cardNumberMessage.txt | grep -v MESSAGE | base64 -d | openssl pkeyutl -decrypt -inkey yourPrivateKey.pem -pkeyopt rsa_padding_mode:oaep -pkeyopt rsa_oaep_label:436172644e756d626572 -pkeyopt rsa_oaep_md:sha256
        // here 436172644e756d626572  is hex form of "CardNumber"
        
    end method.    
 
//    @Test.
    method public void getEncryptedCard3dsPassword():
        // given
        def var cPublicKey as char.
        cPublicKey = "-----BEGIN PUBLIC KEY-----"
             + "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAx5KYjTuXKSe3bAaYCHhP"
             + "QDVOoNfHyfZ7TLEoC0GVmk1TFHpTcYeJT5PKMp44HwurXugKe4cVsrtl30twZIgR"
             + "oBF/7IUFUsxSDoFOBdmvIHcrk/X1qsjM9VV6Rl3tPu8pdl23IrI1f3NVpZA+Kgm2"
             + "CL/bRQlUoi86jhDzSAa4xE6zNcGGFn0fu/B6MBh+o/vgtap+kHwd0NxTAQSJk9yS"
             + "NAXJlHDeyy/yhrfvGiT1Wb7Bqd48fQJQXVvWrsImex71xreEuFY75mSyzvAJfPFp"
             + "eFqePRVuH7dbuSo55hYVeRLh+nawdoQTvTzitHZPQxVo7xMfdsES+b1lQWzzE3bq"
             + "cwIDAQAB"
             + "-----END PUBLIC KEY-----".
             
        cPublicKey = "LS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS0KTUlJQklqQU5CZ2txaGtpRzl3MEJBUUVGQUFPQ0FROEFNSUlCQ2dLQ0FRRUF4NUtZalR1WEtTZTNiQWFZQ0hoUApRRFZPb05mSHlmWjdUTEVvQzBHVm1rMVRGSHBUY1llSlQ1UEtNcDQ0SHd1clh1Z0tlNGNWc3J0bDMwdHdaSWdSCm9CRi83SVVGVXN4U0RvRk9CZG12SUhjcmsvWDFxc2pNOVZWNlJsM3RQdThwZGwyM0lySTFmM05WcFpBK0tnbTIKQ0wvYlJRbFVvaTg2amhEelNBYTR4RTZ6TmNHR0ZuMGZ1L0I2TUJoK28vdmd0YXAra0h3ZDBOeFRBUVNKazl5UwpOQVhKbEhEZXl5L3locmZ2R2lUMVdiN0JxZDQ4ZlFKUVhWdldyc0ltZXg3MXhyZUV1Rlk3NW1TeXp2QUpmUEZwCmVGcWVQUlZ1SDdkYnVTbzU1aFlWZVJMaCtuYXdkb1FUdlR6aXRIWlBReFZvN3hNZmRzRVMrYjFsUVd6ekUzYnEKY3dJREFRQUIKLS0tLS1FTkQgUFVCTElDIEtFWS0tLS0t".
     //   cPublicKey = "TUlJQklqQU5CZ2txaGtpRzl3MEJBUUVGQUFPQ0FROEFNSUlCQ2dLQ0FRRUF4NUtZalR1WEtTZTNiQWFZQ0hoUApRRFZPb05mSHlmWjdUTEVvQzBHVm1rMVRGSHBUY1llSlQ1UEtNcDQ0SHd1clh1Z0tlNGNWc3J0bDMwdHdaSWdSCm9CRi83SVVGVXN4U0RvRk9CZG12SUhjcmsvWDFxc2pNOVZWNlJsM3RQdThwZGwyM0lySTFmM05WcFpBK0tnbTIKQ0wvYlJRbFVvaTg2amhEelNBYTR4RTZ6TmNHR0ZuMGZ1L0I2TUJoK28vdmd0YXAra0h3ZDBOeFRBUVNKazl5UwpOQVhKbEhEZXl5L3locmZ2R2lUMVdiN0JxZDQ4ZlFKUVhWdldyc0ltZXg3MXhyZUV1Rlk3NW1TeXp2QUpmUEZwCmVGcWVQUlZ1SDdkYnVTbzU1aFlWZVJMaCtuYXdkb1FUdlR6aXRIWlBReFZvN3hNZmRzRVMrYjFsUVd6ekUzYnEKY3dJREFRQUI=".
        def var cEncryptedCardNumber as char no-undo init "".
        
        // when
        cEncryptedCardNumber = api:getEncryptedCard3dsPassword("19757104-e0a3-429d-9d04-a72ef951877a", cPublicKey, auditUser).
        
        // then
        Assert:isTrue(cEncryptedCardNumber > "").
        output to "target/getEncryptedCard3dsPassword.txt".
        put unformatted cEncryptedCardNumber skip.
        output close.
        
        // toliau norint atkoduoti pranešimą reikia įvykdyti komandą
        // cat cardNumberMessage.txt | grep -v MESSAGE | base64 -d | openssl pkeyutl -decrypt -inkey yourPrivateKey.pem -pkeyopt rsa_padding_mode:oaep -pkeyopt rsa_oaep_label:436172644e756d626572 -pkeyopt rsa_oaep_md:sha256
        // here 436172644e756d626572  is hex form of "CardNumber"
        
    end method.        
    
 //   @Test.
    method public void getPersonByExternalId():
        // given
        
        // when
        isOk = api:getPersonByExternalId("person_123", auditUser, output table ttPerson).
        
        // then
        Assert:isTrue(isOk).
        temp-table ttPerson:write-json("file", "target/getPersonByExternalId.json", true).
        
    end method.

//    @Test.
    method public void getPersonsByPersonalNumber():
        // given
        
        // when
        isOk = api:getPersonsByPersonalNumber("AK123456", auditUser, output table ttPerson).
        
        // then
        Assert:isTrue(isOk).
        temp-table ttPerson:write-json("file", "target/getPersonsByPersonalNumber.json", true).
        
    end method.
    
//    @Test.
    method public void createAccount():
        // given
        create ttAccountRequest.
        ttAccountRequest.person_id = "d4d87e9f-d556-404f-abbd-905f6473b868".
        ttAccountRequest.external_id = "XX-000002".
        ttAccountRequest.account_name  = "XX-000002".
        ttAccountRequest.currency_code = "EUR".
        ttAccountRequest.credit_limit = 150.
        ttAccountRequest.used_credit = 10.01.

        ttAccountRequest.lim_daily_purchase = 99.99.
        ttAccountRequest.lim_daily_withdrawal = 199.99.
        ttAccountRequest.lim_daily_internet_purchase = 19.99.
        ttAccountRequest.lim_daily_contactless_purchase = 9.99.
        ttAccountRequest.lim_monthly_purchase = 999.99.
        ttAccountRequest.lim_monthly_withdrawal = 899.99.
        ttAccountRequest.lim_monthly_internet_purchase = 799.99.
        ttAccountRequest.lim_monthly_contactless_purchase = 399.99.
                
        // when
        isOk = api:createAccount(table ttAccountRequest, auditUser, output table ttAccount).
        
        // then
        Assert:isTrue(isOK).
        temp-table ttAccount:write-json("file", "target/createAccount.json", true).
        
    end method.
    
    
   // @Test.
    method public void getAccountByExternalId():
        // given
        
        // when
        isOk = api:getAccountByExternalId("XX-000001", auditUser, output table ttAccount).
        
        // then
        Assert:isTrue(isOk).
        temp-table ttAccount:write-json("file", "target/getAccountByExternalId.json", true).
        
    end method.

   // @Test.
    method public void getAccount():
        // given
        
        // when
        isOk = api:getAccountById("ec74c22f-37e9-4cae-8113-f5766d5ef1e0", auditUser, output table ttAccount).
        
        // then
        Assert:isTrue(isOk).
        temp-table ttAccount:write-json("file", "target/getAccountById.json", true).
        
    end method.
 
 
   // @Test.
    method public void getPersonAccounts():
        // given
        
        // when
        isOk = api:getPersonAccounts("d4d87e9f-d556-404f-abbd-905f6473b868", auditUser, output table ttAccount).
        
        // then
        Assert:isTrue(isOk).
        temp-table ttAccount:write-json("file", "target/getPersonAccounts.json", true).
        
    end method.


 //   @Test.
    method public void getAccounts():
        // given
        create ttAccount. ttAccount.id = "45d21fd7-70b2-4600-ade1-976d5cd1b0a5".
        create ttAccount. ttAccount.id = "ec74c22f-37e9-4cae-8113-f5766d5ef1e0".
        
        // when
        isOk = api:getAccounts(input-output table ttAccount, auditUser).
        
        // then
        Assert:isTrue(isOk).
        temp-table ttAccount:write-json("file", "target/getAccounts.json", true).
        
    end method.    
    
 //   @Test.
    method public void adjustAccountBalance():
        // given
        def var dBalBefore as dec no-undo.
        def var dAmount as dec no-undo.
        api:getAccountById("ec74c22f-37e9-4cae-8113-f5766d5ef1e0", auditUser, output table ttAccount).
        temp-table ttAccount:write-json("file", "target/adjustAccountBalance-before.json", true).
        
        find ttAccount.
        dBalBefore = ttAccount.balance.
        
        // when
        dAmount = -150.00.
        isOk = api:adjustAccountBalance("ec74c22f-37e9-4cae-8113-f5766d5ef1e0", "A-005", dAmount, "test adjust", auditUser, output table ttAccount). 
        
        // then
        temp-table ttAccount:write-json("file", "target/adjustAccountBalance-after.json", true).
        Assert:IsTrue(isOk).
        find ttAccount.
        Assert:equals(dBalBefore + dAmount, ttAccount.balance).
        
    end method.

//   @Test.
    method public void createAccountAdjustment():
        // given
        def var dBalBefore as dec no-undo.
        def var dAmount as dec no-undo.
        api:getAccountById("ec74c22f-37e9-4cae-8113-f5766d5ef1e0", auditUser, output table ttAccount).
        temp-table ttAccount:write-json("file", "target/createAccountAdjustment-before.json", true).
        
        find ttAccount.
        dBalBefore = ttAccount.balance.
        
        // when
        dAmount = 15.00.
        isOk = api:createAccountAdjustment("ec74c22f-37e9-4cae-8113-f5766d5ef1e0", "A-006", dAmount, "test adjust", auditUser, output table ttAdj). 
        
        // then
        temp-table ttAdj:write-json("file", "target/createAccountAdjustment.json", true).
        Assert:IsTrue(isOk).

        api:getAccountById("ec74c22f-37e9-4cae-8113-f5766d5ef1e0", auditUser, output table ttAccount).
        temp-table ttAccount:write-json("file", "target/createAccountAdjustment-after.json", true).
        
    end method.
    
  // @Test.
    method public void getCardById():
        // given
        message session:cpInternal skip session:cpstream skip. 
        //view-as alert-box.
        // when
        isOk = api:getCardById("cc7fb8ad-3230-4fb6-9089-1d304fa3ec22", auditUser, output table ttCard).
        
        // then
        temp-table ttCard:write-json("file", "target/getCardById.json", true).
        Assert:isTrue(isOK).
    end method.
    
//    @Test.
    method public void getCardByExternalId():
        // given
        
        // when
        isOk = api:getCardByExternalId("864923", auditUser, output table ttCard).
        
        // then
        temp-table ttCard:write-json("file", "target/getCardByExternalId.json", true).
        Assert:isTrue(isOK).
    end method.

//    @Test.
    method public void getAllCards():
        // given
        
        // when
        isOk = api:getAllCards(0, 1000, auditUser, output table ttCard).
        
        // then
        temp-table ttCard:write-json("file", "target/getAllCards.json", true).
        Assert:isTrue(isOK).
    end method.

//    @Test.
    method public void getAllAccounts():
        // given
        
        // when
        isOk = api:getAllAccounts(0, 1000, auditUser, output table ttAccount).
        
        // then
        temp-table ttAccount:write-json("file", "target/getAllAccounts.json", true).
        Assert:isTrue(isOK).
    end method.
    
//    @Test.
    method public void getAccountCards():
        // given
        
        // when
        isOk = api:getAccountCards("e10530c3-9db8-435f-a43f-ec9eb8489548", auditUser, output table ttCard).
        
        // then
        temp-table ttCard:write-json("file", "target/getAccountCards.json", true).
        Assert:isTrue(isOK).
    end method.
    
//    @Test.
    method public void getPersonCards():
        // given
        
        // when
        isOk = api:getPersonCards("e1123019-723e-4d6e-a215-f4981c479ec6", auditUser, output table ttCard).
        
        // then
        temp-table ttCard:write-json("file", "target/getPersonCards.json", true).
        Assert:isTrue(isOK).
    end method.    
    
 //  @Test.
    method public void createCard():
        // given
        create ttCardRequest.

  //      ttCardRequest.predecessor_card_id = .
        ttCardRequest.account_id = "ec74c22f-37e9-4cae-8113-f5766d5ef1e0".
        ttCardRequest.person_id = "d4d87e9f-d556-404f-abbd-905f6473b868".
        ttCardRequest.external_id = "".
        ttCardRequest.card_type = "ChipAndPin". // ChipAndPin, ChipAndPinAnonymous, Virtual
        ttCardRequest.card_name = "National symbols".
        ttCardRequest.personalization_product_code = "".
        ttCardRequest.expiry_days = 90. // 1....1825 - up to 5 years
        ttCardRequest.expiry_days_round = true.
        ttCardRequest.encrypted_pin = "".
        ttCardRequest.lim_daily_purchase = 99.99.
        ttCardRequest.lim_daily_withdrawal = 199.99.
        ttCardRequest.lim_daily_internet_purchase = 19.99.
        ttCardRequest.lim_daily_contactless_purchase = 9.99.
        ttCardRequest.lim_monthly_purchase = 999.99.
        ttCardRequest.lim_monthly_withdrawal = 899.99.
        ttCardRequest.lim_monthly_internet_purchase = 799.99.
        ttCardRequest.lim_monthly_contactless_purchase = 399.99.
        ttCardRequest.lim_trn_purchase = 88.88.
        ttCardRequest.lim_trn_withdrawal = 77.77.
        ttCardRequest.lim_trn_internet_purchase = 66.66.
        ttCardRequest.lim_trn_contactless_purchase = 55.55.
     //   ttCardRequest.sec_3ds_type = .
        ttCardRequest.sec_3ds_mobile = "+37061495615".
//        ttCardRequest.sec_3ds_language_code = .
        ttCardRequest.sec_3ds_password = "abcd1234".
//        ttCardRequest.delivery_company_name = .
        ttCardRequest.delivery_address1 = "aaa 10".
        ttCardRequest.delivery_address2 = "Žiermarių km.".
        ttCardRequest.delivery_postal_code = "01234".
        ttCardRequest.delivery_city        = "Žiežmariai".
        ttCardRequest.delivery_country_code = "LTU".
        ttCardRequest.delivery_dispatch_method = "StandardLatvianPostMail".
  //      ttCardRequest.delivery_phone = .   
        ttCardRequest.sec_contactless_enabled = yes.
        ttCardRequest.sec_withdrawal_enabled = yes.
        ttCardRequest.sec_internet_purchase_enabled = yes.

                
        // when
        isOk = api:createCard(table ttCardRequest, auditUser, output table ttCard).
        
        // then
        Assert:isTrue(isOK).
        temp-table ttCard:write-json("file", "target/createCard.json", true).
        
    end method.
    
      //  @Test.
    method public void createAnonymousCard():
        // given
        create ttCardRequest.

  //      ttCardRequest.predecessor_card_id = .
  //     ttCardRequest.account_id = "ec74c22f-37e9-4cae-8113-f5766d5ef1e0".
  //      ttCardRequest.person_id = "d4d87e9f-d556-404f-abbd-905f6473b868".
        ttCardRequest.account_id = ?.
        ttCardRequest.external_id = "".
        ttCardRequest.card_type = "ChipAndPinAnonymous". // ChipAndPin, ChipAndPinAnonymous, Virtual
        ttCardRequest.card_name = "".
        ttCardRequest.personalization_product_code = "".
        ttCardRequest.expiry_days = 90. // 1....1825 - up to 5 years
        ttCardRequest.expiry_days_round = true.
        ttCardRequest.encrypted_pin = "".
        ttCardRequest.lim_daily_purchase             =   77.99.
        ttCardRequest.lim_daily_withdrawal           =   77.99.
        ttCardRequest.lim_daily_internet_purchase    =   77.99.
        ttCardRequest.lim_daily_contactless_purchase =   77.99.
        ttCardRequest.lim_monthly_purchase             =    99.99.
        ttCardRequest.lim_monthly_withdrawal           =    99.99.
        ttCardRequest.lim_monthly_internet_purchase    =    99.99.
        ttCardRequest.lim_monthly_contactless_purchase =    99.99.
        ttCardRequest.lim_trn_purchase             =  44.99.
        ttCardRequest.lim_trn_withdrawal           =  44.99.
        ttCardRequest.lim_trn_internet_purchase    =  44.99.
        ttCardRequest.lim_trn_contactless_purchase =  44.99.
     //   ttCardRequest.sec_3ds_type = .
        ttCardRequest.sec_3ds_mobile = "+37061495615".
//        ttCardRequest.sec_3ds_language_code = .
        ttCardRequest.sec_3ds_password = "abcd1234".
//        ttCardRequest.delivery_company_name = .
//        ttCardRequest.delivery_address1 = "Ąžuolų gatvė 10".
        ttCardRequest.delivery_address1 = "Azuolu gatve 10".
 //       ttCardRequest.delivery_address2 = "Žiežmarių km.".
        ttCardRequest.delivery_postal_code = "01234".
//        ttCardRequest.delivery_city        = "Žiežmariai".
        ttCardRequest.delivery_city        = "Ziezmariai".
        ttCardRequest.delivery_country_code = "LVA".
 //       ttCardRequest.delivery_dispatch_method = "StandardLatvianPostMail".
  //      ttCardRequest.delivery_phone = .   
        ttCardRequest.sec_contactless_enabled = no.
        ttCardRequest.sec_withdrawal_enabled = no.
        ttCardRequest.sec_internet_purchase_enabled = no.

                
        // when
        isOk = api:createCard(table ttCardRequest, auditUser, output table ttCard).
        
        // then
        Assert:isTrue(isOK).
        temp-table ttCard:write-json("file", "target/createAnonymousCard.json", true).
        
    end method.
    
   // @Test.
    method public void createMultipleAnonymouseCards ():
        def var i as int no-undo.
        
        do i = 1 to 200:
            createAnonymous(string(i, "999")).
        end.
    end method.
    
    method private void createAnonymous(pcExternalId as char):
        empty temp-table ttCardRequest.
        
        create ttCardRequest.

  //      ttCardRequest.predecessor_card_id = .
  //     ttCardRequest.account_id = "ec74c22f-37e9-4cae-8113-f5766d5ef1e0".
  //      ttCardRequest.person_id = "d4d87e9f-d556-404f-abbd-905f6473b868".
        ttCardRequest.account_id = ?.
        ttCardRequest.external_id = pcExternalId.
        ttCardRequest.card_type = "ChipAndPinAnonymous". // ChipAndPin, ChipAndPinAnonymous, Virtual
        ttCardRequest.card_name = "".
        ttCardRequest.personalization_product_code = "".
        ttCardRequest.expiry_days = 90. // 1....1825 - up to 5 years
        ttCardRequest.expiry_days_round = true.
        ttCardRequest.encrypted_pin = "".
        ttCardRequest.lim_daily_purchase             = 2999.99.
        ttCardRequest.lim_daily_withdrawal           =  199.99.
        ttCardRequest.lim_daily_internet_purchase    = 2999.99.
        ttCardRequest.lim_daily_contactless_purchase =  149.99.
        ttCardRequest.lim_monthly_purchase             = 14999.99.
        ttCardRequest.lim_monthly_withdrawal           =   199.99.
        ttCardRequest.lim_monthly_internet_purchase    = 14999.99.
        ttCardRequest.lim_monthly_contactless_purchase =  4499.99.
        ttCardRequest.lim_trn_purchase             = 999.99.
        ttCardRequest.lim_trn_withdrawal           = 499.99.
        ttCardRequest.lim_trn_internet_purchase    = 699.99.
        ttCardRequest.lim_trn_contactless_purchase = 399.99.
     //   ttCardRequest.sec_3ds_type = .
        ttCardRequest.sec_3ds_mobile = "+37061495615".
//        ttCardRequest.sec_3ds_language_code = .
        ttCardRequest.sec_3ds_password = "abcd1234".
//        ttCardRequest.delivery_company_name = .
        ttCardRequest.delivery_address1 = "Ąžuolų gatvė 10".
 //       ttCardRequest.delivery_address2 = "Žiežmarių km.".
        ttCardRequest.delivery_postal_code = "01234".
        ttCardRequest.delivery_city        = "Žiežmariai".
        ttCardRequest.delivery_country_code = "LTU".
 //       ttCardRequest.delivery_dispatch_method = "StandardLatvianPostMail".
  //      ttCardRequest.delivery_phone = .   
        ttCardRequest.sec_contactless_enabled = no.
        ttCardRequest.sec_withdrawal_enabled = no.
        ttCardRequest.sec_internet_purchase_enabled = no.

                
        api:createCard(table ttCardRequest, auditUser, output table ttCard).
    end method.
    
  //  @Test.
    method public void activateCardByPersonId():
        // given
        
        // when
        isOk = api:activateCard("d4d87e9f-d556-404f-abbd-905f6473b868", "4883", auditUser, output table ttCard).
        
        // then 
        Assert:IsTrue(isOK).
        temp-table ttCard:write-json ("file", "target/activateCardByPersonId.json", true).
        
    end method.

  //  @Test.
    method public void activateCardById():
        // given
        
        // when
        isOk = api:activateCard("9f0444af-f09c-4831-abf8-26eb73651085", auditUser, output table ttCard).
        
        // then 
        Assert:IsTrue(isOK).
        temp-table ttCard:write-json ("file", "target/activateCardById.json", true).
        
    end method.
    
  //  @Test.
    method public void updateCardSecurity():
        // given
        def var lContactlessEnabled as log init true.
        def var lWithdrawalEnabled  as log init true.
        def var lInternetPurchaseEnabled as log init true.
        
        // when
        isOk = api:updateCardSecurity("9f0444af-f09c-4831-abf8-26eb73651085", 
                                      lContactlessEnabled, 
                                      lWithdrawalEnabled, 
                                      lInternetPurchaseEnabled, auditUser, output table ttCard).
                
        // then
        Assert:IsTrue(isOK).
        temp-table ttCard:write-json ("file", "target/updateCardSecurity.json", true).
    end method.
    
  //  @Test.
    method public void updateCardName():
        // given
        
        // when
        isOk = api:updateCardName("9f0444af-f09c-4831-abf8-26eb73651085", "main card", auditUser, output table ttCard).
                
        // then
        Assert:IsTrue(isOK).
        temp-table ttCard:write-json ("file", "target/updateCardName.json", true).
    end method.
    
//    @Test.
    method public void updateAccountName():
        // given
        
        // when
        isOk = api:updateAccountName("ec74c22f-37e9-4cae-8113-f5766d5ef1e0", "main account", auditUser, output table ttAccount).
                
        // then
        Assert:IsTrue(isOK).
        temp-table ttAccount:write-json ("file", "target/updateAccountName.json", true).
    end method.
    
    
//    @Test.
    method public void updateAccountCreditLimit():
        // given
        
        // when
        isOk = api:updateAccountCreditLimit("ec74c22f-37e9-4cae-8113-f5766d5ef1e0", 188.88, "test description", auditUser, output table ttAccount).
                
        // then
        Assert:IsTrue(isOK).
        temp-table ttAccount:write-json ("file", "target/updateAccountCreditLimit.json", true).
    end method.
    
 //   @Test.
    method public void updateAccountLimits():
        // given
        create ttAccountLimits.
        ttAccountLimits.lim_daily_purchase = 11.11.
        ttAccountLimits.lim_daily_withdrawal = 22.22.
        ttAccountLimits.lim_daily_internet_purchase = 33.33.
        ttAccountLimits.lim_daily_contactless_purchase = 44.44.
        ttAccountLimits.lim_monthly_purchase = 55.55.
        ttAccountLimits.lim_monthly_withdrawal = 66.66.
        ttAccountLimits.lim_monthly_internet_purchase = 77.77.
        ttAccountLimits.lim_monthly_contactless_purchase = 88.88.
        
        // when
        isOk = api:updateAccountLimits("ec74c22f-37e9-4cae-8113-f5766d5ef1e0", input table ttAccountLimits, auditUser, output table ttAccount).
                
        // then
        Assert:IsTrue(isOK).
        temp-table ttAccount:write-json ("file", "target/updateAccountLimits.json", true).
    end method.
    
    
   // @Test.
    method public void updateCardLimits():
        // given
        create ttCardLimits.
        ttCardLimits.lim_daily_purchase = 11.11.
        ttCardLimits.lim_daily_withdrawal = 22.22.
        ttCardLimits.lim_daily_internet_purchase = 33.33.
        ttCardLimits.lim_daily_contactless_purchase = 44.44.
        ttCardLimits.lim_monthly_purchase = 55.55.
        ttCardLimits.lim_monthly_withdrawal = 66.66.
        ttCardLimits.lim_monthly_internet_purchase = 77.77.
        ttCardLimits.lim_monthly_contactless_purchase = 88.88.
        ttCardLimits.lim_trn_purchase = 1.11.
        ttCardLimits.lim_trn_withdrawal = 2.22.
        ttCardLimits.lim_trn_internet_purchase = 3.33.
        ttCardLimits.lim_trn_contactless_purchase = 4.44.
        
        // when
        isOk = api:updateCardLimits("9f0444af-f09c-4831-abf8-26eb73651085", input table ttCardLimits, auditUser, output table ttCard).
                
        // then
        Assert:IsTrue(isOK).
        temp-table ttCard:write-json ("file", "target/updateCardLimits.json", true).
    end method.
    
    
    
//    @Test.
    method public void blockCard():
        // given
        
        // when
        isOk = api:blockCard("862c906c-5568-490a-ade2-5b55d076c2ab", CardBlockType:BlockedByClient, auditUser, output table ttCard).
                
        // then
        Assert:IsTrue(isOK).
        temp-table ttCard:write-json ("file", "target/blockCard.json", true).
    end method.
    
  //  @Test.
    method public void unBlockCard():
        // given
        
        // when
        isOk = api:unBlockCard("862c906c-5568-490a-ade2-5b55d076c2ab", auditUser, output table ttCard).
                
        // then
        Assert:IsTrue(isOK).
        temp-table ttCard:write-json ("file", "target/unBlockCard.json", true).
    end method.
    
  //  @Test.
    method public void closeCard():
        // given
        
        // when
        isOk = api:closeCard("74e8aaac-5fa4-443d-87d1-72cc532dd781", CardCloseReason:ClosedByClient, auditUser, output table ttCard).
                
        // then
        Assert:IsTrue(isOK).
        temp-table ttCard:write-json ("file", "target/closeCard.json", true).
    end method.
    
    method public character toBase64(pcString as longchar):
        DEF VAR cEncoded AS char NO-UNDO.
        DEF VAR mAuth AS memptr NO-UNDO.
        
        copy-lob from pcString to mAuth.
        cEncoded = BASE64-ENCODE(mAuth).
        
        return cEncoded.
    end method.
    
//    @Test.
    method public void changePinCode():
        // given
//        message toBase64("1234") skip 
//                view-as alert-box.
//        return.
        
        // when
        isOk = api:changePin("862c906c-5568-490a-ade2-5b55d076c2ab", "1234", auditUser, output table ttCard).
                
        // then
        Assert:IsTrue(isOK).
        temp-table ttCard:write-json ("file", "target/changePinCode.json", true).
    end method.
    
  //  @Test.
    method public void linkCard():
        // given
        
        // when 
        isOk = api:linkCardToAccount("d598ef4f-9dd9-4dbf-b4f9-15d0ef57949d", "d9d4e342-655a-4ffe-b127-bbf555c1a5b5", auditUser, output table ttCard).
        
        // then
        Assert:IsTrue(isOK).
        temp-table ttCard:write-json ("file", "target/linkCard.json", true).
        
    end method.
    
  //  @Test.
    method public void getAccountStatement():
        // given
        create ttStatementRequestParams.
        ttStatementRequestParams.include_account_adjustments = true.
        ttStatementRequestParams.include_authorizations      = true.
        ttStatementRequestParams.include_fees                = true.
        ttStatementRequestParams.include_transactions        = true.
        
        ttStatementRequestParams.from_date = add-interval(now, -24, "days").
        ttStatementRequestParams.to_date   = now.
        
        // when
     //   isOk = api:getAccountStatement("e7e91696-500d-4cb5-a353-582f45ef01bf", 0, 1000, table ttStatementRequestParams, auditUser, output table ttStmt).
        isOk = api:getAccountStatement("7838f52b-8987-4d2a-934e-ed0fefb31cc3", 0, 1000, table ttStatementRequestParams, auditUser, output table ttStmt).
        
        // then
        Assert:isTrue(isOk).
        temp-table ttStmt:write-json("file", "target/getAccountStatement.json", true).
        
        for each ttStmt: 
            
        end.
        
    end method.

//    @Test.
    method public void getTransaction():
        // given
        
        // when
        isOk = api:getTransactionById("1b768eeb-3d82-43da-9af2-07974f18ba90", auditUser, output table ttTrn).
        
        // then
        Assert:isTrue(isOk).
        temp-table ttTrn:write-json("file", "target/getTransactionById.json", true).
        
        find first ttTrn.
        message date(ttTrn.processed_at).
    end method.
    
    // @Test.
    method public void getListOfDirectories():
        // given
        
        // when
        isOk = api:getListOfDirectories(auditUser, output table ttFile).
        
        // then 
        Assert:isTrue(isOk).
        temp-table ttFile:write-json("file", "target/getListOfDirectories.json", true).
        
    end method.

    // @Test.
    method public void getDirectoryIndex():
        // given
        
        // when
        isOk = api:getDirectoryIndex( "transactions-extract", auditUser, output table ttFile).
        
        // then 
        Assert:isTrue(isOk).
        temp-table ttFile:write-json("file", "target/getDirectoryIndex.json", true).
        
    end method.

//    @Test.
    method public void downloadFile():
        // given
        def var cOutputDirectory as char no-undo init "target".
        
        // when
        isOk = api:downloadFile( "transactions-extract", "LATEKOLV_transactions_20210913_20210914010001.csv", cOutputDirectory, auditUser).
        
        // then 
        Assert:isTrue(isOk).
        
    end method.
    
//    @Test.
    method public void getReservedSettlementBalance():
        // given
        
        // when
        isOk = api:getReservedSettlementBalance(auditUser, output table ttReservedBalance).
        
        // then
        temp-table ttReservedBalance:write-json("file", "target/ttReservedBalance.json", true).
        Assert:isTrue(isOk).
        find ttReservedBalance no-error.
        Assert:IsAvailable(buffer ttReservedBalance:handle).
    end method.

end class.