-- Table: Bank
CREATE TABLE Bank (
    Code VARCHAR(10) PRIMARY KEY,
    Name VARCHAR(50) NOT NULL,
    Address VARCHAR(100)
);

-- Table: Branch
CREATE TABLE Branch (
    Branch_id INT PRIMARY KEY,
    Name VARCHAR(50) NOT NULL,
    Address VARCHAR(100),
    Bank_Code VARCHAR(10),
    FOREIGN KEY (Bank_Code) REFERENCES Bank(Code)
);

-- Table: Loan
CREATE TABLE Loan (
    Loan_id INT PRIMARY KEY,
    Loan_type VARCHAR(20),
    Amount DECIMAL(15, 2),
    Branch_id INT,
    FOREIGN KEY (Branch_id) REFERENCES Branch(Branch_id)
);

-- Table: Customer
CREATE TABLE Customer (
    Custid INT PRIMARY KEY,
    Name VARCHAR(50) NOT NULL,
    Phone VARCHAR(15),
    Address VARCHAR(100)
);

-- Table: Account
CREATE TABLE Account (
    Account_No INT PRIMARY KEY,
    Acc_Type VARCHAR(20),
    Balance DECIMAL(15, 2),
    Branch_id INT,
    FOREIGN KEY (Branch_id) REFERENCES Branch(Branch_id)
);

-- Relationship Table: Offer (Between Branch and Loan)
CREATE TABLE Offer (
    Branch_id INT,
    Loan_id INT,
    PRIMARY KEY (Branch_id, Loan_id),
    FOREIGN KEY (Branch_id) REFERENCES Branch(Branch_id),
    FOREIGN KEY (Loan_id) REFERENCES Loan(Loan_id)
);

-- Relationship Table: Maintain (Between Branch and Account)
CREATE TABLE Maintain (
    Branch_id INT,
    Account_No INT,
    PRIMARY KEY (Branch_id, Account_No),
    FOREIGN KEY (Branch_id) REFERENCES Branch(Branch_id),
    FOREIGN KEY (Account_No) REFERENCES Account(Account_No)
);

-- Relationship Table: Availed_By (Between Customer and Loan)
CREATE TABLE Availed_By (
    Custid INT,
    Loan_id INT,
    PRIMARY KEY (Custid, Loan_id),
    FOREIGN KEY (Custid) REFERENCES Customer(Custid),
    FOREIGN KEY (Loan_id) REFERENCES Loan(Loan_id)
);

-- Relationship Table: Hold_By (Between Customer and Account)
CREATE TABLE Hold_By (
    Custid INT,
    Account_No INT,
    PRIMARY KEY (Custid, Account_No),
    FOREIGN KEY (Custid) REFERENCES Customer(Custid),
    FOREIGN KEY (Account_No) REFERENCES Account(Account_No)
);