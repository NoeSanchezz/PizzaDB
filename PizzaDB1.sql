
/* Dashboard 1- Order Dashbord
List of things that the dashboard will need
1.Total Orders
2.Total Sales
3.total Items
4.Average Order Value
5.Sales by Category
6.Top selling Items
7.Orders by Hour
8.Sales by Hour
9.Orders by Address
10.Orders by Deliver/Pickup
*/
create table order_dashboard as (
	select
		  o.order_id
		, i.item_price
		, o.quantity
		, i.item_cat
		, i.item_name
		, o.created_at
		, a.delivery_address1
		, a.delivery_address2
		, a.delivery_city
		, a.delivery_zipcode
		, o.delivery
	from
		orders o
	/*The dashboard will require 3 tables. I will do a left join on the orders id and the item id,
	then to get the address i will need to to a left join on the addres id from the orders table and aaddres id*/	
		left join item i 
			on o.item_id = i.item_id

		left join address a
			on o.add_id = a.address_id
)
;

/* Dashbord 2 - Inventory Management
Need to calculate how much inventory we're using and then identify inventory that needs reordering.
Also ned to calcualte how much pizza cost to make based on the cost of the ingredients.


Here is the list that i will need to make this dashboard
1.total quanity by ingredeient
2.Total cost of ingredients
3.Calculated cost of pizza
4.percentage stock remaining by ingredient
*/

create table stock01 as (
	with inventory_attributes as(
		select
			  o.item_id
			, i.sku
			, i.item_name
			, r.ingredient_id
			, r.quanity as recipe_quanity
			, ing.ingredient_name
			, ing.ingredient_weight
			, ing.ingredient_price
			, sum(o.quantity) as orders_quanity
		from orders o
			left join item i
				on o.item_id = i.item_id
			left join recipe r
				on i.sku = r.recipe_id
			left join ingredient ing
				on ing.ingredient_id = r.ingredient_id
		group by 
			  o.item_id
			, i.sku
			, i.item_name
			, r.ingredient_id
			, r.quanity 
			, ing.ingredient_name
			, ing.ingredient_weight
			, ing.ingredient_price
	)
	
		select
			  ia.item_id
			, ia.sku
			, ia.item_name
			, ia.ingredient_id
			, ia.recipe_quanity
			, ia.ingredient_name
			, ia.ingredient_weight
			, ia.ingredient_price
			, ia.orders_quanity
			, ia.orders_quanity*ia.recipe_quanity as ordered_weight
			, ia.ingredient_price/ia.ingredient_weight as unit_cost
			, (ia.orders_quanity*ia.recipe_quanity)*(ia.ingredient_price/ia.ingredient_weight) as ingredient_cost
		from
		inventory_attributes ia
		
)
;
/*
Now working with the view, named stock1
*/
create temp table stock2 as (
	select
		  ingredient_id 
		, ingredient_name
		, sum (ordered_weight) as ordered_weight
	from
		stock1
	group by
		  ingredient_id 
		, ingredient_name 
)

-- select
-- *
-- from
-- stock2
create table stock2 as(
	select	
		  s2.ingredient_name
		, s2.ordered_weight
		, ing.ingredient_weight * inv.quanity as total_inv_weight
		, (ing.ingredient_weight * inv.quanity)- s2.ordered_weight as remaining_weight
	from
		stock2 s2
		left join inventory inv	
			on inv.item_id = s2.ingredient_id

			left join ingredient ing	
			on ing.ingredient_id = s2.ingredient_id
	)
	;
select
	*
from
	stock2
;

/*
Staff data
*/
create table staff_data as (
	select
		  r.date
		, s.first_name
		, s.last_name
		, s.hourly_rate
		, sh.start_time
		, sh.end_time	
		, (cast (extract(hour from sh.end_time)as decimal (5,2)) -
		   cast (extract(hour from sh.start_time)as decimal (5,2))) as total_hours
		, (cast (extract(hour from sh.end_time)as decimal (5,2)) -
		   cast (extract(hour from sh.start_time)as decimal (5,2))) * s.hourly_rate  as cost_of_staff
	from
		rota r
		left join staff s
			on r.staff_id = s.staff_id
		left join shift sh
			on r.shift_id = sh.shift_id
)		
;

	










