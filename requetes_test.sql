-- ============================================================
-- PROJET THL : JEU DE TESTS (SCÉNARIO PARC AUTOMOBILE)
-- ============================================================

-- ------------------------------------------------------------
-- 1. CRÉATION DE TABLE (DDL)
-- ------------------------------------------------------------
-- Test des types variés : INT, VARCHAR, FLOAT, BOOL
CREATE TABLE Voiture (
    id INT,
    marque VARCHAR(50),
    prix FLOAT,
    disponible BOOL
);

-- ------------------------------------------------------------
-- 2. INSERTION DE DONNÉES (DML)
-- ------------------------------------------------------------
-- Cas 1 : Insertion standard (tous les champs)
INSERT INTO Voiture VALUES (101, 'Toyota', 15000.50, TRUE);

-- Cas 2 : Insertion d'une autre ligne
INSERT INTO Voiture VALUES (102, 'Ford', 22000.00, TRUE);

-- Cas 3 : Insertion avec spécification des colonnes (Syntaxe alternative)
INSERT INTO Voiture (id, marque) VALUES (103, 'Tesla');

-- ------------------------------------------------------------
-- 3. SÉLECTIONS (SELECT)
-- ------------------------------------------------------------
-- Cas 1 : Sélection globale
SELECT * FROM Voiture;

-- Cas 2 : Sélection de champs spécifiques
SELECT marque FROM Voiture;

-- Cas 3 : Clause WHERE simple (Comparaison Float)
SELECT marque, prix FROM Voiture WHERE prix > 20000.00;

-- Cas 4 : Conditions multiples (AND, manipulation BOOL)
SELECT * FROM Voiture WHERE disponible = TRUE AND prix < 18000.00;

-- ------------------------------------------------------------
-- 4. MISES À JOUR (UPDATE)
-- ------------------------------------------------------------
-- Modification simple avec WHERE
UPDATE Voiture SET prix = 14500.00 WHERE id = 101;

-- Modification multiple (prix ET disponibilité)
UPDATE Voiture SET prix = 10000.00, disponible = FALSE WHERE marque = 'Ford';

-- ------------------------------------------------------------
-- 5. SUPPRESSIONS (DELETE)
-- ------------------------------------------------------------
-- Suppression avec condition complexe (OR)
DELETE FROM Voiture WHERE prix > 50000.00 OR disponible = FALSE;

-- Suppression spécifique
DELETE FROM Voiture WHERE id = 103;

-- ------------------------------------------------------------
-- 6. NETTOYAGE
-- ------------------------------------------------------------
DROP TABLE Voiture;


-- ============================================================
-- TESTS D'ERREURS (Doivent déclencher des messages d'erreur)
-- ============================================================

-- TEST 1 : Table inexistante
SELECT * FROM Avion;

-- (On recrée Voiture pour la suite des tests)
CREATE TABLE Voiture (id INT, marque VARCHAR(20));

-- TEST 2 : Champ inexistant

SELECT couleur FROM Voiture;

-- TEST 3 : Incohérence INSERT
-- La table a 2 champs, mais on fournit 3 valeurs.
INSERT INTO Voiture VALUES (1, 'BMW', 'Rouge');

-- TEST 4 : Table déjà existante
CREATE TABLE Voiture (id INT);

-- TEST 5 : Suppression table inexistante
DROP TABLE Camion;

-- TEST 6 : Syntaxe invalide
SELECT marque, FROM Voiture;