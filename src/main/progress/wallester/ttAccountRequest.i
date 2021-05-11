def temp-table tt{&prefix}AccountRequest no-undo
    field id                               as char
    field person_id                        as char
    field external_id                      as char
    field account_name                     as char
    field currency_code                    as char
    field credit_limit                     as dec
    field used_credit                      as dec
    field lim_daily_purchase               as dec
    field lim_daily_withdrawal             as dec
    field lim_daily_internet_purchase      as dec
    field lim_daily_contactless_purchase   as dec
    field lim_monthly_purchase             as dec
    field lim_monthly_withdrawal           as dec
    field lim_monthly_internet_purchase    as dec
    field lim_monthly_contactless_purchase as dec
    .