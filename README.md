# Gestion de livret d'épargne en COBOL

Projet pédagogique en **GnuCOBOL** : une application en terminal qui gère des comptes d'épargne dans un fichier indexé. Le programme propose la création et la consultation de comptes, les dépôts, les retraits, le calcul manuel d'intérêts simples, un journal des mouvements et un rapport texte.

Ce dépôt démontre la programmation COBOL et les fichiers indexés. Il ne s'exécute pas sur IBM z/OS et n'utilise ni JCL, ni DB2, ni VSAM.

## Installation et lancement

Prérequis : GnuCOBOL 3.x (`cobc`) et un terminal Linux, WSL ou équivalent.

```sh
cobc -x -Wall livret.cbl -o livret
./livret
```

Lancer le programme dans un répertoire où il peut créer et modifier ses fichiers. À la première exécution, il crée `comptes.dat` et `mouvements.dat`. Le menu permet ensuite de créer un compte et de réaliser des opérations. Les données des comptes sont conservées entre les exécutions.

## Saisies et calculs

- Le numéro de compte comporte exactement **10 chiffres** et doit être unique.
- Un dépôt ou un retrait est strictement positif, avec au plus deux décimales ; un retrait ne peut pas dépasser le solde.
- Le taux annuel saisi à la création est compris entre **0 et 9,99 %**.
- L'option « Intérêts » calcule `solde × taux / 100`, arrondi au centime. Répondre `O` applique les intérêts ; `N` laisse le solde inchangé.
- L'option « Rapport » écrit `rapport.txt`, avec un compte par ligne. Sur une base vide, le rapport indique « Aucun compte. ».

## Fichiers créés

| Fichier | Rôle |
| --- | --- |
| `comptes.dat` | Base indexée GnuCOBOL des comptes. C'est un fichier binaire propre à l'environnement d'exécution. |
| `mouvements.dat` | Journal séquentiel des dépôts, retraits et intérêts appliqués. Chaque enregistrement contient le compte, le type, le montant, la date et un libellé. |
| `rapport.txt` | Rapport texte lisible généré à la demande. |

Les fichiers de données et le binaire compilé ne sont pas versionnés. Pour repartir de zéro, exécuter le programme dans un nouveau dossier de travail. **Ne pas supprimer `comptes.dat` si des données doivent être conservées.**

## Vérification

```sh
python3 test_livret.py
```

Les tests compilent le programme dans un dossier temporaire et couvrent une base vide, la création, les opérations, les intérêts avec confirmations `O` et `N`, la persistance, le rapport, le journal et les saisies invalides. Ils ne modifient pas vos fichiers de données.

## Portée

Cette application est une simulation pédagogique. Elle ne fournit pas l'authentification, la gestion de plusieurs utilisateurs, une transaction atomique entre le compte et son journal, ni une protection contre l'application répétée des intérêts sur un même exercice. Elle ne doit pas servir à gérer de l'argent réel.
