-- Comments for the Branch table
COMMENT ON TABLE branch IS 'Represents a branch of the bank, containing basic information about each branch.';
COMMENT ON COLUMN branch.branch_id IS 'Unique identifier for each branch.';
COMMENT ON COLUMN branch.branch_name IS 'Name of the bank branch.';
COMMENT ON COLUMN branch.assets IS 'Total assets held by the branch.';
COMMENT ON COLUMN branch.branch_address IS 'Physical address of the bank branch.';

-- Comments for the Banker_Info table
COMMENT ON TABLE banker_info IS 'Represents information about bankers, including their affiliation with a specific branch.';
COMMENT ON COLUMN banker_info.banker_id IS 'Unique identifier for each banker.';
COMMENT ON COLUMN banker_info.banker_name IS 'Name of the banker.';
COMMENT ON COLUMN banker_info.branch_id IS 'Foreign key reference to the branch where the banker is employed.';

-- Comments for the Account table
COMMENT ON TABLE account IS 'Represents bank accounts, specifying type, balance, and associated branch.';
COMMENT ON COLUMN account.account_id IS 'Unique identifier for each bank account.';
COMMENT ON COLUMN account.account_type IS 'Type of the bank account (e.g., savings, current).';
COMMENT ON COLUMN account.account_balance IS 'Current balance of the bank account.';
COMMENT ON COLUMN account.branch_id IS 'Foreign key reference to the branch associated with the account.';

-- Table comment
COMMENT ON TABLE customer IS 'Table to store customer information for the banking system.';

-- Column comments
COMMENT ON COLUMN customer.customer_id IS 'Primary key to uniquely identify each customer.';
COMMENT ON COLUMN customer.customer_name IS 'Name of the customer.';
COMMENT ON COLUMN customer.mobileno IS 'Mobile number of the customer.';
COMMENT ON COLUMN customer.dob IS 'Date of birth of the customer.';
COMMENT ON COLUMN customer.account_id IS 'Foreign key referring to the associated account in the account table.';


-- Comments for the Transaction table
COMMENT ON TABLE transaction IS 'Records all transactions made by customers, linked to both account and customer.';
COMMENT ON COLUMN transaction.transaction_id IS 'Unique identifier for each transaction.';
COMMENT ON COLUMN transaction.amount IS 'Amount involved in the transaction.';
COMMENT ON COLUMN transaction.customer_id IS 'Foreign key reference to the customer who initiated the transaction.';
COMMENT ON COLUMN transaction.account_id IS 'Foreign key reference to the account associated with the transaction.';

-- Comments for the Customer_Credit_Card table
COMMENT ON TABLE customer_credit_card IS 'Represents credit cards issued to customers, linked to customer and account.';
COMMENT ON COLUMN customer_credit_card.credit_card_id IS 'Unique identifier for each credit card.';
COMMENT ON COLUMN customer_credit_card.expiry_date IS 'Expiry date of the credit card.';
COMMENT ON COLUMN customer_credit_card.card_limit IS 'Credit limit of the credit card.';
COMMENT ON COLUMN customer_credit_card.customer_id IS 'Foreign key reference to the customer who owns the credit card.';
COMMENT ON COLUMN customer_credit_card.account_id IS 'Foreign key reference to the account associated with the credit card.';

-- Comments for the Loan table
COMMENT ON TABLE loan IS 'Records loans issued by the branch to specific accounts, tracking issued and remaining amounts.';
COMMENT ON COLUMN loan.loan_id IS 'Unique identifier for each loan.';
COMMENT ON COLUMN loan.issued_amount IS 'Total loan amount initially issued.';
COMMENT ON COLUMN loan.remaining_amount IS 'Outstanding balance remaining on the loan.';
COMMENT ON COLUMN loan.branch_id IS 'Foreign key reference to the branch that issued the loan.';
COMMENT ON COLUMN loan.account_id IS 'Foreign key reference to the account associated with the loan.';

-- Comments for the Loan_Payment table
COMMENT ON TABLE loan_payment IS 'Tracks payments made towards loans, with each payment linked to a specific loan.';
COMMENT ON COLUMN loan_payment.loan_payment_id IS 'Unique identifier for each loan payment record.';
COMMENT ON COLUMN loan_payment.amount IS 'Amount of payment made towards the loan.';
COMMENT ON COLUMN loan_payment.loan_id IS 'Foreign key reference to the loan being repaid.';

-- Comments for the Borrower table
COMMENT ON TABLE borrower IS 'Represents customers who have taken loans, linking customers to specific loans they borrowed.';
COMMENT ON COLUMN borrower.borrower_id IS 'Unique identifier for each borrower entry.';
COMMENT ON COLUMN borrower.customer_id IS 'Foreign key reference to the customer who took the loan.';
COMMENT ON COLUMN borrower.loan_id IS 'Foreign key reference to the loan associated with the borrower.';