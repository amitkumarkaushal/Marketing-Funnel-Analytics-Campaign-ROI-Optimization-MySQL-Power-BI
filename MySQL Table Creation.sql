CREATE TABLE channels (
    channel_id INT PRIMARY KEY,
    channel_name VARCHAR(100) NOT NULL,
    channel_type VARCHAR(50) NOT NULL
);

CREATE TABLE campaign (
    campaign_id INT PRIMARY KEY,
    campaign_name VARCHAR(150) NOT NULL,
    channel_id INT NOT NULL,
    category_focus VARCHAR(100),
    start_date DATE,
    end_date DATE,
    budget DECIMAL(12,2),
    status VARCHAR(50),
    
    CONSTRAINT fk_campaign_channel
        FOREIGN KEY (channel_id) 
        REFERENCES channels(channel_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(150),
    gender VARCHAR(20),
    age_group VARCHAR(50),
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100),
    signup_date DATE,
    acquisition_channel_id INT,
    
    CONSTRAINT fk_customer_channel
        FOREIGN KEY (acquisition_channel_id)
        REFERENCES channels(channel_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(150) NOT NULL,
    category VARCHAR(100),
    subcategory VARCHAR(100),
    price DECIMAL(10,2),
    sku VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATETIME,
    total_amount DECIMAL(12,2),
    discount_amount DECIMAL(12,2),
    payment_method VARCHAR(50),
    order_status VARCHAR(50),
    
    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE funnel_events (
    event_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    campaign_id INT,
    funnel_stage VARCHAR(50),
    event_timestamp DATETIME,
    device_type VARCHAR(50),
    page_url VARCHAR(255),
    session_duration_seconds INT,
    
    CONSTRAINT fk_funnel_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
        
    CONSTRAINT fk_funnel_campaign
        FOREIGN KEY (campaign_id)
        REFERENCES campaign(campaign_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2),
    line_total DECIMAL(12,2),
    
    CONSTRAINT fk_orderitems_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
        
    CONSTRAINT fk_orderitems_product
        FOREIGN KEY (product_id)
        REFERENCES products(product_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

