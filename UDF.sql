-- function to take order and return order id
CREATE OR REPLACE FUNCTION take_order (user_id INTEGER, driver_id INTEGER)
    returns integer as $order_id$
    declare order_id integer;
    BEGIN 
    IF EXISTS(
    SELECT
        *
    FROM
        "users"
        INNER JOIN "roles" ON "users".role_id = "roles"."id"
    WHERE
        "users".id = driver_id
        AND roles.title = 'driver'
) 
    THEN
        INSERT INTO orders(user_id, driver_id) VALUES (user_id, driver_id) RETURNING id into order_id;
    ELSE
        RAISE EXCEPTION 'driver not found';
    END IF;
return order_id;
end;
$order_id$ language plpgsql;
-- function to add order_item and return sum of order_items
CREATE OR REPLACE FUNCTION add_order_item (_order_id INTEGER, item_id INTEGER, quantity INTEGER) 
    returns integer as $sum$
    declare sum integer;
    BEGIN
        INSERT INTO order_item(order_id, food_id, quantity) VALUES (_order_id, item_id, quantity);
    SELECT sum(T.sum) + sum(T.shipping_cost) as sum INTO sum
        FROM 
        (
            SELECT SUM("order_item"."quantity" * "foods"."price") as sum, shipping_cost 
                FROM "order_item"
                INNER JOIN "foods" ON "order_item"."food_id" = "foods"."id"
                INNER JOIN "restaurants" ON "foods"."restaurant_id" = "restaurants"."id"
            WHERE "order_item"."order_id" = _order_id GROUP BY shipping_cost 
        )T;
    return sum;
    end;
$sum$ language plpgsql;

-- function to set payment status of order if amount is equal 
CREATE OR REPLACE FUNCTION set_payment_status (_order_id INTEGER, amount INTEGER) 
    returns void as $$
    declare sum integer;
    BEGIN
    SELECT sum(T.sum) + sum(T.shipping_cost) as sum INTO sum
        FROM 
        (
            SELECT SUM("order_item"."quantity" * "foods"."price") as sum, shipping_cost 
                FROM "order_item"
                INNER JOIN "foods" ON "order_item"."food_id" = "foods"."id"
                INNER JOIN "restaurants" ON "foods"."restaurant_id" = "restaurants"."id"
            WHERE "order_item"."order_id" = _order_id GROUP BY shipping_cost 
        )T;
    IF amount = sum THEN
        UPDATE "orders" SET is_paid = 1 WHERE "id" = _order_id;
    ELSE
        RAISE EXCEPTION 'amount is not equal to sum';
    END IF;
    END;
$$ language plpgsql;


