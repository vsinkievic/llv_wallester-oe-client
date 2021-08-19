def temp-table tt{&prefix}Person no-undo 
    field id                                     as char     init ?
    field personal_number                        as char     init ?
    field personal_number_issuer                 as char     init ?
    field title_name                             as char     init ?  serialize-name "title" // Miss
    field first_name                             as char     init ?  case-sensitive
    field middle_name                            as char     init ?  case-sensitive
    field last_name                              as char     init ?  case-sensitive
    field birth_date                             as date     init ? 
    field birth_country_code                     as char     init ?
    field gender                                 as char     init ? // MALE / FEMALE
    field mobile                                 as char     init ?
    field email                                  as char     init ?
    field external_id                            as char     init ?
    field residence_country_code                 as char     init ?
    field is_represented_by_someone_else         as logical  init ?
    field is_beneficial_owner                    as logical  init ?
    field is_pep                                 as logical  init ?  serialize-name "is_politically_exposed_person"
    field pep_explanation                        as char     init ?  serialize-name "politically_exposed_person_explanation"
    field business_relationship_purpose          as char     init ?
    field risk_profile                           as char     init ? // High
    field loyalty_number                         as char     init ?
    field created_at                             as datetime init ?
    field updated_at                             as datetime init ?
    field deactivated_at                         as datetime init ?
    .
