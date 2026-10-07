"""Tests de bout en bout du projet GnuCOBOL, sans modifier ses données."""

from pathlib import Path
import subprocess
import tempfile
import unittest


SOURCE = Path(__file__).with_name("livret.cbl")


class LivretTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.build_dir = tempfile.TemporaryDirectory(prefix="livret-build-")
        cls.program = Path(cls.build_dir.name) / "livret"
        subprocess.run(
            ["cobc", "-x", "-Wall", str(SOURCE), "-o", str(cls.program)],
            check=True,
            capture_output=True,
            text=True,
        )

    @classmethod
    def tearDownClass(cls):
        cls.build_dir.cleanup()

    def run_livret(self, directory, *answers):
        result = subprocess.run(
            [str(self.program)],
            input="\n".join(answers) + "\n",
            text=True,
            cwd=directory,
            capture_output=True,
            timeout=5,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("Au revoir!", result.stdout)
        return result.stdout

    def test_empty_report_finishes(self):
        with tempfile.TemporaryDirectory(prefix="livret-empty-") as directory:
            output = self.run_livret(directory, "6")
            self.assertIn("Rapport genere avec succes!", output)
            report = (Path(directory) / "rapport.txt").read_text()
            self.assertIn("Aucun compte.\n", report)

    def test_account_operations_interest_and_persistence(self):
        with tempfile.TemporaryDirectory(prefix="livret-full-") as directory:
            output = self.run_livret(
                directory,
                "1", "1234567890", "DUPONT", "Jean", "2.50",
                "2", "1234567890", "1000.00",
                "3", "1234567890", "250.00",
                "5", "1234567890", "N",
                "5", "1234567890", "O",
                "4", "1234567890",
                "6", "0",
            )
            self.assertEqual(output.count("Interets appliques!"), 1)
            self.assertIn("Solde: +00000000768.75 EUR", output)
            report = (Path(directory) / "rapport.txt").read_text()
            self.assertIn("Compte: 1234567890 - Jean DUPONT - Solde: 768.75 EUR\n", report)
            movements = (Path(directory) / "mouvements.dat").read_text().splitlines()
            self.assertEqual(len(movements), 3)
            self.assertEqual([line[10] for line in movements], ["D", "R", "I"])

            output_again = self.run_livret(directory, "4", "1234567890", "0")
            self.assertIn("Solde: +00000000768.75 EUR", output_again)

    def test_invalid_values_do_not_change_balance(self):
        with tempfile.TemporaryDirectory(prefix="livret-invalid-") as directory:
            output = self.run_livret(
                directory,
                "1", "abc",
                "1", "1234567890", "DUPONT", "Jean", "10.00",
                "1", "1234567890", "DUPONT", "Jean", "2.50",
                "1", "1234567890",
                "2", "1234567890", "abc",
                "2", "1234567890", "0",
                "2", "1234567890", "1.234",
                "3", "1234567890", "100.00",
                "4", "1234567890", "0",
            )
            self.assertIn("Numero de compte invalide!", output)
            self.assertIn("Taux attendu de 0 a 9.99%!", output)
            self.assertIn("Ce numero existe deja!", output)
            self.assertIn("Deux decimales maximum!", output)
            self.assertIn("Montant ou solde invalide!", output)
            self.assertIn("Solde: +00000000000.00 EUR", output)
            self.assertEqual((Path(directory) / "mouvements.dat").stat().st_size, 0)


if __name__ == "__main__":
    unittest.main()
