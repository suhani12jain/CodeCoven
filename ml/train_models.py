"""
train_models.py
Full Machine Learning Pipeline for SWMRS:
  - Task 1: Bin Overflow Prediction (Random Forest vs Logistic Regression)
  - Task 4: Waste Type Classification (Multi-Class Random Forest)
  - Task 5: Recycling Facility Recommendation Engine (KNN / Content Scoring)
Exports trained artifacts to ml/models/
"""

import os
import json
import joblib
import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split, cross_val_score
from sklearn.preprocessing import StandardScaler, LabelEncoder
from sklearn.ensemble import RandomForestClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.neighbors import NearestNeighbors
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score, roc_auc_score, confusion_matrix, classification_report

from generate_ml_dataset import generate_overflow_dataset, generate_waste_type_dataset, generate_facility_dataset

ML_DIR = os.path.dirname(os.path.abspath(__file__))
MODELS_DIR = os.path.join(ML_DIR, "models")
DATA_DIR = os.path.join(ML_DIR, "data")
os.makedirs(MODELS_DIR, exist_ok=True)
os.makedirs(DATA_DIR, exist_ok=True)

def train_bin_overflow_model():
    print("\n" + "=" * 65)
    print(" >>> TRAINING TASK 1: BIN OVERFLOW PREDICTION (CLASSIFICATION)")
    print("=" * 65)

    data_file = os.path.join(DATA_DIR, "bin_overflow_data.csv")
    if not os.path.exists(data_file):
        df = generate_overflow_dataset()
    else:
        df = pd.read_csv(data_file)

    feature_cols = [
        'capacity_litres', 'current_fill_pct', 'hourly_rate',
        'days_since_pickup', 'is_weekend', 'festival_surge_index',
        'temperature_celsius', 'zone_density_k'
    ]
    target_col = 'will_overflow_24h'

    X = df[feature_cols]
    y = df[target_col]

    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42, stratify=y)

    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X_train)
    X_test_scaled = scaler.transform(X_test)

    # 1. Model A: Logistic Regression Baseline
    lr = LogisticRegression(random_state=42, max_iter=500)
    lr.fit(X_train_scaled, y_train)
    y_pred_lr = lr.predict(X_test_scaled)
    y_prob_lr = lr.predict_proba(X_test_scaled)[:, 1]

    # 2. Model B: Random Forest Classifier (Primary)
    rf = RandomForestClassifier(n_estimators=100, max_depth=10, min_samples_split=4, random_state=42)
    rf.fit(X_train, y_train)
    y_pred_rf = rf.predict(X_test)
    y_prob_rf = rf.predict_proba(X_test)[:, 1]

    # Evaluate both
    acc_lr = accuracy_score(y_test, y_pred_lr)
    f1_lr = f1_score(y_test, y_pred_lr)
    auc_lr = roc_auc_score(y_test, y_prob_lr)

    acc_rf = accuracy_score(y_test, y_pred_rf)
    prec_rf = precision_score(y_test, y_pred_rf)
    rec_rf = recall_score(y_test, y_pred_rf)
    f1_rf = f1_score(y_test, y_pred_rf)
    auc_rf = roc_auc_score(y_test, y_prob_rf)
    cm_rf = confusion_matrix(y_test, y_pred_rf)

    print("\n--- MODEL COMPARISON ---")
    print(f"1. Logistic Regression : Acc={acc_lr:.4f}, F1={f1_lr:.4f}, ROC-AUC={auc_lr:.4f}")
    print(f"2. Random Forest       : Acc={acc_rf:.4f}, Prec={prec_rf:.4f}, Rec={rec_rf:.4f}, F1={f1_rf:.4f}, ROC-AUC={auc_rf:.4f}")
    print(f"Random Forest Confusion Matrix:\n{cm_rf}")

    # Feature Importance
    importances = dict(zip(feature_cols, rf.feature_importances_))
    sorted_imp = sorted(importances.items(), key=lambda x: x[1], reverse=True)
    print("\nFeature Importances (Random Forest):")
    for feat, imp in sorted_imp:
        print(f"  - {feat:22s}: {imp:.4f}")

    # Save Pipeline
    model_payload = {
        'model': rf,
        'scaler': scaler,
        'features': feature_cols,
        'metrics': {
            'accuracy': round(acc_rf, 4),
            'precision': round(prec_rf, 4),
            'recall': round(rec_rf, 4),
            'f1_score': round(f1_rf, 4),
            'roc_auc': round(auc_rf, 4)
        }
    }
    out_file = os.path.join(MODELS_DIR, "bin_overflow_rf.joblib")
    joblib.dump(model_payload, out_file)
    print(f"[OK] Saved best model to: {out_file}")

def train_waste_classification_model():
    print("\n" + "=" * 65)
    print(" >>> TRAINING TASK 4: WASTE TYPE CLASSIFICATION")
    print("=" * 65)

    data_file = os.path.join(DATA_DIR, "waste_classification_data.csv")
    if not os.path.exists(data_file):
        df = generate_waste_type_dataset()
    else:
        df = pd.read_csv(data_file)

    feature_cols = ['density_g_cm3', 'moisture_pct', 'reflectivity_pct', 'conductivity_micro_s', 'avg_weight_kg']
    X = df[feature_cols]
    y = df['waste_category']

    label_encoder = LabelEncoder()
    y_encoded = label_encoder.fit_transform(y)

    X_train, X_test, y_train, y_test = train_test_split(X, y_encoded, test_size=0.2, random_state=42, stratify=y_encoded)

    clf = RandomForestClassifier(n_estimators=100, max_depth=12, random_state=42)
    clf.fit(X_train, y_train)

    y_pred = clf.predict(X_test)
    acc = accuracy_score(y_test, y_pred)
    f1 = f1_score(y_test, y_pred, average='weighted')

    print(f"Accuracy : {acc:.4f}")
    print(f"F1-Score : {f1:.4f}")
    print("\nClassification Report:")
    print(classification_report(y_test, y_pred, target_names=label_encoder.classes_))

    model_payload = {
        'model': clf,
        'label_encoder': label_encoder,
        'features': feature_cols,
        'classes': list(label_encoder.classes_),
        'metrics': {
            'accuracy': round(acc, 4),
            'f1_score': round(f1, 4)
        }
    }
    out_file = os.path.join(MODELS_DIR, "waste_type_clf.joblib")
    joblib.dump(model_payload, out_file)
    print(f"[OK] Saved waste classification model to: {out_file}")

def build_facility_recommender():
    print("\n" + "=" * 65)
    print(" >>> TRAINING TASK 5: RECYCLING FACILITY RECOMMENDER")
    print("=" * 65)

    data_file = os.path.join(DATA_DIR, "facility_features.csv")
    if not os.path.exists(data_file):
        df = generate_facility_dataset()
    else:
        df = pd.read_csv(data_file)

    # Content-based recommendation matrix
    # Features: Normalized capacity, cost per ton, coordinates
    scaler = StandardScaler()
    feature_cols = ['daily_capacity_tons', 'cost_per_ton', 'lat', 'lon']
    scaled_features = scaler.fit_transform(df[feature_cols])

    # Fit Nearest Neighbors engine
    knn = NearestNeighbors(n_neighbors=3, metric='euclidean')
    knn.fit(scaled_features)

    recommender_payload = {
        'knn_model': knn,
        'scaler': scaler,
        'feature_cols': feature_cols,
        'facilities_df': df.to_dict(orient='records')
    }
    out_file = os.path.join(MODELS_DIR, "facility_recommender.joblib")
    joblib.dump(recommender_payload, out_file)
    print(f"[OK] Built and saved Facility Recommender to: {out_file}")

if __name__ == "__main__":
    train_bin_overflow_model()
    train_waste_classification_model()
    build_facility_recommender()
