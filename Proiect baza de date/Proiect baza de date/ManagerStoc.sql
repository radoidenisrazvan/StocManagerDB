create database ManagerStoc_BD
go

use ManagerStoc_BD
go

CREATE TABLE CategorieProdus (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Denumire NVARCHAR(255) NOT NULL
);
-- Redenumire in categorieProdus
exec sp_rename 'CategorieProdus', 'categorieProdus';
-- Redenumire la forma ei normala.
exec sp_rename 'categorieProdus', 'CategorieProdus';


CREATE TABLE Produs (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Denumire NVARCHAR(255) NOT NULL,
    CategorieId INT,
    Cantitate INT NOT NULL,
    Pret DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (CategorieId) REFERENCES CategorieProdus(Id)
);


CREATE TABLE Client (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Nume NVARCHAR(255) NOT NULL,
    Adresa NVARCHAR(255),
    Telefon NVARCHAR(15)
);

CREATE TABLE CosDeCumparaturi (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Id_Client INT,
    FOREIGN KEY (Id_Client) REFERENCES Client(Id)
);


CREATE TABLE PlaseazaComanda (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Id_CosDeCumparaturi INT,
    Id_Produs INT,
    Cantitate INT,
    FOREIGN KEY (Id_CosDeCumparaturi) REFERENCES CosDeCumparaturi(Id),
    FOREIGN KEY (Id_Produs) REFERENCES Produs(Id)
);



-- Adaugam atributul "Pret" fiindca am uitat de el :(

ALTER TABLE PlaseazaComanda
ADD Pret DECIMAL(10,2);


-- Actualizam atributul 'Pret' în 'PlaseazaComanda' cu suma totală pentru fiecare comandă
UPDATE PC
SET 
    PC.Pret = P.Pret * PC.Cantitate
FROM 
    PlaseazaComanda PC
JOIN 
    Produs P ON PC.Id_Produs = P.Id;


CREATE TABLE VizualizareComenzi (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Id_Comanda INT,
    Id_Produs INT,
    Cantitate INT,
    FOREIGN KEY (Id_Comanda) REFERENCES PlaseazaComanda(Id),
    FOREIGN KEY (Id_Produs) REFERENCES Produs(Id)
);

--Trunchiere 
TRUNCATE TABLE VizualizareComenzi;

-- Adaugam atributul "Pret" fiindca am uitat de el :(
ALTER TABLE VizualizareComenzi
ADD Pret DECIMAL(10,2);

-- Actualizam atributul 'Pret' în 'VizualizareComenzi' cu suma totală pentru fiecare comandă
UPDATE VC
SET 
    VC.Pret = PC.Cantitate * P.Pret
FROM 
    VizualizareComenzi VC
JOIN 
    PlaseazaComanda PC ON VC.Id_Comanda = PC.Id
JOIN 
    Produs P ON VC.Id_Produs = P.Id;



--Adaugam informatii in fiecare tabela.

INSERT INTO CategorieProdus (Denumire) VALUES ('Periferice'), ('Componente'), ('Electronice');
SELECT * from CategorieProdus;

INSERT INTO Produs (Denumire, CategorieId, Cantitate, Pret) VALUES
    ('Mouse GLORIUS model O', 1, 50, 249.99);
    
INSERT INTO Produs (Denumire, CategorieId, Cantitate, Pret) VALUES
    ('Tastatura mecanica Logitech ABC', 1, 30, 99.99);

INSERT INTO Produs (Denumire, CategorieId, Cantitate, Pret) VALUES
    ('Webcam Logitech', 1, 15, 79.99);


INSERT INTO Produs (Denumire, CategorieId, Cantitate, Pret) VALUES
    ('Placa video NVIDIA GeForce RTX 3080', 2, 10, 699.99);
    
INSERT INTO Produs (Denumire, CategorieId, Cantitate, Pret) VALUES
    ('Procesor Intel i7 14700kf', 2, 20, 499.99);

INSERT INTO Produs (Denumire, CategorieId, Cantitate, Pret) VALUES
    ('RAM Corsair 16GB DDR5', 2, 30, 149.99);

INSERT INTO Produs (Denumire, CategorieId, Cantitate, Pret) VALUES
    ('Laptop LENOVO', 3, 25, 129.99);

INSERT INTO Produs (Denumire, CategorieId, Cantitate, Pret) VALUES
    ('Monitor Samsung 240hz', 3, 12, 179.99);

SELECT * FROM Produs;

UPDATE Produs set Pret = 899.99 where Denumire = 'Monitor Samsung 240hz';
UPDATE Produs set Pret = 5699.99 where Denumire = 'Laptop LENOVO';
UPDATE Produs set Pret = 1699.99 where Denumire = 'Procesor Intel i7 14700kf';
UPDATE Produs set Pret = 349.99 where Id = 6;

INSERT INTO Client (Nume, Adresa, Telefon) VALUES 
    ('David Popovici', 'Str. Principală, Nr. 123', '0712345678'),
    ('Rares Rahman', 'Aleea Florilor, Nr. 45', '0723456789'),
    ('Alex Popescu', 'Bulevardul Victoriei, Nr. 67', '0734567890');

select * from Client;

INSERT INTO CosDeCumparaturi (Id_Client) VALUES (1), (2); 
SELECT * FROM CosDeCumparaturi;

INSERT INTO CosDeCumparaturi (Id_Client) VALUES (3);

INSERT INTO PlaseazaComanda (Id_CosDeCumparaturi, Id_Produs, Cantitate) VALUES 
    (1, 1, 2), -- David Popovici comandă 2 bucăți de Mouse GLORIUS model O
    (3, 3, 1), -- Alex Popescu comandă 1 bucată de Webcam Logitech
    (2, 4, 1); -- Rares Rahman comandă 1 bucată de Placa video NVIDIA GeForce RTX 3080

SELECT * FROM PlaseazaComanda;


INSERT INTO VizualizareComenzi (Id_Comanda, Id_Produs, Cantitate) VALUES 
    (1, 1, 2), -- Comanda lui David Popovici, produsul Mouse GLORIUS model O, 2 bucăți
    (3, 3, 1), -- Comanda lui Alex Popescu, produsul Webcam Logitech, 1 bucată
    (2, 4, 1); -- Comanda lui Rares Rahman, produsul Placa video NVIDIA GeForce RTX 3080, 1 bucată

SELECT * FROM VizualizareComenzi;


-- REALIZAM INTEROGARI INTRE TABELE:


--Suma totală a cantităților de produse comandate de fiecare client.
SELECT C.Nume AS NumeClient, SUM(VC.Cantitate) AS CantitateTotala
FROM Client C
JOIN CosDeCumparaturi CC ON C.Id = CC.Id_Client
JOIN PlaseazaComanda PC ON CC.Id = PC.Id_CosDeCumparaturi
JOIN VizualizareComenzi VC ON PC.Id = VC.Id_Comanda
GROUP BY C.Nume;

--Gasește clienții care au comenzi pentru produsele cu prețul peste o anumită valoare.
SELECT * FROM VizualizareComenzi;
SELECT C.Nume AS NumeClient
FROM Client C
WHERE EXISTS (SELECT 1 FROM CosDeCumparaturi CC
        JOIN PlaseazaComanda PC ON CC.Id = PC.Id_CosDeCumparaturi
        JOIN VizualizareComenzi VC ON PC.Id = VC.Id_Comanda
        JOIN Produs P ON VC.Id_Produs = P.Id
		WHERE P.Pret > 200
            AND CC.Id_Client = C.Id
    );


--Găsește clienții care au plasat cel puțin o comandă și numărul total de comenzi plasate de fiecare client, inclusiv prețul.

SELECT C.Nume AS NumeClient, COUNT(DISTINCT PC.Id) AS NumarComenzi, SUM(VC.Pret) AS ValoareTotalaComenzi
FROM Client C
LEFT JOIN CosDeCumparaturi CC ON C.Id = CC.Id_Client
LEFT JOIN PlaseazaComanda PC ON CC.Id = PC.Id_CosDeCumparaturi
LEFT JOIN VizualizareComenzi VC ON PC.Id = VC.Id_Comanda
GROUP BY C.Nume;



--Găsește produsele cu cea mai mare cantitate disponibilă:
SELECT * FROM Produs WHERE Cantitate = (SELECT MAX(Cantitate) FROM Produs);

--Găsește clienții care au plasat comenzi pentru produsele din categoria "Electronice":
select * from VizualizareComenzi;
SELECT DISTINCT C.Nume FROM Client C
JOIN CosDeCumparaturi CC ON C.Id = CC.Id_Client
JOIN PlaseazaComanda PC ON CC.Id = PC.Id_CosDeCumparaturi
JOIN Produs P ON PC.Id_Produs = P.Id
JOIN CategorieProdus CP ON P.CategorieId = CP.Id
WHERE CP.Denumire = 'Electronice';

--Găsește produsele care nu au fost comandate:
--toate produsele --
SELECT * FROM Produs
-- dupa rulare
SELECT * FROM Produs
WHERE Id NOT IN (SELECT DISTINCT Id_Produs FROM VizualizareComenzi);

-- Găsește clienții care au comandat cel puțin o comandă și sunt de pe strada Aleea Teilor.
SELECT Nume AS NumeClient
FROM Client
WHERE Id IN (
    SELECT DISTINCT C.Id
    FROM Client C
    JOIN CosDeCumparaturi CC ON C.Id = CC.Id_Client
    JOIN PlaseazaComanda PC ON CC.Id = PC.Id_CosDeCumparaturi
    WHERE C.Adresa LIKE 'Aleea Teilor'
);
--toti clientii
SELECT * FROM Client;

--actualizeaza pretul in vizualizare comenzi, trebuie rulat o data.

CREATE TRIGGER ActualizeazaPretVizualizareComenzi
ON VizualizareComenzi
AFTER INSERT, UPDATE
AS
BEGIN
    UPDATE VC
    SET 
        VC.Pret = P.Pret * VC.Cantitate
    FROM 
        VizualizareComenzi VC
    JOIN 
        Produs P ON VC.Id_Produs = P.Id
    JOIN 
        INSERTED I ON VC.Id_Comanda = I.Id_Comanda
    WHERE
        VC.Id IN (SELECT Id FROM INSERTED);
END;

--actualizeaza pretul in plaseaza comanda, trebuie rulat o data.
CREATE TRIGGER ActualizeazaPretPlaseazaComanda
ON PlaseazaComanda
AFTER INSERT, UPDATE
AS
BEGIN
    UPDATE PC
    SET 
        PC.Pret = P.Pret * PC.Cantitate
    FROM 
        PlaseazaComanda PC
    JOIN 
        Produs P ON PC.Id_Produs = P.Id
    JOIN 
        INSERTED I ON PC.Id = I.Id
    WHERE
        PC.Id IN (SELECT Id FROM INSERTED);
END;

select * from produs;

insert into Client(Nume, Adresa, Telefon) VALUES ('Razvan', 'Aleea Teilor', '0773345356');

INSERT INTO CosDeCumparaturi (Id_Client) VALUES (5);
Select * from CosDeCumparaturi;

select * from Client;

INSERT INTO PlaseazaComanda (Id_CosDeCumparaturi, Id_Produs, Cantitate) VALUES (8, 8, 2);  


select * from PlaseazaComanda;

-- trigger ce completeaza automat in vizualizare comenzi cu informatii despre comanda atunci cand un client plaseaza comanda.
CREATE TRIGGER TriggerPlaseazaComanda
ON PlaseazaComanda
AFTER INSERT
AS
BEGIN
    INSERT INTO VizualizareComenzi (Id_Comanda, Id_Produs, Cantitate)
    SELECT Id, Id_Produs, Cantitate
    FROM inserted;
END;

INSERT INTO PlaseazaComanda (Id_CosDeCumparaturi, Id_Produs, Cantitate) VALUES (8, 8, 2);  
select * from VizualizareComenzi;



--Verificarea tabelelor
SELECT * FROM INFORMATION_SCHEMA.TABLES;

 -- despre tabele
exec sp_help 'CategorieProdus';

exec sp_help 'Produs';

exec sp_help 'Client';

exec sp_help 'CosDeCumparaturi';

exec sp_help 'PlaseazaComanda';

exec sp_help 'VizualizareComenzi';

select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS;

--VEDERI , SECVENTE, SINONIME , INDECSI

-- VEDERI pentru a afisa informatii despre clienti, comenzile lor si produsele comandate respectiv pretul produselor.
CREATE VIEW VizualizareClientiComenzi AS
SELECT
    C.Id AS IdClient,
    C.Nume AS NumeClient,
    C.Adresa AS AdresaClient,
    P.Denumire AS DenumireProdus,
    PC.Cantitate AS CantitateComandata,
    P.Pret AS PretUnitar
FROM
    Client C
JOIN
    CosDeCumparaturi CC ON C.Id = CC.Id_Client
JOIN
    PlaseazaComanda PC ON CC.Id = PC.Id_CosDeCumparaturi
JOIN
    Produs P ON PC.Id_Produs = P.Id;

select * from VizualizareClientiComenzi;

-- modificam vederea pentru a afisa doar comenzile plasate de catre clientii care sunt domiciliati la adresa "Aleea Teilor"
-- Modificarea vederii pentru a afișa doar comenzile plasate de pe strada "Aleea Teilor".
ALTER VIEW VizualizareClientiComenzi AS
SELECT
    C.Id AS IdClient,
    C.Nume AS NumeClient,
    C.Adresa AS AdresaClient,
    P.Denumire AS DenumireProdus,
    PC.Cantitate AS CantitateComandata,
    P.Pret AS PretUnitar
FROM
    Client C
JOIN
    CosDeCumparaturi CC ON C.Id = CC.Id_Client
JOIN
    PlaseazaComanda PC ON CC.Id = PC.Id_CosDeCumparaturi
JOIN
    Produs P ON PC.Id_Produs = P.Id
WHERE
    C.Adresa LIKE '%Aleea Teilor%';

-- Stergerea vederii
DROP VIEW VizualizareClientiComenzi;

--SECVENTA
--creearea secventelor produs,client
CREATE SEQUENCE Seq_Produs_Id
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 1000000
    CYCLE;
CREATE SEQUENCE Seq_Client_Id
    START WITH 50
    INCREMENT BY 10
    MINVALUE 10
    MAXVALUE 1000000
    CYCLE;

--afisarea secventelor
SELECT name, type,type_desc, start_value, increment, current_value, minimum_value, maximum_value, is_cycling from sys.sequences;
SELECT NEXT VALUE FOR Seq_Produs_Id;
DROP sequence Seq_Produs_Id;

--index
--creare index:
CREATE INDEX IndiceCantitateProdus ON Produs(Cantitate);
-- verificare index:
IF EXISTS (
    SELECT *
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('Produs') 
        AND name = 'IndiceCantitateProdus'
)
    PRINT 'Indicele pentru Cantitate în Tabela Produs exista.';
ELSE
    PRINT 'Indicele pentru Cantitate în Tabela Produs nu exista.';
--stergere index:
DROP INDEX Produs.IndiceCantitateProdus;

--Sinonime
--creare sinonim:
CREATE SYNONYM SinonimProdus FOR Produs;

--Confirmare sinonim:
IF OBJECT_ID('SinonimProdus', 'SN') IS NOT NULL
    PRINT 'Sinonimul pentru Tabelul Produs exista.';
ELSE
    PRINT 'Sinonimul pentru Tabelul Produs nu exista.';
--Stergere sinonim:
DROP SYNONYM SinonimProdus;


--interogari pentru views:
--vedere pentru a afisa numarul minim de produse disponibile intr-o categorie
CREATE VIEW ViewCategoriiPutine AS
SELECT CP.Denumire AS NumeCategorie, MIN(P.Cantitate) AS MinimProduseDisponibile
FROM CategorieProdus CP
JOIN Produs P ON CP.Id = P.CategorieId
GROUP BY CP.Denumire;
select * from ViewCategoriiPutine;
--vedere pentru afisarea tuturor produselor disponibile
CREATE VIEW ViewProduseDisponibile AS
SELECT P.Denumire, CP.Denumire AS Categorie, P.Cantitate, P.Pret
FROM Produs P
JOIN CategorieProdus CP ON P.CategorieId = CP.Id
WHERE P.Cantitate > 0;
select * from ViewProduseDisponibile;
--vedere pentru afisarea comenzilor comandate de clientii cu numele care incepe cu 'A'
CREATE VIEW ViewComenziClientiA AS
SELECT C.Nume AS NumeClient, PC.Id AS IdComanda, P.Denumire AS NumeProdus, PC.Cantitate, VC.Pret
FROM Client C
JOIN CosDeCumparaturi CC ON C.Id = CC.Id_Client
JOIN PlaseazaComanda PC ON CC.Id = PC.Id_CosDeCumparaturi
JOIN VizualizareComenzi VC ON PC.Id = VC.Id_Comanda
JOIN Produs P ON VC.Id_Produs = P.Id
WHERE C.Nume LIKE 'A%';
select * from ViewComenziClientiA;


