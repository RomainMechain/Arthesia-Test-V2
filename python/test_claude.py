from anthropic import Anthropic
import config

print("🔍 Test de connexion à Claude...")
print(f"🔑 Clé API : {config.CLAUDE_API_KEY[:20]}...")

client = Anthropic(api_key=config.CLAUDE_API_KEY)

# Liste des modèles à tester
models = [
    "claude-sonnet-4-6"
]

for model in models:
    print(f"\n🧪 Test du modèle : {model}")
    try:
        response = client.messages.create(
            model=model,
            max_tokens=50,
            messages=[{"role": "user", "content": "Hi"}]
        )
        print(f"   ✅ FONCTIONNE !")
        print(f"   Réponse : {response.content[0].text[:50]}...")
        break  # Si un modèle marche, on s'arrête
        
    except Exception as e:
        error_msg = str(e)
        if "not_found_error" in error_msg:
            print(f"   ❌ Modèle non disponible (404)")
        elif "authentication" in error_msg.lower():
            print(f"   ❌ Erreur d'authentification")
            print(f"   Vérifie ta clé API !")
            break
        else:
            print(f"   ❌ Erreur : {error_msg[:100]}")