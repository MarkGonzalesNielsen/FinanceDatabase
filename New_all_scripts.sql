SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET utf8 ;
USE `mydb` ;

-- -----------------------------------------------------
-- Table `mydb`.`Category`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Category` (
  `idCategory` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  `type` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`idCategory`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`User`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`User` (
  `idUser` INT NOT NULL AUTO_INCREMENT,
  `username` VARCHAR(45) NOT NULL,
  `password` VARCHAR(45) NOT NULL,
  `email` VARCHAR(45) NOT NULL,
  `created_at` DATE NOT NULL,
  PRIMARY KEY (`idUser`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Account`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Account` (
  `idAccount` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  `saldo` FLOAT NOT NULL,
  `User_idUser` INT NOT NULL,
  PRIMARY KEY (`idAccount`),
  INDEX `fk_Account_User1_idx` (`User_idUser` ASC) VISIBLE,
  CONSTRAINT `fk_Account_User1`
    FOREIGN KEY (`User_idUser`)
    REFERENCES `mydb`.`User` (`idUser`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Transaktion`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Transaktion` (
  `idTransaktion` INT NOT NULL AUTO_INCREMENT,
  `amount` FLOAT NOT NULL,
  `description` VARCHAR(45) NULL,
  `date` DATE NULL,
  `type` ENUM("income", "expends") NULL,
  `Category_idCategory` INT NOT NULL,
  `Account_idAccount` INT NOT NULL,
  PRIMARY KEY (`idTransaktion`),
  INDEX `fk_Transaktion_Category1_idx` (`Category_idCategory` ASC) VISIBLE,
  INDEX `fk_Transaktion_Account1_idx` (`Account_idAccount` ASC) VISIBLE,
  CONSTRAINT `fk_Transaktion_Category1`
    FOREIGN KEY (`Category_idCategory`)
    REFERENCES `mydb`.`Category` (`idCategory`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Transaktion_Account1`
    FOREIGN KEY (`Account_idAccount`)
    REFERENCES `mydb`.`Account` (`idAccount`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Budget`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Budget` (
  `idBudget` INT NOT NULL AUTO_INCREMENT,
  `amount` FLOAT NOT NULL,
  `budget_date` DATE NULL,
  `Category_idCategory` INT NOT NULL,
  `User_idUser` INT NOT NULL,
  PRIMARY KEY (`idBudget`),
  INDEX `fk_Budget_Category1_idx` (`Category_idCategory` ASC) VISIBLE,
  INDEX `fk_Budget_User1_idx` (`User_idUser` ASC) VISIBLE,
  CONSTRAINT `fk_Budget_Category1`
    FOREIGN KEY (`Category_idCategory`)
    REFERENCES `mydb`.`Category` (`idCategory`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Budget_User1`
    FOREIGN KEY (`User_idUser`)
    REFERENCES `mydb`.`User` (`idUser`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Goal`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Goal` (
  `idGoal` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NULL,
  `target_amount` FLOAT NULL,
  `current_amount` FLOAT NULL,
  `target_date` DATE NULL,
  `status` VARCHAR(45) NULL,
  `User_idUser` INT NOT NULL,
  PRIMARY KEY (`idGoal`),
  INDEX `fk_Goal_User1_idx` (`User_idUser` ASC) VISIBLE,
  CONSTRAINT `fk_Goal_User1`
    FOREIGN KEY (`User_idUser`)
    REFERENCES `mydb`.`User` (`idUser`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`GroupAccount`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`GroupAccount` (
  `idGroupAccount` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  `saldo` FLOAT NOT NULL,
  PRIMARY KEY (`idGroupAccount`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`User_has_GroupAccount`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`User_has_GroupAccount` (
  `User_idUser` INT NOT NULL,
  `GroupAccount_idGroupAccount` INT NOT NULL,
  PRIMARY KEY (`User_idUser`, `GroupAccount_idGroupAccount`),
  INDEX `fk_User_has_GroupAccount_GroupAccount1_idx` (`GroupAccount_idGroupAccount` ASC) VISIBLE,
  INDEX `fk_User_has_GroupAccount_User1_idx` (`User_idUser` ASC) VISIBLE,
  CONSTRAINT `fk_User_has_GroupAccount_User1`
    FOREIGN KEY (`User_idUser`)
    REFERENCES `mydb`.`User` (`idUser`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_User_has_GroupAccount_GroupAccount1`
    FOREIGN KEY (`GroupAccount_idGroupAccount`)
    REFERENCES `mydb`.`GroupAccount` (`idGroupAccount`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`plannedtransaktions`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`plannedtransaktions` (
  `idtable1` INT NOT NULL,
  `date` DATE NULL,
  `planneddate` DATE NULL,
  `Transaktion_idTransaktion` INT NOT NULL,
  PRIMARY KEY (`idtable1`),
  INDEX `fk_plannedtransaktions_Transaktion1_idx` (`Transaktion_idTransaktion` ASC) VISIBLE,
  CONSTRAINT `fk_plannedtransaktions_Transaktion1`
    FOREIGN KEY (`Transaktion_idTransaktion`)
    REFERENCES `mydb`.`Transaktion` (`idTransaktion`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

USE mydb;

DELIMITER //

-- ============================
-- Stored Procedures
-- ============================


-- ============================
-- CATEGORY
-- ============================
CREATE PROCEDURE sp_CreateCategory(IN p_name VARCHAR(45), IN p_type VARCHAR(45))
BEGIN
  INSERT INTO Category (name, type) VALUES (p_name, p_type);
END //

CREATE PROCEDURE sp_ReadCategory(IN p_id INT)
BEGIN
  SELECT * FROM Category WHERE idCategory = p_id;
END //

CREATE PROCEDURE sp_UpdateCategory(IN p_id INT, IN p_name VARCHAR(45), IN p_type VARCHAR(45))
BEGIN
  UPDATE Category SET name = p_name, type = p_type WHERE idCategory = p_id;
END //

CREATE PROCEDURE sp_DeleteCategory(IN p_id INT)
BEGIN
  DELETE FROM Category WHERE idCategory = p_id;
END //

-- ============================
-- USER
-- ============================
CREATE PROCEDURE sp_CreateUser(IN p_username VARCHAR(45), IN p_password VARCHAR(45), IN p_email VARCHAR(45), IN p_created_at DATE)
BEGIN
  INSERT INTO User (username, password, email, created_at)
  VALUES (p_username, p_password, p_email, p_created_at);
END //

CREATE PROCEDURE sp_ReadUser(IN p_id INT)
BEGIN
  SELECT * FROM User WHERE idUser = p_id;
END //

CREATE PROCEDURE sp_UpdateUser(IN p_id INT, IN p_username VARCHAR(45), IN p_password VARCHAR(45), IN p_email VARCHAR(45))
BEGIN
  UPDATE User
  SET username = p_username,
      password = p_password,
      email = p_email
  WHERE idUser = p_id;
END //

CREATE PROCEDURE sp_DeleteUser(IN p_id INT)
BEGIN
  DELETE FROM User WHERE idUser = p_id;
END //

-- ============================
-- ACCOUNT
-- ============================
CREATE PROCEDURE sp_CreateAccount(IN p_name VARCHAR(45), IN p_saldo FLOAT, IN p_userId INT)
BEGIN
  INSERT INTO Account (name, saldo, User_idUser)
  VALUES (p_name, p_saldo, p_userId);
END //

CREATE PROCEDURE sp_ReadAccount(IN p_id INT)
BEGIN
  SELECT * FROM Account WHERE idAccount = p_id;
END //

CREATE PROCEDURE sp_UpdateAccount(IN p_id INT, IN p_name VARCHAR(45), IN p_saldo FLOAT)
BEGIN
  UPDATE Account
  SET name = p_name, saldo = p_saldo
  WHERE idAccount = p_id;
END //

CREATE PROCEDURE sp_DeleteAccount(IN p_id INT)
BEGIN
  DELETE FROM Account WHERE idAccount = p_id;
END //

-- ============================
-- TRANSAKTION
-- ============================
CREATE PROCEDURE sp_CreateTransaktion(
  IN p_amount FLOAT,
  IN p_description VARCHAR(45),
  IN p_date DATE,
  IN p_type ENUM('income', 'expends'),
  IN p_categoryId INT,
  IN p_accountId INT)
BEGIN
  INSERT INTO Transaktion (amount, description, date, type, Category_idCategory, Account_idAccount)
  VALUES (p_amount, p_description, p_date, p_type, p_categoryId, p_accountId);
END //

CREATE PROCEDURE sp_ReadTransaktion(IN p_id INT)
BEGIN
  SELECT * FROM Transaktion WHERE idTransaktion = p_id;
END //

CREATE PROCEDURE sp_UpdateTransaktion(
  IN p_id INT,
  IN p_amount FLOAT,
  IN p_description VARCHAR(45),
  IN p_date DATE,
  IN p_type ENUM('income', 'expends'))
BEGIN
  UPDATE Transaktion
  SET amount = p_amount,
      description = p_description,
      date = p_date,
      type = p_type
  WHERE idTransaktion = p_id;
END //

CREATE PROCEDURE sp_DeleteTransaktion(IN p_id INT)
BEGIN
  DELETE FROM Transaktion WHERE idTransaktion = p_id;
END //

-- ============================
-- BUDGET
-- ============================
CREATE PROCEDURE sp_CreateBudget(IN p_amount FLOAT, IN p_budget_date DATE, IN p_categoryId INT, IN p_userId INT)
BEGIN
  INSERT INTO Budget (amount, budget_date, Category_idCategory, User_idUser)
  VALUES (p_amount, p_budget_date, p_categoryId, p_userId);
END //

CREATE PROCEDURE sp_ReadBudget(IN p_id INT)
BEGIN
  SELECT * FROM Budget WHERE idBudget = p_id;
END //

CREATE PROCEDURE sp_UpdateBudget(IN p_id INT, IN p_amount FLOAT, IN p_budget_date DATE)
BEGIN
  UPDATE Budget
  SET amount = p_amount, budget_date = p_budget_date
  WHERE idBudget = p_id;
END //

CREATE PROCEDURE sp_DeleteBudget(IN p_id INT)
BEGIN
  DELETE FROM Budget WHERE idBudget = p_id;
END //

-- ============================
-- GOAL
-- ============================
CREATE PROCEDURE sp_CreateGoal(IN p_name VARCHAR(45), IN p_target_amount FLOAT, IN p_current_amount FLOAT, IN p_target_date DATE, IN p_status VARCHAR(45), IN p_userId INT)
BEGIN
  INSERT INTO Goal (name, target_amount, current_amount, target_date, status, User_idUser)
  VALUES (p_name, p_target_amount, p_current_amount, p_target_date, p_status, p_userId);
END //

CREATE PROCEDURE sp_ReadGoal(IN p_id INT)
BEGIN
  SELECT * FROM Goal WHERE idGoal = p_id;
END //

CREATE PROCEDURE sp_UpdateGoal(IN p_id INT, IN p_name VARCHAR(45), IN p_target_amount FLOAT, IN p_current_amount FLOAT, IN p_target_date DATE, IN p_status VARCHAR(45))
BEGIN
  UPDATE Goal
  SET name = p_name,
      target_amount = p_target_amount,
      current_amount = p_current_amount,
      target_date = p_target_date,
      status = p_status
  WHERE idGoal = p_id;
END //

CREATE PROCEDURE sp_DeleteGoal(IN p_id INT)
BEGIN
  DELETE FROM Goal WHERE idGoal = p_id;
END //

-- ============================
-- GROUP ACCOUNT
-- ============================
CREATE PROCEDURE sp_CreateGroupAccount(IN p_name VARCHAR(45), IN p_saldo FLOAT)
BEGIN
  INSERT INTO GroupAccount (name, saldo) VALUES (p_name, p_saldo);
END //

CREATE PROCEDURE sp_ReadGroupAccount(IN p_id INT)
BEGIN
  SELECT * FROM GroupAccount WHERE idGroupAccount = p_id;
END //

CREATE PROCEDURE sp_UpdateGroupAccount(IN p_id INT, IN p_name VARCHAR(45), IN p_saldo FLOAT)
BEGIN
  UPDATE GroupAccount SET name = p_name, saldo = p_saldo WHERE idGroupAccount = p_id;
END //

CREATE PROCEDURE sp_DeleteGroupAccount(IN p_id INT)
BEGIN
  DELETE FROM GroupAccount WHERE idGroupAccount = p_id;
END //

-- ============================
-- USER_HAS_GROUPACCOUNT
-- ============================
CREATE PROCEDURE sp_CreateUserGroup(IN p_userId INT, IN p_groupId INT)
BEGIN
  INSERT INTO User_has_GroupAccount (User_idUser, GroupAccount_idGroupAccount)
  VALUES (p_userId, p_groupId);
END //

CREATE PROCEDURE sp_ReadUserGroup(IN p_userId INT, IN p_groupId INT)
BEGIN
  SELECT * FROM User_has_GroupAccount
  WHERE User_idUser = p_userId AND GroupAccount_idGroupAccount = p_groupId;
END //

CREATE PROCEDURE sp_DeleteUserGroup(IN p_userId INT, IN p_groupId INT)
BEGIN
  DELETE FROM User_has_GroupAccount
  WHERE User_idUser = p_userId AND GroupAccount_idGroupAccount = p_groupId;
END //

-- ============================
-- PLANNEDTRANSAKTIONS
-- ============================
CREATE PROCEDURE sp_CreatePlannedTransaktion(IN p_id INT, IN p_date DATE, IN p_planneddate DATE, IN p_transId INT)
BEGIN
  INSERT INTO plannedtransaktions (idtable1, date, planneddate, Transaktion_idTransaktion)
  VALUES (p_id, p_date, p_planneddate, p_transId);
END //

CREATE PROCEDURE sp_ReadPlannedTransaktion(IN p_id INT)
BEGIN
  SELECT * FROM plannedtransaktions WHERE idtable1 = p_id;
END //

CREATE PROCEDURE sp_UpdatePlannedTransaktion(IN p_id INT, IN p_date DATE, IN p_planneddate DATE)
BEGIN
  UPDATE plannedtransaktions
  SET date = p_date, planneddate = p_planneddate
  WHERE idtable1 = p_id;
END //

CREATE PROCEDURE sp_DeletePlannedTransaktion(IN p_id INT)
BEGIN
  DELETE FROM plannedtransaktions WHERE idtable1 = p_id;
END //

DELIMITER ;
-- ============================
-- Indexes
-- ============================

-- Faster searches on username and email
CREATE INDEX idx_user_username ON User(username);
CREATE INDEX idx_user_email ON User(email);

-- Faster queries for transactions by date or type
CREATE INDEX idx_transaktion_date ON Transaktion(date);
CREATE INDEX idx_transaktion_type ON Transaktion(type);

-- Faster queries for budgets per user or category
CREATE INDEX idx_budget_user ON Budget(User_idUser);
CREATE INDEX idx_budget_category ON Budget(Category_idCategory);

-- Goals per user and status
CREATE INDEX idx_goal_user ON Goal(User_idUser);
CREATE INDEX idx_goal_status ON Goal(status);

-- Accounts by user
CREATE INDEX idx_account_user ON Account(User_idUser);

-- ============================
-- Triggers
-- ============================
-- Automatically update Account saldo when a transaction is inserted
DELIMITER //
CREATE TRIGGER trg_after_insert_transaktion
AFTER INSERT ON Transaktion
FOR EACH ROW
BEGIN
    IF NEW.type = 'income' THEN
        UPDATE Account SET saldo = saldo + NEW.amount WHERE idAccount = NEW.Account_idAccount;
    ELSEIF NEW.type = 'expends' THEN
        UPDATE Account SET saldo = saldo - NEW.amount WHERE idAccount = NEW.Account_idAccount;
    END IF;
END;
//

-- Prevent deleting a category if transactions exist
CREATE TRIGGER trg_before_delete_category
BEFORE DELETE ON Category
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM Transaktion WHERE Category_idCategory = OLD.idCategory) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot delete category with transactions';
    END IF;
END;
//

-- Automatically update current_amount in Goal when a transaction is added
CREATE TRIGGER trg_after_insert_transaktion_goal
AFTER INSERT ON Transaktion
FOR EACH ROW
BEGIN
    DECLARE cat_user_id INT;
    SELECT User_idUser INTO cat_user_id
    FROM Account
    WHERE idAccount = NEW.Account_idAccount;
    
    UPDATE Goal
    SET current_amount = current_amount + NEW.amount
    WHERE User_idUser = cat_user_id
      AND status = 'active';
END;
//
DELIMITER ;

-- ============================
-- Events
-- ============================
-- Enable event scheduler
SET GLOBAL event_scheduler = ON;

-- Monthly reset of Budget (example: zero-out spent amount)
DELIMITER //
CREATE EVENT ev_reset_budget
ON SCHEDULE EVERY 1 MONTH STARTS '2025-12-01 00:00:00'
DO
BEGIN
    UPDATE Budget SET amount = 0;
END;
//

-- Daily check of planned transactions: insert planned transaction if due today
CREATE EVENT ev_daily_planned_transactions
ON SCHEDULE EVERY 1 DAY STARTS CURRENT_DATE
DO
BEGIN
    INSERT INTO Transaktion (amount, description, date, type, Category_idCategory, Account_idAccount)
    SELECT t.amount, t.description, t.planneddate, t.type, t.Category_idCategory, t.Account_idAccount
    FROM plannedtransaktions t
    WHERE t.planneddate = CURRENT_DATE;
END;
//
DELIMITER ;






-- =========================================
-- View: Budget Status (Actual vs Remaining)
-- =========================================
CREATE OR REPLACE VIEW v_BudgetStatus AS
SELECT 
    b.idBudget,
    c.name AS CategoryName,
    b.amount AS BudgetAmount,
    IFNULL(SUM(t.amount), 0) AS ActualSpent,
    b.amount - IFNULL(SUM(t.amount), 0) AS Remaining
FROM Budget b
JOIN Category c ON b.Category_idCategory = c.idCategory
LEFT JOIN Transaktion t 
       ON t.Category_idCategory = c.idCategory
      AND t.Account_idAccount IN (SELECT idAccount FROM Account WHERE User_idUser = b.User_idUser)
GROUP BY b.idBudget, c.name, b.amount;

-- =========================================
-- View: User Transactions
-- =========================================
CREATE OR REPLACE VIEW v_UserTransactions AS
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
JOIN Account a ON t.Account_idAccount = a.idAccount
JOIN User u ON a.User_idUser = u.idUser
JOIN Category c ON t.Category_idCategory = c.idCategory;

-- =========================================
-- View: Budget Overview
-- =========================================
CREATE OR REPLACE VIEW v_BudgetOverview AS
SELECT 
    u.username,
    c.name AS category_name,
    b.amount AS budget_amount,
    b.budget_date
FROM Budget b
JOIN Category c ON b.Category_idCategory = c.idCategory
JOIN User u ON b.User_idUser = u.idUser;

-- =========================================
-- View: Goal Progress
-- =========================================
CREATE OR REPLACE VIEW v_GoalProgress AS
SELECT 
    u.username,
    g.name AS goal_name,
    g.target_amount,
    g.current_amount,
    g.target_date,
    g.status,
    CASE 
        WHEN g.target_amount = 0 THEN 0
        ELSE (g.current_amount / g.target_amount) * 100
    END AS progress_percent
FROM Goal g
JOIN User u ON g.User_idUser = u.idUser;

-- =========================================
-- View: Account Balances
-- =========================================
CREATE OR REPLACE VIEW v_AccountBalances AS
SELECT 
    u.username,
    a.name AS account_name,
    a.saldo
FROM Account a
JOIN User u ON a.User_idUser = u.idUser;

-- =========================================
-- View: Spending vs Budget
-- =========================================
CREATE OR REPLACE VIEW v_SpendingVsBudget AS
SELECT 
    u.username,
    c.name AS category_name,
    IFNULL(SUM(t.amount), 0) AS total_spent,
    b.amount AS budget_amount,
    IFNULL(SUM(t.amount), 0) - b.amount AS difference
FROM Transaktion t
JOIN Account a ON t.Account_idAccount = a.idAccount
JOIN User u ON a.User_idUser = u.idUser
JOIN Category c ON t.Category_idCategory = c.idCategory
JOIN Budget b ON b.Category_idCategory = c.idCategory 
               AND b.User_idUser = u.idUser
GROUP BY u.username, c.name, b.amount;

DELIMITER ;
