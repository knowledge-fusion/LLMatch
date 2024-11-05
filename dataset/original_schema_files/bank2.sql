CREATE TABLE branch(
    branch_id INT NOT NULL AUTO_INCREMENT,
    branch_name VARCHAR(30) NOT NULL,
    assets INT NOT NULL,
    branch_address VARCHAR(255) NOT NULL,
    PRIMARY KEY(branch_id)
);


CREATE TABLE banker_info(
    banker_id INT NOT NULL AUTO_INCREMENT,
    banker_name VARCHAR(255) NOT NULL,
    branch_id INT NOT NULL,
    PRIMARY KEY (banker_id),
    FOREIGN KEY (branch_id) REFERENCES branch(branch_id)
);

CREATE TABLE account(
    account_id INT NOT NULL AUTO_INCREMENT,
    account_type VARCHAR(30) NOT NULL,
    account_balance INT NOT NULL,
    branch_id INT NOT NULL,
    PRIMARY KEY (account_id),
    FOREIGN KEY (branch_id) REFERENCES branch(branch_id)
);

CREATE TABLE account(
    account_id INT NOT NULL AUTO_INCREMENT,
    account_type VARCHAR(30) NOT NULL,
    account_balance INT NOT NULL,
    branch_id INT NOT NULL,
    PRIMARY KEY (account_id),
    FOREIGN KEY (branch_id) REFERENCES branch(branch_id)
);

CREATE TABLE transaction(
    transaction_id INT NOT NULL AUTO_INCREMENT,
    amount INT NOT NULL,
    customer_id INT NOT NULL,
    account_id INT NOT NULL,
    PRIMARY KEY (transaction_id),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    FOREIGN KEY (account_id) REFERENCES account(account_id)
);

CREATE TABLE customer(
    customer_id INT NOT NULL AUTO_INCREMENT,
    customer_name VARCHAR(30) NOT NULL,
    mobileno VARCHAR(10) NOT NULL,
    dob DATE,
    account_id INT NOT NULL,
    PRIMARY KEY (customer_id),
    FOREIGN KEY (account_id) REFERENCES account(account_id)
);

CREATE TABLE customer_credit_card(
    credit_card_id INT NOT NULL AUTO_INCREMENT,
    expiry_date DATE NOT NULL,
    card_limit INT NOT NULL,
    customer_id INT NOT NULL,
    account_id INT NOT NULL,
    PRIMARY KEY (credit_card_id),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    FOREIGN KEY (account_id) REFERENCES account(account_id)
);


CREATE TABLE loan(
    loan_id INT NOT NULL AUTO_INCREMENT,
    issued_amount INT NOT NULL,
    remaining_amount INT NOT NULL,
    branch_id INT NOT NULL,
    account_id INT NOT NULL,
    PRIMARY KEY(loan_id),
    FOREIGN KEY (branch_id) REFERENCES branch(branch_id),
    FOREIGN KEY (account_id) REFERENCES account(account_id)
);


CREATE TABLE loan_payment(
    loan_payment_id INT NOT NULL AUTO_INCREMENT,
    amount INT NOT NULL,
    loan_id INT NOT NULL,
    PRIMARY KEY (loan_payment_id),
    FOREIGN KEY (loan_id) REFERENCES loan(loan_id)
);


CREATE TABLE borrower(
    borrower_id INT NOT NULL AUTO_INCREMENT,
    customer_id INT NOT NULL,
    loan_id INT NOT NULL,
    PRIMARY KEY (borrower_id),
    FOREIGN KEY (loan_id) REFERENCES loan(loan_id),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);


