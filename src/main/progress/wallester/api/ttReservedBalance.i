def temp-table tt{&prefix}ReservedBalance no-undo
    field amount                  as dec      init ?
    field authorizations_count    as int      init ?
    field authorizations_tot_amt  as dec      init ?
    field currency_code           as char     init ?
    .