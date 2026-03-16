# Configuration du générateur de zones

# ============================================================================
# API GEMINI
# ============================================================================

GEMINI_API_KEY = "AIzaSyAbm2vzM0IkGuCfkOjebEn6ayjzEXmWwxs"  
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
        }
    ],
    "vegetation": [
        {
            "id": "tree_oak",
            "name": "Chêne",
            "size": [40, 40],
            "description": "Un chêne standard"
        }
    ]
}

# ============================================================================
# LIMITES
# ============================================================================

MAX_OUTPUT_TOKENS = 8192  # Limite pour éviter les coûts excessifs