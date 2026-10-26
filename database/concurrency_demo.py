"""
concurrency_demo.py
ACID Transactions, Locking, and Concurrency Simulation
Demonstrates:
  1. Atomicity & Rollback with SAVEPOINT
  2. Isolation Levels (READ COMMITTED vs REPEATABLE READ)
  3. Pessimistic Row-Level Locking (SELECT ... FOR UPDATE)
  4. Controlled Deadlock Reproduction and Error Handling (Error 1213)
"""

import time
import threading
import sys

def print_separator(title):
    print("\n" + "=" * 75)
    print(f" >>> {title}")
    print("=" * 75)

def run_simulation_walkthrough():
    """
    Detailed, executable transaction walkthrough script showing exact SQL commands,
    session interactions, and engine responses.
    """
    print_separator("SCENARIO 1: ATOMICITY, SAVEPOINT, AND ROLLBACK")
    print("""
[Business Problem]:
A driver completes collection for Bin #2 (CurrentFillLevel=92%).
The transaction must:
  Step 1: Deduct fill level to 0% and mark status = 'NORMAL'
  Step 2: Set a SAVEPOINT 'after_bin_reset'
  Step 3: Insert into Collection_Record
  Step 4: Update Citizen reward points (+50 points)
  Step 5: If reward point update fails (e.g. invalid citizen ID), rollback to SAVEPOINT.

--- SESSION 1 (SQL EXECUTION TRACE) ---
mysql> START TRANSACTION;
Query OK, 0 rows affected (0.00 sec)

mysql> UPDATE Bin SET CurrentFillLevel = 0.00, Status = 'NORMAL', LastCleanedAt = NOW() WHERE BinID = 2;
Query OK, 1 row affected (0.01 sec)

mysql> SAVEPOINT after_bin_reset;
Query OK, 0 rows affected (0.00 sec)

mysql> INSERT INTO Collection_Record (BinID, RouteID, DriverID, VehicleID, CollectedWeightKg, FillLevelBefore, CollectionTimestamp)
       VALUES (2, 1, 1, 1, 310.50, 92.40, NOW());
Query OK, 1 row affected (0.01 sec)

-- Simulating a downstream integrity or application check failure:
mysql> UPDATE Citizen SET RewardPoints = RewardPoints + 50 WHERE CitizenID = 99999;
-- Check affected rows: 0 rows found!

mysql> ROLLBACK TO SAVEPOINT after_bin_reset;
Query OK, 0 rows affected (0.00 sec)
[Result]: Collection_Record rolled back, but Bin reset remains intact under the active transaction!

mysql> COMMIT;
Query OK, 0 rows affected (0.01 sec)
[Conclusion]: Atomicity preserved. The partial rollback protected the state from corruption.
""")

    print_separator("SCENARIO 2: CONCURRENCY & ROW LOCKING (SELECT ... FOR UPDATE)")
    print("""
[Business Problem]:
Two collection dispatchers simultaneously attempt to assign the same available
Collection_Vehicle (VehicleID = 1) to two different emergency routes.

--- TIMELINE OF TWO CONCURRENT SESSIONS ---

[T = 0s] SESSION 1:
mysql> START TRANSACTION;
mysql> SELECT VehicleID, OperationalStatus FROM Collection_Vehicle 
       WHERE VehicleID = 1 FOR UPDATE;
+-----------+-------------------+
| VehicleID | OperationalStatus |
+-----------+-------------------+
|         1 | Available         |
+-----------+-------------------+
(Exclusive X-Lock acquired on VehicleID = 1 by Session 1)

[T = 1s] SESSION 2:
mysql> START TRANSACTION;
mysql> SELECT VehicleID, OperationalStatus FROM Collection_Vehicle 
       WHERE VehicleID = 1 FOR UPDATE;
-- [BLOCKED]: Session 2 is placed into lock wait state...

[T = 2s] SESSION 1:
mysql> UPDATE Collection_Vehicle SET OperationalStatus = 'On Route' WHERE VehicleID = 1;
mysql> COMMIT;
-- [RELEASED]: Session 1 releases exclusive lock on commit.

[T = 2.05s] SESSION 2 (Unblocks):
+-----------+-------------------+
| VehicleID | OperationalStatus |
+-----------+-------------------+
|         1 | On Route          |
+-----------+-------------------+
(Session 2 reads updated status 'On Route' and cancels duplicate assignment!)
mysql> ROLLBACK;

[Conclusion]: SELECT ... FOR UPDATE completely prevents the 'Lost Update' anomaly.
""")

    print_separator("SCENARIO 3: TRANSACTION ISOLATION LEVELS (NON-REPEATABLE READS)")
    print("""
[Comparison]: READ COMMITTED vs REPEATABLE READ (MySQL InnoDB Default)

A. Under READ COMMITTED:
   Session 1: START TRANSACTION;
   Session 1: SELECT SUM(CollectedWeightKg) FROM Collection_Record WHERE RouteID = 1; -> 450.00 kg
   Session 2: INSERT INTO Collection_Record (..., CollectedWeightKg = 150.00) ...; COMMIT;
   Session 1: SELECT SUM(CollectedWeightKg) FROM Collection_Record WHERE RouteID = 1; -> 600.00 kg (CHANGED!)
   Anomaly: Non-Repeatable Read observed within the same transaction.

B. Under REPEATABLE READ (Default):
   Session 1: START TRANSACTION;
   Session 1: SELECT SUM(CollectedWeightKg) FROM Collection_Record WHERE RouteID = 1; -> 450.00 kg
   Session 2: INSERT INTO Collection_Record (..., CollectedWeightKg = 150.00) ...; COMMIT;
   Session 1: SELECT SUM(CollectedWeightKg) FROM Collection_Record WHERE RouteID = 1; -> 450.00 kg (CONSISTENT SNAPSHOT!)
   Mechanism: InnoDB Multi-Version Concurrency Control (MVCC) uses undo logs to serve a consistent read view.
""")

    print_separator("SCENARIO 4: DEADLOCK REPRODUCTION & INNODB ENGINE RESOLUTION")
    print("""
[How Deadlocks Occur]:
A circular dependency occurs when Session 1 holds Resource A and waits for Resource B,
while Session 2 holds Resource B and waits for Resource A.

[T = 0s] Session 1:
START TRANSACTION;
UPDATE Bin SET Status = 'UNDER_MAINTENANCE' WHERE BinID = 10;
(Lock on Bin 10 acquired)

[T = 1s] Session 2:
START TRANSACTION;
UPDATE Bin SET Status = 'UNDER_MAINTENANCE' WHERE BinID = 20;
(Lock on Bin 20 acquired)

[T = 2s] Session 1:
UPDATE Bin SET Status = 'UNDER_MAINTENANCE' WHERE BinID = 20;
(Session 1 waits for Bin 20...)

[T = 3s] Session 2:
UPDATE Bin SET Status = 'UNDER_MAINTENANCE' WHERE BinID = 10;
(Session 2 waits for Bin 10 -> DEADLOCK DETECTED!)

--- MYSQL INNODB ENGINE RESPONSE ---
ERROR 1213 (40001): Deadlock found when trying to get lock; try restarting transaction.

Engine Resolution:
InnoDB inspects the wait-for graph, detects the cycle, and automatically selects the
transaction with the smallest undo log (least work done) as the victim, issuing an
automatic ROLLBACK to release its locks so the other transaction completes.
""")

if __name__ == "__main__":
    run_simulation_walkthrough()
