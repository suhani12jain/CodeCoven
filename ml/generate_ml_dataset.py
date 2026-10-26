"""
generate_ml_dataset.py
Synthetic dataset generator for SWMRS AI/ML module.
Generates realistic data for:
  - Task 1: Bin Overflow Prediction (Classification)
  - Task 4: Waste Type Classification (Multi-class Classification)
  - Task 5: Recycling Facility Recommendation (KNN / Feature matrix)
"""

import os
import random
import numpy as np
import pandas as pd

random.seed(42)
np.random.seed(42)

ML_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_DIR = os.path.join(ML_DIR, "data")
os.makedirs(DATA_DIR, exist_ok=True)

def generate_overflow_dataset(n_samples=2000):
    """
    Task 1: Predict whether bin will overflow (>90% fill) within 24 hours.
    Features:
      - current_fill_pct: [5.0 - 95.0]
      - fill_rate_hourly: [0.5 - 4.5] %/hr
      - days_since_pickup: [0.2 - 6.0] days
      - is_weekend: 0 or 1
      - festival_surge_index: 1.0 (normal) to 2.5 (festival/holiday surge)
      - temperature_celsius: [20.0 - 42.0]
      - zone_density_k: population density in thousands [2.5 - 22.0]
      - capacity_litres: [660, 1100, 1500, 2000]
    """
    data = []
    capacities = [660, 1100, 1500, 2000]

    for _ in range(n_samples):
        capacity = random.choice(capacities)
        current_fill = round(random.uniform(10.0, 92.0), 1)
        is_weekend = 1 if random.random() < 0.28 else 0
        festival = round(random.choice([1.0, 1.0, 1.0, 1.2, 1.5, 2.0]), 1)
        zone_density = round(random.uniform(2.5, 22.0), 1)
        temp = round(random.uniform(20.0, 42.0), 1)
        days_since_pickup = round(random.uniform(0.2, 5.0), 1)

        # Fill velocity model: influenced by density, weekend, festival, and weather
        base_rate = (zone_density / 7.0) * (1.3 if is_weekend else 1.0) * festival
        hourly_rate = round(max(0.2, min(5.0, random.gauss(base_rate, 0.4))), 2)

        # Expected fill in next 24 hours
        projected_fill_24h = current_fill + (hourly_rate * 24.0)
        # Target: Will it breach 90%?
        will_overflow = 1 if (projected_fill_24h >= 90.0 or current_fill >= 85.0) else 0

        data.append({
            'capacity_litres': capacity,
            'current_fill_pct': current_fill,
            'hourly_rate': hourly_rate,
            'days_since_pickup': days_since_pickup,
            'is_weekend': is_weekend,
            'festival_surge_index': festival,
            'temperature_celsius': temp,
            'zone_density_k': zone_density,
            'will_overflow_24h': will_overflow
        })

    df = pd.DataFrame(data)
    out_path = os.path.join(DATA_DIR, "bin_overflow_data.csv")
    df.to_csv(out_path, index=False)
    print(f"[OK] Generated {len(df)} rows for Task 1: {out_path}")
    return df

def generate_waste_type_dataset(n_samples=2500):
    """
    Task 4: Classify waste material into 5 categories based on physical/optical properties:
      1: Organic / Wet Waste
      2: Recyclable Plastic
      3: Paper & Cardboard
      4: Metal & Aluminum
      5: Electronic Waste
    Features:
      - density_g_cm3: [0.05 - 7.8]
      - moisture_pct: [2.0 - 85.0]
      - reflectivity_pct: [5.0 - 95.0]
      - conductivity_micro_s: [0.0 - 1500.0]
      - avg_weight_kg: [0.1 - 25.0]
    """
    categories = ['Organic', 'Plastic', 'Paper', 'Metal', 'Electronic Waste']
    data = []

    for _ in range(n_samples):
        cat = random.choice(categories)

        if cat == 'Organic':
            density = random.gauss(0.85, 0.15)
            moisture = random.gauss(68.0, 10.0)
            reflectivity = random.gauss(15.0, 5.0)
            conductivity = random.gauss(120.0, 30.0)
            weight = random.gauss(2.5, 1.2)
        elif cat == 'Plastic':
            density = random.gauss(0.92, 0.12)
            moisture = random.gauss(8.0, 4.0)
            reflectivity = random.gauss(65.0, 12.0)
            conductivity = random.gauss(5.0, 3.0)
            weight = random.gauss(0.8, 0.4)
        elif cat == 'Paper':
            density = random.gauss(0.65, 0.10)
            moisture = random.gauss(14.0, 5.0)
            reflectivity = random.gauss(75.0, 10.0)
            conductivity = random.gauss(12.0, 5.0)
            weight = random.gauss(1.2, 0.6)
        elif cat == 'Metal':
            density = random.gauss(4.80, 1.20)
            moisture = random.gauss(4.0, 2.0)
            reflectivity = random.gauss(88.0, 6.0)
            conductivity = random.gauss(950.0, 150.0)
            weight = random.gauss(5.5, 2.5)
        else:  # Electronic Waste
            density = random.gauss(2.40, 0.60)
            moisture = random.gauss(6.0, 3.0)
            reflectivity = random.gauss(45.0, 15.0)
            conductivity = random.gauss(450.0, 110.0)
            weight = random.gauss(4.2, 2.0)

        # Ensure realistic bounded positive values
        data.append({
            'density_g_cm3': round(max(0.05, density), 3),
            'moisture_pct': round(max(0.5, min(95.0, moisture)), 2),
            'reflectivity_pct': round(max(2.0, min(99.0, reflectivity)), 2),
            'conductivity_micro_s': round(max(0.0, conductivity), 1),
            'avg_weight_kg': round(max(0.05, weight), 2),
            'waste_category': cat
        })

    df = pd.DataFrame(data)
    out_path = os.path.join(DATA_DIR, "waste_classification_data.csv")
    df.to_csv(out_path, index=False)
    print(f"[OK] Generated {len(df)} rows for Task 4: {out_path}")
    return df

def generate_facility_dataset():
    """
    Task 5: Facility profiles for recommendation matching (KNN / Content Scoring)
    """
    facilities = [
        {'facility_id': 1, 'facility_name': 'EcoCycle Green Composting Plant',     'primary_category': 'Organic',          'daily_capacity_tons': 150.0, 'cost_per_ton': 850.0,  'lat': 18.532, 'lon': 73.854},
        {'facility_id': 2, 'facility_name': 'PolyReclaim Plastics Refinery',       'primary_category': 'Plastic',          'daily_capacity_tons': 200.0, 'cost_per_ton': 1400.0, 'lat': 18.510, 'lon': 73.910},
        {'facility_id': 3, 'facility_name': 'KagazCraft Pulp & Cardboard Mills',   'primary_category': 'Paper',            'daily_capacity_tons': 120.0, 'cost_per_ton': 950.0,  'lat': 18.495, 'lon': 73.832},
        {'facility_id': 4, 'facility_name': 'MetalForge Scrap Smelting Yard',      'primary_category': 'Metal',            'daily_capacity_tons': 250.0, 'cost_per_ton': 1800.0, 'lat': 18.505, 'lon': 73.925},
        {'facility_id': 5, 'facility_name': 'Vitreous Clean Glass Melting Works',  'primary_category': 'Glass',            'daily_capacity_tons': 80.0,  'cost_per_ton': 1100.0, 'lat': 18.570, 'lon': 73.890},
        {'facility_id': 6, 'facility_name': 'CircuitSafe Urban E-Waste Recycler',  'primary_category': 'Electronic Waste', 'daily_capacity_tons': 50.0,  'cost_per_ton': 3200.0, 'lat': 18.560, 'lon': 73.790},
        {'facility_id': 7, 'facility_name': 'BioClean Medical Autoclave Facility', 'primary_category': 'Hazardous',        'daily_capacity_tons': 40.0,  'cost_per_ton': 4500.0, 'lat': 18.480, 'lon': 73.860},
        {'facility_id': 8, 'facility_name': 'Apex Material Recovery Facility',     'primary_category': 'Plastic',          'daily_capacity_tons': 300.0, 'cost_per_ton': 1600.0, 'lat': 18.525, 'lon': 73.850},
        {'facility_id': 9, 'facility_name': 'Western Suburbs Composting Yard',     'primary_category': 'Organic',          'daily_capacity_tons': 90.0,  'cost_per_ton': 880.0,  'lat': 18.515, 'lon': 73.780},
        {'facility_id': 10,'facility_name': 'Harbor Secondary Smelting Unit',      'primary_category': 'Metal',            'daily_capacity_tons': 180.0, 'cost_per_ton': 1950.0, 'lat': 18.502, 'lon': 73.930}
    ]
    df = pd.DataFrame(facilities)
    out_path = os.path.join(DATA_DIR, "facility_features.csv")
    df.to_csv(out_path, index=False)
    print(f"[OK] Generated {len(df)} rows for Task 5: {out_path}")
    return df

if __name__ == "__main__":
    generate_overflow_dataset()
    generate_waste_type_dataset()
    generate_facility_dataset()
