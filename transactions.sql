-- add new rating
BEGIN TRANSACTION;
    CALL set_rating(12, 1, 'good');
    COMMIT;

-- add new order item
BEGIN TRANSACTION;
    SELECT add_order_item(1, 1, 4);
    COMMIT;