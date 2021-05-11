def temp-table tt{&prefix}Person no-undo 
    field id                                     as char
    field personal_number                        as char
    field personal_number_issuer                 as char
    field title_name                             as char serialize-name "title" // Miss
    field first_name                             as char
    field middle_name                            as char
    field last_name                              as char
    field birth_date                             as date
    field birth_country_code                     as char
    field gender                                 as char // MALE / FEMALE
    field mobile                                 as char
    field email                                  as char
    field external_id                            as char
    field residence_country_code                 as char
    field is_represented_by_someone_else         as logical
    field is_beneficial_owner                    as logical
    field is_pep                                 as logical serialize-name "is_politically_exposed_person"
    field pep_explanation                        as char    serialize-name "politically_exposed_person_explanation"
    field business_relationship_purpose          as char
    field risk_profile                           as char // High
    field loyalty_number                         as char
    field created_at                             as datetime
    field updated_at                             as datetime
    field deactivated_at                         as datetime
    .
