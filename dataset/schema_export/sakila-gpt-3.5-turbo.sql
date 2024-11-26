CREATE TABLE actor_information (
    actor_identifier SMALLINT,
    actor_first_name VARCHAR(45),
    actor_last_name VARCHAR(45),
    information_last_update TIMESTAMP
);

COMMENT ON TABLE actor_information IS 'This table contains information about all actors in the database. It is joined to the film table by means of the film_actor table.';
COMMENT ON COLUMN actor_information.actor_identifier IS 'Primary Key. A unique identifier used to uniquely identify each actor in the table. Type: Small Integer';
COMMENT ON COLUMN actor_information.actor_first_name IS 'The first name of the actor. Type: Variable Character(45)';
COMMENT ON COLUMN actor_information.actor_last_name IS 'The last name of the actor. Type: Variable Character(45)';
COMMENT ON COLUMN actor_information.information_last_update IS 'The date and time the row was most recently updated. Type: Date and Time';

CREATE TABLE address_information (
    address_line_1 VARCHAR(50),
    address_line_2 VARCHAR(50),
    address_identifier SMALLINT,
    city_identifier SMALLINT,
    region VARCHAR(20),
    information_last_update TIMESTAMP,
    address_location GEOMETRY,
    address_phone VARCHAR(20),
    address_postal_code VARCHAR(10)
);

COMMENT ON TABLE address_information IS 'This table contains address details for customers, staff, and stores. The primary key column in this table appears as a foreign key in the customer, staff, and store tables.';
COMMENT ON COLUMN address_information.address_line_1 IS 'The first line of an address. Type: Variable Character, max length 50.';
COMMENT ON COLUMN address_information.address_line_2 IS 'An optional second line of an address. Type: Variable Character, max length 50.';
COMMENT ON COLUMN address_information.address_identifier IS 'Primary Key. A unique identifier used to uniquely identify each address in the table. Type: Small Integer.';
COMMENT ON COLUMN address_information.city_identifier IS 'Foreign Key. A reference to the city table. Type: Small Integer.';
COMMENT ON COLUMN address_information.region IS 'The region of an address, this may be a state, province, prefecture, etc. Type: Variable Character, max length 20.';
COMMENT ON COLUMN address_information.information_last_update IS 'When the row was created or most recently updated. Type: Timestamp.';
COMMENT ON COLUMN address_information.address_location IS 'A Geometry column with a spatial index on it. Type: Geometry.';
COMMENT ON COLUMN address_information.address_phone IS 'The telephone number for the address. Type: Variable Character, max length 20.';
COMMENT ON COLUMN address_information.address_postal_code IS 'The postal code or ZIP code of the address (where applicable). Type: Variable Character, max length 10.';

CREATE TABLE city_information (
    city_name VARCHAR(50),
    city_identifier SMALLINT,
    country_identifier SMALLINT,
    information_last_update TIMESTAMP
);

COMMENT ON TABLE city_information IS 'This table contains a list of cities and their corresponding country information.';
COMMENT ON COLUMN city_information.city_name IS 'The name of the city. Type: Text';
COMMENT ON COLUMN city_information.city_identifier IS 'Primary Key. A unique identifier used to identify each city in the table. Type: Integer';
COMMENT ON COLUMN city_information.country_identifier IS 'Foreign Key. A reference to the country table. Type: Integer';
COMMENT ON COLUMN city_information.information_last_update IS 'The timestamp of when the row was created or last updated. Type: Timestamp';

CREATE TABLE country_information (
    country_name VARCHAR(50),
    country_identifier SMALLINT,
    information_last_update TIMESTAMP
);

COMMENT ON TABLE country_information IS 'This table contains a list of countries and is referred to by a foreign key in the city table.';
COMMENT ON COLUMN country_information.country_name IS 'The name of the country. Type: Text';
COMMENT ON COLUMN country_information.country_identifier IS 'Primary Key. A unique identifier used to uniquely identify each country in the table. Type: Small Integer';
COMMENT ON COLUMN country_information.information_last_update IS 'When the row was created or most recently updated. Type: Timestamp';

CREATE TABLE customer_information (
    is_active BOOLEAN,
    address_identifier SMALLINT,
    creation_date DATETIME,
    customer_identifier SMALLINT,
    customer_email VARCHAR(50),
    customer_first_name VARCHAR(45),
    customer_last_name VARCHAR(45),
    information_last_update TIMESTAMP,
    store_identifier TINYINT
);

COMMENT ON TABLE customer_information IS 'This table contains a list of all customers. It is referred to in the payment and rental tables and refers to the address and store tables using foreign keys.';
COMMENT ON COLUMN customer_information.is_active IS 'Indicates whether the customer is an active customer. Setting this to FALSE serves as an alternative to deleting a customer outright. Most queries should have a WHERE is_active = TRUE clause. Type: Boolean';
COMMENT ON COLUMN customer_information.address_identifier IS 'Foreign Key. A reference to the customer address in the address table. Type: Small Integer';
COMMENT ON COLUMN customer_information.creation_date IS 'The date the customer was added to the system. This date is automatically set using a trigger during an INSERT. Type: Datetime';
COMMENT ON COLUMN customer_information.customer_identifier IS 'Primary Key. A surrogate primary key used to uniquely identify each customer in the table. Type: Small Integer';
COMMENT ON COLUMN customer_information.customer_email IS 'The customer email address. Type: Text';
COMMENT ON COLUMN customer_information.customer_first_name IS 'The customer first name. Type: Text';
COMMENT ON COLUMN customer_information.customer_last_name IS 'The customer last name. Type: Text';
COMMENT ON COLUMN customer_information.information_last_update IS 'When the row was created or most recently updated. Type: Timestamp';
COMMENT ON COLUMN customer_information.store_identifier IS 'Foreign Key. A reference to the customer "home store." Customers are not limited to renting only from this store, but this is the store at which they generally shop. Type: Tiny Integer';

CREATE TABLE customer_payments (
    payment_amount DECIMAL(5,2),
    customer_identifier SMALLINT,
    information_last_update TIMESTAMP,
    transaction_date DATETIME,
    payment_identifier SMALLINT,
    rental_identifier INT,
    staff_identifier TINYINT
);

COMMENT ON TABLE customer_payments IS 'This table records each payment made by a customer, with information such as the amount and the rental being paid for (when applicable). It refers to the customer, rental, and staff tables.';';
COMMENT ON COLUMN customer_payments.payment_amount IS 'The amount of the payment. Type: Decimal(5,2)';
COMMENT ON COLUMN customer_payments.customer_identifier IS 'Foreign Key. The customer whose balance the payment is being applied to. This is a reference to the customer table. Type: Small Integer';
COMMENT ON COLUMN customer_payments.information_last_update IS 'When the row was created or most recently updated. Type: Timestamp';
COMMENT ON COLUMN customer_payments.transaction_date IS 'The date the payment was processed. Type: Datetime';
COMMENT ON COLUMN customer_payments.payment_identifier IS 'Primary Key. A unique identifier used to uniquely identify each payment. Type: Small Integer';
COMMENT ON COLUMN customer_payments.rental_identifier IS 'Foreign Key. The rental that the payment is being applied to. This is optional because some payments are for outstanding fees and may not be directly related to a rental. Type: Integer';
COMMENT ON COLUMN customer_payments.staff_identifier IS 'Foreign Key. The staff member who processed the payment. This is a reference to the staff table. Type: Tiny Integer';

CREATE TABLE film_actor_relationship (
    actor_identifier SMALLINT,
    film_identifier SMALLINT,
    information_last_update TIMESTAMP
);

COMMENT ON TABLE film_actor_relationship IS 'This table supports the many-to-many relationship between films and actors. For each actor in a given film, there will be one row in the table listing the actor and film.';
COMMENT ON COLUMN film_actor_relationship.actor_identifier IS 'Foreign Key. A unique identifier for the actor table. Type: Small Integer';
COMMENT ON COLUMN film_actor_relationship.film_identifier IS 'Foreign Key. A unique identifier for the film table. Type: Small Integer';
COMMENT ON COLUMN film_actor_relationship.information_last_update IS 'When the row was created or most recently updated. Type: Timestamp';

CREATE TABLE film_category (
    category_identifier TINYINT,
    information_last_update TIMESTAMP,
    category_name VARCHAR(25)
);

COMMENT ON TABLE film_category IS 'This table lists the categories that can be assigned to a film. It is joined with the film table by means of the film_category table.';
COMMENT ON COLUMN film_category.category_identifier IS 'Primary Key. A unique identifier used to uniquely identify each category in the table. Type: Tiny Integer';
COMMENT ON COLUMN film_category.information_last_update IS 'When the row was created or most recently updated. Type: Timestamp';
COMMENT ON COLUMN film_category.category_name IS 'The name of the category. Examples of category names include: "Action", "Animation", "Children", "Classics", "Comedy", "Documentary", "Drama", "Family", "Foreign", "Games", "Horror", "Music", "New", "Sci-Fi", "Sports", "Travel". Type: Varchar(25)';

CREATE TABLE film_description (
    plot_summary TEXT,
    film_identifier SMALLINT,
    film_title VARCHAR(255)
);

COMMENT ON TABLE film_description IS 'This table contains the descriptions and summaries for all the films in the Sakila sample database. Do not modify directly. Use the film table instead.';
COMMENT ON COLUMN film_description.plot_summary IS 'A brief summary of the film's plot. Type: Text.';
COMMENT ON COLUMN film_description.film_identifier IS 'Primary Key. A unique identifier for each film. Type: Small Integer.';
COMMENT ON COLUMN film_description.film_title IS 'The title of the film. Type: Varchar(255).';

CREATE TABLE film_inventory (
    film_identifier SMALLINT,
    inventory_identifier MEDIUMINT,
    information_last_update TIMESTAMP,
    store_identifier TINYINT
);

COMMENT ON TABLE film_inventory IS 'This table contains one row for each copy of a given film in a given store. It refers to the film and store tables using foreign keys and is referred to by the rental table.';
COMMENT ON COLUMN film_inventory.film_identifier IS 'Foreign Key. A reference to the film table. Type: Small Integer';
COMMENT ON COLUMN film_inventory.inventory_identifier IS 'Primary Key. A unique identifier used to uniquely identify each item in inventory. Type: Medium Integer';
COMMENT ON COLUMN film_inventory.information_last_update IS 'Indicates when the row was created or most recently updated. Type: Timestamp';
COMMENT ON COLUMN film_inventory.store_identifier IS 'Foreign Key. A reference to the store table. Type: Tiny Integer';

CREATE TABLE language_lookup (
    language_identifier TINYINT,
    information_last_update TIMESTAMP,
    english_language_name CHAR(20)
);

COMMENT ON TABLE language_lookup IS 'This table is a lookup table used to list the possible languages for films' language and original language values. It is referred to by the film table.';
COMMENT ON COLUMN language_lookup.language_identifier IS 'Primary Key. A unique identifier used to identify each language. Type: Tiny Integer';
COMMENT ON COLUMN language_lookup.information_last_update IS 'The timestamp of when the row was created or most recently updated. Type: Timestamp';
COMMENT ON COLUMN language_lookup.english_language_name IS 'The English name of the language. Type: Character (20)';

CREATE TABLE movie (
    short_description TEXT,
    movie_identifier SMALLINT,
    language_identifier TINYINT,
    information_last_update TIMESTAMP,
    duration SMALLINT,
    original_language_identifier TINYINT,
    movie_rating ENUM('G','PG','PG-13','R','NC-17'),
    release_year YEAR,
    rental_duration TINYINT,
    rental_rate DECIMAL(4,2),
    replacement_cost DECIMAL(5,2),
    common_special_features SET('TRAILERS','COMMENTARIES','DELETEDSCENES','BEHINDTHESCENES'),
    movie_title VARCHAR(128)
);

COMMENT ON TABLE movie IS 'The movie table contains details of all the movies potentially in stock in the stores. The actual in-stock copies of each movie are represented in the inventory table. It refers to the language table and is referred to by the film_category, film_actor, and inventory tables.';
COMMENT ON COLUMN movie.short_description IS 'A short description or plot summary of the movie. Type: Text';
COMMENT ON COLUMN movie.movie_identifier IS 'Primary Key. A surrogate key used to uniquely identify each movie in the table. Type: Smallint';
COMMENT ON COLUMN movie.language_identifier IS 'Foreign Key. A unique identifier from the language table. Identifies the language of the movie. Type: Tinyint';
COMMENT ON COLUMN movie.information_last_update IS 'When the movie information was created or last updated. Type: Timestamp';
COMMENT ON COLUMN movie.duration IS 'The duration of the movie, in minutes. Type: Smallint';
COMMENT ON COLUMN movie.original_language_identifier IS 'Foreign Key. A unique identifier from the language table. Identifies the original language of the movie. Used when a movie has been dubbed into a new language. Type: Tinyint';
COMMENT ON COLUMN movie.movie_rating IS 'The rating assigned to the movie. Can be one of: G, PG, PG-13, R, or NC-17. Type: Enumeration';
COMMENT ON COLUMN movie.release_year IS 'The year in which the movie was released. Type: Year';
COMMENT ON COLUMN movie.rental_duration IS 'The length of the rental period, in days. Type: Tinyint';
COMMENT ON COLUMN movie.rental_rate IS 'The cost to rent the movie for the period specified in the rental_duration column. Type: Decimal';
COMMENT ON COLUMN movie.replacement_cost IS 'The cost to replace the movie if it is not returned or is returned in a damaged state. Type: Decimal';
COMMENT ON COLUMN movie.common_special_features IS 'Lists which common special features are included on the DVD. Can be zero or more of: Trailers, Commentaries, Deleted Scenes, Behind the Scenes. Type: Set';
COMMENT ON COLUMN movie.movie_title IS 'The title of the movie. Type: Varchar';

CREATE TABLE movie_category_relationship (
    category_identifier TINYINT,
    movie_identifier SMALLINT,
    information_last_update TIMESTAMP
);

COMMENT ON TABLE movie_category_relationship IS 'This table supports the many-to-many relationship between movies and categories. Each row in the table lists a category and movie that are associated with each other. The table refers to the movie and category tables using foreign keys.';
COMMENT ON COLUMN movie_category_relationship.category_identifier IS 'Foreign Key. Identifies the category associated with the movie. Type: Tiny Integer';
COMMENT ON COLUMN movie_category_relationship.movie_identifier IS 'Foreign Key. Identifies the movie associated with the category. Type: Small Integer';
COMMENT ON COLUMN movie_category_relationship.information_last_update IS 'When the row was created or most recently updated. Type: Timestamp';

CREATE TABLE rental_information (
    customer_identifier SMALLINT,
    inventory_identifier MEDIUMINT,
    information_last_update TIMESTAMP,
    rental_time DATETIME,
    rental_identifier INT,
    return_time DATETIME,
    staff_identifier TINYINT
);

COMMENT ON TABLE rental_information IS 'This table contains information on item rentals, including when an item was rented, who rented it, and when it was returned. It refers to the inventory, customer, and staff tables.';
COMMENT ON COLUMN rental_information.customer_identifier IS 'Foreign Key. A reference to the customer table. Type: Small Integer';
COMMENT ON COLUMN rental_information.inventory_identifier IS 'Foreign Key. A reference to the inventory table. Type: Medium Integer';
COMMENT ON COLUMN rental_information.information_last_update IS 'The date and time when the row was most recently updated. Type: Timestamp';
COMMENT ON COLUMN rental_information.rental_time IS 'The date and time when the item was rented. Type: Date-Time';
COMMENT ON COLUMN rental_information.rental_identifier IS 'Primary Key. A unique identifier that uniquely identifies the rental. Type: Integer';
COMMENT ON COLUMN rental_information.return_time IS 'The date and time when the item was returned. Type: Date-Time';
COMMENT ON COLUMN rental_information.staff_identifier IS 'Foreign Key. A reference to the staff table. Type: Tiny Integer';

CREATE TABLE staff_information (
    is_active BOOLEAN,
    address_identifier SMALLINT,
    staff_email VARCHAR(50),
    staff_first_name VARCHAR(45),
    staff_last_name VARCHAR(45),
    information_last_update TIMESTAMP,
    staff_password VARCHAR(40),
    staff_photo BLOB,
    staff_identifier TINYINT,
    staff_store_identifier TINYINT,
    staff_username VARCHAR(16)
);

COMMENT ON TABLE staff_information IS 'This table contains information for all staff members, including email, login, and picture. It has foreign keys to the store and address tables, and is referenced by the rental, payment, and store tables.';
COMMENT ON COLUMN staff_information.is_active IS 'Indicates if the staff member is currently active. Type: Boolean.';
COMMENT ON COLUMN staff_information.address_identifier IS 'Foreign Key. A reference to the staff member's address in the address_information table. Type: Small Integer.';
COMMENT ON COLUMN staff_information.staff_email IS 'The email address of the staff member. Type: Variable Character (50).';
COMMENT ON COLUMN staff_information.staff_first_name IS 'The first name of the staff member. Type: Variable Character (45).';
COMMENT ON COLUMN staff_information.staff_last_name IS 'The last name of the staff member. Type: Variable Character (45).';
COMMENT ON COLUMN staff_information.information_last_update IS 'Timestamp indicating when the row was created or most recently updated. Type: Timestamp.';
COMMENT ON COLUMN staff_information.staff_password IS 'The password used by the staff member to access the rental system. The password is stored as a hash using the SHA2() function. Type: Variable Character (40).';
COMMENT ON COLUMN staff_information.staff_photo IS 'A BLOB containing a photograph of the staff member. Type: Binary Large Object (BLOB).';
COMMENT ON COLUMN staff_information.staff_identifier IS 'Primary Key. A unique identifier used to identify the staff member. Type: Tiny Integer.';
COMMENT ON COLUMN staff_information.staff_store_identifier IS 'The store identifier of the staff member's "home store". The employee can work at other stores but is generally assigned to the store listed. Type: Tiny Integer.';
COMMENT ON COLUMN staff_information.staff_username IS 'The username used by the staff member to access the rental system. Type: Variable Character (16).';

CREATE TABLE store_information (
    store_address_identifier SMALLINT,
    store_information_last_update TIMESTAMP,
    store_manager_identifier TINYINT,
    store_identifier TINYINT
);

COMMENT ON TABLE store_information IS 'This table contains details of all stores in the system. Inventory, staff, and customers are each associated with a specific store. It is referenced by the staff, customer, and inventory tables via foreign keys and refers to the staff and address tables using foreign keys.';
COMMENT ON COLUMN store_information.store_address_identifier IS 'Foreign Key. Identifies the address of this store. Type: Small Integer';
COMMENT ON COLUMN store_information.store_information_last_update IS 'The date and time when the row was created or most recently updated. Type: Timestamp';
COMMENT ON COLUMN store_information.store_manager_identifier IS 'Foreign Key. Identifies the manager of this store. Type: Tiny Integer';
COMMENT ON COLUMN store_information.store_identifier IS 'Primary Key. A unique identifier used to identify the store. Type: Tiny Integer';