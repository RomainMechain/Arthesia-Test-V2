"""
Générateur de prefabs Arthesia via IA
Usage: py -3.12 generate_prefab.py --prompt "une petite maison en bois" --category building --size small
"""

import json
import argparse
from pathlib import Path
from google import genai

# Import des configs et prompts
import config
import prompts_prefab

# ============================================================================
# GÉNÉRATEUR
# ============================================================================

class PrefabGenerator:
    def __init__(self):
        """Initialise le générateur"""
        self.client = genai.Client(api_key=config.GEMINI_API_KEY)
        self.model = config.GEMINI_MODEL
        
        print("✅ Générateur de prefabs initialisé")
        print(f"   Modèle : {self.model}")
    
    def generate_prefab(self, description, category="building", size="medium"):
        """Génère un prefab via l'IA"""
        
        print("\n" + "="*70)
        print("🔨 GÉNÉRATION DE PREFAB")
        print("="*70)
        print(f"Description : {description}")
        print(f"Catégorie   : {category}")
        print(f"Taille      : {size}")
        print()
        
        # Construire le prompt
        prompt = prompts_prefab.build_prefab_generation_prompt(
            description,
            category,
            size
        )
        
        print("📤 Envoi du prompt à Gemini...")
        
        try:
            # Appel à l'API
            response = self.client.models.generate_content(
                model=self.model,
                contents=prompt,
                config={
                    'max_output_tokens': config.MAX_OUTPUT_TOKENS,
                    'temperature': 0.7,  # Un peu moins créatif que les zones
                }
            )
            
            print("✅ Réponse reçue !")
            
            # Récupérer le texte
            prefab_json_text = response.text.strip()
            
            # Nettoyer si besoin
            if prefab_json_text.startswith("```json"):
                prefab_json_text = prefab_json_text[7:]
            if prefab_json_text.startswith("```"):
                prefab_json_text = prefab_json_text[3:]
            if prefab_json_text.endswith("```"):
                prefab_json_text = prefab_json_text[:-3]
            
            prefab_json_text = prefab_json_text.strip()
            
            # Parser le JSON
            prefab_data = json.loads(prefab_json_text)
            
            print("✅ JSON valide !")
            print(f"   Prefab ID : {prefab_data.get('prefab_id', 'Sans ID')}")
            print(f"   Nom       : {prefab_data.get('name', 'Sans nom')}")
            print(f"   Éléments  : {len(prefab_data.get('elements', []))}")
            print(f"   Taille    : {prefab_data.get('size', [0, 0])}")
            
            return prefab_data
            
        except json.JSONDecodeError as e:
            print(f"❌ Erreur : Le JSON généré est invalide")
            print(f"   {e}")
            print("\n📄 Réponse brute :")
            print(response.text)
            return None
            
        except Exception as e:
            print(f"❌ Erreur lors de la génération : {e}")
            return None
    
    def save_prefab(self, prefab_data, category):
        """Sauvegarde le prefab en JSON"""
        
        prefab_id = prefab_data.get('prefab_id', 'prefab_unknown')
        
        # Déterminer le dossier selon la catégorie
        category_folders = {
            "building": "buildings",
            "vegetation": "vegetation",
            "structure": "structures",
            "decoration": "decorations"
        }
        
        folder = category_folders.get(category, "other")
        output_path = Path("../core/data/prefabs") / folder / f"{prefab_id}.json"
        output_path.parent.mkdir(parents=True, exist_ok=True)
        
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(prefab_data, f, indent=2, ensure_ascii=False)
        
        print(f"\n💾 Prefab sauvegardé : {output_path}")
        return output_path
    
    def generate_sprite_prompt(self, prefab_data, description, category, size):
        """Génère le prompt pour créer le sprite"""
        return prompts_prefab.generate_sprite_prompt(prefab_data, description, category, size)  

# ============================================================================
# INTERFACE LIGNE DE COMMANDE
# ============================================================================

def main():
    parser = argparse.ArgumentParser(
        description="Générateur de prefabs Arthesia via IA"
    )
    
    parser.add_argument(
        "--prompt",
        type=str,
        required=True,
        help="Description du prefab à générer (ex: 'une petite maison en bois')"
    )
    
    parser.add_argument(
        "--category",
        type=str,
        choices=["building", "vegetation", "structure", "decoration"],
        default="building",
        help="Catégorie du prefab (défaut: building)"
    )
    
    parser.add_argument(
        "--size",
        type=str,
        choices=["small", "medium", "large"],
        default="medium",
        help="Taille du prefab (défaut: medium)"
    )
    
    parser.add_argument(
        "--with-sprite-prompt",
        action="store_true",
        help="Générer aussi le prompt pour le sprite"
    )
    
    args = parser.parse_args()
    
    # Créer le générateur
    generator = PrefabGenerator()
    
    # Générer le prefab
    prefab_data = generator.generate_prefab(
        description=args.prompt,
        category=args.category,
        size=args.size
    )
    
    if prefab_data:
        # Sauvegarder
        output_file = generator.save_prefab(prefab_data, args.category)
        
        print("\n" + "="*70)
        print("🎉 GÉNÉRATION TERMINÉE !")
        print("="*70)
        print(f"📁 Fichier : {output_file}")
        
        # Générer le prompt sprite si demandé
        if args.with_sprite_prompt:
            sprite_prompt = generator.generate_sprite_prompt(
                prefab_data,
                args.prompt,
                args.category,
                args.size
            )
            
            print("\n" + "🎨 PROMPT POUR LE SPRITE ".ljust(70, "━"))
            print(sprite_prompt)
            print("━" * 70)
            
            prefab_id = prefab_data.get('prefab_id', 'prefab')
            sprite_filename = f"{prefab_id}.png"
            
            print("\n💡 ÉTAPES SUIVANTES :")
            print(f"   1. Copie le prompt ci-dessus dans DALL-E / Midjourney")
            print(f"   2. Génère l'image")
            print(f"   3. Télécharge et renomme en : {sprite_filename}")
            print(f"   4. Place dans : res://assets/{args.category}s/{sprite_filename}")
            print(f"   5. Le prefab est prêt à être utilisé !")
        
        print("="*70)
    else:
        print("\n❌ La génération a échoué.")

if __name__ == "__main__":
    main()