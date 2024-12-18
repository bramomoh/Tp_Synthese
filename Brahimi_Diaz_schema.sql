-- MySQL Script generated by MySQL Workbench
-- Wed Nov 27 08:30:33 2024
-- Model: New Model    Version: 1.0
-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
DROP DATABASE IF EXISTS bd_tp_synthese;
CREATE DATABASE bd_tp_synthese;
USE bd_tp_synthese;

-- -----------------------------------------------------
-- Table `vendeur`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `vendeur` ;

CREATE TABLE IF NOT EXISTS `vendeur` (
  `numeroVendeur` TINYINT(3) UNSIGNED NOT NULL,
  `nom` VARCHAR(50) NULL,
  `numeroSuperviseur` TINYINT(3) UNSIGNED NOT NULL,
  PRIMARY KEY (`numeroVendeur`),
  INDEX `fk_vendeur_vendeur_idx` (`numeroSuperviseur` ASC) VISIBLE,
  CONSTRAINT `fk_vendeur_vendeur`
    FOREIGN KEY (`numeroSuperviseur`)
    REFERENCES `vendeur` (`numeroVendeur`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `client`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `client` ;

CREATE TABLE IF NOT EXISTS `client` (
  `codeClient` CHAR(6) NOT NULL,
  `titre` VARCHAR(4) NULL,
  `prenom` VARCHAR(20) NULL,
  `nom` VARCHAR(30) NULL,
  `adresse` VARCHAR(50) NULL,
  `codePostal` DECIMAL(5,0) UNSIGNED NULL,
  `ville` VARCHAR(50) NULL,
  `telephone` CHAR(10) NULL,
  `dateNaissance` DATE NULL,
  PRIMARY KEY (`codeClient`),
constraint ck_titre_valide CHECK('titre' IN ('Mlle','M.','Mme')))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paiement`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `paiement` ;

CREATE TABLE IF NOT EXISTS `paiement` (
  `modePaiement` CHAR(2) NOT NULL,
  `signification` VARCHAR(50) NULL,
  PRIMARY KEY (`modePaiement`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `commande`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `commande` ;

CREATE TABLE IF NOT EXISTS `commande` (
  `numeroCommande` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `codeClient` CHAR(6) NOT NULL,
  `dateCommande` DATE NULL,
  `modePaiement` CHAR(2) NOT NULL,
  `numeroVendeur` TINYINT(3) UNSIGNED NULL,
  PRIMARY KEY (`numeroCommande`),
  INDEX `fk_commande_vendeur1_idx` (`numeroVendeur` ASC) VISIBLE,
  INDEX `fk_commande_client1_idx` (`codeClient` ASC) VISIBLE,
  INDEX `fk_commande_paiement1_idx` (`modePaiement` ASC) VISIBLE,
  CONSTRAINT `fk_commande_vendeur1`
    FOREIGN KEY (`numeroVendeur`)
    REFERENCES `vendeur` (`numeroVendeur`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_commande_client1`
    FOREIGN KEY (`codeClient`)
    REFERENCES `client` (`codeClient`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_commande_paiement1`
    FOREIGN KEY (`modePaiement`)
    REFERENCES `paiement` (`modePaiement`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `categorie`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `categorie` ;

CREATE TABLE IF NOT EXISTS `categorie` (
  `codeCategorie` CHAR(2) NOT NULL,
  `signification` VARCHAR(20) NOT NULL,
  PRIMARY KEY (`codeCategorie`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `livre`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `livre` ;

CREATE TABLE IF NOT EXISTS `livre` (
  `numeroLivre` SMALLINT(5) NOT NULL AUTO_INCREMENT,
  `titre` VARCHAR(255) NULL,
  `codeCategorie` CHAR(2) NOT NULL,
  `descriptif` TEXT NULL,
  `prixCatalogue` DECIMAL(10,2) NULL,
  `nbrePages` SMALLINT(5) NULL,
  PRIMARY KEY (`numeroLivre`),
  INDEX `fk_livre_categorie1_idx` (`codeCategorie` ASC) VISIBLE,
  CONSTRAINT `fk_livre_categorie1`
    FOREIGN KEY (`codeCategorie`)
    REFERENCES `categorie` (`codeCategorie`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    CONSTRAINT ck_nbrePages_valide CHECK (nbrePages BETWEEN 0 AND 1000))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `detailCommande`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `detailCommande` ;

CREATE TABLE IF NOT EXISTS `detailCommande` (
  `numeroCommande` INT(10) UNSIGNED NOT NULL,
  `numeroLivre` SMALLINT(5) NOT NULL,
  `prixUnitaire` DECIMAL(10,2) NOT NULL,
  `quantite` SMALLINT(6) NOT NULL,
  PRIMARY KEY (`numeroCommande`, `numeroLivre`),
  INDEX `fk_detailCommande_livre1_idx` (`numeroLivre` ASC) VISIBLE,
  CONSTRAINT `fk_detailCommande_commande1`
    FOREIGN KEY (`numeroCommande`)
    REFERENCES `commande` (`numeroCommande`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_detailCommande_livre1`
    FOREIGN KEY (`numeroLivre`)
    REFERENCES `livre` (`numeroLivre`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    CONSTRAINT ck_prix_valide CHECK (prixUnitaire > 0),
    CONSTRAINT ck_quantite_valide CHECK (quantite > 0))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `auteur`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `auteur` ;

CREATE TABLE IF NOT EXISTS `auteur` (
  `codeAuteur` SMALLINT(5) NOT NULL,
  `auteur` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`codeAuteur`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `livre_auteur`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `livre_auteur` ;

CREATE TABLE IF NOT EXISTS `livre_auteur` (
  `codeAuteur` SMALLINT(5) NOT NULL,
  `numeroLivre` SMALLINT(5) NOT NULL,
  PRIMARY KEY (`codeAuteur`, `numeroLivre`),
  INDEX `fk_livre_auteur_livre1_idx` (`numeroLivre` ASC) VISIBLE,
  CONSTRAINT `fk_livre_auteur_auteur1`
    FOREIGN KEY (`codeAuteur`)
    REFERENCES `auteur` (`codeAuteur`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_livre_auteur_livre1`
    FOREIGN KEY (`numeroLivre`)
    REFERENCES `livre` (`numeroLivre`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
