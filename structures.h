/* ================================================================== */
/* STRUCTURES.H : Structures de données et Prototypes                 */
/* ================================================================== */

#ifndef STRUCTURES_H
#define STRUCTURES_H

/* --- 1. DÉFINITIONS DES STRUCTURES --- */

// Types de données SQL supportés
typedef enum {
    TYPE_INT = 1,
    TYPE_FLOAT = 2,
    TYPE_BOOL = 3,
    TYPE_VARCHAR = 4
} DataType;

// Structure pour un Champ (Colonne)
typedef struct Field {
    char *name;             // Nom du champ
    int type;               // Type de donnée
    struct Field *next;     // Chaînage vers le prochain champ
} Field;

// Structure pour une Table
typedef struct Table {
    char *name;             // Nom de la table
    Field *fields;          // Pointeur vers la liste des champs
    struct Table *next;     // Chaînage vers la prochaine table
} Table;

/* --- 2. VARIABLE GLOBALE (Accessible partout) --- */
extern Table *symbolTable;

/* --- 3. PROTOTYPES DES FONCTIONS (Implémentées dans semantics.c) --- */

// Vérifie si une table existe (1 = Oui, 0 = Non)
int check_table_exists(char *name);

// Ajoute une table à la table des symboles
void add_table(char *name, Field *fields);

// Compte le nombre de colonnes d'une table
int get_field_count(char *tableName);

// Supprime une table et nettoie la mémoire
void drop_table_semantic(char *name);

#endif