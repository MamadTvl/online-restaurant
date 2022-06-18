-- all foods must be from one restaurant and if food already exists update quantity
CREATE OR REPLACE FUNCTION add_food_restaurant_check() RETURNS TRIGGER
AS $BODY$
declare new_restaurant_id integer;
declare order_resturant_id integer;
BEGIN
    SELECT "foods"."restaurant_id" INTO new_restaurant_id FROM foods WHERE id = NEW.food_id;
    SELECT "foods"."restaurant_id" INTO order_resturant_id FROM foods WHERE id = (SELECT food_id FROM order_item WHERE order_id = NEW.order_id LIMIT 1);
    IF NOT EXISTS(SELECT food_id FROM order_item WHERE order_id = NEW.order_id) OR new_restaurant_id = order_resturant_id THEN
        IF NEW.food_id NOT IN (SELECT food_id FROM order_item WHERE order_id = NEW.order_id) THEN
            RETURN NEW;
        ELSE
            UPDATE order_item SET quantity = NEW.quantity + order_item.quantity WHERE order_id = NEW.order_id AND food_id = NEW.food_id;
            RETURN NULL;
        END IF;
    ELSE
        RAISE EXCEPTION 'foods from different restaurants not allowed';
    END IF;
END;
$BODY$
language plpgsql;
CREATE OR REPLACE TRIGGER add_food_restaurant_check 
BEFORE INSERT ON order_item
FOR EACH ROW 
EXECUTE PROCEDURE add_food_restaurant_check();

-- check phone is valid on insert or update users
CREATE OR REPLACE FUNCTION check_phone() RETURNS TRIGGER
AS $BODY$
BEGIN
    IF NEW.phone IS NULL THEN
        RAISE EXCEPTION 'phone is required';
    END IF;
    IF NOT NEW.phone ~* '[0][9][0-9]{9}' THEN
        RAISE EXCEPTION 'phone is not valid';
    END IF;
    RETURN NEW;
END;
$BODY$
language plpgsql;
CREATE OR REPLACE TRIGGER check_phone
BEFORE INSERT OR UPDATE ON users
FOR EACH ROW
EXECUTE PROCEDURE check_phone();

-- rating value must be between 1 and 5
CREATE OR REPLACE FUNCTION check_rating() RETURNS TRIGGER
AS $BODY$
BEGIN
    IF NEW.rating < 1 OR NEW.rating > 5 THEN
        RAISE EXCEPTION 'rating value must be between 1 and 5';
    END IF;
    RETURN NEW;
END;
$BODY$
language plpgsql;
CREATE OR REPLACE TRIGGER check_rating 
BEFORE INSERT ON rating
FOR EACH ROW 
EXECUTE PROCEDURE check_rating();

-- food price must be greater than 0
CREATE OR REPLACE FUNCTION check_price() RETURNS TRIGGER
AS $BODY$
BEGIN
    IF NEW.price < 0 THEN
        RAISE EXCEPTION 'food price must be greater than 0';
    END IF;
    RETURN NEW;
END;
$BODY$
language plpgsql;
CREATE OR REPLACE TRIGGER check_price
BEFORE INSERT OR UPDATE ON foods
FOR EACH ROW
EXECUTE PROCEDURE check_price();

-- order_item quantity must be greater than 0
CREATE OR REPLACE FUNCTION check_quantity() RETURNS TRIGGER
AS $BODY$
BEGIN
    IF NEW.quantity < 0 THEN
        RAISE EXCEPTION 'order_item quantity must be greater than 0';
    END IF;
    RETURN NEW;
END;
$BODY$
language plpgsql;
CREATE OR REPLACE TRIGGER check_quantity
BEFORE INSERT OR UPDATE ON order_item
FOR EACH ROW
EXECUTE PROCEDURE check_quantity();

-- shipping_cost must be greater than 0

CREATE OR REPLACE FUNCTION check_shipping_cost() RETURNS TRIGGER
AS $BODY$
BEGIN
    IF NEW.shipping_cost < 0 THEN
        RAISE EXCEPTION 'shipping_cost must be greater than 0';
    END IF;
    RETURN NEW;
END;
$BODY$
language plpgsql;



