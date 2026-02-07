/* ================================================================== */
/* MAIN.C : Point d'entrée de l'interpréteur GLSimpleSQL              */
/* ================================================================== */

#include <stdio.h>
#include <stdlib.h>

/* --- Déclarations externes fournies par Flex/Bison --- */
extern int yyparse();       // La fonction principale de parsing
extern FILE *yyin;          // Le pointeur de fichier lu par le scanner
extern int yylineno;        // Compteur de ligne

int main(int argc, char *argv[]) {
    
    // 1. Vérification des arguments
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <fichier_requetes.sql>\n", argv[0]);
        return 1;
    }

    // 2. Ouverture du fichier SQL
    FILE *file = fopen(argv[1], "r");
    if (!file) {
        perror("Erreur lors de l'ouverture du fichier");
        return 1;
    }

    // 3. Configuration de Flex pour lire ce fichier
    yyin = file;

    printf("==================================================\n");
    printf("   INTERPRÉTEUR GLSimpleSQL - DÉBUT D'ANALYSE\n");
    printf("==================================================\n");

    // 4. Lancement de l'analyse syntaxique
    // yyparse() renvoie 0 si succès, 1 si erreur syntaxique
    int result = yyparse();

    printf("==================================================\n");
    if (result == 0) {
        printf("   ANALYSE TERMINÉE AVEC SUCCÈS.\n");
    } else {
        printf("   ANALYSE TERMINÉE AVEC ERREURS.\n");
    }
    printf("==================================================\n");

    // 5. Nettoyage
    fclose(file);
    return result;
}