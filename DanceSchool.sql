Use master
Go
Drop Database if exists DanceSchool
Go
Create Database DanceSchool
Go
Use DanceSchool
GO

CREATE TABLE Students (
    ID INT PRIMARY KEY,
    First_Name NVARCHAR(50),
    Last_Name NVARCHAR(50),
    Age INT
) as Node;
GO

CREATE TABLE Groups (
    ID INT PRIMARY KEY,
    [Name] NVARCHAR(50),
    Style NVARCHAR(50)
) as Node;
GO

CREATE TABLE Teachers (
    ID INT PRIMARY KEY,
    First_Name NVARCHAR(50),
    Last_Name NVARCHAR(50),
    Degree INT
) as Node ;
GO

CREATE TABLE Friends AS EDGE;
GO
ALTER TABLE Friends ADD CONSTRAINT EC_Friends CONNECTION (Students to Students);

CREATE TABLE Teaches AS EDGE;
GO
ALTER TABLE Teaches ADD CONSTRAINT EC_Teaches CONNECTION (Teachers to Groups);

CREATE TABLE Belongs AS EDGE;
GO
ALTER TABLE Belongs ADD CONSTRAINT EC_Belongs CONNECTION (Students To Groups);

-- Заполнение таблицы узлов "Студенты"
INSERT INTO Students (ID, First_Name, Last_Name, Age)
VALUES 
(1, 'John', 'Doe', 20),
(2, 'Alice', 'Smith', 21),
(3, 'Michael', 'Johnson', 19),
(4, 'Emily', 'Brown', 22),
(5, 'James', 'Wilson', 20),
(6, 'Sophia', 'Miller', 21),
(7, 'Daniel', 'Davis', 19),
(8, 'Olivia', 'Martinez', 22),
(9, 'William', 'Garcia', 20),
(10, 'Ava', 'Rodriguez', 21);
GO

INSERT INTO Groups (ID, [Name], Style)
VALUES
    (1, 'Group 1', 'Contemporary'),
    (2, 'Group 2', 'Hip Hop'),
    (3, 'Group 3', 'Ballet'),
    (4, 'Group 4', 'Salsa'),
    (5, 'Group 5', 'Jazz'),
    (6, 'Group 6', 'Tap'),
    (7, 'Group 7', 'Ballroom'),
    (8, 'Group 8', 'Street Dance');

INSERT INTO Teachers (ID, First_Name, Last_Name, Degree)
VALUES
    (1, 'Sarah', 'Johnson', 1),
    (2, 'David', 'Wilson', 2),
    (3, 'Emily', 'Brown', 3),
    (4, 'Michael', 'Smith', 2),
    (5, 'Jessica', 'Davis', 1),
    (6, 'Daniel', 'Miller', 3);


-- Заполнение таблицы рёбер "Friends"
INSERT INTO Friends ($from_id, $to_id)
VALUES 
((Select $node_id From Students Where id = 1), (Select $node_id From Students Where id = 2)),
((Select $node_id From Students Where id = 2), (Select $node_id From Students Where id = 3)),
((Select $node_id From Students Where id = 2), (Select $node_id From Students Where id = 3)),
((Select $node_id From Students Where id = 3), (Select $node_id From Students Where id = 4)),
((Select $node_id From Students Where id = 4), (Select $node_id From Students Where id = 5)),
((Select $node_id From Students Where id = 7), (Select $node_id From Students Where id = 4)),
((Select $node_id From Students Where id = 6), (Select $node_id From Students Where id = 7)),
((Select $node_id From Students Where id = 8), (Select $node_id From Students Where id = 3)),
((Select $node_id From Students Where id = 9), (Select $node_id From Students Where id = 8)),
((Select $node_id From Students Where id = 10), (Select $node_id From Students Where id = 1));
go

-- Заполнение таблицы рёбер "Teaches"
INSERT INTO Teaches ($from_id, $to_id)
VALUES 
((Select $node_id From Teachers Where id = 1), (Select $node_id From Groups Where id = 3)),
((Select $node_id From Teachers Where id = 1), (Select $node_id From Groups Where id = 2)),
((Select $node_id From Teachers Where id = 2), (Select $node_id From Groups Where id = 3)),
((Select $node_id From Teachers Where id = 3), (Select $node_id From Groups Where id = 4)),
((Select $node_id From Teachers Where id = 4), (Select $node_id From Groups Where id = 5)),
((Select $node_id From Teachers Where id = 5), (Select $node_id From Groups Where id = 6)),
((Select $node_id From Teachers Where id = 6), (Select $node_id From Groups Where id = 7)),
((Select $node_id From Teachers Where id = 1), (Select $node_id From Groups Where id = 8)),
((Select $node_id From Teachers Where id = 2), (Select $node_id From Groups Where id = 1)),
((Select $node_id From Teachers Where id = 3),(Select $node_id From Groups Where id = 2))
go


-- Заполнение таблицы рёбер "Belongs"
INSERT INTO Belongs ($from_id, $to_id)
VALUES 
((Select $node_id From Students Where id = 1), (Select $node_id From Groups Where id = 1)),
((Select $node_id From Students Where id = 2), (Select $node_id From Groups Where id = 1)),
((Select $node_id From Students Where id = 3), (Select $node_id From Groups Where id = 2)),
((Select $node_id From Students Where id = 4), (Select $node_id From Groups Where id = 3)),
((Select $node_id From Students Where id = 5), (Select $node_id From Groups Where id = 4)),
((Select $node_id From Students Where id = 6), (Select $node_id From Groups Where id = 5)),
((Select $node_id From Students Where id = 7), (Select $node_id From Groups Where id = 2)),
((Select $node_id From Students Where id = 8), (Select $node_id From Groups Where id = 6)),
((Select $node_id From Students Where id = 9), (Select $node_id From Groups Where id = 4)),
((Select $node_id From Students Where id = 10), (Select $node_id From Groups  Where id = 2))
go


-- Найти всех друзей определенного студента:
SELECT Student1.First_Name AS [Student],
       Student2.First_Name AS [Friend]
FROM Students AS Student1, Friends, Students AS Student2
WHERE Match(Student1-(Friends)->Student2)
	  And Student1.First_Name = N'John'
GO

-- Найти всех студентов группы Group 2:
Select S.First_Name
From Students as S
	 , Belongs as B
	 , Groups as G
Where Match(S-(B)->G)
	  And G.[Name] = N'Group 2'  
Go

-- Найти всех студентов, танцующих в стиле Street Dance:
Select S.First_Name
From Students as S
	 , Belongs as B
	 , Groups as G
Where Match(S-(B)->G)
	  And G.Style = N'Contemporary' 
Go


-- Найти всех группы, которые обучает Sarah:
SELECT G.[Name]
FROM Teachers as T
	 , Teaches
	 , Groups as G
WHERE T.First_Name = N'Sarah'
	  and MATCH(T-(Teaches)->G)
GO

-- Группа и учитель ученика John
select G.[Name], T.First_name,  T.Last_name
from Students as S
	 , Belongs as B
	 , Groups as G
	 , Teachers as T
	 , Teaches
where S.First_Name = 'John'
and MATCH(T-(Teaches)->G)
and MATCH(S-(B)->G)

-- Поиск кратчайшего пути дружбы между двумя студентами (используя "+"):

SELECT Student1.First_Name
, STRING_AGG(Student2.First_Name, '->') WITHIN GROUP (GRAPH PATH) AS
Friends
FROM Students AS Student1
, Friends FOR PATH AS fo
, Students FOR PATH AS Student2
WHERE MATCH(SHORTEST_PATH(Student1(-(fo)->Student2)+))
AND Student1.First_Name = N'John';

--Поиск кратчайшего пути между студентами, где количество ребер не превышает 2 (используя "{1,n}"): 

SELECT Student1.First_Name
, STRING_AGG(Student2.First_Name, '->') WITHIN GROUP (GRAPH PATH) AS
Friends
FROM Students AS Student1
, Friends FOR PATH AS fo
, Students FOR PATH AS Student2
WHERE MATCH(SHORTEST_PATH(Student1(-(fo)->Student2){1,2}))
AND Student1.First_Name = N'John';
