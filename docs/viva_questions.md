# 15 ADVANCED DBMS & AI/ML VIVA VOCE QUESTIONS & ANSWERS
## Project: Smart Waste Management and Recycling System (SWMRS)

---

### Q1: Why is your schema in BCNF and not just 3NF? What is the strict difference?
**Answer:** A relation is in 3NF if for every functional dependency $X \rightarrow Y$, either $X$ is a superkey OR $Y$ is a prime attribute. BCNF removes the second condition: $X$ **must strictly be a superkey** for every non-trivial dependency. In our system, entities like `Driver_Employee` have multiple candidate keys (`DriverID`, `UserID`, `LicenseNumber`). Every determinant is an independent superkey with no dependencies on non-superkeys, eliminating all update anomalies and ensuring strict BCNF compliance.

---

### Q2: What is the difference between a Stored Procedure and a Database Trigger?
**Answer:** 
- A **Trigger** is event-driven and invoked implicitly by the database engine upon a DML statement (`BEFORE` or `AFTER` `INSERT`, `UPDATE`, or `DELETE`). In SWMRS, `trg_sensor_auto_update_bin_status` triggers automatically when sensor telemetry arrives.
- A **Stored Procedure** is explicitly executed using the `CALL` statement by an application or user. It can accept `IN`, `OUT`, and `INOUT` parameters and perform administrative transactions, such as `sp_assign_emergency_pickup`.

---

### Q3: How did you implement and demonstrate ACID properties?
**Answer:**
- **Atomicity**: Using `START TRANSACTION`, `COMMIT`, `SAVEPOINT`, and `ROLLBACK`. If an auxiliary reward update fails, `ROLLBACK TO SAVEPOINT` recovers state without corrupting base collection data.
- **Consistency**: Enforced through schema-level `CHECK` constraints (e.g. `CurrentFillLevel BETWEEN 0 AND 100`) and foreign key referential integrity.
- **Isolation**: Controlled through MySQL InnoDB isolation levels (`READ COMMITTED` and `REPEATABLE READ`) using MVCC undo logs.
- **Durability**: Guaranteed by InnoDB's write-ahead redo log (`ib_logfile`), flushing committed data to disk.

---

### Q4: What is the purpose of the `Audit_Log` table and which trigger writes to it?
**Answer:** The `Audit_Log` tracks compliance and historical status transitions. The trigger `trg_audit_bin_update` fires `AFTER UPDATE ON Bin`. Whenever a bin's fill level or operational status changes, it captures `OLD.Status`, `NEW.Status`, the timestamp, and the responsible user, preserving an immutable security trail.

---

### Q5: How does `trg_prevent_vehicle_overload` prevent vehicle overload?
**Answer:** It is a `BEFORE INSERT` trigger on `Collection_Record`. It calculates the sum of all previously collected weights for the assigned route plus `NEW.CollectedWeightKg` and compares it with `Collection_Vehicle.CapacityKg`. If the sum breaches the rated payload, it issues a `SIGNAL SQLSTATE '45000'` with a custom rejection message, causing the engine to abort the transaction before writing to disk.

---

### Q6: What is a Correlated Subquery and where did you use it?
**Answer:** A subquery is correlated when its inner query references a column from the outer query, evaluating once for every candidate row of the outer query. In **Query 11**, we find bins whose current fill exceeds the average fill level of *their specific zone*:
```sql
SELECT BinCode, CurrentFillLevel FROM Bin b
WHERE b.CurrentFillLevel > (
    SELECT AVG(CurrentFillLevel) FROM Bin b_sub WHERE b_sub.ZoneID = b.ZoneID
);
```

---

### Q7: Explain the difference between `RANK()`, `DENSE_RANK()`, and `ROW_NUMBER()`.
**Answer:** All three are SQL window functions:
- `ROW_NUMBER()` assigns a strict, unique incrementing integer to every row regardless of ties ($1, 2, 3, 4$).
- `RANK()` assigns identical ranks to tied values but leaves gaps in the sequence ($1, 2, 2, 4$).
- `DENSE_RANK()` assigns identical ranks to tied values without leaving gaps ($1, 2, 2, 3$).

---

### Q8: What is a View and why did you use 5 Views in this project?
**Answer:** A View is a virtual table defined by an underlying SQL query. It does not store physical data (unless materialized). We used views to:
1. Simplify complex analytical multi-table joins for the frontend.
2. Provide pre-aggregated summaries (`vw_zone_waste_summary`).
3. Enhance security by hiding sensitive employee and system columns from unauthorized users.

---

### Q9: How do your indexes improve performance? What did the `EXPLAIN` plan show?
**Answer:** We created composite B-Tree indexes such as `idx_sensor_bin_time(BinID, ReadingTimestamp DESC)`. Before indexing, a query filtering by bin and sorting by timestamp performed an `ALL` (full table scan) across 1,363 rows with a memory filesort. After indexing, the engine performed an efficient `range` scan of 45 index entries without filesort, reducing latency by over 90%.

---

### Q10: How does InnoDB handle Deadlocks? How did you demonstrate it?
**Answer:** A deadlock occurs when two transactions have circular wait conditions on locked rows. In `concurrency_demo.py`, Session 1 locks Bin 10 and waits for Bin 20, while Session 2 locks Bin 20 and waits for Bin 10. InnoDB detects the cycle in its wait-for graph and resolves it by automatically rolling back the transaction that has done the least work (smallest undo log), throwing error `1213: Deadlock found when trying to get lock`.

---

### Q11: How do you prevent SQL Injection in your Flask application?
**Answer:** We use 100% **parameterized queries** via `mysql-connector-python`. Instead of string formatting (e.g. `f"SELECT * FROM Users WHERE username='{u}'"`), we pass query templates with `%s` placeholders and deliver parameters in a separate tuple:
```python
cursor.execute("SELECT * FROM Users WHERE Username = %s", (username,))
```
The MySQL protocol compiles the SQL query plan before binding data values, making it impossible for malicious SQL fragments to alter the execution logic.

---

### Q12: Why did you choose Random Forest over Logistic Regression for Task 1 (Bin Overflow)?
**Answer:** Logistic Regression is a linear classifier that assumes linear separability in feature space. Bin overflow, however, involves complex non-linear feature interactions (e.g. high population density combined with a weekend surge and elevated temperature). Random Forest uses an ensemble of 100 decision trees with feature bagging, capturing non-linear interactions without overfitting, yielding 97% accuracy and a 0.995 ROC-AUC.

---

### Q13: What features drive Task 4 (Waste Type Classification)?
**Answer:** We use physical and optical material characteristics that can be measured by sorting sensors:
1. **Density ($g/cm^3$)**: High in metals ($\sim 4.8$), low in paper ($\sim 0.65$).
2. **Moisture %**: High in organic kitchen waste ($\sim 68\%$), negligible in plastics.
3. **Optical Reflectivity %**: High in metals and plastics, low in wet organics.
4. **Electrical Conductivity ($\mu S$)**: Distinguishes metals and printed circuit boards (e-waste).

---

### Q14: How does the Task 5 Facility Recommendation Engine work?
**Answer:** It uses K-Nearest Neighbors (KNN) with normalized Euclidean distance across four dimensions: facility daily capacity, operating cost per ton, and geographical coordinates (latitude and longitude). Given a waste batch from a specific collection point, the model filters by accepted category and recommends the Top-3 plants with the lowest transportation and processing overhead.

---

### Q15: How does the AI/ML module integrate back into the DBMS?
**Answer:** Machine learning is not treated as an isolated script. When a prediction is generated in the web application (e.g. overflow risk or material classification), the user can click **"Write Prediction to MySQL"**. The system executes an `INSERT` into the `AI_Prediction` table, storing the predicted class, confidence score, and input features as a JSON document (`FeaturesJson`) for audit and dispatch tracking.
