DROP DATABASE Test;
CREATE DATABASE Test;
DROP TABLE IF EXISTS transactions;
DROP TABLE accounts;

 CREATE TABLE accounts (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    balance DECIMAL(10, 2) DEFAULT 0.00
 );
 CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    shop VARCHAR(100) NOT NULL,
    product VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL
 );
-- Insert test data
 INSERT INTO accounts (name, balance) VALUES
    ('Alice', 1000.00),
    ('Bob', 500.00),
    ('Wally', 750.00);
 INSERT INTO products (shop, product, price) VALUES
    ('Joe''s Shop', 'Coke', 2.50),
    ('Joe''s Shop', 'Pepsi', 3.00);

--TASK 3.2
BEGIN;
 UPDATE accounts SET balance = balance - 100.00
    WHERE name = 'Alice';
 UPDATE accounts SET balance = balance + 100.00
    WHERE name = 'Bob';
COMMIT;

SELECT * FROM accounts WHERE name IN ('Alice', 'Bob');

--after transaction balance of Alice and Bob are 900 and 600.
--Grouping guarantees atomicity - ether both operations executed , or neither.
--The money would be deducted from Alice but not credited to Bob, which would lead to a loss of funds.

--3.3 ROLLBACK
 BEGIN;
 UPDATE accounts SET balance = balance - 500.00
    WHERE name = 'Alice';
 SELECT * FROM accounts WHERE name = 'Alice';-- Oops! Wrong amount, let's undo
 ROLLBACK;
 SELECT * FROM accounts WHERE name = 'Alice';
--a)Alice's balance was 500.00 (1000.00 - 500.00).
--b)Alice's balance is 1000.00 (restored to original amount before the transaction started).
--c)When:Errors occur during transaction processing ,Errors occur during transaction processing , User cancels an operation.

--3.4
 BEGIN;
 UPDATE accounts SET balance = balance - 100.00
    WHERE name = 'Alice';
 SAVEPOINT my_savepoint;
UPDATE accounts SET balance = balance + 100.00
    WHERE name = 'Bob';-- Oops, should transfer to Wally instead
 ROLLBACK TO my_savepoint;
 UPDATE accounts SET balance = balance + 100.00
    WHERE name = 'Wally';
 COMMIT;
SELECT * FROM accounts;
--a)Bob - 600 , Alice - 800 , Wally - 850.
--b)Yes, Bob's account was temporarily credited during the transaction However, this change was undone by ROLLBACK TO my_savepoint, which reverted the database to the state just before Bob was credited.
--c)You can undo only part of a transaction instead of all changes since BEGIN/Avoids restarting the entire transaction.

--3.5
-- Scenario A: READ COMMITTED
--terminal 1
 BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
 SELECT * FROM products WHERE shop = 'Joe''s Shop';-- Wait for Terminal 2 to make changes and COMMIT-- Then re-run:
 SELECT * FROM products WHERE shop = 'Joe''s Shop';
 COMMIT;
--terminal 2
 BEGIN;
 DELETE FROM products WHERE shop = 'Joe''s Shop';
 INSERT INTO products (shop, product, price)
    VALUES ('Joe''s Shop', 'Fanta', 3.50);
 COMMIT;

--Scenario B: SERIALIZABLE
--terminal 1
 BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
 SELECT * FROM products WHERE shop = 'Joe''s Shop';-- Wait for Terminal 2 to make changes and COMMIT-- Then re-run:
 SELECT * FROM products WHERE shop = 'Joe''s Shop';
 COMMIT;
--terminal 2
BEGIN;
 DELETE FROM products WHERE shop = 'Joe''s Shop';
 INSERT INTO products (shop, product, price)
    VALUES ('Joe''s Shop', 'Fanta', 3.50);
 COMMIT;

--a)Before Terminal 2 commits: Terminal 1 sees the original products: Coke (2.50) and Pepsi (3.00)
--After Terminal 2 commits: Terminal 1 sees the new product: Fanta (3.50) only (Coke and Pepsi have been deleted and replaced)
--This demonstrates non-repeatable reads - the same query returns different results within the same transaction.
--b)Both SELECT statements show the same data: Coke (2.50) and Pepsi (3.00)
--Terminal 1 does not see Terminal 2's changes (deletion of Coke/Pepsi and insertion of Fanta) because SERIALIZABLE isolation creates a snapshot of the data at the start of the transaction.
--Terminal 2's transaction might be blocked until Terminal 1 commits, or might proceed but then Terminal 1 would get a serialization error when trying to commit.
--c)READ COMMITTED:
-- Each query sees only committed data from other transactions
--Can see different data in subsequent queries if other transactions commit changes
--Allows non-repeatable reads
--SERIALIZABLE:
--Creates a snapshot of the database at transaction start
--Sees consistent view throughout the transaction (repeatable reads)
--Prevents non-repeatable reads and phantom reads

--3.6
--Terminal 1:
 BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
 SELECT MAX(price), MIN(price) FROM products
    WHERE shop = 'Joe''s Shop';-- Wait for Terminal 2
 SELECT MAX(price), MIN(price) FROM products
    WHERE shop = 'Joe''s Shop';
 COMMIT;
--Terminal 2:
 BEGIN;
 INSERT INTO products (shop, product, price)
    VALUES ('Joe''s Shop', 'Sprite', 4.00);

SELECT * FROM  products;
--a)No, Terminal 1 does not see the new product (Sprite with price 4.00) inserted by Terminal 2.
--b)Phantom reads involve new rows appearing, unlike non-repeatable reads which involve changes to existing rows.
--c)SERIALIZABLE is the only standard SQL isolation level that prevents phantom reads.
COMMIT; -- если есть незавершенная транзакция
-- или
ROLLBACK; -- если нужно откатить
--3.6
 --Terminal 1:
 BEGIN TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
 SELECT * FROM products WHERE shop = 'Joe''s Shop';-- Wait for Terminal 2 to UPDATE but NOT commit
 SELECT * FROM products WHERE shop = 'Joe''s Shop';-- Wait for Terminal 2 to ROLLBACK
 SELECT * FROM products WHERE shop = 'Joe''s Shop';
 COMMIT;
 --Terminal 2:
 BEGIN;
 UPDATE products SET price = 99.99
    WHERE product = 'Fanta';-- Wait here (don't commit yet)-- Then:
 ROLLBACK;

--a)No, Terminal 1 would not see the price of 99.99 because PostgreSQL doesn't allow true dirty reads.
--b)A dirty read occurs when a transaction reads data that has been modified by another transaction that has not yet been committed.
--c)Can read data that doesn't officially exist .READ COMMITTED provides better consistency with minimal performance penalty

--ex 1

BEGIN;


DO $$
DECLARE
    bob_balance DECIMAL(10,2);
BEGIN

    SELECT balance INTO bob_balance
    FROM accounts WHERE name = 'Bob';

    IF bob_balance < 200.00 THEN
        RAISE EXCEPTION 'Insufficient funds. Bob has only $%', bob_balance;
    END IF;
END $$;


UPDATE accounts SET balance = balance - 200.00
    WHERE name = 'Bob' AND balance >= 200.00;


IF NOT FOUND THEN
    ROLLBACK;
    RAISE NOTICE 'Transfer failed: Insufficient funds or Bob not found';
ELSE
    UPDATE accounts SET balance = balance + 200.00
        WHERE name = 'Wally';
    COMMIT;
    RAISE NOTICE 'Transfer successful: $200 transferred from Bob to Wally';
END IF;

--ex 2
BEGIN;

-- 1. Insert a new product
INSERT INTO products (shop, product, price)
VALUES ('Test Shop', 'Water', 1.00);

-- 2. Create first savepoint

SAVEPOINT sp1;

-- 3. Update the price
UPDATE products SET price = 1.50
WHERE product = 'Water' AND shop = 'Test Shop';

-- 4. Create second savepoint
SAVEPOINT sp2;

-- 5. Delete the product
DELETE FROM products
WHERE product = 'Water' AND shop = 'Test Shop';

-- 6. Roll back to first savepoint
ROLLBACK TO SAVEPOINT sp1;

-- 7. Commit
COMMIT;

SELECT * FROM products WHERE shop = 'Test Shop';

--ex 3
-- Reset account
UPDATE accounts SET balance = 1000.00 WHERE name = 'Alice';
--SC A
-- Terminal 1:
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT balance FROM accounts WHERE name = 'Alice'; -- Sees 1000

-- Terminal 2:
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT balance FROM accounts WHERE name = 'Alice'; -- Also sees 1000
UPDATE accounts SET balance = balance - 300 WHERE name = 'Alice'; -- Now 700
COMMIT;

-- Back to Terminal 1:
UPDATE accounts SET balance = balance - 400 WHERE name = 'Alice'; -- Uses OLD 1000!
COMMIT;

--sc B
-- Terminal 1:
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SELECT balance FROM accounts WHERE name = 'Alice';

-- Terminal 2:
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SELECT balance FROM accounts WHERE name = 'Alice';
UPDATE accounts SET balance = balance - 300 WHERE name = 'Alice';
COMMIT; -- Success

-- Back to Terminal 1:
UPDATE accounts SET balance = balance - 400 WHERE name = 'Alice';

ROLLBACK;

--ex 4
CREATE TABLE Sells (shop VARCHAR(100), product VARCHAR(100), price DECIMAL(10,2));
INSERT INTO Sells VALUES
    ('A', 'X', 10),
    ('A', 'Y', 20),
    ('A', 'Z', 30);

--without transactions
DELETE FROM Sells WHERE shop = 'A' AND price = 10;
INSERT INTO Sells VALUES ('A', 'W', 40);

SELECT MAX(price) FROM Sells WHERE shop = 'A';

SELECT MIN(price) FROM Sells WHERE shop = 'A';  -- Sees 20 (from Y)

--with transaction Joe's transaction:
BEGIN;
DELETE FROM Sells WHERE shop = 'A' AND price = 10;
INSERT INTO Sells VALUES ('A', 'W', 40);
COMMIT;

-- Sally's transaction:
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SELECT MAX(price) FROM Sells WHERE shop = 'A';
SELECT MIN(price) FROM Sells WHERE shop = 'A';
COMMIT;
-- Now sees consistent view: both queries see same data snapshot

-- Atomicity: All or nothing (bank transfer either completes fully or not at all)
-- Consistency: Valid state transitions (account balance never negative)
-- Isolation: Transactions don't interfere (concurrent transfers don't mix)
-- Durability: Survives crashes (completed transfers persist after reboot)

-- COMMIT makes changes permanent; ROLLBACK undoes them to last COMMIT

-- SAVEPOINT for partial undo within a transaction; ROLLBACK for complete undo

-- READ UNCOMMITTED: Dirty reads allowed
-- READ COMMITTED: Only committed data visible
-- REPEATABLE READ: Consistent reads within transaction
-- SERIALIZABLE: Complete isolation, serial execution

-- Dirty read: Reading uncommitted data; allowed in READ UNCOMMITTED

-- Non-repeatable read: Same query returns different results; occurs when data changed by others between reads

-- Phantom read: New rows appear; prevented by SERIALIZABLE (and REPEATABLE READ in PostgreSQL)

-- READ COMMITTED has better performance, less locking than SERIALIZABLE

-- Transactions ensure operations appear atomic and isolated, preventing partial updates and interference

-- Uncommitted changes are lost (rolled back automatically on recovery)