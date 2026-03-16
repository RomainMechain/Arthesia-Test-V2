from google import genai

client = genai.Client(api_key="AIzaSyAbm2vzM0IkGuCfkOjebEn6ayjzEXmWwxs")

print("Modèles disponibles :")
try:
    for model in client.models.list():
        print(f"  - {model.name}")
        if hasattr(model, 'supported_generation_methods'):
            print(f"    Méthodes: {model.supported_generation_methods}")
except Exception as e:
    print(f"Erreur: {e}")