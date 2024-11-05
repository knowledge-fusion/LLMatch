-- Foreign key constraints for Branch table
ALTER TABLE Branch
ADD CONSTRAINT fk_branch_bank
FOREIGN KEY (Bank_Code)
REFERENCES Bank(Code);

-- Foreign key constraints for Loan table
ALTER TABLE Loan
ADD CONSTRAINT fk_loan_branch
FOREIGN KEY (Branch_id)
REFERENCES Branch(Branch_id);

-- Foreign key constraints for Account table
ALTER TABLE Account
ADD CONSTRAINT fk_account_branch
FOREIGN KEY (Branch_id)
REFERENCES Branch(Branch_id);

-- Foreign key constraints for Offer relationship table
ALTER TABLE Offer
ADD CONSTRAINT fk_offer_branch
FOREIGN KEY (Branch_id)
REFERENCES Branch(Branch_id);

ALTER TABLE Offer
ADD CONSTRAINT fk_offer_loan
FOREIGN KEY (Loan_id)
REFERENCES Loan(Loan_id);

-- Foreign key constraints for Maintain relationship table
ALTER TABLE Maintain
ADD CONSTRAINT fk_maintain_branch
FOREIGN KEY (Branch_id)
REFERENCES Branch(Branch_id);

ALTER TABLE Maintain
ADD CONSTRAINT fk_maintain_account
FOREIGN KEY (Account_No)
REFERENCES Account(Account_No);

-- Foreign key constraints for Availed_By relationship table
ALTER TABLE Availed_By
ADD CONSTRAINT fk_availed_by_customer
FOREIGN KEY (Custid)
REFERENCES Customer(Custid);

ALTER TABLE Availed_By
ADD CONSTRAINT fk_availed_by_loan
FOREIGN KEY (Loan_id)
REFERENCES Loan(Loan_id);

-- Foreign key constraints for Hold_By relationship table
ALTER TABLE Hold_By
ADD CONSTRAINT fk_hold_by_customer
FOREIGN KEY (Custid)
REFERENCES Customer(Custid);

ALTER TABLE Hold_By
ADD CONSTRAINT fk_hold_by_account
FOREIGN KEY (Account_No)
REFERENCES Account(Account_No);