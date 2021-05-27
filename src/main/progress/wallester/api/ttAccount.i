def temp-table tt{&prefix}Account no-undo
    field id                               as char     init ?
    field person_id                        as char     init ?
    field external_id                      as char     init ?
    field account_name                     as char     init ?
    field currency_code                    as char     init ?
    field credit_limit                     as dec      init ?
    field used_credit                      as dec      init ?
    field balance                          as dec      init ?
    field available_amount                 as dec      init ?
    field blocked_amount                   as dec      init ?
    field account_status                   as char     init ?
    field created_at                       as datetime init ?
    field updated_at                       as datetime init ?
    field closed_at                        as datetime init ?
    field closed_by                        as char     init ?
    field close_reason                     as char     init ?
    field lim_daily_purchase               as dec      init ?
    field lim_daily_withdrawal             as dec      init ?
    field lim_daily_internet_purchase      as dec      init ?
    field lim_daily_contactless_purchase   as dec      init ?
    field lim_monthly_purchase             as dec      init ?
    field lim_monthly_withdrawal           as dec      init ?
    field lim_monthly_internet_purchase    as dec      init ?
    field lim_monthly_contactless_purchase as dec      init ?
    .