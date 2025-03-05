CREATE TABLE actor (
    actor_id SMALLINT,
    first_name VARCHAR(45),
    last_name VARCHAR(45),
    last_update TIMESTAMP
);

COMMENT ON TABLE actor IS 'The actor table lists information for all actors. The actor table is joined to the film table by means of the film_actor table.';';
COMMENT ON COLUMN actor.actor_id IS 'A surrogate primary key used to uniquely identify each actor in the table.';
COMMENT ON COLUMN actor.first_name IS 'The actor\';
COMMENT ON COLUMN actor.last_name IS 'The actor\';
COMMENT ON COLUMN actor.last_update IS 'When the row was created or most recently updated.';

CREATE TABLE address (
    address VARCHAR(50),
    address2 VARCHAR(50),
    address_id SMALLINT,
    city_id SMALLINT,
    district VARCHAR(20),
    last_update TIMESTAMP,
    location GEOMETRY,
    phone VARCHAR(20),
    postal_code VARCHAR(10)
);

COMMENT ON TABLE address IS 'The address table contains address information for customers, staff, and stores. The address table primary key appears as a foreign key in the customer, staff, and store tables.';';
COMMENT ON COLUMN address.address IS 'The first line of an address.';
COMMENT ON COLUMN address.address2 IS 'An optional second line of an address.';
COMMENT ON COLUMN address.address_id IS 'A surrogate primary key used to uniquely identify each address in the table.';
COMMENT ON COLUMN address.city_id IS 'A foreign key pointing to the city table.';
COMMENT ON COLUMN address.district IS 'The region of an address, this may be a state, province, prefecture, etc.';
COMMENT ON COLUMN address.last_update IS 'When the row was created or most recently updated.';
COMMENT ON COLUMN address.location IS 'A Geometry column with a spatial index on it.';
COMMENT ON COLUMN address.phone IS 'The telephone number for the address.';
COMMENT ON COLUMN address.postal_code IS 'The postal code or ZIP code of the address (where applicable).';

CREATE TABLE category (
    category_id TINYINT,
    last_update TIMESTAMP,
    name VARCHAR(25)
);

COMMENT ON TABLE category IS 'The category table lists the categories that can be assigned to a film. The category table is joined to the film table by means of the film_category table.';';
COMMENT ON COLUMN category.category_id IS 'A surrogate primary key used to uniquely identify each category in the table.';
COMMENT ON COLUMN category.last_update IS 'When the row was created or most recently updated.';
COMMENT ON COLUMN category.name IS 'The name of the category. such as [ "Action", "Animation", "Children", "Classics", "Comedy", "Documentary", "Drama", "Family", "Foreign", "Games", "Horror", "Music", "New", "Sci-Fi", "Sports", "Travel" ]';

CREATE TABLE city (
    city VARCHAR(50),
    city_id SMALLINT,
    country_id SMALLINT,
    last_update TIMESTAMP
);

COMMENT ON TABLE city IS 'The city table contains a list of cities. It is referred to by a foreign key in the address table and refers to the country table using a foreign key.';';
COMMENT ON COLUMN city.city IS 'The name of the city.';
COMMENT ON COLUMN city.city_id IS 'A surrogate primary key used to uniquely identify each city in the table.';
COMMENT ON COLUMN city.country_id IS 'A foreign key identifying the country that the city belongs to.';
COMMENT ON COLUMN city.last_update IS 'When the row was created or most recently updated.';

CREATE TABLE country (
    country VARCHAR(50),
    country_id SMALLINT,
    last_update TIMESTAMP
);

COMMENT ON TABLE country IS 'The country table contains a list of countries. The country table is referred to by a foreign key in the city table.';';
COMMENT ON COLUMN country.country IS 'The name of the country.';
COMMENT ON COLUMN country.country_id IS 'A surrogate primary key used to uniquely identify each country in the table.';
COMMENT ON COLUMN country.last_update IS 'When the row was created or most recently updated.';

CREATE TABLE customer (
    active BOOLEAN,
    address_id SMALLINT,
    create_date DATETIME,
    customer_id SMALLINT,
    email VARCHAR(50),
    first_name VARCHAR(45),
    last_name VARCHAR(45),
    last_update TIMESTAMP,
    store_id TINYINT
);

COMMENT ON TABLE customer IS 'The customer table contains a list of all customers. It is referred to in the payment and rental tables and refers to the address and store tables using foreign keys.';';
COMMENT ON COLUMN customer.active IS 'Indicates whether the customer is an active customer. Setting this to FALSE serves as an alternative to deleting a customer outright. Most queries should have a WHERE active = TRUE clause.';
COMMENT ON COLUMN customer.address_id IS 'A foreign key identifying the customer address in the address table.';
COMMENT ON COLUMN customer.create_date IS 'The date the customer was added to the system. This date is automatically set using a trigger during an INSERT.';
COMMENT ON COLUMN customer.customer_id IS 'A surrogate primary key used to uniquely identify each customer in the table.';
COMMENT ON COLUMN customer.email IS 'The customer email address.';
COMMENT ON COLUMN customer.first_name IS 'The customer first name.';
COMMENT ON COLUMN customer.last_name IS 'The customer last name.';
COMMENT ON COLUMN customer.last_update IS 'When the row was created or most recently updated.';
COMMENT ON COLUMN customer.store_id IS 'A foreign key identifying the customer "home store." Customers are not limited to renting only from this store, but this is the store at which they generally shop.';

CREATE TABLE film (
    description TEXT,
    film_id SMALLINT,
    language_id TINYINT,
    last_update TIMESTAMP,
    length SMALLINT,
    original_language_id TINYINT,
    rating ENUM('G','PG','PG-13','R','NC-17'),
    release_year YEAR,
    rental_duration TINYINT,
    rental_rate DECIMAL(4,2),
    replacement_cost DECIMAL(5,2),
    special_features SET('TRAILERS','COMMENTARIES','DELETEDSCENES','BEHINDTHESCENES'),
    title VARCHAR(128)
);

COMMENT ON TABLE film IS 'The film table is a list of all films potentially in stock in the stores. The actual in-stock copies of each film are represented in the inventory table. It refers to the language table and is referred to by the film_category, film_actor, and inventory tables.';';
COMMENT ON COLUMN film.description IS 'A short description or plot summary of the film.';
COMMENT ON COLUMN film.film_id IS 'A surrogate primary key used to uniquely identify each film in the table.';
COMMENT ON COLUMN film.language_id IS 'A foreign key pointing at the language table. identifies the language of the film.';
COMMENT ON COLUMN film.last_update IS 'When the row was created or most recently updated.';
COMMENT ON COLUMN film.length IS 'The duration of the film, in minutes.';
COMMENT ON COLUMN film.original_language_id IS 'A foreign key pointing at the language table. identifies the original language of the film. Used when a film has been dubbed into a new language.';
COMMENT ON COLUMN film.rating IS 'The rating assigned to the film. Can be one of: G, PG, PG-13, R, or NC-17.';
COMMENT ON COLUMN film.release_year IS 'The year in which the movie was released.';
COMMENT ON COLUMN film.rental_duration IS 'The length of the rental period, in days.';
COMMENT ON COLUMN film.rental_rate IS 'The cost to rent the film for the period specified in the rental_duration column.';
COMMENT ON COLUMN film.replacement_cost IS 'The amount charged to the customer if the film is not returned or is returned in a damaged state.';
COMMENT ON COLUMN film.special_features IS 'Lists which common special features are included on the DVD. Can be zero or more of: Trailers, Commentaries, Deleted Scenes, Behind the Scenes.';
COMMENT ON COLUMN film.title IS 'The title of the film.';

CREATE TABLE film_actor (
    actor_id SMALLINT,
    film_id SMALLINT,
    last_update TIMESTAMP
);

COMMENT ON TABLE film_actor IS 'The film_actor table is used to support a many-to-many relationship between films and actors. For each actor in a given film, there will be one row in the film_actor table listing the actor and film. It refers to the film and actor tables using foreign keys.';';
COMMENT ON COLUMN film_actor.actor_id IS 'A foreign key identifying the actor.';
COMMENT ON COLUMN film_actor.film_id IS 'A foreign key identifying the film.';
COMMENT ON COLUMN film_actor.last_update IS 'When the row was created or most recently updated.';

CREATE TABLE film_category (
    category_id TINYINT,
    film_id SMALLINT,
    last_update TIMESTAMP
);

COMMENT ON TABLE film_category IS 'The film_category table is used to support a many-to-many relationship between films and categories. For each category applied to a film, there will be one row in the film_category table listing the category and film. It refers to the film and category tables using foreign keys.';';
COMMENT ON COLUMN film_category.category_id IS 'A foreign key identifying the category.';
COMMENT ON COLUMN film_category.film_id IS 'A foreign key identifying the film.';
COMMENT ON COLUMN film_category.last_update IS 'When the row was created or most recently updated.';

CREATE TABLE film_text (
    description TEXT,
    film_id SMALLINT,
    title VARCHAR(255)
);

COMMENT ON TABLE film_text IS 'The film_text table contains the film_id, title and description columns of the film table, with the contents of the table kept in synchrony with the film table by means of triggers on film table INSERT, UPDATE and DELETE operations. Before MySQL server 5.6.10, the film_text table was the only table in the Sakila sample database that used the MyISAM storage engine. This is because full-text search is used for titles and descriptions of films listed in the film table. MyISAM was used because full-text search support with InnoDB was not available until MySQL server 5.6.10. The contents of the film_text table should never be modified directly. All changes should be made to the film table instead.';';
COMMENT ON COLUMN film_text.description IS 'A short description or plot summary of the film.';
COMMENT ON COLUMN film_text.film_id IS 'A surrogate primary key used to uniquely identify each film in the table.';
COMMENT ON COLUMN film_text.title IS 'The title of the film.';

CREATE TABLE inventory (
    film_id SMALLINT,
    inventory_id MEDIUMINT,
    last_update TIMESTAMP,
    store_id TINYINT
);

COMMENT ON TABLE inventory IS 'The inventory table contains one row for each copy of a given film in a given store. It refers to the film and store tables using foreign keys and is referred to by the rental table.';';
COMMENT ON COLUMN inventory.film_id IS 'A foreign key pointing to the film this item represents.';
COMMENT ON COLUMN inventory.inventory_id IS 'A surrogate primary key used to uniquely identify each item in inventory.';
COMMENT ON COLUMN inventory.last_update IS 'When the row was created or most recently updated.';
COMMENT ON COLUMN inventory.store_id IS 'A foreign key pointing to the store stocking this item.';

CREATE TABLE language (
    language_id TINYINT,
    last_update TIMESTAMP,
    name CHAR(20)
);

COMMENT ON TABLE language IS 'The language table is a lookup table listing the possible languages that films can have for their language and original language values. It is referred to by the film table.';';
COMMENT ON COLUMN language.language_id IS 'A surrogate primary key used to uniquely identify each language.';
COMMENT ON COLUMN language.last_update IS 'When the row was created or most recently updated.';
COMMENT ON COLUMN language.name IS 'The English name of the language.';

CREATE TABLE payment (
    amount DECIMAL(5,2),
    customer_id SMALLINT,
    last_update TIMESTAMP,
    payment_date DATETIME,
    payment_id SMALLINT,
    rental_id INT,
    staff_id TINYINT
);

COMMENT ON TABLE payment IS 'The payment table records each payment made by a customer, with information such as the amount and the rental being paid for (when applicable). It refers to the customer, rental, and staff tables.';';
COMMENT ON COLUMN payment.amount IS 'The amount of the payment.';
COMMENT ON COLUMN payment.customer_id IS 'The customer whose balance the payment is being applied to. This is a foreign key reference to the customer table.';
COMMENT ON COLUMN payment.last_update IS 'When the row was created or most recently updated.';
COMMENT ON COLUMN payment.payment_date IS 'The date the payment was processed.';
COMMENT ON COLUMN payment.payment_id IS 'A surrogate primary key used to uniquely identify each payment.';
COMMENT ON COLUMN payment.rental_id IS 'The rental that the payment is being applied to. This is optional because some payments are for outstanding fees and may not be directly related to a rental.';
COMMENT ON COLUMN payment.staff_id IS 'The staff member who processed the payment. This is a foreign key reference to the staff table.';

CREATE TABLE rental (
    customer_id SMALLINT,
    inventory_id MEDIUMINT,
    last_update TIMESTAMP,
    rental_date DATETIME,
    rental_id INT,
    return_date DATETIME,
    staff_id TINYINT
);

COMMENT ON TABLE rental IS 'The rental table contains one row for each rental of each inventory item with information about who rented what item, when it was rented, and when it was returned. It refers to the inventory, customer, and staff tables and is referred to by the payment table.';';
COMMENT ON COLUMN rental.customer_id IS 'The customer renting the item. This is a foreign key reference to the customer table.';
COMMENT ON COLUMN rental.inventory_id IS 'The item being rented. This is a foreign key reference to the inventory table.';
COMMENT ON COLUMN rental.last_update IS 'When the row was created or most recently updated.';
COMMENT ON COLUMN rental.rental_date IS 'The date and time that the item was rented.';
COMMENT ON COLUMN rental.rental_id IS 'A surrogate primary key that uniquely identifies the rental.';
COMMENT ON COLUMN rental.return_date IS 'The date and time the item was returned.';
COMMENT ON COLUMN rental.staff_id IS 'The staff member who processed the rental. This is a foreign key reference to the staff table.';

CREATE TABLE staff (
    active BOOLEAN,
    address_id SMALLINT,
    email VARCHAR(50),
    first_name VARCHAR(45),
    last_name VARCHAR(45),
    last_update TIMESTAMP,
    password VARCHAR(40),
    picture BLOB,
    staff_id TINYINT,
    store_id TINYINT,
    username VARCHAR(16)
);

COMMENT ON TABLE staff IS 'The staff table lists all staff members, including information for email address, login information, and picture. It refers to the store and address tables using foreign keys, and is referred to by the rental, payment, and store tables.';';
COMMENT ON COLUMN staff.active IS 'Whether this is an active employee. If employees leave, their rows are not deleted from this table. instead, this column is set to FALSE.';
COMMENT ON COLUMN staff.address_id IS 'A foreign key to the staff member address in the address table.';
COMMENT ON COLUMN staff.email IS 'The staff member email address.';
COMMENT ON COLUMN staff.first_name IS 'The first name of the staff member.';
COMMENT ON COLUMN staff.last_name IS 'The last name of the staff member.';
COMMENT ON COLUMN staff.last_update IS 'When the row was created or most recently updated.';
COMMENT ON COLUMN staff.password IS 'The password used by the staff member to access the rental system. The password should be stored as a hash using the SHA2() function.';
COMMENT ON COLUMN staff.picture IS 'A BLOB containing a photograph of the employee.';
COMMENT ON COLUMN staff.staff_id IS 'A surrogate primary key that uniquely identifies the staff member.';
COMMENT ON COLUMN staff.store_id IS 'The staff member “home store.” The employee can work at other stores but is generally assigned to the store listed.';
COMMENT ON COLUMN staff.username IS 'The user name used by the staff member to access the rental system.';

CREATE TABLE store (
    address_id SMALLINT,
    last_update TIMESTAMP,
    manager_staff_id TINYINT,
    store_id TINYINT
);

COMMENT ON TABLE store IS 'The store table lists all stores in the system. All inventory is assigned to specific stores, and staff and customers are assigned a “home store”. It refers to the staff and address tables using foreign keys and is referred to by the staff, customer, and inventory tables.';';
COMMENT ON COLUMN store.address_id IS 'A foreign key identifying the address of this store.';
COMMENT ON COLUMN store.last_update IS 'When the row was created or most recently updated.';
COMMENT ON COLUMN store.manager_staff_id IS 'A foreign key identifying the manager of this store.';
COMMENT ON COLUMN store.store_id IS 'A surrogate primary key that uniquely identifies the store.';