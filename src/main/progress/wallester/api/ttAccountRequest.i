def temp-table tt{&prefix}AccountRequest no-undo
    field person_id                        as char init ?
    field external_id                      as char init ?
    field account_name                     as char init ?
    field currency_code                    as char init ?
    field credit_limit                     as dec  init ?
    field used_credit                      as dec  init ?
    field lim_daily_purchase               as dec  init ?
    field lim_daily_withdrawal             as dec  init ?
    field lim_daily_internet_purchase      as dec  init ?
    field lim_daily_contactless_purchase   as dec  init ?
    field lim_monthly_purchase             as dec  init ?
    field lim_monthly_withdrawal           as dec  init ?
    field lim_monthly_internet_purchase    as dec  init ?
    field lim_monthly_contactless_purchase as dec  init ?
    .