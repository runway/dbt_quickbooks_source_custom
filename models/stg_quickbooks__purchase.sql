with base as (

    select * 
    from {{ ref('stg_quickbooks__purchase_tmp') }}

),

fields as (

    select
        /*
        The below macro is used to generate the correct SQL for package staging models. It takes a list of columns 
        that are expected/needed (staging_columns from dbt_quickbooks_source/models/tmp/) and compares it with columns 
        in the source (source_columns from dbt_quickbooks_source/macros/).
        For more information refer to our dbt_fivetran_utils documentation (https://github.com/fivetran/dbt_fivetran_utils.git).
        */

        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_quickbooks__purchase_tmp')),
                staging_columns=get_purchase_columns()
            )
        }}
        
        {{ fivetran_utils.add_dbt_source_relation() }}
    from base
),

final as (
     
    select 
        cast(id as {{ dbt_utils.type_string() }}) as purchase_id,
        cast(account_id as {{ dbt_utils.type_string() }}) as account_id,
        created_at,
        cast(doc_number as {{ dbt_utils.type_string() }}) as doc_number,
        currency_id,
        exchange_rate,
        credit,
        total_amount,
        payment_type,
        department_id,
        cast(customer_id as {{ dbt_utils.type_string() }}) as customer_id,
        cast(vendor_id as {{ dbt_utils.type_string() }}) as vendor_id,
        transaction_date,
        _fivetran_deleted

        {{ fivetran_utils.source_relation() }}

    from fields
)

select * 
from final
where not coalesce(_fivetran_deleted, false)
