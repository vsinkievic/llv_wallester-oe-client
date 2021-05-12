 
 /*------------------------------------------------------------------------
    File        : PingPongCallTest
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : vsink_000
    Created     : Wed Apr 14 18:45:10 EEST 2021
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.Core.Assert from propath.
using wallester.WallesterApiClient from propath.
using wallester.WallesterApi from propath.

block-level on error undo, throw.

class wallester.WallesterApiClientItTest:
//    def var SMART_URL as char no-undo init "http://localhost:8089".
//    def var SMART_USER as char no-undo init "user".
//    def var SMART_PASSWD as char no-undo init "user".

  {wallester/ttAccount.i}
  {wallester/ttAccountLimits.i}
  {wallester/ttAccountRequest.i}
  {wallester/ttCard.i}
  {wallester/ttCardLimits.i}
  {wallester/ttPerson.i}
      
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
        oClient = new WallesterApiClient().      
          
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
        return.

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
       ttPerson.personal_number = "AK123456".
       ttPerson.personal_number_issuer = "LTU".
       ttPerson.title_name = "".
       ttPerson.first_name = "Testauskas".
       ttPerson.middle_name = "Middle".
       ttPerson.last_name = "Tester".
       ttPerson.birth_date = date(09, 19, 1999).
       ttPerson.birth_country_code = "LTU".
       ttPerson.gender = "MALE".
       ttPerson.mobile = "+37061495615".
       ttPerson.email = "valdemar@bpm-id.com".
       ttPerson.external_id = "person_123".
       ttPerson.residence_country_code = "LTU".
       ttPerson.is_represented_by_someone_else = false.
       ttPerson.is_beneficial_owner = true.
       ttPerson.is_pep = false.
       ttPerson.pep_explanation = "Testing political explanation".
       ttPerson.business_relationship_purpose = "business relation".
       ttPerson.risk_profile = "Low".
       ttPerson.loyalty_number = "loyalty_number".
       
       // when 
       isOk = api:createPerson(input-output table ttPerson, auditUser).
       
       // then
       Assert:IsTrue(isOk).
       temp-table ttPerson:write-json("file", "target/createPerson.json", true).
    end method.
 
   // @Test.
    method public void updatePersonTest():
       // given
       create ttPerson.
       ttPerson.id = "d4d87e9f-d556-404f-abbd-905f6473b868".
       ttPerson.personal_number = "AK123456".
       ttPerson.personal_number_issuer = "LTU".
       ttPerson.title_name = "Mr.".
       ttPerson.first_name = "Testauskas s".
       ttPerson.middle_name = "Middle.".
       ttPerson.last_name = "Tester.".
       ttPerson.birth_date = date(09, 09, 1999).
       ttPerson.birth_country_code = "LVA".
       ttPerson.gender = "FEMALE".
       ttPerson.mobile = "+37061411111".
       ttPerson.email = "valdemar_@bpm-id.com".
       ttPerson.external_id = "person_123_".
       ttPerson.residence_country_code = "LIE".
       ttPerson.is_represented_by_someone_else = true.
       ttPerson.is_beneficial_owner = false.
       ttPerson.is_pep = false.
       ttPerson.pep_explanation = "Testing political explanation".
       ttPerson.business_relationship_purpose = "business relation_".
       ttPerson.risk_profile = "Medium".
       ttPerson.loyalty_number = "loyalty_number".
       
       // when 
       isOk = api:updatePerson(input-output table ttPerson, auditUser).
       
       // then
       Assert:IsTrue(isOk).
       temp-table ttPerson:write-json("file", "target/updatePersonTest.json", true).
    end method.
    
    
 //   @Test.
    method public void getPersonById():
        // given
        
        // when
        isOk = api:getPersonById("d4d87e9f-d556-404f-abbd-905f6473b868", auditUser, output table ttPerson).
        
        // then
        Assert:isTrue(isOk).
        temp-table ttPerson:write-json("file", "target/getPersonById.json", true).
        
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


    @Test.
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
end class.