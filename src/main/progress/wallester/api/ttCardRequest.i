def temp-table tt{&prefix}CardRequest no-undo
    field predecessor_card_id              as char   init ?  
    field account_id                       as char   init ? 
    field person_id                        as char   init ? 
    field external_id                      as char   init ? 
    field card_type                        as char   init ? // ChipAndPin, ChipAndPinAnonymous, Virtual
    field card_name                        as char   init ? 
//    field masked_card_number as char
//    field reference_number as char
//    field expiry_date as datetime
//    field block_type as char
//    field blocked_at as datetime
//    field card_status as char
    field embossing_name as char
//    field renew_automatically as log
    field personalization_product_code     as char    init ?
    field expiry_days                      as int     init 1095 // 1....1825 - up to 5 years
    field expiry_days_round                as logical init true
    field encrypted_pin                    as char    init ?
    field is_disposable                    as logical init ?    // aplicable for Virtual card only
//    field card_metadata_profile_id as char
//    field activated_at as datetime
//    field created_at as datetime
//    field updated_at as datetime
//    field closed_at as datetime
//    field closed_by as char
//    field close_reason as char
    field lim_daily_purchase               as dec     init ?
    field lim_daily_withdrawal             as dec     init ?
    field lim_daily_internet_purchase      as dec     init ?
    field lim_daily_contactless_purchase   as dec     init ?
    field lim_monthly_purchase             as dec     init ?
    field lim_monthly_withdrawal           as dec     init ?
    field lim_monthly_internet_purchase    as dec     init ?
    field lim_monthly_contactless_purchase as dec     init ?
    field lim_trn_purchase                 as dec     init ?
    field lim_trn_withdrawal               as dec     init ?
    field lim_trn_internet_purchase        as dec     init ?
    field lim_trn_contactless_purchase     as dec     init ?
    
//    field is_enrolled_for_3ds as log
//    field is_3ds_activated as log
    field sec_3ds_mobile                   as char    init ?
    field sec_3ds_email                    as char    init "ENG"
    field sec_3ds_password                 as char    init ?
//    field delivery_first_name as char
//    field delivery_last_name  as char
    field delivery_company_name            as char    init ?
    field delivery_address1                as char    init ?
    field delivery_address2                as char    init ?
    field delivery_postal_code             as char    init ?
    field delivery_city                    as char    init ?
    field delivery_country_code            as char    init ?
    field delivery_dispatch_method         as char    init ?     // "DPDExpress""StandardLatvianPostMail"
    field delivery_phone                   as char    init ?     //  Phone number is required in case of dispatch_method is "DPDExpress"
    field sec_contactless_enabled          as log     init ?
    field sec_withdrawal_enabled           as log     init ?
    field sec_internet_purchase_enabled    as log     init ?
    .
    