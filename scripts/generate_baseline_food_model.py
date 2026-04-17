from __future__ import annotations

from pathlib import Path

import coremltools as ct
import numpy as np
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report
from sklearn.model_selection import train_test_split

FEATURE_NAMES = [
    "redMean",
    "greenMean",
    "blueMean",
    "redStd",
    "greenStd",
    "blueStd",
    "brightnessMean",
    "saturationMean",
    "warmPixelRatio",
    "darkPixelRatio",
    "greenPixelRatio",
    "brightPixelRatio",
]

CENTROIDS = {
    "Jollof Rice": {
        "redMean": 0.73,
        "greenMean": 0.42,
        "blueMean": 0.22,
        "redStd": 0.18,
        "greenStd": 0.15,
        "blueStd": 0.10,
        "brightnessMean": 0.74,
        "saturationMean": 0.70,
        "warmPixelRatio": 0.68,
        "darkPixelRatio": 0.06,
        "greenPixelRatio": 0.04,
        "brightPixelRatio": 0.29,
    },
    "Waakye": {
        "redMean": 0.48,
        "greenMean": 0.34,
        "blueMean": 0.24,
        "redStd": 0.21,
        "greenStd": 0.19,
        "blueStd": 0.14,
        "brightnessMean": 0.50,
        "saturationMean": 0.55,
        "warmPixelRatio": 0.42,
        "darkPixelRatio": 0.20,
        "greenPixelRatio": 0.06,
        "brightPixelRatio": 0.12,
    },
    "Banku and Tilapia": {
        "redMean": 0.56,
        "greenMean": 0.50,
        "blueMean": 0.38,
        "redStd": 0.17,
        "greenStd": 0.18,
        "blueStd": 0.15,
        "brightnessMean": 0.71,
        "saturationMean": 0.39,
        "warmPixelRatio": 0.18,
        "darkPixelRatio": 0.09,
        "greenPixelRatio": 0.16,
        "brightPixelRatio": 0.34,
    },
    "Fufu and Light Soup": {
        "redMean": 0.75,
        "greenMean": 0.62,
        "blueMean": 0.42,
        "redStd": 0.13,
        "greenStd": 0.14,
        "blueStd": 0.12,
        "brightnessMean": 0.81,
        "saturationMean": 0.47,
        "warmPixelRatio": 0.41,
        "darkPixelRatio": 0.04,
        "greenPixelRatio": 0.08,
        "brightPixelRatio": 0.46,
    },
    "Unknown Food": {
        "redMean": 0.50,
        "greenMean": 0.50,
        "blueMean": 0.50,
        "redStd": 0.20,
        "greenStd": 0.20,
        "blueStd": 0.20,
        "brightnessMean": 0.55,
        "saturationMean": 0.30,
        "warmPixelRatio": 0.17,
        "darkPixelRatio": 0.15,
        "greenPixelRatio": 0.14,
        "brightPixelRatio": 0.20,
    },
}

FEATURE_SPREADS = {
    "redMean": 0.06,
    "greenMean": 0.06,
    "blueMean": 0.06,
    "redStd": 0.03,
    "greenStd": 0.03,
    "blueStd": 0.03,
    "brightnessMean": 0.05,
    "saturationMean": 0.05,
    "warmPixelRatio": 0.08,
    "darkPixelRatio": 0.05,
    "greenPixelRatio": 0.05,
    "brightPixelRatio": 0.06,
}


def synthesize_samples(label: str, centroid: dict[str, float], sample_count: int, rng: np.random.Generator) -> tuple[np.ndarray, np.ndarray]:
    rows: list[list[float]] = []
    labels: list[str] = []

    for _ in range(sample_count):
        row: list[float] = []
        for feature_name in FEATURE_NAMES:
            base_value = centroid[feature_name]
            spread = FEATURE_SPREADS[feature_name]
            sampled_value = float(rng.normal(base_value, spread))
            row.append(float(np.clip(sampled_value, 0.0, 1.0)))

        rows.append(row)
        labels.append(label)

    return np.array(rows, dtype=np.float32), np.array(labels)


def build_training_matrix(sample_count: int = 500, seed: int = 42) -> tuple[np.ndarray, np.ndarray]:
    rng = np.random.default_rng(seed)
    feature_batches: list[np.ndarray] = []
    label_batches: list[np.ndarray] = []

    for label, centroid in CENTROIDS.items():
        features, labels = synthesize_samples(label, centroid, sample_count, rng)
        feature_batches.append(features)
        label_batches.append(labels)

    return np.vstack(feature_batches), np.concatenate(label_batches)


def main() -> None:
    project_root = Path(__file__).resolve().parents[1]
    output_path = project_root / "ObeseFoodApp" / "BaselineFoodClassifier.mlmodel"

    features, labels = build_training_matrix()
    train_x, test_x, train_y, test_y = train_test_split(
        features,
        labels,
        test_size=0.2,
        random_state=42,
        stratify=labels,
    )

    classifier = RandomForestClassifier(
        n_estimators=300,
        max_depth=8,
        min_samples_leaf=2,
        random_state=42,
    )
    classifier.fit(train_x, train_y)

    predictions = classifier.predict(test_x)
    print(classification_report(test_y, predictions))

    coreml_model = ct.converters.sklearn.convert(
        classifier,
        input_features=FEATURE_NAMES,
        output_feature_names="foodName",
    )

    coreml_model.author = "Cursor"
    coreml_model.license = "MIT"
    coreml_model.short_description = "Baseline Ghanaian meal classifier using engineered image color features."
    coreml_model.input_description["redMean"] = "Mean normalized red channel value."
    coreml_model.input_description["greenMean"] = "Mean normalized green channel value."
    coreml_model.input_description["blueMean"] = "Mean normalized blue channel value."
    coreml_model.output_description["foodName"] = "Predicted meal label for the supported MVP dish set."
    coreml_model.output_description["classProbability"] = "Per-class confidence scores for the supported meal labels."
    coreml_model.save(str(output_path))

    print(f"Saved CoreML model to {output_path}")


if __name__ == "__main__":
    main()
