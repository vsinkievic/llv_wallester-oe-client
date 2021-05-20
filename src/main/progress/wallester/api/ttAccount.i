def temp-table tt{&prefix}Account no-undo
    field id                               as char
    field person_id                        as char init ?
    field external_id                      as char init ?
    field account_name                     as char
    field currency_code                    as char
    field credit_limit                     as dec
    field used_credit                      as dec
    field balance                          as dec
    field available_amount                 as dec
    field blocked_amount                   as dec
    field account_status                   as char
    field created_at                       as datetime
    field updated_at                       as datetime
    field closed_at                        as datetime
    field closed_by                        as char
    field close_reason                     as char
    field lim_daily_purchase               as dec init ?
    field lim_daily_withdrawal             as dec init ?
    field lim_daily_internet_purchase      as dec init ?
    field lim_daily_contactless_purchase   as dec init ?
    field lim_monthly_purchase             as dec init ?
    field lim_monthly_withdrawal           as dec init ?
    field lim_monthly_internet_purchase    as dec init ?
    field lim_monthly_contactless_purchase as dec init ?
    .