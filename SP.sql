-- PROCEDURE that set  rating for an order if is_paid=1
CREATE OR REPLACE procedure set_rating (_order_id INTEGER, _rating INTEGER, _message text)
language plpgsql 
AS $$
BEGIN
    IF EXISTS(SELECT * FROM orders WHERE id = _order_id AND is_paid = 1)
    THEN
        IF EXISTS(SELECT * FROM rating WHERE order_id = _order_id)
        THEN
            UPDATE rating SET value = _rating, description = _message WHERE order_id = _order_id;
        ELSE
            INSERT INTO rating(order_id, value, description) VALUES (_order_id, _rating, _message);
        END IF;
    ELSE
        RAISE EXCEPTION 'order is not paid';
    END IF;
END;$$

-- procedure that add media to a model 
CREATE OR REPLACE procedure add_media (_model character varying, _model_id INTEGER, _collection character varying, _file_name character varying)
language plpgsql
AS $$
BEGIN
    IF _model = ANY ('{resturants,users,foods,categories}'::character varying[]) THEN
        IF EXISTS(SELECT * FROM media WHERE model = _model AND model_id = _model_id AND collection = _collection) THEN
            UPDATE media SET file_name = _file_name WHERE model = _model AND model_id = _model_id AND collection = _collection;
        ELSE
            INSERT INTO media(model, model_id, collection, file_name) VALUES (_model, _model_id, _collection, _file_name);
        END IF;
    ELSE
        RAISE EXCEPTION 'model is not valid';
    END IF;
END;$$