def temp-table tt{&prefix}CardLimits no-undo
    field lim_daily_purchase               as dec init ?
    field lim_daily_withdrawal             as dec init ?
    field lim_daily_internet_purchase      as dec init ?
    field lim_daily_contactless_purchase   as dec init ?
    field lim_monthly_purchase             as dec init ?
    field lim_monthly_withdrawal           as dec init ?
    field lim_monthly_internet_purchase    as dec init ?
    field lim_monthly_contactless_purchase as dec init ?
    field lim_trn_purchase                 as dec init ?
    field lim_trn_withdrawal               as dec init ?
    field lim_trn_internet_purchase        as dec init ?
    field lim_trn_contactless_purchase     as dec init ?
    .
    