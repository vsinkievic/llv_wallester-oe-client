 
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
    
    
    @Test.
    method public void getPersonById():
        // given
        
        // when
        isOk = api:getPersonById("d4d87e9f-d556-404f-abbd-905f6473b868", auditUser, output table ttPerson).
        
        // then
        Assert:isTrue(isOk).
        temp-table ttPerson:write-json("file", "target/getPersonById.json", true).
        
    end method.
end class.