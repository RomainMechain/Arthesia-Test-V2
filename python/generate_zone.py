"""
Générateur de zones Arthesia via IA
Usage: py -3.12 generate_zone.py --prompt "village paisible" --output zone_001.json
"""

import json
import argparse
from pathlib import Path
from google import genai

# Import des configs et prompts
import config
import prompts

# ============================================================================
# GÉNÉRATEUR
# ============================================================================

class ZoneGenerator:
    def __init__(self):
        """Initialise le générateur"""
        self.client = genai.Client(api_key=config.GEMINI_API_KEY)
        self.model = config.GEMINI_MODEL
        
        print("✅ Générateur de zones initialisé")
        print(f"   Modèle : {self.model}")
    
    def generate_zone(self, zone_description, zone_size=[1500, 1000], level_range=[1, 5]):
        """Génère une zone via l'IA"""
        
        print("\n" + "="*60)
        print("🤖 GÉNÉRATION DE ZONE")
        print("="*60)
        print(f"Description : {zone_description}")
        print(f"Taille      : {zone_size[0]} x {zone_size[1]}")
        print(f"Niveau      : {level_range[0]}-{level_range[1]}")
        print()
        
        # Construire le prompt
        prompt = prompts.build_zone_generation_prompt(
            zone_description,
            config.AVAILABLE_PREFABS,
            zone_size,
            level_range
        )
        
        print("📤 Envoi du prompt à Gemini...")
        
        try:
            # Appel à l'API
            response = self.client.models.generate_content(
                model=self.model,
                contents=prompt,
                config={
                    'max_output_tokens': config.MAX_OUTPUT_TOKENS,
                    'temperature': 0.8,  # Créativité
                }
            )
            
            print("✅ Réponse reçue !")
            
            # Récupérer le texte
            zone_json_text = response.text.strip()
            
            # Nettoyer si besoin (enlever les ```json si présents)
            if zone_json_text.startswith("```json"):
                zone_json_text = zone_json_text[7:]
            if zone_json_text.startswith("```"):
                zone_json_text = zone_json_text[3:]
            if zone_json_text.endswith("```"):
                zone_json_text = zone_json_text[:-3]
            
            zone_json_text = zone_json_text.strip()
            
            # Parser le JSON
            zone_data = json.loads(zone_json_text)
            
            print("✅ JSON valide !")
            print(f"   Zone : {zone_data.get('name', 'Sans nom')}")
            print(f"   Prefabs : {len(zone_data.get('prefab_instances', []))}")
            print(f"   Éléments : {len(zone_data.get('elements', []))}")
            
            return zone_data
            
        except json.JSONDecodeError as e:
            print(f"❌ Erreur : Le JSON généré est invalide")
            print(f"   {e}")
            print("\n📄 Réponse brute :")
            print(response.text)
            return None
            
        except Exception as e:
            print(f"❌ Erreur lors de la génération : {e}")
            return None
    
    def save_zone(self, zone_data, output_path):
        """Sauvegarde la zone en JSON"""
        
        output_file = Path(config.ZONES_OUTPUT_PATH) / output_path
        output_file.parent.mkdir(parents=True, exist_ok=True)
        
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(zone_data, f, indent=2, ensure_ascii=False)
        
        print(f"\n💾 Zone sauvegardée : {output_file}")
        return output_file

# ============================================================================
# INTERFACE LIGNE DE COMMANDE
# ============================================================================

def main():
    parser = argparse.ArgumentParser(
        description="Générateur de zones Arthesia via IA"
    )
    
    parser.add_argument(
        "--prompt",
        type=str,
        required=True,
        help="Description de la zone à générer (ex: 'village paisible')"
    )
    
    parser.add_argument(
        "--output",
        type=str,
        default="zone_generated.json",
        help="Nom du fichier de sortie (défaut: zone_generated.json)"
    )
    
    parser.add_argument(
        "--size",
        type=int,
        nargs=2,
        default=[1500, 1000],
        help="Taille de la zone [largeur hauteur] (défaut: 1500 1000)"
    )
    
    parser.add_argument(
        "--level",
        type=int,
        nargs=2,
        default=[1, 5],
        help="Niveau min-max [min max] (défaut: 1 5)"
    )
    
    args = parser.parse_args()
    
    # Créer le générateur
    generator = ZoneGenerator()
    
    # Générer la zone
    zone_data = generator.generate_zone(
        zone_description=args.prompt,
        zone_size=args.size,
        level_range=args.level
    )
    
    if zone_data:
        # Sauvegarder
        output_file = generator.save_zone(zone_data, args.output)
        
        print("\n" + "="*60)
        print("🎉 GÉNÉRATION TERMINÉE !")
        print("="*60)
        print(f"📁 Fichier : {output_file}")
        print("\n💡 Prochaine étape : Charge ce fichier dans Godot !")
        print("   ZoneViewer.gd → zone_json_path = 'res://test/{}'".format(args.output))
        print("="*60)
    else:
        print("\n❌ La génération a échoué.")

if __name__ == "__main__":
    main()