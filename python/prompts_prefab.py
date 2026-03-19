"""
Templates de prompts pour la génération de prefabs
"""

def get_prefab_rules():
    """Règles de génération des prefabs"""
    return """
# RÈGLES DE GÉNÉRATION DE PREFABS

## TYPES D'ÉLÉMENTS AUTORISÉS

UNIQUEMENT ces 3 types sont permis :

1. **element_type: "wall"** - Pour TOUS les éléments solides
   - Murs extérieurs
   - Murs intérieurs
   - Toit (considéré comme un wall)
   - Cheminée (considéré comme un wall)
   - Sol (considéré comme un wall avec wall_type: "floor")
   - Décoration (considérée comme un wall)
   - Tout élément visuel/collision

2. **element_type: "exit"** - Pour les portes/sorties uniquement
   - Portes
   - Portails
   - Escaliers

3. **element_type: "poi"** - NON utilisé dans les prefabs
   - Les POI sont ajoutés par les zones, pas par les prefabs

**IMPORTANT : N'utilise QUE "wall" et "exit". Tout le reste doit être un "wall" !**

## STRUCTURE

1. **Structure** :
   - Maximum 10-12 éléments par prefab
   - Tous les éléments doivent être connectés logiquement
   - Les portes/exits doivent être SUR un mur, pas dans le vide

2. **Tailles** :
   - Small : 60x60 à 100x100 pixels
   - Medium : 100x100 à 180x180 pixels
   - Large : 180x180 à 300x300 pixels

3. **Cohérence** :
   - Les murs doivent former une structure fermée (pour les bâtiments)
   - Les positions doivent être relatives à [0, 0] (coin supérieur gauche)
   - Les couleurs doivent être cohérentes avec le type/matériau

4. **Nommage** :
   - Format : {category}_{material}_{size}_{variant}
   - Ex: house_wood_small_01, forge_stone_medium_01

5. **Types de prefabs** :
   - **Buildings** : Maisons, forges, auberges, tours, etc.
   - **Vegetation** : Arbres individuels, groupes, buissons
   - **Structures** : Fontaines, ruines, campements, ponts
   - **Decorations** : Tonneaux, charrettes, bancs, enseignes
"""

def get_prefab_json_format():
    """Format JSON attendu pour un prefab"""
    return """
# FORMAT JSON ATTENDU

{
  "prefab_id": "house_wood_small_01",
  "prefab_type": "building",
  "name": "Petite Maison en Bois",
  "size": [100, 80],
  "anchor_point": [0, 0],
  
  "elements": [
    {
      "element_type": "wall",
      "id": "wall_north",
      "position": [0, 0],
      "size": [100, 10],
      "wall_type": "wood",
      "color": "#8B4513"
    },
    {
      "element_type": "exit",
      "id": "door",
      "position": [40, 70],
      "size": [20, 10],
      "target_zone_id": "interior",
      "target_spawn_name": "entrance",
      "exit_type": "door",
      "color": "#654321",
      "locked": false,
      "required_key_id": "",
      "min_level": 0
    }
  ]
}
"""

def build_prefab_generation_prompt(description, category="building", size="medium"):
    """Construit le prompt complet pour générer un prefab"""
    
    size_ranges = {
        "small": "60x60 à 100x100",
        "medium": "100x100 à 180x180",
        "large": "180x180 à 300x300"
    }
    
    prompt = f"""Tu es un générateur de prefabs pour le jeu Arthesia, un MMORPG 2D en vue top-down.

{get_prefab_rules()}

{get_prefab_json_format()}

# TÂCHE

Génère un prefab avec les caractéristiques suivantes :
- **Description** : {description}
- **Catégorie** : {category}
- **Taille** : {size} ({size_ranges.get(size, "100x100 à 180x180")} pixels)

**IMPORTANT** : 
- Retourne UNIQUEMENT le JSON du prefab, sans ```json ni aucune autre balise ou texte.
- Les positions doivent commencer à [0, 0] (coin supérieur gauche)
- Assure-toi que les portes/exits sont bien placées SUR un mur
"""
    
    return prompt

def generate_sprite_prompt(prefab_data, description, category, size):
    """Génère le prompt pour créer le sprite du prefab avec contraintes strictes"""
    
    prefab_size = prefab_data.get('size', [128, 128])
    elements = prefab_data.get('elements', [])
    
    # Compter les éléments
    wall_count = sum(1 for e in elements if e.get('element_type') == 'wall')
    exit_count = sum(1 for e in elements if e.get('element_type') == 'exit')
    
    # Identifier les éléments spéciaux
    has_chimney = any('chimney' in e.get('id', '').lower() or 'chimney' in e.get('wall_type', '').lower() 
                      for e in elements if e.get('element_type') == 'wall')
    has_roof = any('roof' in e.get('id', '').lower() or 'roof' in e.get('wall_type', '').lower() 
                   for e in elements if e.get('element_type') == 'wall')
    
    # Construire la description de structure
    structure_parts = []
    if has_roof:
        structure_parts.append("roof")
    if has_chimney:
        structure_parts.append("chimney on top")
    if exit_count > 0:
        structure_parts.append("door at bottom center")
    
    structure_desc = ", ".join(structure_parts) if structure_parts else "simple structure"
    
    # Mots-clés selon la catégorie
    category_style = {
        "building": "stone/wood building",
        "vegetation": "tree or plant",
        "structure": "monument or structure",
        "decoration": "decorative object"
    }
    
    style_hint = category_style.get(category, "game object")
    
    # Construire le prompt
    sprite_prompt = f"""STRICT top-down view pixel art sprite (like classic Zelda or Pokemon),
{description}, 2D FLAT view from directly above,
NOT isometric, NOT 3D perspective, COMPLETELY FLAT overhead view,

CRITICAL DIMENSIONS:
- Sprite size: EXACTLY {prefab_size[0]}x{prefab_size[1]} pixels
- Canvas: 128x128px (sprite centered)
- Building MUST fit within {prefab_size[0]}x{prefab_size[1]}px boundaries
- Rectangular shape when viewed from above

STRUCTURE:
- {wall_count} structural elements
- Features: {structure_desc}
- {exit_count} entrance(s)

COLLISION RULES:
1. Sprite MUST NOT exceed {prefab_size[0]}x{prefab_size[1]}px
2. Walls are solid barriers (visible as rectangular outline)
3. Match rectangular collision boundaries exactly
4. All elements viewed from directly overhead (flat)

MUST BE SIMPLE:
- Solid color blocks, NOT complex tilemap
- Clean geometric shapes
- Maximum 6-8 colors total
- Large simple areas, minimal detail

STYLE:
- Retro 16-bit JRPG pixel art (like SNES Zelda)
- Simple flat geometric shapes from above
- Warm medieval fantasy colors
- Clear rectangular silhouette
- Transparent background
- NO perspective, NO depth, FLAT 2D only

Reference: The Legend of Zelda A Link to the Past buildings,
Pokemon town structures, Stardew Valley buildings,
classic top-down RPG architecture - SIMPLE style, not detailed tilemap"""
    
    # Nettoyer les retours à la ligne multiples
    return " ".join(sprite_prompt.split())