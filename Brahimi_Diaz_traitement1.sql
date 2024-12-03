USE bd_tp_synthese;
/********************Question R1***********************/
SELECT  DISTINCT signification as "categorie",nom as "vendeur",SUM(prixUnitaire * quantite) as "total" from livre 
INNER JOIN categorie on categorie.codeCategorie = livre.codeCategorie
INNER JOIN detailcommande on livre.numeroLivre = detailcommande.numeroLivre
INNER JOIN commande ON  detailcommande.numeroCommande = commande.numeroCommande
INNER JOIN vendeur ON vendeur.numeroVendeur = commande.numeroVendeur
GROUP BY signification,nom
HAVING signification IN ('Art','Histoire','Psychologie')
ORDER BY categorie,SUM(prixUnitaire * quantite)  DESC;
/********************Question R2***********************/
SELECT  DISTINCT nom as "vendeur",signification as "categorie",SUM(prixUnitaire * quantite) as "total" from livre 
INNER JOIN categorie on categorie.codeCategorie = livre.codeCategorie
INNER JOIN detailcommande on livre.numeroLivre = detailcommande.numeroLivre
INNER JOIN commande ON  detailcommande.numeroCommande = commande.numeroCommande
INNER JOIN vendeur ON vendeur.numeroVendeur = commande.numeroVendeur
GROUP BY signification,nom HAVING SUM(prixUnitaire * quantite) > 200
ORDER BY SUM(prixUnitaire * quantite)  DESC;
/********************Question R3***********************/
SELECT livre.numeroLivre, titre, prixCatalogue from livre
LEFT JOIN detailcommande on livre.numeroLivre = detailcommande.numeroLivre
WHERE prixCatalogue < 12 AND detailcommande.numeroLivre IS NULL
ORDER BY prixCatalogue;
/********************Question R4***********************/
SELECT DISTINCT ville, count(codeClient) as "Nombre de client"from client
GROUP BY ville
ORDER BY ville;
/********************Question R5***********************/
SELECT nom, COUNT(numeroCommande) from vendeur
LEFT JOIN commande ON vendeur.numeroVendeur = commande.numeroVendeur
GROUP BY nom;
/********************question D1****************/
DROP TRIGGER IF EXISTS trigControlePrixUnitaire;
DELIMITER |
CREATE TRIGGER trigControlePrixUnitaire BEFORE INSERT ON detailCommande
FOR EACH ROW
BEGIN
DECLARE vPrixCatalogue DECIMAL(10,2);
SET vPrixCatalogue = (SELECT prixCatalogue FROM livre WHERE livre.numeroLivre = NEW.numeroLivre);
IF prixUnitaire > vPrixCatalogue THEN
SET NEW.prixUnitaire = vPrixCatalogue;
END IF;
END|
DELIMITER ;
/********************question D2****************/
DROP TRIGGER IF EXISTS trigControleAjoutClient;
DELIMITER |
CREATE TRIGGER trigControleAjoutClient BEFORE INSERT ON client
FOR EACH ROW
BEGIN
DECLARE errorMessage varChar(255);
DECLARE vCount SMALLINT;
SET errorMessage = concat('Un client de nom ' , NEW.prenom , ' ' , NEW.nom , ' avec un téléphone ' , NEW.telephone , ' existe déja dans la BD. Ajout Annulé');
SET vCount = (SELECT COUNT(codeClient) FROM client WHERE nom = NEW.nom AND prenom = NEW.prenom  AND telephone = NEW.telephone);
IF vCount > 0 THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = errorMessage;
END IF;
END|
DELIMITER ;
SELECT * from client;
INSERT INTO client(codeClient,titre,prenom,nom,adresse,codePostal,ville,telephone,dateNaissance)  VALUES ("AIM009","Mme","Anne","aime","12, rue Claude François",66002,"NANTES","0240683721","1956-03-01");
INSERT INTO client(codeClient,titre,prenom,nom,adresse,codePostal,ville,telephone,dateNaissance)  VALUES ("AIM009","Mme","Ae","aime","12, rue Claude François",66002,"NANTES","0240683721","1956-03-01");
/********************question D3****************/
DROP TRIGGER IF EXISTS trigSupressionCategorie;
DELIMITER |
CREATE TRIGGER trigSupressionCategorie BEFORE DELETE ON categorie
FOR EACH ROW
BEGIN
UPDATE livre set codeCategorie = null WHERE codeCategorie = old.codeCategorie;
END|
DELIMITER ;
SELECT * FROM livre_auteur;
SELECT * FROM categorie;
SELECT * from livre;
DELETE FROM categorie WHERE codeCategorie = 'LI';
/********************question P1****************/
DROP PROCEDURE IF EXISTS supprimerCommande;
DELIMITER |
CREATE PROCEDURE supprimerCommande(IN p_numerocommande int)
BEGIN
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
SELECT ('Une erreur s\'est produite, la suppression est annulée') AS message;
ROLLBACK;
END;
START TRANSACTION;
SET SQL_SAFE_UPDATES = OFF;
SET autocommit = 0;
DELETE FROM detailCommande WHERE numeroCommande = p_numerocommande;
DELETE FROM commande WHERE numeroCommande = p_numerocommande;
SET SQL_SAFE_UPDATES = ON;
COMMIT;
END|
DELIMITER ;

CALL supprimerCommande (2);
CALL supprimerCommande (7321);
SELECT * FROM commande WHERE numeroCommande = 232;
/********************question F1****************/
DROP FUNCTION IF EXISTS nbLivresAuteur;
DELIMITER |
CREATE FUNCTION nbLivresAuteur (p_auteur varchar(40)) RETURNS SMALLINT READS SQL DATA
BEGIN
DECLARE vCodeAuteur SMALLINT;
DECLARE vNombreLivre SMALLINT;
SET vCodeAuteur = (SELECT codeAuteur FROM auteur WHERE auteur LIKE p_auteur);
SET vNombreLivre = (SELECT COUNT(numeroLivre) FROM livre_auteur WHERE codeAuteur = vCodeAuteur);
RETURN vNombreLivre;
END|
DELIMITER ;
SELECT nbLivresAuteur("mauriac");
/********************question F2****************/

SELECT * from auteur;
DROP FUNCTION IF EXISTS totalCommande;
DELIMITER |
CREATE FUNCTION totalCommande( p_numeroCommande int)RETURNS DECIMAL(10,2) READS SQL DATA
BEGIN
DECLARE vPrix DECIMAL(10,2);
SET vPrix = (SELECT SUM(prixUnitaire * quantite) from detailcommande WHERE numeroCommande = p_numeroCommande);
RETURN vPrix;
END|
DELIMITER ;
SELECT totalCommande(155);

/********************question F3****************/

SELECT * from auteur;
DROP FUNCTION IF EXISTS totalFinalCommande;
DELIMITER |
CREATE FUNCTION totalFinalCommande( p_numeroCommande int)RETURNS DECIMAL(10,2) READS SQL DATA
BEGIN
DECLARE vPrix DECIMAL(10,2);
SET vPrix = (SELECT totalCommande(p_numeroCommande));
IF vPrix BETWEEN 30 and 50 THEN
SET vPrix = vPrix - (vPrix * 0.05);
ELSEIF vPrix > 50 THEN
SET vPrix = vPrix - (vPrix * 0.1);
END IF;
SET vPrix = vPrix + (vPrix * 0.05);
RETURN vPrix;
END|
DELIMITER ;
SELECT totalFinalCommande(155);