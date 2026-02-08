#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "structures.h"

Table *symbolTable = NULL;

static int fields_have_duplicates(Field *fields) {
    for (Field *a = fields; a; a = a->next) {
        for (Field *b = a->next; b; b = b->next) {
            if (strcmp(a->name, b->name) == 0) return 1;
        }
    }
    return 0;
}

void free_fields(Field *fields) {
    while (fields) {
        Field *n = fields->next;
        free(fields->name);
        free(fields);
        fields = n;
    }
}

int check_table_exists(const char *name) {
    for (Table *t = symbolTable; t; t = t->next) {
        if (strcmp(t->name, name) == 0) return 1;
    }
    return 0;
}

static Table* find_table(const char *name) {
    for (Table *t = symbolTable; t; t = t->next) {
        if (strcmp(t->name, name) == 0) return t;
    }
    return NULL;
}

int check_field_exists(const char *tableName, const char *fieldName) {
    Table *t = find_table(tableName);
    if (!t) return 0;
    for (Field *f = t->fields; f; f = f->next) {
        if (strcmp(f->name, fieldName) == 0) return 1;
    }
    return 0;
}

int add_table(const char *name, Field *fields) {
    if (check_table_exists(name)) return 0;
    if (fields_have_duplicates(fields)) return 0;

    Table *t = (Table*)malloc(sizeof(Table));
    if (!t) return 0;

    t->name = _strdup(name); /* Windows */
    if (!t->name) { free(t); return 0; }

    t->fields = fields;
    t->next = symbolTable;
    symbolTable = t;
    return 1;
}

int get_field_count(const char *tableName) {
    Table *t = find_table(tableName);
    if (!t) return -1;
    int c = 0;
    for (Field *f = t->fields; f; f = f->next) c++;
    return c;
}

int drop_table_semantic(const char *name) {
    Table *cur = symbolTable;
    Table *prev = NULL;

    while (cur) {
        if (strcmp(cur->name, name) == 0) {
            if (prev) prev->next = cur->next;
            else symbolTable = cur->next;

            free_fields(cur->fields);
            free(cur->name);
            free(cur);
            return 1;
        }
        prev = cur;
        cur = cur->next;
    }
    return 0;
}

void free_all_tables(void) {
    while (symbolTable) {
        Table *n = symbolTable->next;
        free_fields(symbolTable->fields);
        free(symbolTable->name);
        free(symbolTable);
        symbolTable = n;
    }
}
