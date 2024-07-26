ALTER TABLE address
ADD CONSTRAINT fk_address_city
FOREIGN KEY (city_id) REFERENCES city (city_id)
;

ALTER TABLE city
ADD CONSTRAINT fk_city_country
FOREIGN KEY (country_id) REFERENCES country (country_id)
;

ALTER TABLE customer
ADD CONSTRAINT fk_customer_address
FOREIGN KEY (address_id) REFERENCES address (address_id)
;
ALTER TABLE customer
ADD CONSTRAINT fk_customer_store
FOREIGN KEY (store_id) REFERENCES store (store_id)
;

ALTER TABLE film
ADD CONSTRAINT fk_film_language
FOREIGN KEY (language_id) REFERENCES language (language_id)
;
ALTER TABLE film
ADD CONSTRAINT fk_film_language_original
FOREIGN KEY (original_language_id) REFERENCES language (language_id)
;

ALTER TABLE film_actor
ADD CONSTRAINT fk_film_actor_actor
FOREIGN KEY (actor_id) REFERENCES actor (actor_id)
;
ALTER TABLE film_actor
ADD CONSTRAINT fk_film_actor_film
FOREIGN KEY (film_id) REFERENCES film (film_id)
;

ALTER TABLE film_category
ADD CONSTRAINT fk_film_category_film
FOREIGN KEY (film_id) REFERENCES film (film_id)
;
ALTER TABLE film_category
ADD CONSTRAINT fk_film_category_category
FOREIGN KEY (category_id) REFERENCES category (category_id)
;

ALTER TABLE inventory
ADD CONSTRAINT fk_inventory_store
FOREIGN KEY (store_id) REFERENCES store (store_id)
;
ALTER TABLE inventory
ADD CONSTRAINT fk_inventory_film
FOREIGN KEY (film_id) REFERENCES film (film_id)
;

ALTER TABLE payment
ADD CONSTRAINT fk_payment_rental
FOREIGN KEY (rental_id) REFERENCES rental (rental_id)
;
ALTER TABLE payment
ADD CONSTRAINT fk_payment_customer
FOREIGN KEY (customer_id) REFERENCES customer (customer_id)
;
ALTER TABLE payment
ADD CONSTRAINT fk_payment_staff
FOREIGN KEY (staff_id) REFERENCES staff (staff_id)
;

ALTER TABLE rental
ADD CONSTRAINT fk_rental_staff
FOREIGN KEY (staff_id) REFERENCES staff (staff_id)
;
ALTER TABLE rental
ADD CONSTRAINT fk_rental_inventory
FOREIGN KEY (inventory_id) REFERENCES inventory (inventory_id)
;
ALTER TABLE rental
ADD CONSTRAINT fk_rental_customer
FOREIGN KEY (customer_id) REFERENCES customer (customer_id)
;

ALTER TABLE staff
ADD CONSTRAINT fk_staff_store
FOREIGN KEY (store_id) REFERENCES store (store_id)
;
ALTER TABLE staff
ADD CONSTRAINT fk_staff_address
FOREIGN KEY (address_id) REFERENCES address (address_id)
;

ALTER TABLE store
ADD CONSTRAINT fk_store_staff
FOREIGN KEY (manager_staff_id) REFERENCES staff (staff_id)
;
ALTER TABLE store
ADD CONSTRAINT fk_store_address
FOREIGN KEY (address_id) REFERENCES address (address_id)
;