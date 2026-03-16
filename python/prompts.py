"""
Templates de prompts pour la génération de zones Arthesia
"""

def get_lore_context():
    """Contexte lore d'Arthesia"""
    return """
# LORE D'ARTHESIA

## La Tour d'Arthesia
Suite à la Fracture (catastrophe cosmique), le monde unifié d'Arthesia s'est fragmenté 
en étages dimensionnels superposés. Chaque étage est un monde complet avec son propre 
ciel, sa géographie et son atmosphère.

## Les Marqués (Joueurs)
Certains individus portent une Marque mystérieuse et ressentent un appel irrésistible 
vers le haut de la Tour. Ils restaurent des fragments de mémoire en franchissant chaque étage.

## Les Architectes
Civilisation ancienne qui a créé la Tour. Leurs ruines et artefacts parsèment tous les étages.
Ils ont disparu lors de la Fracture, laissant des fragments de vérité à découvrir.

## Étage 1 - Les Plaines d'Aube
- Thème : Pastoral, aurore éternelle, début de l'aventure
- Ambiance : Prairies verdoyantes, ciel doré, villages paisibles, ruines anciennes
- Niveau : 1-10
- Atmosphère : Accueillant mais mystérieux
"""

def get_prefabs_list(prefabs_config):
    """Liste des prefabs disponibles formatée pour le prompt"""
    lines = ["# PREFABS DISPONIBLES\n"]
    
    for category, prefabs in prefabs_config.items():
        lines.append(f"\n## {category.upper()}")
        for prefab in prefabs:
            lines.append(f"- **{prefab['id']}** : {prefab['description']} (taille: {prefab['size']})")
    
    return "\n".join(lines)

def get_json_format():
    """Format JSON attendu"""
    return """
# FORMAT JSON ATTENDU

{
  "id": "floor1_zone_XXX",
  "name": "Nom Évocateur de la Zone",
  "floor_id": 1,
  "theme_tags": ["tag1", "tag2"],
  "level_range": [min, max],
  "description": "Description immersive de la zone (2-3 phrases).",
  
  "size": [largeur, hauteur],
  
  "spawn_points": {
    "default": [x, y],
    "entrance_north": [x, y],
    "entrance_south": [x, y]
  },
  
  "prefab_instances": [
    {
      "prefab_id": "house_simple",
      "instance_id": "house_001",
      "position": [x, y],
      "rotation": 0,
      "scale": 1.0,
      "overrides": {}
    }
  ],
  
  "elements": [
    {
      "element_type": "wall",
      "id": "wall_001",
      "position": [x, y],
      "size": [w, h],
      "wall_type": "stone",
      "color": "#808080"
    },
    {
      "element_type": "poi",
      "poi_type": "npc",
      "id": "npc_001",
      "position": [x, y],
      "poi_name": "Nom du PNJ",
      "interaction_text": "Parler",
      "dialogues": ["Phrase 1", "Phrase 2"],
      "quest_id": "",
      "npc_type": "villager"
    },
    {
      "element_type": "poi",
      "poi_type": "lore_stone",
      "id": "lore_001",
      "position": [x, y],
      "poi_name": "Pierre Ancienne",
      "interaction_text": "Examiner",
      "lore_text": "Texte de lore immersif...",
      "lore_category": "architects"
    }
  ]
}
"""

def get_generation_rules():
    """Règles de génération"""
    return """
# RÈGLES DE GÉNÉRATION

1. **Layout cohérent** :
   - Utilise les prefabs intelligemment (ne les superpose pas)
   - Les maisons doivent être accessibles
   - Les arbres peuvent être proches mais pas exactement au même endroit

2. **Spawn points** :
   - Toujours inclure "default" au centre approximatif
   - Ajouter des spawn points aux entrées (north, south, east, west selon la zone)

3. **Murs périphériques** :
   - Ajoute EXACTEMENT 4 murs pour border la zone
   - **wall_north** : position [0, 0], size [largeur_zone, 50]
   - **wall_south** : position [0, hauteur_zone - 50], size [largeur_zone, 50]
   - **wall_west** : position [0, 0], size [50, hauteur_zone]
   - **wall_east** : position [largeur_zone - 50, 0], size [50, hauteur_zone]
   - IMPORTANT : La position est le coin SUPÉRIEUR GAUCHE du mur

4. **POI (Points d'Intérêt)** :
   - Ajouter 1-3 POI par zone (PNJ, pierres de lore, coffres)
   - Les dialogues des PNJ doivent être immersifs et respecter le lore
   - Les textes de lore doivent faire référence aux Architectes ou à la Fracture

5. **Cohérence narrative** :
   - Le nom de la zone doit être évocateur
   - La description doit créer une atmosphère
   - Les tags doivent correspondre au contenu

6. **Format** :
   - Retourne UNIQUEMENT le JSON valide
   - Pas de markdown, pas d'explications, juste le JSON
"""

def build_zone_generation_prompt(zone_description, prefabs_config, zone_size=[1500, 1000], level_range=[1, 5]):
    """Construit le prompt complet pour générer une zone"""
    
    prompt = f"""Tu es un générateur de zones pour le jeu Arthesia, un MMORPG 2D.

{get_lore_context()}

{get_prefabs_list(prefabs_config)}

{get_json_format()}

{get_generation_rules()}

# TÂCHE

Génère une zone avec les caractéristiques suivantes :
- **Description** : {zone_description}
- **Taille** : {zone_size[0]} x {zone_size[1]} pixels
- **Niveau** : {level_range[0]}-{level_range[1]}

**IMPORTANT** : Retourne UNIQUEMENT le JSON, sans ```json ni aucune autre balise ou texte.
"""
    
    return prompt