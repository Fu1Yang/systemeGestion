******************************************************************
      * SYSTEME DE GESTION DE LIVRET D'EPARGNE
      * Programme principal de gestion des operations
      * Auteur: FU YANG
      * Date: 06/10/2025
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. LIVRET-EPARGNE.
       
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-Z15.
       OBJECT-COMPUTER. IBM-Z15.
       
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT COMPTES-FILE ASSIGN TO "comptes.dat"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS CPT-NUMERO
               FILE STATUS IS WS-FILE-STATUS.
           
           SELECT MOUVEMENTS-FILE ASSIGN TO "mouvements.dat"
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-MVT-STATUS.
           
           SELECT RAPPORT-FILE ASSIGN TO "rapport.txt"
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-RPT-STATUS.
       
       DATA DIVISION.
       FILE SECTION.
       FD  COMPTES-FILE.
       01  COMPTE-RECORD.
           05 CPT-NUMERO           PIC 9(10).
           05 CPT-NOM              PIC X(30).
           05 CPT-PRENOM           PIC X(30).
           05 CPT-SOLDE            PIC S9(11)V99.
           05 CPT-DATE-OUVERTURE   PIC X(10).
           05 CPT-TAUX-INTERET     PIC 9V99.
           05 CPT-STATUT           PIC X.
               88 COMPTE-ACTIF     VALUE 'A'.
               88 COMPTE-FERME     VALUE 'F'.
           05 CPT-DATE-MAJ         PIC X(10).
       
       FD  MOUVEMENTS-FILE.
       01  MOUVEMENT-RECORD.
           05 MVT-NUMERO-COMPTE    PIC 9(10).
           05 MVT-TYPE             PIC X.
               88 MVT-DEPOT        VALUE 'D'.
               88 MVT-RETRAIT      VALUE 'R'.
               88 MVT-INTERET      VALUE 'I'.
           05 MVT-MONTANT          PIC S9(9)V99.
           05 MVT-DATE             PIC X(10).
           05 MVT-LIBELLE          PIC X(50).
       
       FD  RAPPORT-FILE.
       01  RAPPORT-RECORD          PIC X(132).
       
       WORKING-STORAGE SECTION.
       01  WS-FILE-STATUS          PIC XX.
           88 WS-FILE-OK           VALUE '00'.
           88 WS-FILE-NOT-FOUND    VALUE '23'.
       
       01  WS-MVT-STATUS           PIC XX.
       01  WS-RPT-STATUS           PIC XX.
       
       01  WS-CHOIX-MENU           PIC 9 VALUE 9.
           88 CREATION-COMPTE      VALUE 1.
           88 DEPOT                VALUE 2.
           88 RETRAIT              VALUE 3.
           88 CONSULTATION         VALUE 4.
           88 CALCUL-INTERETS      VALUE 5.
           88 RAPPORT              VALUE 6.
           88 QUITTER              VALUE 0.
       
       01  WS-NUMERO-COMPTE        PIC 9(10).
       01  WS-MONTANT              PIC 9(9)V99.
       01  WS-NOM                  PIC X(30).
       01  WS-PRENOM               PIC X(30).
       01  WS-TAUX                 PIC 9V99.
       
       01  WS-DATE-JOUR.
           05 WS-ANNEE             PIC 9999.
           05 WS-MOIS              PIC 99.
           05 WS-JOUR              PIC 99.
       
       01  WS-DATE-FORMAT          PIC X(10).
       
       01  WS-CALCUL.
           05 WS-INTERETS          PIC S9(9)V99.
           05 WS-NOUVEAU-SOLDE     PIC S9(11)V99.
       
       01  WS-COMPTEURS.
           05 WS-NB-COMPTES        PIC 9(5) VALUE 0.
           05 WS-NB-OPERATIONS     PIC 9(5) VALUE 0.
       
       01  WS-MESSAGES.
           05 WS-MSG-BIENVENUE     PIC X(50) VALUE
              '===== GESTION DE LIVRET D''EPARGNE ====='.
           05 WS-MSG-MENU          PIC X(50) VALUE
              '1-Creer 2-Depot 3-Retrait 4-Consulter'.
           05 WS-MSG-MENU2         PIC X(50) VALUE
              '5-Interets 6-Rapport 0-Quitter'.
       
       PROCEDURE DIVISION.
       MAIN-PROCEDURE.
           PERFORM INITIALISATION
           IF WS-FILE-OK
               PERFORM MENU-PRINCIPAL UNTIL QUITTER
           END-IF
           PERFORM TERMINAISON
           STOP RUN.
       
       INITIALISATION.
           DISPLAY WS-MSG-BIENVENUE
           OPEN I-O COMPTES-FILE
           IF WS-FILE-STATUS = '35'
               DISPLAY 'Fichier inexistant. Creation...'
               OPEN OUTPUT COMPTES-FILE
               CLOSE COMPTES-FILE
               OPEN I-O COMPTES-FILE
           END-IF
           
           IF NOT WS-FILE-OK
               DISPLAY 'ERREUR ouverture: ' WS-FILE-STATUS
               DISPLAY 'Impossible de continuer.'
           ELSE
               DISPLAY 'Systeme pret!'
           END-IF
           
           ACCEPT WS-DATE-JOUR FROM DATE YYYYMMDD
           STRING WS-JOUR DELIMITED BY SIZE
                  '/' DELIMITED BY SIZE
                  WS-MOIS DELIMITED BY SIZE
                  '/' DELIMITED BY SIZE
                  WS-ANNEE DELIMITED BY SIZE
                  INTO WS-DATE-FORMAT
           END-STRING.
       
       MENU-PRINCIPAL.
           DISPLAY ' '
           DISPLAY WS-MSG-MENU
           DISPLAY WS-MSG-MENU2
           DISPLAY 'Votre choix: ' WITH NO ADVANCING
           ACCEPT WS-CHOIX-MENU
           
           EVALUATE TRUE
               WHEN CREATION-COMPTE
                   PERFORM CREER-COMPTE
               WHEN DEPOT
                   PERFORM EFFECTUER-DEPOT
               WHEN RETRAIT
                   PERFORM EFFECTUER-RETRAIT
               WHEN CONSULTATION
                   PERFORM CONSULTER-COMPTE
               WHEN CALCUL-INTERETS
                   PERFORM CALCULER-INTERETS
               WHEN RAPPORT
                   PERFORM GENERER-RAPPORT
               WHEN QUITTER
                   DISPLAY 'Au revoir!'
               WHEN OTHER
                   DISPLAY 'Choix invalide!'
           END-EVALUATE.
       
       CREER-COMPTE.
           DISPLAY ' '
           DISPLAY '===== CREATION DE COMPTE ====='
           DISPLAY 'Numero de compte (10 chiffres): '
                   WITH NO ADVANCING
           ACCEPT WS-NUMERO-COMPTE
           
           MOVE WS-NUMERO-COMPTE TO CPT-NUMERO
           READ COMPTES-FILE
               INVALID KEY
                   DISPLAY 'Nom: ' WITH NO ADVANCING
                   ACCEPT WS-NOM
                   DISPLAY 'Prenom: ' WITH NO ADVANCING
                   ACCEPT WS-PRENOM
                   DISPLAY 'Taux interet (ex: 2.50): '
                           WITH NO ADVANCING
                   ACCEPT WS-TAUX
                   
                   MOVE WS-NOM TO CPT-NOM
                   MOVE WS-PRENOM TO CPT-PRENOM
                   MOVE 0 TO CPT-SOLDE
                   MOVE WS-DATE-FORMAT TO CPT-DATE-OUVERTURE
                   MOVE WS-TAUX TO CPT-TAUX-INTERET
                   SET COMPTE-ACTIF TO TRUE
                   MOVE WS-DATE-FORMAT TO CPT-DATE-MAJ
                   
                   WRITE COMPTE-RECORD
                   DISPLAY 'Compte cree avec succes!'
                   ADD 1 TO WS-NB-COMPTES
               NOT INVALID KEY
                   DISPLAY 'ERREUR: Ce numero existe deja!'
           END-READ.
       
       EFFECTUER-DEPOT.
           DISPLAY ' '
           DISPLAY '===== DEPOT ====='
           DISPLAY 'Numero de compte: ' WITH NO ADVANCING
           ACCEPT WS-NUMERO-COMPTE
           
           MOVE WS-NUMERO-COMPTE TO CPT-NUMERO
           READ COMPTES-FILE
               INVALID KEY
                   DISPLAY 'ERREUR: Compte inexistant!'
               NOT INVALID KEY
                   IF COMPTE-ACTIF
                       DISPLAY 'Montant du depot: ' WITH NO ADVANCING
                       ACCEPT WS-MONTANT
                       IF WS-MONTANT > 0
                           ADD WS-MONTANT TO CPT-SOLDE
                           MOVE WS-DATE-FORMAT TO CPT-DATE-MAJ
                           REWRITE COMPTE-RECORD
                           DISPLAY 'Depot effectue. Nouveau solde: '
                                   CPT-SOLDE ' EUR'
                           ADD 1 TO WS-NB-OPERATIONS
                           PERFORM ENREGISTRER-MOUVEMENT
                       ELSE
                           DISPLAY 'ERREUR: Montant invalide!'
                       END-IF
                   ELSE
                       DISPLAY 'ERREUR: Compte ferme!'
                   END-IF
           END-READ.
       
       EFFECTUER-RETRAIT.
           DISPLAY ' '
           DISPLAY '===== RETRAIT ====='
           DISPLAY 'Numero de compte: ' WITH NO ADVANCING
           ACCEPT WS-NUMERO-COMPTE
           
           MOVE WS-NUMERO-COMPTE TO CPT-NUMERO
           READ COMPTES-FILE
               INVALID KEY
                   DISPLAY 'ERREUR: Compte inexistant!'
               NOT INVALID KEY
                   IF COMPTE-ACTIF
                       DISPLAY 'Solde actuel: ' CPT-SOLDE ' EUR'
                       DISPLAY 'Montant du retrait: ' WITH NO ADVANCING
                       ACCEPT WS-MONTANT
                       IF WS-MONTANT > 0 AND WS-MONTANT <= CPT-SOLDE
                           SUBTRACT WS-MONTANT FROM CPT-SOLDE
                           MOVE WS-DATE-FORMAT TO CPT-DATE-MAJ
                           REWRITE COMPTE-RECORD
                           DISPLAY 'Retrait effectue. Nouveau solde: '
                                   CPT-SOLDE ' EUR'
                           ADD 1 TO WS-NB-OPERATIONS
                           PERFORM ENREGISTRER-MOUVEMENT
                       ELSE
                           DISPLAY 'ERREUR: Montant ou solde invalide!'
                       END-IF
                   ELSE
                       DISPLAY 'ERREUR: Compte ferme!'
                   END-IF
           END-READ.
       
       CONSULTER-COMPTE.
           DISPLAY ' '
           DISPLAY '===== CONSULTATION ====='
           DISPLAY 'Numero de compte: ' WITH NO ADVANCING
           ACCEPT WS-NUMERO-COMPTE
           
           MOVE WS-NUMERO-COMPTE TO CPT-NUMERO
           READ COMPTES-FILE
               INVALID KEY
                   DISPLAY 'ERREUR: Compte inexistant!'
               NOT INVALID KEY
                   DISPLAY '================================='
                   DISPLAY 'Titulaire: ' CPT-PRENOM ' ' CPT-NOM
                   DISPLAY 'Numero: ' CPT-NUMERO
                   DISPLAY 'Solde: ' CPT-SOLDE ' EUR'
                   DISPLAY 'Date ouverture: ' CPT-DATE-OUVERTURE
                   DISPLAY 'Taux: ' CPT-TAUX-INTERET '%'
                   DISPLAY 'Statut: ' CPT-STATUT
                   DISPLAY 'Derniere MAJ: ' CPT-DATE-MAJ
                   DISPLAY '================================='
           END-READ.
       
       CALCULER-INTERETS.
           DISPLAY ' '
           DISPLAY '===== CALCUL DES INTERETS ====='
           DISPLAY 'Numero de compte: ' WITH NO ADVANCING
           ACCEPT WS-NUMERO-COMPTE
           
           MOVE WS-NUMERO-COMPTE TO CPT-NUMERO
           READ COMPTES-FILE
               INVALID KEY
                   DISPLAY 'ERREUR: Compte inexistant!'
               NOT INVALID KEY
                   IF COMPTE-ACTIF
                       COMPUTE WS-INTERETS =
                           CPT-SOLDE * CPT-TAUX-INTERET / 100
                       COMPUTE WS-NOUVEAU-SOLDE =
                           CPT-SOLDE + WS-INTERETS
                       
                       DISPLAY 'Solde actuel: ' CPT-SOLDE ' EUR'
                       DISPLAY 'Interets calcules: ' WS-INTERETS ' EUR'
                       DISPLAY 'Nouveau solde: ' WS-NOUVEAU-SOLDE ' EUR'
                       
                       DISPLAY 'Appliquer interets? (O/N): '
                               WITH NO ADVANCING
                       ACCEPT WS-CHOIX-MENU
                       IF WS-CHOIX-MENU = 1 OR WS-CHOIX-MENU = 79
                           MOVE WS-NOUVEAU-SOLDE TO CPT-SOLDE
                           MOVE WS-DATE-FORMAT TO CPT-DATE-MAJ
                           REWRITE COMPTE-RECORD
                           DISPLAY 'Interets appliques avec succes!'
                       END-IF
                   ELSE
                       DISPLAY 'ERREUR: Compte ferme!'
                   END-IF
           END-READ.
       
       ENREGISTRER-MOUVEMENT.
           OPEN EXTEND MOUVEMENTS-FILE
           MOVE WS-NUMERO-COMPTE TO MVT-NUMERO-COMPTE
           MOVE WS-MONTANT TO MVT-MONTANT
           MOVE WS-DATE-FORMAT TO MVT-DATE
           
           IF WS-CHOIX-MENU = 2
               MOVE 'D' TO MVT-TYPE
               MOVE 'DEPOT EN ESPECES' TO MVT-LIBELLE
           ELSE
               MOVE 'R' TO MVT-TYPE
               MOVE 'RETRAIT EN ESPECES' TO MVT-LIBELLE
           END-IF
           
           WRITE MOUVEMENT-RECORD
           CLOSE MOUVEMENTS-FILE.
       
       GENERER-RAPPORT.
           DISPLAY ' '
           DISPLAY '===== GENERATION DU RAPPORT ====='
           OPEN OUTPUT RAPPORT-FILE
           
           MOVE 'RAPPORT DES COMPTES D''EPARGNE' TO RAPPORT-RECORD
           WRITE RAPPORT-RECORD
           MOVE '==============================' TO RAPPORT-RECORD
           WRITE RAPPORT-RECORD
           
           MOVE LOW-VALUES TO CPT-NUMERO
           START COMPTES-FILE KEY >= CPT-NUMERO
           
           PERFORM UNTIL WS-FILE-STATUS = '10'
               READ COMPTES-FILE NEXT
                   AT END
                       CONTINUE
                   NOT AT END
                       STRING 'Compte: ' DELIMITED BY SIZE
                              CPT-NUMERO DELIMITED BY SIZE
                              ' - ' DELIMITED BY SIZE
                              CPT-PRENOM DELIMITED BY SIZE
                              ' ' DELIMITED BY SIZE
                              CPT-NOM DELIMITED BY SIZE
                              ' - Solde: ' DELIMITED BY SIZE
                              CPT-SOLDE DELIMITED BY SIZE
                              ' EUR' DELIMITED BY SIZE
                              INTO RAPPORT-RECORD
                       END-STRING
                       WRITE RAPPORT-RECORD
               END-READ
           END-PERFORM
           
           CLOSE RAPPORT-FILE
           DISPLAY 'Rapport genere avec succes!'.
       
       TERMINAISON.
           CLOSE COMPTES-FILE
           DISPLAY 'Nombre de comptes traites: ' WS-NB-COMPTES
           DISPLAY 'Nombre d''operations: ' WS-NB-OPERATIONS.
           