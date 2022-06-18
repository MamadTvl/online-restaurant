-- view that shows drivers profits
DROP VIEW IF EXISTS driver_profit;
CREATE VIEW driver_profit AS 
SELECT
    T.driver_id as id,
    T.first_name,
    T.last_name,
    SUM(T.shipping_cost) as shipping_cost
FROM
    (
        SELECT
            users.id as driver_id,
            users.first_name as first_name,
            users.last_name as last_name,
            sum(restaurants.shipping_cost) as shipping_cost
        from
            users,
            roles,
            orders,
            order_item,
            foods,
            restaurants
        WHERE
            users.role_id = roles.id
            AND orders.id = order_item.order_id
            AND foods.id = order_item.food_id
            AND foods.restaurant_id = restaurants.id
            AND users.id = orders.driver_id
            AND roles.title = 'driver'
        GROUP BY
            users.id,
            orders.id,
            restaurants.id
    ) T
GROUP BY
    id,T.first_name,T.last_name;
-- orders that not paid in every restaurant
DROP VIEW IF EXISTS orders_not_paid;
CREATE VIEW orders_not_paid AS
    SELECT
        restaurants.id as restaurant_id,
        restaurants.name,
        count(orders.id) as count_of_unpaid_orders
    FROM
        restaurants,
        orders,
        order_item,
        foods
    WHERE
        restaurants.id = foods.restaurant_id
        AND orders.id = order_item.order_id
        AND order_item.food_id = foods.id
        AND orders.is_paid = 0
    GROUP BY
        restaurants.id;