-- Constraints for banker_info table
ALTER TABLE banker_info
ADD CONSTRAINT fk_banker_info_branch
FOREIGN KEY (branch_id)
REFERENCES branch(branch_id);

-- Constraints for account table
ALTER TABLE account
ADD CONSTRAINT fk_account_branch
FOREIGN KEY (branch_id)
REFERENCES branch(branch_id);

-- Constraints for transaction table
ALTER TABLE transaction
ADD CONSTRAINT fk_transaction_customer
FOREIGN KEY (customer_id)
REFERENCES customer(customer_id);

-- Foreign key constraint for customer table
ALTER TABLE customer
ADD CONSTRAINT fk_customer_account
FOREIGN KEY (account_id)
REFERENCES account(account_id);


ALTER TABLE transaction
ADD CONSTRAINT fk_transaction_account
FOREIGN KEY (account_id)
REFERENCES account(account_id);

-- Constraints for customer_credit_card table
ALTER TABLE customer_credit_card
ADD CONSTRAINT fk_credit_card_customer
FOREIGN KEY (customer_id)
REFERENCES customer(customer_id);

ALTER TABLE customer_credit_card
ADD CONSTRAINT fk_credit_card_account
FOREIGN KEY (account_id)
REFERENCES account(account_id);

-- Constraints for loan table
ALTER TABLE loan
ADD CONSTRAINT fk_loan_branch
FOREIGN KEY (branch_id)
REFERENCES branch(branch_id);

ALTER TABLE loan
ADD CONSTRAINT fk_loan_account
FOREIGN KEY (account_id)
REFERENCES account(account_id);

-- Constraints for loan_payment table
ALTER TABLE loan_payment
ADD CONSTRAINT fk_loan_payment_loan
FOREIGN KEY (loan_id)
REFERENCES loan(loan_id);

-- Constraints for borrower table
ALTER TABLE borrower
ADD CONSTRAINT fk_borrower_loan
FOREIGN KEY (loan_id)
REFERENCES loan(loan_id);

ALTER TABLE borrower
ADD CONSTRAINT fk_borrower_customer
FOREIGN KEY (customer_id)
REFERENCES customer(customer_id);