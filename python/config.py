# Configuration du générateur de zones

# ============================================================================
# API GEMINI
# ============================================================================

GEMINI_API_KEY = "key"  
GEMINI_MODEL = "models/gemini-2.5-flash"  # Modèle à utiliser

# ============================================================================
# CHEMINS
# ============================================================================

# Chemin vers le dossier Godot (ajuste selon ton projet)
GODOT_PROJECT_PATH = "../"  # Dossier parent
ZONES_OUTPUT_PATH = "../test/"  # Où sauvegarder les zones générées

# ============================================================================
# PREFABS DISPONIBLES
# ============================================================================

AVAILABLE_PREFABS = {
    "buildings": [
        {
            "id": "house_simple",
            "name": "Maison Simple",
            "size": [120, 100],
            "description": "Petite maison en bois avec une porte"
        },
        {
            "id": "forge",
            "name": "Forge",
            "size": [140, 120],
            "description": "Forge en pierre avec cheminée"
        },
        {
            "id": "inn",
            "name": "Auberge",
            "size": [180, 140],
            "description": "Grande auberge en bois avec enseigne"
        }
    ],
    "vegetation": [
        {
            "id": "tree_oak",
            "name": "Chêne",
            "size": [40, 40],
            "description": "Un chêne standard"
        },
        {
            "id": "tree_cluster_5",
            "name": "Groupe de 5 Arbres",
            "size": [120, 120],
            "description": "Un groupe de 5 arbres pré-placés"
        }
    ]
}

# ============================================================================
# LIMITES
# ============================================================================

MAX_OUTPUT_TOKENS = 8192  # Limite pour éviter les coûts excessifs