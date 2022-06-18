-- print order_id details
CREATE OR REPLACE FUNCTION print_bill (_order_id INTEGER)
    returns void as $$
    declare user_name character varying;
    declare user_lastName character varying;
    declare total integer;
    DECLARE id INT;
	DECLARE food_name text;
	DECLARE quantity integer;
    DECLARE price integer;
    DECLARE sum integer;
    DECLARE is_paid integer;
    DECLARE c CURSOR FOR (
        SELECT
            "foods".name as food_name,
            "order_item"."quantity" as quantity,
            "foods"."price" as price,
            "foods"."price" * "order_item"."quantity" as sum
        FROM
            "orders" 
            INNER JOIN "order_item" ON "orders"."id" = "order_item"."order_id"
            INNER JOIN "foods" ON "order_item"."food_id" = "foods"."id"
        WHERE
            "orders".id = _order_id
    );
    BEGIN
        SELECT "users"."first_name", "users"."last_name" INTO user_name, user_lastName 
            FROM "users" INNER JOIN "orders" ON "users"."id" = "orders"."user_id" 
        WHERE "orders"."id" = _order_id;
        SELECT orders.is_paid INTO is_paid FROM "orders" WHERE "orders"."id" = _order_id;
        SELECT sum(T.sum) + sum(T.shipping_cost) as total INTO total
            FROM 
            (
                SELECT SUM("order_item"."quantity" * "foods"."price") as sum, shipping_cost 
                    FROM "order_item"
                    INNER JOIN "foods" ON "order_item"."food_id" = "foods"."id"
                    INNER JOIN "restaurants" ON "foods"."restaurant_id" = "restaurants"."id"
                WHERE "order_item"."order_id" = _order_id GROUP BY shipping_cost 
            )T;
        RAISE NOTICE 'User: % % | orderID: %', user_name, user_lastName, _order_id;
        OPEN c;
        LOOP
            FETCH c INTO food_name , quantity, price, sum;
            IF NOT FOUND THEN EXIT; END IF;
            RAISE NOTICE 'food name: % | quantity: % | price: % | sum: %', food_name, quantity, price, sum;
        END LOOP;
        CLOSE c;
        RAISE NOTICE 'total price: % | is paid : %', total, is_paid;
    END;
$$ language plpgsql;

-- print resturant sales
CREATE OR REPLACE FUNCTION print_restaurant_sales (_restaurant_id INTEGER)
    returns void as $$
    declare restaurant_name character varying;
    DECLARE food_name text;
    DECLARE quantity integer;
    DECLARE sum integer;
    DECLARE c CURSOR FOR (
        SELECT T.food_name as food_name, sum(T.quantity) as quantity ,  SUM(T.price) * sum(T.quantity) as sum
            FROM 
            (
                SELECT
                    "foods".id as id,
                    "foods".name as food_name,
                    "order_item"."quantity" as quantity,
                    "foods"."price" as price
                FROM
                    "orders" 
                    INNER JOIN "order_item" ON "orders"."id" = "order_item"."order_id"
                    INNER JOIN "foods" ON "order_item"."food_id" = "foods"."id"
                WHERE
                    "foods"."restaurant_id" = _restaurant_id)T 
                    GROUP BY  T.food_name
    );
    BEGIN
        SELECT "restaurants"."name" INTO restaurant_name FROM "restaurants" WHERE "restaurants"."id" = _restaurant_id;
        RAISE NOTICE 'Restaurant: %', restaurant_name;
        OPEN c;
        LOOP
            FETCH c INTO food_name , quantity, sum;
            IF NOT FOUND THEN EXIT; END IF;
            RAISE NOTICE 'food name: % | quantity: % | sum: %', food_name, quantity, sum;
        END LOOP;
        CLOSE c;
    END;
$$ language plpgsql;
    