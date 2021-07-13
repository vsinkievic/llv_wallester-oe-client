def temp-table tt{&prefix}StatementRequestParams no-undo
    field from_date                       as datetime init ? // FromDate defines a beginning date of requested data set (used with to_date parameter in pair)
    field to_date                         as datetime init ? // ToDate defines an end date of requested data set (used with from_date parameter in pair)
    field include_authorizations          as log      init ? // IncludeAuthorizations defines whether to include authorizations to account statement or not.
    field include_transactions            as log      init ? // IncludeTransactions defines whether to include transactions to account statement or not.
    field include_account_adjustments     as log      init ? // IncludeAccountAdjustments defines whether to include account adjustments to account statement or not.
    field include_fees                    as log      init ? // IncludeFees defines whether to include fees to account statement or not.
    field exclude_declined_authorizations as log      init ? // ExcludeDeclinedAuthorizations defines whether to exclude declined authorizations from account statement or not.
    field exclude_reversed_authorizations as log      init ? // ExcludeReversedAuthorizations defines whether to exclude reversed authorizations and reversals from account statement or not.
    field exclude_cleared_authorizations  as log      init ? // ExcludeClearedAuthorizations defines whether to exclude cleared authorizations from account statement or not.
    field exclude_pending_authorizations  as log      init ? // ExcludePendingAuthorizations defines whether to exclude pending authorizations from account statement or not.
    field exclude_status_authorizations   as log      init ? // ExcludeStatusAuthorizations defines whether to exclude status authorizations from account statement or not.
    field exclude_pending_fees            as log      init ? // ExcludePendingFees defines whether to exclude pending fees from account statement or not.
    field exclude_cleared_fees            as log      init ? // ExcludeClearedFees defines whether to exclude cleared fees from account statement or not.
    field exclude_declined_fees           as log      init ? // ExcludeDeclinedFees defines whether to exclude declined fees from account statement or not.
    field merge_fees                      as log      init ? // MergeFees defines whether to merge fees per authorization or not.
    .