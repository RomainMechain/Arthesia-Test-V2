# Configuration du générateur de zones

# =============================================================================
# API PROVIDER SELECTION
# =============================================================================

USE_CLAUDE = False  # True = Claude, False = Gemini

# =============================================================================
# CLAUDE API CONFIGURATION
# =============================================================================

CLAUDE_API_KEY = ""  # ← REMPLACE par ta clé API
CLAUDE_MODEL = "claude-sonnet-4-6"  # Modèle recommandé

# Alternative models:
# "claude-3-opus-20240229"  # Plus puissant mais plus cher
# "claude-3-5-haiku-20241022"  # Plus rapide et moins cher

CLAUDE_MAX_TOKENS = 8192  # Output tokens max

# ============================================================================
# API GEMINI
# ============================================================================

GEMINI_API_KEY = ""  
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
            "id": "forge_stone_medium_01",
            "name": "Petite Forge en Pierre",
            "size": [120, 100],
            "description": "Forge en pierre avec cheminée"
        },
        {
            "id": "shop_rune_wood_medium_01",
            "name": "Boutique de Runes en Bois",
            "size": [120, 100],
            "description": "Boutique en bois spécialisée dans les runes magiques"
        },
        {
            "id": "guild_hall_wood_stone_large_01",
            "name": "Guilde des Aventuriers",
            "size": [280, 220],
            "description": "Salle de réunion pour les membres de la guilde"
        },
        {
            "id": "house_wood_medium_01",
            "name": "Maison de Villageois en Bois",
            "size": [130, 110],
            "description": "Maison en bois typique d'un village"
        },
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