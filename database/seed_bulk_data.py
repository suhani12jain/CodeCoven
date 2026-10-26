"""
seed_bulk_data.py
Bulk Synthetic Data Generator for Smart Waste Management and Recycling System (SWMRS)
Generates 600+ Sensor_Reading records and 500+ Collection_Record transactions.
Outputs both directly to MySQL (if reachable) and saves a standalone 'bulk_data.sql' file.
"""

import os
import random
import datetime
from datetime import timedelta

OUTPUT_SQL_PATH = os.path.join(os.path.dirname(__file__), "bulk_data.sql")

def generate_bulk_sql():
    print("[*] Generating 600+ Sensor Readings and 500+ Collection Records...")
    random.seed(42)  # Deterministic repeatability for academic review

    now = datetime.datetime.now()
    start_date = now - timedelta(days=30)

    # Bin configurations from data.sql (30 bins across 15 zones)
    # BinID 1..30, capacities, categories
    bin_ids = list(range(1, 31))
    route_ids = list(range(1, 16))
    driver_ids = list(range(1, 8))
    vehicle_ids = [1, 2, 3, 4, 5, 6, 7, 8, 10, 11, 12, 13, 14]

    sensor_readings = []
    # Generate 650 Sensor Readings with realistic fill level progression
    # Each bin gets regular telemetry snapshots over the past 30 days
    reading_id = 1
    for day in range(30):
        current_day = start_date + timedelta(days=day)
        for b_id in bin_ids:
            # 1 to 2 readings per bin per day
            for reading_idx in range(random.choice([1, 2])):
                hour = random.choice([6, 9, 12, 15, 18, 21])
                minute = random.randint(0, 59)
                second = random.randint(0, 59)
                timestamp = current_day.replace(hour=hour, minute=minute, second=second)

                # Base fill influenced by days and random surges
                # Weekend effect on residential/commercial
                is_weekend = timestamp.weekday() >= 5
                fill_pct = round(min(99.5, max(5.0, random.gauss(55.0 + (15.0 if is_weekend else 0.0), 22.0))), 2)
                battery = round(max(15.0, min(100.0, 98.0 - (day * 0.8) + random.uniform(-2, 2))), 2)
                temp = round(random.uniform(22.0, 38.5), 1)
                tilt = round(max(0.0, random.gauss(1.5, 2.0)), 1)
                if tilt > 45.0:
                    tilt = 3.5  # occasional outlier correction

                ts_str = timestamp.strftime('%Y-%m-%d %H:%M:%S')
                sensor_readings.append(
                    f"({reading_id}, {b_id}, {fill_pct}, {battery}, {temp}, {tilt}, '{ts_str}')"
                )
                reading_id += 1

    # Generate 520 Collection Records
    # Representing realistic collection route executions over 30 days
    collection_records = []
    record_id = 1
    for day in range(30):
        current_day = start_date + timedelta(days=day)
        # 16-18 collections per day
        daily_collections = random.randint(16, 20)
        for _ in range(daily_collections):
            b_id = random.choice(bin_ids)
            r_id = random.choice(route_ids)
            d_id = random.choice(driver_ids)
            v_id = random.choice(vehicle_ids)

            hour = random.choice([6, 7, 8, 9, 10, 14, 15, 16, 17, 22, 23])
            minute = random.randint(0, 59)
            second = random.randint(0, 59)
            timestamp = current_day.replace(hour=hour, minute=minute, second=second)

            fill_before = round(random.uniform(70.0, 98.5), 2)
            # Collected weight in Kg (typically 120 kg to 550 kg depending on category & fill)
            weight = round(random.uniform(150.0, 480.0) * (fill_before / 100.0), 2)
            verified = 1

            ts_str = timestamp.strftime('%Y-%m-%d %H:%M:%S')
            collection_records.append(
                f"({record_id}, {b_id}, {r_id}, {d_id}, {v_id}, {weight}, {fill_before}, '{ts_str}', {verified})"
            )
            record_id += 1

    print(f"[+] Total Sensor Readings to write: {len(sensor_readings)}")
    print(f"[+] Total Collection Records to write: {len(collection_records)}")

    # Write out bulk_data.sql
    with open(OUTPUT_SQL_PATH, "w", encoding="utf-8") as f:
        f.write("-- =============================================================================\n")
        f.write("-- BULK SEED DATA: Sensor_Reading (600+) and Collection_Record (500+)\n")
        f.write("-- =============================================================================\n\n")
        f.write("USE waste_mgmt_db;\n\n")
        f.write("SET FOREIGN_KEY_CHECKS = 0;\n\n")

        # Sensor readings in batches of 100
        f.write("-- Inserting Sensor_Reading rows\n")
        batch_size = 100
        for i in range(0, len(sensor_readings), batch_size):
            chunk = sensor_readings[i:i + batch_size]
            f.write("INSERT INTO Sensor_Reading (ReadingID, BinID, FillPercentage, BatteryLevelPct, TemperatureCelsius, TiltAngleDegrees, ReadingTimestamp) VALUES\n")
            f.write(",\n".join(chunk))
            f.write(";\n\n")

        # Collection records in batches of 100
        f.write("-- Inserting Collection_Record rows\n")
        for i in range(0, len(collection_records), batch_size):
            chunk = collection_records[i:i + batch_size]
            f.write("INSERT INTO Collection_Record (RecordID, BinID, RouteID, DriverID, VehicleID, CollectedWeightKg, FillLevelBefore, CollectionTimestamp, VerifiedBySupervisor) VALUES\n")
            f.write(",\n".join(chunk))
            f.write(";\n\n")

        f.write("SET FOREIGN_KEY_CHECKS = 1;\n")
        f.write("-- Bulk data generation successfully completed.\n")

    print(f"[OK] Successfully exported bulk SQL to: {OUTPUT_SQL_PATH}")

if __name__ == "__main__":
    generate_bulk_sql()
