CREATE TABLE actor_information (
    actor_identifier SMALLINT,
    actor_first_name VARCHAR(45),
    actor_last_name VARCHAR(45),
    last_modification_timestamp TIMESTAMP 
);

COMMENT ON TABLE actor_information IS 'This table contains information for all actors and is joined to the film table via the film_actor table.';
COMMENT ON COLUMN actor_information.actor_identifier IS 'Primary Key. A unique identifier used to uniquely identify each actor in the table. Type: Small Integer';
COMMENT ON COLUMN actor_information.actor_first_name IS 'The first name of the actor. Type: Variable Character (45)';
COMMENT ON COLUMN actor_information.actor_last_name IS 'The last name of the actor. Type: Variable Character (45)';
COMMENT ON COLUMN actor_information.last_modification_timestamp IS 'The timestamp when the row was created or most recently updated. Type: Timestamp';

CREATE TABLE address_details (
    primary_address_line VARCHAR(50),
    secondary_address_line VARCHAR(50),
    address_identifier SMALLINT,
    city_identifier SMALLINT,
    region VARCHAR(20),
    last_modification_timestamp TIMESTAMP,
    geographic_coordinates GEOMETRY,
    telephone_number VARCHAR(20),
    zip_or_postal_code VARCHAR(10) 
);

COMMENT ON TABLE address_details IS 'This table contains address information for customers, staff, and stores, with references to the city table.';
COMMENT ON COLUMN address_details.primary_address_line IS 'The first line of an address. Type: Text';
COMMENT ON COLUMN address_details.secondary_address_line IS 'An optional second line of an address. Type: Text';
COMMENT ON COLUMN address_details.address_identifier IS 'Primary Key. A unique identifier used to identify each address in the table. Type: Small Integer';
COMMENT ON COLUMN address_details.city_identifier IS 'Foreign Key. A reference to the city table. Type: Small Integer';
COMMENT ON COLUMN address_details.region IS 'The region of an address, such as a state, province, or prefecture. Type: Text';
COMMENT ON COLUMN address_details.last_modification_timestamp IS 'When the row was created or most recently updated. Type: Timestamp';
COMMENT ON COLUMN address_details.geographic_coordinates IS 'A Geometry column with a spatial index for geographic coordinates. Type: Geometry';
COMMENT ON COLUMN address_details.telephone_number IS 'The telephone number associated with the address. Type: Text';
COMMENT ON COLUMN address_details.zip_or_postal_code IS 'The postal code or ZIP code of the address, where applicable. Type: Text';

CREATE TABLE city_information (
    city_name VARCHAR(50),
    city_identifier SMALLINT,
    country_identifier SMALLINT,
    last_modification_timestamp TIMESTAMP 
);

COMMENT ON TABLE city_information IS 'This table contains a list of cities. It is referred to by a foreign key in the address table and links to the country table using a foreign key.';
COMMENT ON COLUMN city_information.city_name IS 'The name of the city. Type: Text';
COMMENT ON COLUMN city_information.city_identifier IS 'Primary Key. A unique identifier used to uniquely identify each city in the table. Type: Small Integer';
COMMENT ON COLUMN city_information.country_identifier IS 'Foreign Key. A reference to the country that the city belongs to. Type: Small Integer';
COMMENT ON COLUMN city_information.last_modification_timestamp IS 'Timestamp of when the row was created or most recently updated. Type: Timestamp';

CREATE TABLE country_list (
    country_name VARCHAR(50),
    country_identifier SMALLINT,
    last_modification_timestamp TIMESTAMP 
);

COMMENT ON TABLE country_list IS 'This table contains a list of countries, which is referenced by a foreign key in the city table.';
COMMENT ON COLUMN country_list.country_name IS 'The name of the country. Type: Text';
COMMENT ON COLUMN country_list.country_identifier IS 'Primary Key. A unique identifier used to uniquely identify each country in the table. Type: Small Integer';
COMMENT ON COLUMN country_list.last_modification_timestamp IS 'The timestamp when the row was created or most recently updated. Type: Timestamp';

CREATE TABLE customer_information (
    is_active BOOLEAN,
    address_identifier SMALLINT,
    creation_date DATETIME,
    customer_identifier SMALLINT,
    email_address VARCHAR(50),
    customer_first_name VARCHAR(45),
    customer_last_name VARCHAR(45),
    last_modification_timestamp TIMESTAMP,
    home_store_identifier TINYINT 
);

COMMENT ON TABLE customer_information IS 'This table contains a list of all customers and their related details. It is referenced in the payment and rental tables and refers to the address and store tables using foreign keys.';
COMMENT ON COLUMN customer_information.is_active IS 'Indicates whether the customer is an active customer. Useful for filtering active customers. Type: Boolean';
COMMENT ON COLUMN customer_information.address_identifier IS 'Foreign Key. A unique identifier linking to the customer's address in the address table. Type: Small Integer';
COMMENT ON COLUMN customer_information.creation_date IS 'The date when the customer was added to the system. Automatically set during an INSERT operation. Type: DateTime';
COMMENT ON COLUMN customer_information.customer_identifier IS 'Primary Key. A unique identifier used to uniquely identify each customer in the table. Type: Small Integer';
COMMENT ON COLUMN customer_information.email_address IS 'The customer's email address. Type: String (50 characters max)';
COMMENT ON COLUMN customer_information.customer_first_name IS 'The customer's first name. Type: String (45 characters max)';
COMMENT ON COLUMN customer_information.customer_last_name IS 'The customer's last name. Type: String (45 characters max)';
COMMENT ON COLUMN customer_information.last_modification_timestamp IS 'The timestamp when the row was created or last updated. Type: Timestamp';
COMMENT ON COLUMN customer_information.home_store_identifier IS 'Foreign Key. A unique identifier linking to the customer's primary store in the store table. Type: Tiny Integer';

CREATE TABLE film_actor_relationship (
    actor_identifier SMALLINT,
    film_identifier SMALLINT,
    last_modification_timestamp TIMESTAMP 
);

COMMENT ON TABLE film_actor_relationship IS 'This table supports a many-to-many relationship between films and actors. Each row represents an actor associated with a film, utilizing foreign keys to reference the actor and film tables.';
COMMENT ON COLUMN film_actor_relationship.actor_identifier IS 'Foreign Key. A unique identifier referencing an actor. Type: Small Integer';
COMMENT ON COLUMN film_actor_relationship.film_identifier IS 'Foreign Key. A unique identifier referencing a film. Type: Small Integer';
COMMENT ON COLUMN film_actor_relationship.last_modification_timestamp IS 'The timestamp when the row was created or most recently updated. Type: Timestamp';

CREATE TABLE film_category (
    category_identifier TINYINT,
    last_modification_timestamp TIMESTAMP,
    category_name VARCHAR(25) 
);

COMMENT ON TABLE film_category IS 'This table lists the categories that can be assigned to a film and is joined to the film table through the film_category table.';
COMMENT ON COLUMN film_category.category_identifier IS 'Primary Key. A unique identifier for each category in the table. Type: Tiny Integer';
COMMENT ON COLUMN film_category.last_modification_timestamp IS 'The timestamp indicating when the row was created or most recently updated. Type: Timestamp';
COMMENT ON COLUMN film_category.category_name IS 'The name of the category, such as "Action", "Animation", "Children", etc. Type: Text';

CREATE TABLE film_category_associations (
    category_identifier TINYINT,
    film_identifier SMALLINT,
    last_modification_timestamp TIMESTAMP 
);

COMMENT ON TABLE film_category_associations IS 'This table supports a many-to-many relationship between films and categories, listing each category applied to a film. It references the film and category tables using foreign keys.';
COMMENT ON COLUMN film_category_associations.category_identifier IS 'Foreign Key. A unique identifier for the category. Type: Tiny Integer';
COMMENT ON COLUMN film_category_associations.film_identifier IS 'Foreign Key. A unique identifier for the film. Type: Small Integer';
COMMENT ON COLUMN film_category_associations.last_modification_timestamp IS 'The timestamp when the row was created or most recently updated. Type: Timestamp';

CREATE TABLE film_information (
    film_description TEXT,
    film_identifier SMALLINT,
    language_identifier TINYINT,
    last_modification_timestamp TIMESTAMP,
    film_duration SMALLINT,
    original_language_identifier TINYINT,
    film_rating ENUM('G','PG','PG-13','R','NC-17'),
    release_year YEAR,
    rental_period TINYINT,
    rental_cost DECIMAL(4,2),
    replacement_fee DECIMAL(5,2),
    special_features_list SET('TRAILERS','COMMENTARIES','DELETEDSCENES','BEHINDTHESCENES'),
    film_title VARCHAR(128) 
);

COMMENT ON TABLE film_information IS 'This table contains a list of all films potentially in stock in the stores. It includes references to the language table and is linked by the film_category, film_actor, and inventory tables.';
COMMENT ON COLUMN film_information.film_description IS 'A short description or plot summary of the film. Type: Text';
COMMENT ON COLUMN film_information.film_identifier IS 'Primary Key. A unique identifier for each film in the table. Type: Small Integer';
COMMENT ON COLUMN film_information.language_identifier IS 'Foreign Key. A reference to the language table that identifies the language of the film. Type: Tiny Integer';
COMMENT ON COLUMN film_information.last_modification_timestamp IS 'Timestamp indicating when the row was created or most recently updated. Type: Timestamp';
COMMENT ON COLUMN film_information.film_duration IS 'The duration of the film in minutes. Type: Small Integer';
COMMENT ON COLUMN film_information.original_language_identifier IS 'Foreign Key. A reference to the language table that identifies the original language of the film before dubbing. Type: Tiny Integer';
COMMENT ON COLUMN film_information.film_rating IS 'The rating assigned to the film. Possible values: G, PG, PG-13, R, NC-17. Type: Enumeration';
COMMENT ON COLUMN film_information.release_year IS 'The year in which the film was released. Type: Year';
COMMENT ON COLUMN film_information.rental_period IS 'The length of the rental period in days. Type: Tiny Integer';
COMMENT ON COLUMN film_information.rental_cost IS 'The cost to rent the film for the specified rental period. Type: Decimal (4,2)';
COMMENT ON COLUMN film_information.replacement_fee IS 'The fee charged to the customer if the film is not returned or is returned in a damaged state. Type: Decimal (5,2)';
COMMENT ON COLUMN film_information.special_features_list IS 'A list of special features included on the DVD, such as Trailers, Commentaries, Deleted Scenes, or Behind the Scenes. Type: Set';
COMMENT ON COLUMN film_information.film_title IS 'The title of the film. Type: Text (128 characters)';

CREATE TABLE film_inventory (
    film_identifier SMALLINT,
    inventory_identifier MEDIUMINT,
    last_modification_timestamp TIMESTAMP,
    home_store_identifier TINYINT 
);

COMMENT ON TABLE film_inventory IS 'This table contains one row for each copy of a given film in a given store. It refers to the film and store tables using foreign keys and is referred to by the rental table.';
COMMENT ON COLUMN film_inventory.film_identifier IS 'Foreign Key. A reference to the film this item represents. Type: Small Integer';
COMMENT ON COLUMN film_inventory.inventory_identifier IS 'Primary Key. A unique identifier used to uniquely identify each item in the inventory. Type: Medium Integer';
COMMENT ON COLUMN film_inventory.last_modification_timestamp IS 'When the row was created or most recently updated. Type: Timestamp';
COMMENT ON COLUMN film_inventory.home_store_identifier IS 'Foreign Key. A reference to the store stocking this item. Type: Tiny Integer';

CREATE TABLE film_language_information (
    language_identifier TINYINT,
    last_modification_timestamp TIMESTAMP,
    language_name CHAR(20) 
);

COMMENT ON TABLE film_language_information IS 'This table lists possible languages that films can have for their language and original language values, referenced by the film table.';
COMMENT ON COLUMN film_language_information.language_identifier IS 'Primary Key. A unique identifier used to uniquely identify each language. Type: Tiny Integer';
COMMENT ON COLUMN film_language_information.last_modification_timestamp IS 'The timestamp when the row was created or most recently updated. Type: Timestamp';
COMMENT ON COLUMN film_language_information.language_name IS 'The English name of the language. Type: Character(20)';

CREATE TABLE film_summary_information (
    film_description TEXT,
    film_identifier SMALLINT,
    film_title VARCHAR(255) 
);

COMMENT ON TABLE film_summary_information IS 'This table contains summaries, titles, and identifiers for films, synchronized with the film table via triggers on film table INSERT, UPDATE, and DELETE operations. Direct modifications should be made to the film table only.';
COMMENT ON COLUMN film_summary_information.film_description IS 'A short description or plot summary of the film. Type: Text';
COMMENT ON COLUMN film_summary_information.film_identifier IS 'Primary Key. A unique identifier used to identify each film in the table. Type: Small Integer';
COMMENT ON COLUMN film_summary_information.film_title IS 'The title of the film. Type: Text';

CREATE TABLE payment_records (
    payment_amount DECIMAL(5,2),
    customer_identifier SMALLINT,
    last_modification_timestamp TIMESTAMP,
    payment_processing_date DATETIME,
    payment_identifier SMALLINT,
    rental_identifier INT,
    staff_identifier TINYINT 
);

COMMENT ON TABLE payment_records IS 'This table records each payment made by a customer, including the amount, related rental, payment date, and staff member who processed the payment. It refers to the customer, rental, and staff tables.';
COMMENT ON COLUMN payment_records.payment_amount IS 'The monetary amount of the payment. Type: Decimal(5,2)';
COMMENT ON COLUMN payment_records.customer_identifier IS 'Foreign Key. The customer whose balance the payment is being applied to, referencing the customer table. Type: SmallInt';
COMMENT ON COLUMN payment_records.last_modification_timestamp IS 'Timestamp of when the row was most recently updated. Type: Timestamp';
COMMENT ON COLUMN payment_records.payment_processing_date IS 'The date and time the payment was processed. Type: DateTime';
COMMENT ON COLUMN payment_records.payment_identifier IS 'Primary Key. A unique identifier for each payment. Type: SmallInt';
COMMENT ON COLUMN payment_records.rental_identifier IS 'Foreign Key (Optional). The rental that the payment is being applied to, referencing the rental table. Type: Int';
COMMENT ON COLUMN payment_records.staff_identifier IS 'Foreign Key. The staff member who processed the payment, referencing the staff table. Type: TinyInt';

CREATE TABLE rental_information (
    customer_identifier SMALLINT,
    inventory_identifier MEDIUMINT,
    last_modification_timestamp TIMESTAMP,
    rental_timestamp DATETIME,
    rental_identifier INT,
    return_timestamp DATETIME,
    staff_identifier TINYINT 
);

COMMENT ON TABLE rental_information IS 'This table contains information about each rental of inventory items including who rented the item, when it was rented, when it was returned, and which staff member processed the rental. It refers to the inventory, customer, and staff tables and is referred to by the payment table.';
COMMENT ON COLUMN rental_information.customer_identifier IS 'Foreign Key. The customer renting the item. Reference to the customer table. Type: Small Integer';
COMMENT ON COLUMN rental_information.inventory_identifier IS 'Foreign Key. The item being rented. Reference to the inventory table. Type: Medium Integer';
COMMENT ON COLUMN rental_information.last_modification_timestamp IS 'The timestamp when the row was created or most recently updated. Type: Timestamp';
COMMENT ON COLUMN rental_information.rental_timestamp IS 'The date and time when the item was rented. Type: DateTime';
COMMENT ON COLUMN rental_information.rental_identifier IS 'Primary Key. A unique identifier that uniquely identifies the rental. Type: Integer';
COMMENT ON COLUMN rental_information.return_timestamp IS 'The date and time when the item was returned. Type: DateTime';
COMMENT ON COLUMN rental_information.staff_identifier IS 'Foreign Key. The staff member who processed the rental. Reference to the staff table. Type: Tiny Integer';

CREATE TABLE staff_members (
    is_active BOOLEAN,
    address_identifier SMALLINT,
    email_address VARCHAR(50),
    staff_first_name VARCHAR(45),
    staff_last_name VARCHAR(45),
    last_modification_timestamp TIMESTAMP,
    login_password_hash VARCHAR(40),
    photograph_blob BLOB,
    staff_identifier TINYINT,
    home_store_identifier TINYINT,
    login_username VARCHAR(16) 
);

COMMENT ON TABLE staff_members IS 'This table lists all staff members, including their email address, login information, and photograph. It links to the store and address tables using foreign keys and is referenced by rental, payment, and store tables.';
COMMENT ON COLUMN staff_members.is_active IS 'Indicates whether the employee is currently active. If the employee leaves, this is set to FALSE instead of deleting the row. Type: Boolean';
COMMENT ON COLUMN staff_members.address_identifier IS 'Foreign Key. Identifies the staff member's address in the address table. Type: Small Integer';
COMMENT ON COLUMN staff_members.email_address IS 'The staff member's email address. Type: Text';
COMMENT ON COLUMN staff_members.staff_first_name IS 'The first name of the staff member. Type: Text';
COMMENT ON COLUMN staff_members.staff_last_name IS 'The last name of the staff member. Type: Text';
COMMENT ON COLUMN staff_members.last_modification_timestamp IS 'The timestamp of when the row was created or most recently updated. Type: Timestamp';
COMMENT ON COLUMN staff_members.login_password_hash IS 'The password hash used by the staff member to access the rental system. The password should be stored as a hash using the SHA2() function. Type: Text';
COMMENT ON COLUMN staff_members.photograph_blob IS 'A BLOB containing a photograph of the employee. Type: BLOB';
COMMENT ON COLUMN staff_members.staff_identifier IS 'Primary Key. A unique identifier that uniquely identifies the staff member. Type: Tiny Integer';
COMMENT ON COLUMN staff_members.home_store_identifier IS 'Foreign Key. Identifies the staff member's home store. The employee can work at other stores but is generally assigned to this store. Type: Tiny Integer';
COMMENT ON COLUMN staff_members.login_username IS 'The username used by the staff member to access the rental system. Type: Text';

CREATE TABLE store_information (
    store_address_identifier SMALLINT,
    last_modification_timestamp TIMESTAMP,
    manager_identifier TINYINT,
    store_identifier TINYINT 
);

COMMENT ON TABLE store_information IS 'This table lists all stores in the system, assigning inventory to specific stores, and associating staff and customers to a home store. It references the staff and address tables using foreign keys and is referenced by the staff, customer, and inventory tables.';
COMMENT ON COLUMN store_information.store_address_identifier IS 'Foreign Key. A unique identifier for the store's address, pointing to the address table. Type: Small Integer';
COMMENT ON COLUMN store_information.last_modification_timestamp IS 'Timestamp of when the row was created or most recently updated. Type: Timestamp';
COMMENT ON COLUMN store_information.manager_identifier IS 'Foreign Key. A unique identifier for the store manager, pointing to the staff table. Type: Tiny Integer';
COMMENT ON COLUMN store_information.store_identifier IS 'Primary Key. A unique identifier that uniquely identifies the store. Type: Tiny Integer';