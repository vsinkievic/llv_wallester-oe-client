def temp-table tt{&prefix}Stmt no-undo before-table ttb{&prefix}Stmt
    field id as char
    field card_id as char
    field account_id as char
    field type as char
    field tx_group as char
    field date as datetime
    field transaction_amount as dec
    field transaction_currency_code as char
    field account_amount as dec
    field account_currency_code as char
    field merchant_category_code as char
    field merchant_id as char
    field terminal_id as char
    field merchant_name as char
    field merchant_city as char
    field merchant_country_code as char
    field description as char
    field original_authorization_id as char
    field is_reversal as log
    field is_declined as log
    field is_cleared as log
    field marked_for_dispute_at as datetime
    field marked_for_dispute_by as char
    field rec_status as char     // status
    field response as char
    .