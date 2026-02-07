/* ================================================================== */
/* SEMANTICS.C : Implémentation de la Table des Symboles              */
/* ================================================================== */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "structures.h"

// Variable globale : Tête de la liste chaînée des tables
Table *symbolTable = NULL;

/* ------------------------------------------------------------------ */
/* Fonction : check_table_exists                                      */
/* Rôle : Vérifie si une table existe déjà par son nom                */
/* Retourne : 1 (Vrai) ou 0 (Faux)                                    */
/* ------------------------------------------------------------------ */
int check_table_exists(char *name) {
    Table *current = symbolTable;
    while (current != NULL) {
        if (strcmp(current->name, name) == 0) {
            return 1; // Trouvé
        }
        current = current->next;
    }
    return 0; // Pas trouvé
}

/* ------------------------------------------------------------------ */
/* Fonction : add_table                                               */
/* Rôle : Ajoute une nouvelle table et ses champs en mémoire          */
/* ------------------------------------------------------------------ */
void add_table(char *name, Field *fields) {
    // 1. Allouer la nouvelle table
    Table *newTable = (Table*)malloc(sizeof(Table));
    
    // 2. Copier le nom (strdup alloue la mémoire nécessaire)
    newTable->name = strdup(name);
    
    // 3. Associer la liste des champs
    newTable->fields = fields;
    
    // 4. Insérer en tête de liste (plus rapide)
    newTable->next = symbolTable;
    symbolTable = newTable;
}

/* ------------------------------------------------------------------ */
/* Fonction : get_field_count                                         */
/* Rôle : Compte le nombre de colonnes d'une table (pour INSERT)      */
/* ------------------------------------------------------------------ */
int get_field_count(char *tableName) {
    Table *current = symbolTable;
    
    // Trouver la table
    while (current != NULL) {
        if (strcmp(current->name, tableName) == 0) {
            // Table trouvée, compter les champs
            int count = 0;
            Field *f = current->fields;
            while (f != NULL) {
                count++;
                f = f->next;
            }
            return count;
        }
        current = current->next;
    }
    return -1; // Table non trouvée (sécurité)
}

/* ------------------------------------------------------------------ */
/* Fonction : drop_table_semantic                                     */
/* Rôle : Supprime une table et libère toute la mémoire associée      */
/* ------------------------------------------------------------------ */
void drop_table_semantic(char *name) {
    Table *current = symbolTable;
    Table *prev = NULL;

    while (current != NULL) {
        if (strcmp(current->name, name) == 0) {
            // --- Suppression trouvée ---
            
            // 1. Détacher le noeud de la liste des tables
            if (prev == NULL) {
                symbolTable = current->next; // C'était le premier élément
            } else {
                prev->next = current->next; // C'était au milieu ou à la fin
            }

            // 2. Libérer les champs (Field) de cette table
            Field *f = current->fields;
            while (f != NULL) {
                Field *tempF = f;
                f = f->next;
                free(tempF->name); // Libérer le nom du champ
                free(tempF);       // Libérer la structure champ
            }

            // 3. Libérer la table elle-même
            free(current->name);
            free(current);
            return;
        }
        
        // Avancer
        prev = current;
        current = current->next;
    }
}