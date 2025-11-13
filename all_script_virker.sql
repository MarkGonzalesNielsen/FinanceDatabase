-- ===================================
-- 0️⃣ Database
-- ===================================
CREATE DATABASE IF NOT EXISTS BudgetDB;
USE BudgetDB;

DELIMITER //

-- ===================================
-- 1️⃣ Tables
-- ===================================
CREATE TABLE User (
    idUser INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(45),
    password VARCHAR(45),
    email VARCHAR(45),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Account (
    idAccount INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    name VARCHAR(45),
    saldo FLOAT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE Category (
    idCategory INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    name VARCHAR(45),
    type FLOAT
);

CREATE TABLE Budget (
    idBudget INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    category_id INT,
    amount FLOAT,
    budget_date DATE
);

CREATE TABLE Goal (
    idGoal INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    name VARCHAR(45),
    target_amount FLOAT,
    current_amount FLOAT,
    target_date DATE,
    status VARCHAR(45)
);

CREATE TABLE Transaktion (
    idTransaction INT AUTO_INCREMENT PRIMARY KEY,
    account_id INT NOT NULL,
    amount FLOAT,
    description VARCHAR(45),
    date DATE,
    type VARCHAR(45),
    category_id INT
);

-- Optional log table for triggers
CREATE TABLE IF NOT EXISTS BudgetLog (
    id INT AUTO_INCREMENT PRIMARY KEY,
    Budget_id INT,
    action VARCHAR(45),
    action_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===================================
-- 2️⃣ Indexes
-- ===================================
-- User
CREATE INDEX idx_user_username ON User(username);
CREATE INDEX idx_user_email ON User(email);

-- Account
CREATE INDEX idx_account_user ON Account(user_id);
CREATE INDEX idx_account_name ON Account(name);

-- Budget
CREATE INDEX idx_budget_user ON Budget(user_id);
CREATE INDEX idx_budget_category_date ON Budget(category_id, budget_date);

-- Goal
CREATE INDEX idx_goal_user ON Goal(user_id);
CREATE INDEX idx_goal_status ON Goal(status);
CREATE INDEX idx_goal_target_date ON Goal(target_date);

-- Transaktion
CREATE INDEX idx_transaktion_account ON Transaktion(account_id);
CREATE INDEX idx_transaktion_category ON Transaktion(category_id);
CREATE INDEX idx_transaktion_date ON Transaktion(date);
CREATE INDEX idx_transaktion_type ON Transaktion(type);

-- ===================================
-- 3️⃣ Triggers
-- ===================================
-- Update updated_at on Account
CREATE TRIGGER trg_update_account
BEFORE UPDATE ON Account
FOR EACH ROW
BEGIN
    SET NEW.updated_at = NOW();
END //

-- Log Budget insert
CREATE TRIGGER trg_after_insert_budget
AFTER INSERT ON Budget
FOR EACH ROW
BEGIN
    INSERT INTO BudgetLog (Budget_id, action, action_date)
    VALUES (NEW.idBudget, 'INSERT', NOW());
END //

-- Check if Goal achieved
CREATE TRIGGER trg_CheckGoalAchieved
AFTER UPDATE ON Goal
FOR EACH ROW
BEGIN
    IF NEW.current_amount <> OLD.current_amount AND OLD.status <> 'completed' THEN
        IF NEW.current_amount >= NEW.target_amount THEN
            UPDATE Goal
            SET status = 'completed'
            WHERE idGoal = NEW.idGoal;
        END IF;
    END IF;
END //

-- ===================================
-- 4️⃣ Function
-- ===================================
CREATE FUNCTION fn_GetTotalSpentByCategory(p_category_id INT)
RETURNS FLOAT
READS SQL DATA
BEGIN
    DECLARE v_total_spent FLOAT DEFAULT 0.0;

    SELECT SUM(T.amount)
    INTO v_total_spent
    FROM Transaktion T
    WHERE T.category_id = p_category_id
      AND T.type = 'expends';

    IF v_total_spent IS NULL THEN
        SET v_total_spent = 0.0;
    END IF;

    RETURN v_total_spent;
END //

-- ===================================
-- 5️⃣ CRUD Stored Procedures
-- ===================================
-- Account CRUD
CREATE PROCEDURE CreateAccount(IN p_user_id INT, IN p_name VARCHAR(45), IN p_saldo FLOAT)
BEGIN
    INSERT INTO Account (user_id, name, saldo) VALUES (p_user_id, p_name, p_saldo);
END //

CREATE PROCEDURE GetAllAccounts() BEGIN SELECT * FROM Account; END //
CREATE PROCEDURE GetAccountById(IN p_id INT) BEGIN SELECT * FROM Account WHERE idAccount = p_id; END //
CREATE PROCEDURE UpdateAccount(IN p_account_id INT, IN p_name VARCHAR(45), IN p_saldo FLOAT)
BEGIN UPDATE Account SET name=p_name, saldo=p_saldo WHERE idAccount=p_account_id; END //
CREATE PROCEDURE DeleteAccount(IN p_account_id INT) BEGIN DELETE FROM Account WHERE idAccount=p_account_id; END //

-- User CRUD
CREATE PROCEDURE CreateUser(IN p_username VARCHAR(45), IN p_password VARCHAR(45), IN p_email VARCHAR(45))
BEGIN INSERT INTO User (username,password,email,created_at) VALUES(p_username,p_password,p_email,NOW()); END //
CREATE PROCEDURE GetAllUsers() BEGIN SELECT * FROM User; END //
CREATE PROCEDURE GetUserById(IN p_user_id INT) BEGIN SELECT * FROM User WHERE idUser=p_user_id; END //
CREATE PROCEDURE UpdateUser(IN p_user_id INT, IN p_username VARCHAR(45), IN p_email VARCHAR(45))
BEGIN UPDATE User SET username=p_username,email=p_email WHERE idUser=p_user_id; END //
CREATE PROCEDURE DeleteUser(IN p_user_id INT) BEGIN DELETE FROM User WHERE idUser=p_user_id; END //

-- Category CRUD
CREATE PROCEDURE CreateCategory(IN p_user_id INT, IN p_name VARCHAR(45), IN p_type FLOAT)
BEGIN INSERT INTO Category(user_id,name,type) VALUES(p_user_id,p_name,p_type); END //
CREATE PROCEDURE GetAllCategories() BEGIN SELECT * FROM Category; END //
CREATE PROCEDURE GetCategoryById(IN p_category_id INT) BEGIN SELECT * FROM Category WHERE idCategory=p_category_id; END //
CREATE PROCEDURE UpdateCategory(IN p_category_id INT, IN p_name VARCHAR(45), IN p_type FLOAT)
BEGIN UPDATE Category SET name=p_name,type=p_type WHERE idCategory=p_category_id; END //
CREATE PROCEDURE DeleteCategory(IN p_category_id INT) BEGIN DELETE FROM Category WHERE idCategory=p_category_id; END //

-- Budget CRUD
CREATE PROCEDURE CreateBudget(IN p_user_id INT, IN p_amount FLOAT, IN p_budget_date DATE)
BEGIN INSERT INTO Budget(user_id,amount,budget_date) VALUES(p_user_id,p_amount,p_budget_date); END //
CREATE PROCEDURE GetAllBudgets() BEGIN SELECT * FROM Budget; END //
CREATE PROCEDURE GetBudgetById(IN p_budget_id INT) BEGIN SELECT * FROM Budget WHERE idBudget=p_budget_id; END //
CREATE PROCEDURE UpdateBudget(IN p_budget_id INT, IN p_amount FLOAT, IN p_budget_date DATE)
BEGIN UPDATE Budget SET amount=p_amount,budget_date=p_budget_date WHERE idBudget=p_budget_id; END //
CREATE PROCEDURE DeleteBudget(IN p_budget_id INT) BEGIN DELETE FROM Budget WHERE idBudget=p_budget_id; END //
CREATE PROCEDURE StartNewBudgetMonth()
BEGIN
    DECLARE next_month_date DATE;
    SET next_month_date = DATE_ADD(LAST_DAY(CURDATE()), INTERVAL 1 DAY);
    INSERT INTO Budget(user_id,amount,budget_date,category_id)
    SELECT B.user_id,B.amount,next_month_date,B.category_id
    FROM Budget B
    WHERE B.budget_date = (SELECT MAX(budget_date) FROM Budget);
END //

-- Goal CRUD
CREATE PROCEDURE CreateGoal(IN p_user_id INT, IN p_name VARCHAR(45), IN p_target_amount FLOAT, IN p_current_amount FLOAT, IN p_target_date DATE, IN p_status VARCHAR(45))
BEGIN INSERT INTO Goal(user_id,name,target_amount,current_amount,target_date,status) VALUES(p_user_id,p_name,p_target_amount,p_current_amount,p_target_date,p_status); END //
CREATE PROCEDURE GetAllGoals() BEGIN SELECT * FROM Goal; END //
CREATE PROCEDURE GetGoalById(IN p_goal_id INT) BEGIN SELECT * FROM Goal WHERE idGoal=p_goal_id; END //
CREATE PROCEDURE UpdateGoal(IN p_goal_id INT, IN p_name VARCHAR(45), IN p_target_amount FLOAT, IN p_current_amount FLOAT, IN p_target_date DATE, IN p_status VARCHAR(45))
BEGIN UPDATE Goal SET name=p_name,target_amount=p_target_amount,current_amount=p_current_amount,target_date=p_target_date,status=p_status WHERE idGoal=p_goal_id; END //
CREATE PROCEDURE DeleteGoal(IN p_goal_id INT) BEGIN DELETE FROM Goal WHERE idGoal=p_goal_id; END //

-- Transaktion CRUD
CREATE PROCEDURE CreateTransaction(IN p_account_id INT, IN p_amount FLOAT, IN p_description VARCHAR(45), IN p_date DATE, IN p_type VARCHAR(45), IN p_category_id INT)
BEGIN INSERT INTO Transaktion(account_id,amount,description,date,type,category_id) VALUES(p_account_id,p_amount,p_description,p_date,p_type,p_category_id); END //
CREATE PROCEDURE GetAllTransactions() BEGIN SELECT * FROM Transaktion; END //
CREATE PROCEDURE GetTransactionById(IN p_transaction_id INT) BEGIN SELECT * FROM Transaktion WHERE idTransaction=p_transaction_id; END //
CREATE PROCEDURE UpdateTransaction(IN p_transaction_id INT, IN p_account_id INT, IN p_amount FLOAT, IN p_description VARCHAR(45), IN p_date DATE, IN p_type VARCHAR(45), IN p_category_id INT)
BEGIN UPDATE Transaktion SET account_id=p_account_id,amount=p_amount,description=p_description,date=p_date,type=p_type,category_id=p_category_id WHERE idTransaction=p_transaction_id; END //
CREATE PROCEDURE DeleteTransaction(IN p_transaction_id INT) BEGIN DELETE FROM Transaktion WHERE idTransaction=p_transaction_id; END //

-- ===================================
-- 6️⃣ Views
-- ===================================
CREATE VIEW v_BudgetStatus AS
SELECT 
    b.idBudget,
    c.name AS CategoryName,
    b.amount AS BudgetAmount,
    fn_GetTotalSpentByCategory(c.idCategory) AS ActualSpent,
    b.amount - fn_GetTotalSpentByCategory(c.idCategory) AS Remaining
FROM Budget b
JOIN Category c ON b.category_id = c.idCategory;

CREATE VIEW UserTransactions AS
SELECT 
    u.idUser,
    u.username,
    a.name AS account_name,
    t.amount,
    t.description,
    t.date,
    t.type,
    c.name AS category_name,
    c.type AS category_type
FROM Transaktion t
JOIN Account a ON t.account_id = a.idAccount
JOIN User u ON a.user_id = u.idUser
JOIN Category c ON t.category_id = c.idCategory;

CREATE VIEW BudgetOverview AS
SELECT 
    u.username,
    c.name AS category_name,
    b.amount AS budget_amount,
    b.budget_date
FROM Budget b
JOIN Category c ON b.category_id = c.idCategory
JOIN User u ON b.user_id = u.idUser;

CREATE VIEW GoalProgress AS
SELECT 
    u.username,
    g.name AS goal_name,
    g.target_amount,
    g.current_amount,
    g.target_date,
    g.status,
    (g.current_amount / g.target_amount) * 100 AS progress_percent
FROM Goal g
JOIN User u ON g.user_id = u.idUser;

CREATE VIEW AccountBalances AS
SELECT 
    u.username,
    a.name AS account_name,
    a.saldo
FROM Account a
JOIN User u ON a.user_id = u.idUser;

CREATE VIEW SpendingVsBudget AS
SELECT 
    u.username,
    c.name AS category_name,
    SUM(t.amount) AS total_spent,
    b.amount AS budget_amount,
    (SUM(t.amount) - b.amount) AS difference
FROM Transaktion t
JOIN Account a ON t.account_id = a.idAccount
JOIN User u ON a.user_id = u.idUser
JOIN Category c ON t.category_id = c.idCategory
JOIN Budget b ON b.category_id = c.idCategory 
               AND b.user_id = u.idUser
GROUP BY u.username, c.name, b.amount;

-- ===================================
-- 7️⃣ Events
-- ===================================
CREATE EVENT evt_MonthlyBudgetSetup
ON SCHEDULE EVERY 1 MONTH
STARTS DATE_ADD(MAKEDATE(YEAR(CURDATE()), 1), INTERVAL 1 MONTH)
DO
BEGIN
    CALL StartNewBudgetMonth();
END //

DELIMITER ;
