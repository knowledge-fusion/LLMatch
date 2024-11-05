-- Comments for Bank table
COMMENT ON TABLE Bank IS 'Bank stores information about the bank, including name, code, and address.';
COMMENT ON COLUMN Bank.Code IS 'Unique code for each bank';
COMMENT ON COLUMN Bank.Name IS 'Name of the bank';
COMMENT ON COLUMN Bank.Address IS 'Address of the bank headquarters';

-- Comments for Branch table
COMMENT ON TABLE Branch IS 'Branch stores details about each branch of the bank.';
COMMENT ON COLUMN Branch.Branch_id IS 'Unique identifier for each branch';
COMMENT ON COLUMN Branch.Name IS 'Name of the branch';
COMMENT ON COLUMN Branch.Address IS 'Address of the branch';
COMMENT ON COLUMN Branch.Bank_Code IS 'Foreign key linking the branch to its bank';

-- Comments for Loan table
COMMENT ON TABLE Loan IS 'Loan contains information about the loans offered by branches.';
COMMENT ON COLUMN Loan.Loan_id IS 'Unique identifier for each loan';
COMMENT ON COLUMN Loan.Loan_type IS 'Type of loan (e.g., personal, mortgage)';
COMMENT ON COLUMN Loan.Amount IS 'Amount of the loan';
COMMENT ON COLUMN Loan.Branch_id IS 'Foreign key linking the loan to the branch offering it';

-- Comments for Customer table
COMMENT ON TABLE Customer IS 'Customer stores personal information about each bank customer.';
COMMENT ON COLUMN Customer.Custid IS 'Unique identifier for each customer';
COMMENT ON COLUMN Customer.Name IS 'Name of the customer';
COMMENT ON COLUMN Customer.Phone IS 'Phone number of the customer';
COMMENT ON COLUMN Customer.Address IS 'Address of the customer';

-- Comments for Account table
COMMENT ON TABLE Account IS 'Account stores information about accounts held by customers at the bank.';
COMMENT ON COLUMN Account.Account_No IS 'Unique identifier for each account';
COMMENT ON COLUMN Account.Acc_Type IS 'Type of account (e.g., savings, checking)';
COMMENT ON COLUMN Account.Balance IS 'Current balance in the account';
COMMENT ON COLUMN Account.Branch_id IS 'Foreign key linking the account to the branch where it is maintained';

-- Comments for Offer relationship table
COMMENT ON TABLE Offer IS 'Offer represents the relationship between branches and the loans they offer.';
COMMENT ON COLUMN Offer.Branch_id IS 'Foreign key linking the offer to a branch';
COMMENT ON COLUMN Offer.Loan_id IS 'Foreign key linking the offer to a loan';

-- Comments for Maintain relationship table
COMMENT ON TABLE Maintain IS 'Maintain represents the relationship between branches and the accounts they manage.';
COMMENT ON COLUMN Maintain.Branch_id IS 'Foreign key linking the maintenance to a branch';
COMMENT ON COLUMN Maintain.Account_No IS 'Foreign key linking the maintenance to an account';

-- Comments for Availed_By relationship table
COMMENT ON TABLE Availed_By IS 'Availed_By represents the relationship between customers and the loans they have taken.';
COMMENT ON COLUMN Availed_By.Custid IS 'Foreign key linking the loan to a customer who availed it';
COMMENT ON COLUMN Availed_By.Loan_id IS 'Foreign key linking the loan to a customer';

-- Comments for Hold_By relationship table
COMMENT ON TABLE Hold_By IS 'Hold_By represents the relationship between customers and the accounts they hold.';
COMMENT ON COLUMN Hold_By.Custid IS 'Foreign key linking the account to the customer who holds it';
COMMENT ON COLUMN Hold_By.Account_No IS 'Foreign key linking the account to the customer';