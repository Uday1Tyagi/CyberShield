import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import classification_report, accuracy_score
import joblib

# -------------------- Load Dataset --------------------
df = pd.read_csv("Phishing_validation_emails.csv")

# Column names may differ, adjust accordingly
# Assuming columns are: "Email Text" and "Email Type"
df.rename(columns=lambda x: x.strip().lower().replace(" ", "_"), inplace=True)

# Encode labels (Safe Email = 0, Phishing Email = 1)
df["email_type"] = df["email_type"].map({"Safe Email": 0, "Phishing Email": 1})

X = df["email_text"]
y = df["email_type"]

# -------------------- Vectorization --------------------
vectorizer = TfidfVectorizer(max_features=5000)
X_vec = vectorizer.fit_transform(X)

# -------------------- Train-Test Split --------------------
X_train, X_test, y_train, y_test = train_test_split(
    X_vec, y, test_size=0.2, random_state=42, stratify=y
)

# -------------------- Train Model --------------------
model = LogisticRegression(max_iter=200)
model.fit(X_train, y_train)

# -------------------- Evaluation --------------------
y_pred = model.predict(X_test)
print("✅ Accuracy:", accuracy_score(y_test, y_pred))
print("\nClassification Report:\n", classification_report(y_test, y_pred))

# -------------------- Save Model and Vectorizer --------------------
joblib.dump(model, "phishing_model.pkl")
joblib.dump(vectorizer, "tfidf_vectorizer.pkl")

print("\n🎉 Model and vectorizer saved as 'phishing_model.pkl' and 'tfidf_vectorizer.pkl'")
