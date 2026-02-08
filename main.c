#include <stdio.h>
#include <stdlib.h>
#include "structures.h"

extern int yyparse(void);
extern FILE *yyin;

int main(int argc, char **argv) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <fichier.sql>\n", argv[0]);
        return 1;
    }

    FILE *f = fopen(argv[1], "r");
    if (!f) {
        perror("Erreur ouverture fichier");
        return 1;
    }

    yyin = f;
        printf("==================================================\n");
    printf("   INTERPRETEUR GLSimpleSQL - DEBUT D'ANALYSE\n");
    printf("==================================================\n");

    int r = yyparse();

    printf("==================================================\n");
    if (r == 0) {
        printf("   ANALYSE TERMINEE AVEC SUCCES.\n");
    } else {
        printf("   ANALYSE TERMINEE AVEC ERREURS.\n");
    }
    printf("==================================================\n");

    fclose(f);
    free_all_tables();
    return r;
}
