#ifndef STRUCTURES_H
#define STRUCTURES_H

typedef enum {
    TYPE_INT = 1,
    TYPE_FLOAT = 2,
    TYPE_BOOL = 3,
    TYPE_VARCHAR = 4
} DataType;

typedef struct Field {
    char *name;
    int type;           /* TYPE_INT, TYPE_FLOAT, TYPE_BOOL, TYPE_VARCHAR */
    int varchar_len;    /* 0 si pas VARCHAR(n) */
    struct Field *next;
} Field;

typedef struct Table {
    char *name;
    Field *fields;
    struct Table *next;
} Table;

extern Table *symbolTable;

int check_table_exists(const char *name);
int check_field_exists(const char *tableName, const char *fieldName);

int add_table(const char *name, Field *fields);
int get_field_count(const char *tableName);
int drop_table_semantic(const char *name);

void free_fields(Field *fields);
void free_all_tables(void);

#endif