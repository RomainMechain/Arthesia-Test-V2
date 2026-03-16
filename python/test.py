from google import genai

# Configure avec ta clé
client = genai.Client(api_key="AIzaSyAbm2vzM0IkGuCfkOjebEn6ayjzEXmWwxs")

# Utilise gemini-2.5-flash (le meilleur gratuit)
response = client.models.generate_content(
    model='models/gemini-2.5-flash',  # ← Le bon nom
    contents='Dis bonjour en français !'
)

print(response.text)