DROP SCHEMA public CASCADE;

CREATE SCHEMA public;

CREATE Table roles(
    id SERIAL PRIMARY KEY,
    title VARCHAR(255)
);

CREATE Table users(
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    phone VARCHAR(255),
    address VARCHAR(255),
    password VARCHAR(255),
    role_id INTEGER,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (role_id) REFERENCES roles(id)
);

CREATE Table restaurants(
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    address VARCHAR(255),
    contact VARCHAR(255),
    shipping_cost INTEGER,
    manager_id INTEGER,
    FOREIGN KEY (manager_id) REFERENCES users(id)
);

CREATE Table foods(
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    details text,
    price INTEGER,
    restaurant_id INTEGER,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(id)
);

CREATE Table categories(
    id SERIAL PRIMARY KEY,
    title VARCHAR(255),
    description text,
    parent_id INTEGER DEFAULT NULL,
    FOREIGN KEY (parent_id) REFERENCES categories(id)
);

CREATE TABLE food_has_category(
    food_id INTEGER,
    category_id INTEGER,
    FOREIGN KEY (food_id) REFERENCES foods(id),
    FOREIGN KEY (category_id) REFERENCES categories(id)
);

CREATE Table orders(
    id SERIAL PRIMARY KEY,
    user_id INTEGER,
    driver_id INTEGER,
    is_paid SMALLINT DEFAULT '0',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (driver_id) REFERENCES users(id)
);

CREATE Table order_item(
    id SERIAL PRIMARY KEY,
    food_id INTEGER,
    order_id INTEGER,
    quantity INTEGER DEFAULT '1',
    FOREIGN KEY (food_id) REFERENCES foods(id),
    FOREIGN KEY (order_id) REFERENCES orders(id)
);

CREATE Table rating(
    id SERIAL PRIMARY KEY,
    order_id INTEGER,
    value INTEGER,
    description text,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (order_id) REFERENCES orders(id)
);

CREATE Table media(
    id SERIAL PRIMARY KEY,
    collection VARCHAR(255),
    model VARCHAR(255),
    model_id INTEGER,
    file_name VARCHAR(255),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE Table tokens(
    id SERIAL PRIMARY KEY,
    token VARCHAR(255),
    user_id INTEGER,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    Foreign Key (user_id) REFERENCES users(id)
);