# Documentation Système de Gestion de Livret d'Épargne

## Informations générales

**Nom du projet** : Système de Gestion de Livret d'Épargne  
**Langage** : COBOL 85  
**Auteur** : Fu YANG  
**Date** : Octobre 2025  
**Version** : 1.0

## Description

Application mainframe de gestion bancaire permettant la création et la gestion de livrets d'épargne. Le système offre des fonctionnalités complètes pour gérer les comptes clients, effectuer des opérations bancaires et générer des rapports.

## Architecture du système

### Fichiers de données

Le système utilise trois fichiers principaux :

1. **comptes.dat** - Fichier indexé

   - Stockage des informations des comptes clients
   - Accès direct par numéro de compte
   - Clé primaire : CPT-NUMERO

2. **mouvements.dat** - Fichier séquentiel

   - Historique de toutes les transactions
   - Enregistrement chronologique des opérations

3. **rapport.txt** - Fichier séquentiel
   - Génération des états et rapports
   - Format texte lisible

### Structure des données

#### Enregistrement COMPTE-RECORD

01 COMPTE-RECORD.
05 CPT-NUMERO PIC 9(10) - Numéro unique du compte
05 CPT-NOM PIC X(30) - Nom du titulaire
05 CPT-PRENOM PIC X(30) - Prénom du titulaire
05 CPT-SOLDE PIC S9(11)V99 - Solde du compte (signé)
05 CPT-DATE-OUVERTURE PIC X(10) - Date création (JJ/MM/AAAA)
05 CPT-TAUX-INTERET PIC 9V99 - Taux d'intérêt annuel
05 CPT-STATUT PIC X - A=Actif, F=Fermé
05 CPT-DATE-MAJ PIC X(10) - Dernière mise à jour

#### Enregistrement MOUVEMENT-RECORD

01 MOUVEMENT-RECORD.
05 MVT-NUMERO-COMPTE PIC 9(10) - Référence compte
05 MVT-TYPE PIC X - D=Dépôt, R=Retrait, I=Intérêt
05 MVT-MONTANT PIC S9(9)V99 - Montant de l'opération
05 MVT-DATE PIC X(10) - Date de l'opération
05 MVT-LIBELLE PIC X(50) - Description

## Fonctionnalités

### 1. Création de compte (Option 1)

Permet d'ouvrir un nouveau livret d'épargne.

**Données requises** :

- Numéro de compte (10 chiffres, unique)
- Nom du titulaire
- Prénom du titulaire
- Taux d'intérêt (format décimal, ex: 2.50)

**Processus** :

1. Vérification de l'unicité du numéro de compte
2. Initialisation du solde à 0 EUR
3. Définition du statut sur "Actif"
4. Enregistrement de la date d'ouverture

**Codes retour** :

- Succès : "Compte cree avec succes!"
- Erreur : "ERREUR: Ce numero existe deja!"

### 2. Dépôt (Option 2)

Ajoute des fonds sur un compte existant.

**Données requises** :

- Numéro de compte
- Montant du dépôt (doit être > 0)

**Processus** :

1. Recherche et lecture du compte
2. Vérification du statut actif
3. Ajout du montant au solde
4. Mise à jour de la date de dernière modification
5. Enregistrement du mouvement dans l'historique

**Validations** :

- Le compte doit exister
- Le compte doit être actif
- Le montant doit être positif

### 3. Retrait (Option 3)

Retire des fonds d'un compte existant.

**Données requises** :

- Numéro de compte
- Montant du retrait

**Processus** :

1. Affichage du solde actuel
2. Vérification de la disponibilité des fonds
3. Soustraction du montant
4. Mise à jour du compte
5. Enregistrement du mouvement

**Validations** :

- Le compte doit exister et être actif
- Le montant doit être positif
- Le solde doit être suffisant (montant ≤ solde)

### 4. Consultation (Option 4)

Affiche les détails complets d'un compte.

**Informations affichées** :

- Identité du titulaire (prénom + nom)
- Numéro de compte
- Solde actuel
- Date d'ouverture
- Taux d'intérêt
- Statut du compte
- Date de dernière mise à jour

### 5. Calcul des intérêts (Option 5)

Calcule et applique les intérêts annuels sur un compte.

**Formule** :

Intérêts = Solde × Taux / 100
Nouveau solde = Solde + Intérêts

**Processus** :

1. Lecture du compte
2. Calcul des intérêts basé sur le taux
3. Affichage du montant des intérêts
4. Demande de confirmation
5. Application si validé (O/N)

**Note** : Les intérêts ne sont appliqués qu'après confirmation de l'utilisateur.

### 6. Génération de rapport (Option 6)

Produit un rapport textuel de tous les comptes du système.

**Contenu du rapport** :

- Titre du rapport
- Liste de tous les comptes avec :
  - Numéro de compte
  - Nom complet du titulaire
  - Solde actuel

**Fichier généré** : rapport.txt

### 0. Quitter

Ferme proprement le système et affiche les statistiques :

- Nombre de comptes traités
- Nombre d'opérations effectuées

## Installation et compilation

### Prérequis

- GnuCOBOL (OpenCOBOL) installé
- Système Linux/Unix ou Windows avec environnement COBOL

### Compilation

cobc -x livret.cbl -o livret

Options de compilation :

- `-x` : Génère un exécutable standalone
- `-o` : Spécifie le nom du fichier de sortie

### Première exécution

./livret

Le système crée automatiquement les fichiers de données nécessaires lors du premier lancement.

## Utilisation

### Démarrage du système

===== GESTION DE LIVRET D'EPARGNE =====
Systeme pret!

1-Creer 2-Depot 3-Retrait 4-Consulter
5-Interets 6-Rapport 0-Quitter
Votre choix:

### Exemple de session complète

1. Créer un compte

   - Numéro : 1234567890
   - Nom : DUPONT
   - Prénom : Jean
   - Taux : 2.50

2. Effectuer un dépôt

   - Compte : 1234567890
   - Montant : 1000.00

3. Consulter le compte

   - Solde : 1000.00 EUR

4. Calculer les intérêts

   - Intérêts : 25.00 EUR
   - Nouveau solde : 1025.00 EUR

5. Générer un rapport
   - Fichier rapport.txt créé

## Gestion des erreurs

### Codes de statut fichier

- `00` : Opération réussie
- `23` : Enregistrement non trouvé
- `35` : Fichier non trouvé
- `10` : Fin de fichier

### Messages d'erreur courants

| Message                        | Cause                       | Solution                 |
| ------------------------------ | --------------------------- | ------------------------ |
| ERREUR: Compte inexistant!     | Numéro de compte invalide   | Vérifier le numéro       |
| ERREUR: Ce numero existe deja! | Doublon lors de la création | Utiliser un autre numéro |
| ERREUR: Compte ferme!          | Opération sur compte fermé  | Réactiver le compte      |
| ERREUR: Montant invalide!      | Montant ≤ 0 ou > solde      | Saisir un montant valide |

## Maintenance

### Sauvegarde des données

# Sauvegarder les fichiers de données

cp comptes.dat comptes.dat.bak
cp mouvements.dat mouvements.dat.bak

### Réinitialisation du système

# Supprimer tous les fichiers de données

rm comptes.dat mouvements.dat rapport.txt

# Relancer le programme pour recréer les fichiers

./livret

### Consultation des mouvements

# Afficher l'historique des transactions

cat mouvements.dat

## Limitations connues

1. **Capacité** : Maximum 99,999 comptes (PIC 9(5))
2. **Solde maximum** : 999,999,999.99 EUR
3. **Sécurité** : Pas d'authentification utilisateur
4. **Concurrence** : Pas de gestion multi-utilisateur
5. **Encodage** : Pas de caractères accentués dans les données

## Évolutions possibles

### Version 2.0 (propositions)

- Ajout de la gestion des bénéficiaires
- Historique complet des opérations par compte
- Calcul d'intérêts composés mensuels
- Génération de relevés PDF
- Interface utilisateur améliorée
- Gestion des virements entre comptes
- Module de statistiques avancées

### Intégration moderne

- API REST pour exposer les données
- Interface web en C#/.NET
- Base de données DB2 pour stockage persistant
- Audit trail complet des opérations

## Support technique

### Compilation échouée

Vérifier :

- Version de GnuCOBOL (minimum 2.0)
- Format du fichier source (Unix LF, pas Windows CRLF)
- Droits d'accès au répertoire

### Problèmes d'exécution

- Vérifier les droits d'écriture dans le répertoire
- Supprimer les fichiers .dat corrompus
- Relancer en mode debug : `./livret 2> debug.log`

## Références

### Documentation COBOL

- Standard COBOL 85
- GnuCOBOL Programmer's Guide
- IBM Enterprise COBOL for z/OS

### Concepts bancaires

- Calcul d'intérêts simples
- Gestion de comptes d'épargne
- Traçabilité des opérations

---

**Note** : Ce projet est développé à des fins pédagogiques dans le cadre de l'apprentissage des technologies mainframe (COBOL/JCL/DB2).
