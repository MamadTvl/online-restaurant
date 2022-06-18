
SELECT
    foods.name,
    foods.price,
    order_item.quantity
FROM
    orders
    INNER JOIN users ON users.id = orders.user_id
    INNER JOIN order_item ON orders.id = order_item.order_id
    INNER JOIN foods ON order_item.food_id = foods.id
WHERE
    users.first_name = 'Cleve';


SELECT
    SUM(order_item.quantity * foods.price)
FROM
    orders
    INNER JOIN users ON users.id = orders.user_id
    INNER JOIN order_item ON orders.id = order_item.order_id
    INNER JOIN foods ON order_item.food_id = foods.id
WHERE
    users.first_name = 'Cleve';


SELECT
    restaurants.id,
    restaurants.name,
    AVG(order_item.quantity * foods.price) as average_sale
FROM
    orders
    INNER JOIN order_item ON orders.id = order_item.order_id
    INNER JOIN foods ON order_item.food_id = foods.id
    INNER JOIN restaurants ON restaurants.id = foods.restaurant_id
GROUP BY
    restaurants.id;



SELECT
    users.id as user_id,
    users.first_name,
    users.last_name,
    orders.id as order_id
FROM
    orders,
    users,
    foods,
    order_item
WHERE
    orders.user_id = users.id
    AND order_item.order_id = orders.id
    AND foods.id = order_item.food_id
    AND foods.name = 'Ham - Cooked';



SELECT
    users.id as user_id,
    users.first_name,
    users.last_name,
    orders.id as order_id
FROM
    orders,
    users,
    foods,
    order_item
WHERE
    orders.user_id = users.id
    AND order_item.order_id = orders.id
    AND foods.id = order_item.food_id
    AND foods.name = 'Ham - Cooked'
INTERSECT
SELECT
    users.id as user_id,
    users.first_name,
    users.last_name,
    orders.id as order_id
FROM
    orders,
    users,
    foods,
    order_item
WHERE
    orders.user_id = users.id
    AND order_item.order_id = orders.id
    AND foods.id = order_item.food_id
    AND foods.name = 'Coffee - Ristretto Coffee Capsule';



SELECT
    *
FROM
    users
WHERE
    id NOT IN (
        SELECT
            user_id
        FROM
            orders
            INNER JOIN order_item ON orders.id = order_item.order_id
            INNER JOIN foods ON order_item.food_id = foods.id
        WHERE
            foods.name = 'Coffee - Ristretto Coffee Capsule'
    );



SELECT
    SUM(order_item.quantity * foods.price) as total_sale,
    date_trunc('day', orders.updated_at) as day
FROM
    orders
    INNER JOIN order_item ON orders.id = order_item.order_id
    INNER JOIN foods ON order_item.food_id = foods.id
    INNER JOIN restaurants ON restaurants.id = foods.restaurant_id
WHERE
    restaurants.name = 'Warrior and the Sorceress'
GROUP BY
    orders.updated_at;



SELECT
    T.driver_id,
    SUM(T.shipping_cost) as shipping_cost
FROM
    (
        SELECT
            users.id as driver_id,
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
    T.driver_id;



SELECT
    AVG(rating.value)
FROM
    rating,
    orders,
    order_item,
    foods,
    restaurants
WHERE
    rating.order_id = orders.id
    AND order_item.order_id = orders.id
    AND foods.id = order_item.food_id
    AND foods.restaurant_id = restaurants.id
    AND restaurants.id = 1;



SELECT
    users.id,
    users.first_name,
    users.last_name,
    media.file_name as avatar
FROM
    users
    LEFT JOIN media ON users.id = media.model_id
    AND media.model = 'user'
    AND media.collection = 'avatar';



SELECT
    categories.id as category_id,
    categories.title,
    count(foods.id) as count_of_foods
FROM
    categories,
    foods,
    food_has_category
WHERE
    categories.id = food_has_category.category_id
    AND foods.id = food_has_category.food_id
    AND categories.parent_id IS NULL
GROUP BY
    categories.id
ORDER BY
    count_of_foods DESC;



SELECT
    *
FROM
    categories,
    (
        SELECT
            count(*) as count_of_subcategories,
            parent_id
        FROM
            categories
        GROUP BY
            parent_id
    ) subcategories
WHERE
    categories.id = subcategories.parent_id;





SELECT
    *
FROM
    (
        SELECT
            categories.id as category_id,
            categories.title,
            MAX(foods.price) as max_price
        FROM
            categories,
            foods,
            food_has_category
        WHERE
            categories.id = food_has_category.category_id
            AND foods.id = food_has_category.food_id
            AND categories.parent_id IS NULL
        GROUP BY
            categories.id
    ) T
order by
    max_price DESC;



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



SELECT
    *
FROM
    users
EXCEPT
    (
        SELECT
            users.*
        FROM
            users,
            orders,
            order_item,
            foods,
            restaurants
        WHERE
            users.id = orders.user_id
            AND orders.id = order_item.order_id
            AND foods.id = order_item.food_id
            AND foods.restaurant_id = restaurants.id
            AND restaurants.id = 3
    );