import pandas as pd
import re

# Load your CSV file
# Replace 'Phishing_validation_emails.csv' with your actual file path
df = pd.read_csv('Phishing_validation_emails.csv')

# Feature 1: Has_Link (1 if email contains http:// or https://)
df['Has_Link'] = df['Email Text'].apply(lambda x: 1 if re.search(r'http[s]?://', x) else 0)

# Feature 2: Suspicious_Keywords
suspicious_words = ['urgent', 'verify', 'click here', 'prize', 'account', 'personal information', 'bank', 'password', 'win', 'security']
df['Suspicious_Keywords'] = df['Email Text'].apply(lambda x: 1 if any(word.lower() in x.lower() for word in suspicious_words) else 0)

# Feature 3: Special_Char_Count
special_chars = ['!', '$', '%', '#', '*']
df['Special_Char_Count'] = df['Email Text'].apply(lambda x: sum(x.count(c) for c in special_chars))

# Feature 4: Email_Length (number of words)
df['Email_Length'] = df['Email Text'].apply(lambda x: len(x.split()))

# Encode label: Phishing Email -> 1, Safe Email -> 0
df['Label'] = df['Email Type'].apply(lambda x: 1 if x.lower() == 'phishing email' else 0)

# Save new feature-rich CSV
output_file = 'Phishing_validation_emails_features.csv'
df.to_csv(output_file, index=False)

print(f"Feature-rich dataset saved as {output_file}")
