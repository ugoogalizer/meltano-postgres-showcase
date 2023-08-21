--https://docs.getdbt.com/docs/build/incremental-models

{{
  config(
    materialized='incremental',
    unique_key='orderid'
  )
}}

select ord.orderid, 
  ord.custid, 
  ord.productid, 
  ord.purchasetimestamp
  cust.custname, 
  cust.custadd,
  prod.productid, 
  prod.productname, 
  prod.prodcat, 
  prod.storeid
from {{ source('tap_postgres', 'fact_order') }} as ord
left join {{ source('tap_postgres', 'customer') }}  as cust 
  on ord.custid = cust.custid
left join {{ source('tap_postgres', 'productinfo') }}  as prod 
  on ord.productid = prod.productid

{% if is_incremental() %}
  -- this filter will only be applied on an incremental run
  where purchasetimestamp > (select max(purchasetimestamp) from {{ this }})

{% endif %}