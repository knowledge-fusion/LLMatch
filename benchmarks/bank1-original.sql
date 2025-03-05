CREATE TABLE account (
    acc_type VARCHAR(20),
    account_no INT,
    balance DECIMAL(15,
    branch_id INT
);

COMMENT ON TABLE account IS 'Account stores information about accounts held by customers at the bank.';';
COMMENT ON COLUMN account.acc_type IS 'Type of account (e.g., savings, checking)';
COMMENT ON COLUMN account.account_no IS 'Unique identifier for each account';
COMMENT ON COLUMN account.balance IS 'Current balance in the account';
COMMENT ON COLUMN account.branch_id IS 'Foreign key linking the account to the branch where it is maintained';

CREATE TABLE availed_by (
    custid INT,
    loan_id INT
);

COMMENT ON TABLE availed_by IS 'Availed_By represents the relationship between customers and the loans they have taken.';';
COMMENT ON COLUMN availed_by.custid IS 'Foreign key linking the loan to a customer who availed it';
COMMENT ON COLUMN availed_by.loan_id IS 'Foreign key linking the loan to a customer';

CREATE TABLE bank (
    address VARCHAR(100),
    code VARCHAR(10),
    name VARCHAR(50)
);

COMMENT ON TABLE bank IS 'Bank stores information about the bank, including name, code, and address.';';
COMMENT ON COLUMN bank.address IS 'Address of the bank headquarters';
COMMENT ON COLUMN bank.code IS 'Unique code for each bank';
COMMENT ON COLUMN bank.name IS 'Name of the bank';

CREATE TABLE branch (
    address VARCHAR(100),
    bank_code VARCHAR(10),
    branch_id INT,
    name VARCHAR(50)
);

COMMENT ON TABLE branch IS 'Branch stores details about each branch of the bank.';';
COMMENT ON COLUMN branch.address IS 'Address of the branch';
COMMENT ON COLUMN branch.bank_code IS 'Foreign key linking the branch to its bank';
COMMENT ON COLUMN branch.branch_id IS 'Unique identifier for each branch';
COMMENT ON COLUMN branch.name IS 'Name of the branch';

CREATE TABLE customer (
    address VARCHAR(100),
    custid INT,
    name VARCHAR(50),
    phone VARCHAR(15)
);

COMMENT ON TABLE customer IS 'Customer stores personal information about each bank customer.';';
COMMENT ON COLUMN customer.address IS 'Address of the customer';
COMMENT ON COLUMN customer.custid IS 'Unique identifier for each customer';
COMMENT ON COLUMN customer.name IS 'Name of the customer';
COMMENT ON COLUMN customer.phone IS 'Phone number of the customer';

CREATE TABLE hold_by (
    account_no INT,
    custid INT
);

COMMENT ON TABLE hold_by IS 'Hold_By represents the relationship between customers and the accounts they hold.';';
COMMENT ON COLUMN hold_by.account_no IS 'Foreign key linking the account to the customer';
COMMENT ON COLUMN hold_by.custid IS 'Foreign key linking the account to the customer who holds it';

CREATE TABLE loan (
    amount DECIMAL(15,
    branch_id INT,
    loan_id INT,
    loan_type VARCHAR(20)
);

COMMENT ON TABLE loan IS 'Loan contains information about the loans offered by branches.';';
COMMENT ON COLUMN loan.amount IS 'Amount of the loan';
COMMENT ON COLUMN loan.branch_id IS 'Foreign key linking the loan to the branch offering it';
COMMENT ON COLUMN loan.loan_id IS 'Unique identifier for each loan';
COMMENT ON COLUMN loan.loan_type IS 'Type of loan (e.g., personal, mortgage)';

CREATE TABLE maintain (
    account_no INT,
    branch_id INT
);

COMMENT ON TABLE maintain IS 'Maintain represents the relationship between branches and the accounts they manage.';';
COMMENT ON COLUMN maintain.account_no IS 'Foreign key linking the maintenance to an account';
COMMENT ON COLUMN maintain.branch_id IS 'Foreign key linking the maintenance to a branch';

CREATE TABLE offer (
    branch_id INT,
    loan_id INT
);

COMMENT ON TABLE offer IS 'Offer represents the relationship between branches and the loans they offer.';';
COMMENT ON COLUMN offer.branch_id IS 'Foreign key linking the offer to a branch';
COMMENT ON COLUMN offer.loan_id IS 'Foreign key linking the offer to a loan';