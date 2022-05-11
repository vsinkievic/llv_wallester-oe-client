def temp-table tt{&prefix}Auth no-undo before-table ttb{&prefix}Auth
    field id  as char
    field card_id as char
    field account_id as char
    field date as datetime
    field expiration_date as datetime
    field type as char
    field transaction_amount as dec
    field transaction_currency_code as char
    field account_amount as dec
    field account_currency_code as char
    field approved_amount as dec
    field reserved_amount as dec
    field threshold_amount as dec
    field reversed_amount as dec
    field cleared_amount as dec
    field balance as dec
    field foreign_exchange_fee as dec
    field merchant_category_code as char
    field merchant_id as char
    field terminal_id as char
    field merchant_name as char
    field merchant_city as char
    field merchant_country_code as char
    field response_code as char
    field created_at as datetime
    field tx_group      as char     // group
    field original_authorization_id as char
    field retrieval_reference_number as char
    field marked_for_dispute_at as datetime
    field marked_for_dispute_by as char
    field released_at as datetime
    field is_reversal as log
    field is_declined as log
    field is_contactles as log
    field is_mass_transit as log
    index pk is primary unique id
    .
    
def temp-table tt{&prefix}Trn no-undo before-table ttb{&prefix}Trn
    field id                        as char        init ?
    field authorization_id          as char        init ?
    field account_id                as char        init ?
    field card_id                   as char        init ?
    field purchase_date             as datetime-tz init ?
    field transaction_amount        as dec         init ?
    field transaction_currency_code as char        init ?
    field account_amount            as dec         init ?
    field account_currency_code     as char        init ?
    field foreign_exchange_fee      as dec         init ?
    field merchant_category_code    as char        init ?
    field merchant_id               as char        init ?
    field terminal_id               as char        init ?
    field merchant_name             as char        init ?
    field merchant_city             as char        init ?
    field merchant_country_code     as char        init ?
    field created_at                as datetime-tz init ?
    field tx_group                  as char        init ?
    field marked_for_dispute_at     as datetime    init ?
    field marked_for_dispute_by     as char        init ?
    field merchant_postal_code      as char        init ?
    field acquirer_reference_code   as char        init ?
    field acquirer_reference_number as char        init ?
    field acquirer_business_id      as char        init ?
    field transaction_code          as char        init ?
    field transaction_identifier    as char        init ?
    field processed_at              as datetime-tz init ?
    index pk is primary unique id
    .

def temp-table tt{&prefix}Fee no-undo before-table ttb{&prefix}Fee   
    field id as char
    field authorization_id as char
    field transaction_id as char
    field card_id as char 
    field account_id as char
    field person_id as char
    field type as char
    field amount as dec
    field currency_code as char
    field created_at as datetime
    field created_by as char
    field update_at as datetime
    field update_by as char
    field fee_status as char        // status
    field completed_at as datetime
    field canceled_at as datetime
    field canceled_by as char
    field canceled_reason as char
    field completed_by as char
    index pk is primary unique id
    .
    
def temp-table tt{&prefix}Adj no-undo before-table ttb{&prefix}Adj
    field id as char
    field external_id as char
    field account_id as char
    field amount as dec
    field created_at as datetime
    field description as char
    .
    
def dataset ds{&prefix}Statement
    for tt{&prefix}Auth, tt{&prefix}Trn, tt{&prefix}Fee, 
        tt{&prefix}Adj
    .  