def temp-table tt{&prefix}CardRequest no-undo
    field predecessor_card_id as char
    field account_id as char
    field person_id as char
    field external_id as char
    field card_type as char // ChipAndPin, ChipAndPinAnonymous, Virtual
    field card_name as char
//    field masked_card_number as char
//    field reference_number as char
//    field expiry_date as datetime
//    field block_type as char
//    field blocked_at as datetime
//    field card_status as char
//    field embossing_name as char
//    field renew_automatically as log
    field personalization_product_code as char
    field expiry_days as int // 1....1825 - up to 5 years
    field expiry_days_round as logical init true
    field encrypted_pin as char
//    field card_metadata_profile_id as char
//    field activated_at as datetime
//    field created_at as datetime
//    field updated_at as datetime
//    field closed_at as datetime
//    field closed_by as char
//    field close_reason as char
    field lim_daily_purchase as dec
    field lim_daily_withdrawal as dec
    field lim_daily_internet_purchase as dec
    field lim_daily_contactless_purchase as dec
    field lim_monthly_purchase as dec
    field lim_monthly_withdrawal as dec
    field lim_monthly_internet_purchase as dec
    field lim_monthly_contactless_purchase as dec
    field lim_trn_purchase as dec
    field lim_trn_withdrawal as dec
    field lim_trn_internet_purchase as dec
    field lim_trn_contactless_purchase as dec
    
//    field is_enrolled_for_3ds as log
//    field is_3ds_activated as log
    field sec_3ds_type as char init "SMSOTPAndStaticPassword"
    field sec_3ds_mobile as char
    field sec_3ds_language_code as char init "ENG"
    field sec_3ds_password as char
//    field delivery_first_name as char
//    field delivery_last_name  as char
    field delivery_company_name as char
    field delivery_address1 as char
    field delivery_address2 as char
    field delivery_postal_code as char
    field delivery_city        as char
    field delivery_country_code as char
    field delivery_dispatch_method as char  // "DPDExpress""StandardLatvianPostMail"
    field delivery_phone as char     //  Phone number is required in case of dispatch_method is "DPDExpress"
    field sec_contactless_enabled as log init true
    field sec_widhdrawal_enabled as log init true
    field sec_internet_purchase_enabled as log init false
    .
    