CREATE DATABASE Mile2
USE Mile2

GO

CREATE PROCEDURE createAllTables

AS

CREATE TABLE SystemUser(
username VARCHAR(20) CONSTRAINT PK_System_User PRIMARY KEY,
password VARCHAR(20)
);

CREATE TABLE Fan(
national_id VARCHAR(20) CONSTRAINT PK_Fan PRIMARY KEY,
name VARCHAR(20),
birth_date DATE,
address VARCHAR(20) ,
phone_no INT,
status BIT DEFAULT 1,
username VARCHAR(20),
CONSTRAINT FK_FanSysUserName FOREIGN KEY(username) REFERENCES SystemUser
ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Stadium(
ID INT IDENTITY CONSTRAINT PK_Stadium PRIMARY KEY ,
name VARCHAR(20) ,
location VARCHAR(20) ,
capacity INT,
status BIT DEFAULT 1
);

CREATE TABLE Stadium_Manager(
ID INT IDENTITY CONSTRAINT PK_Stadium_Manager PRIMARY KEY ,
name VARCHAR(20),
stadium_id INT,
username VARCHAR(20),
CONSTRAINT FK_StadMangerSysUserName FOREIGN KEY(username) REFERENCES SystemUser
ON DELETE CASCADE ON UPDATE CASCADE,
CONSTRAINT FK_StadMangerStadium FOREIGN KEY(stadium_id) REFERENCES Stadium
ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Club(
club_ID INT IDENTITY CONSTRAINT PK_Club PRIMARY KEY ,
name VARCHAR(20),
location VARCHAR(20)
);

CREATE TABLE Club_Representative(
ID INT IDENTITY CONSTRAINT PK_Club_Representative PRIMARY KEY ,
name VARCHAR(20),
club_id INT,
username VARCHAR(20),
CONSTRAINT FK_ClubReprestativeSysUserName FOREIGN KEY(username) REFERENCES SystemUser
ON DELETE CASCADE ON UPDATE CASCADE,
CONSTRAINT FK_ClubReprestativeClub FOREIGN KEY(club_id) REFERENCES Club
ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Sports_Association_Manager(
ID INT IDENTITY CONSTRAINT PK_Sports_Association_Manager PRIMARY KEY ,
name VARCHAR(20),
username VARCHAR(20),
CONSTRAINT FK_SportsAssMangerSysUserName FOREIGN KEY(username) REFERENCES SystemUser
ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE System_Admin(
ID INT IDENTITY CONSTRAINT PK_System_Admin PRIMARY KEY ,
name VARCHAR(20),
username VARCHAR(20),
CONSTRAINT FK_SysAdminSysUserName FOREIGN KEY(username) REFERENCES SystemUser
ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Matches(
match_ID INT IDENTITY CONSTRAINT PK_Matches PRIMARY KEY ,
start_time DATETIME,
end_time DATETIME,
host_club_ID INT,
guest_club_ID INT,
stadium_ID INT,
CONSTRAINT FK_MatchHostClubID FOREIGN KEY(host_club_ID) REFERENCES Club
ON DELETE CASCADE ON UPDATE CASCADE,
CONSTRAINT FK_MatchGuestClubID FOREIGN KEY(guest_club_ID) REFERENCES Club,
CONSTRAINT FK_MatchStadiumID FOREIGN KEY(stadium_ID) REFERENCES Stadium
ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Ticket(
ID INT IDENTITY CONSTRAINT PK_Ticket PRIMARY KEY ,
status BIT DEFAULT 1,
match_ID INT,
CONSTRAINT FK_TicketMatchID FOREIGN KEY(match_ID) REFERENCES Matches
ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Ticket_Buying_Transactions(
fan_national_ID VARCHAR(20),
ticket_ID INT,
CONSTRAINT FK_TicBuyTransFanID FOREIGN KEY(fan_national_ID) REFERENCES Fan
ON DELETE CASCADE ON UPDATE CASCADE,
CONSTRAINT FK_TicBuyTransTickID FOREIGN KEY(ticket_ID) REFERENCES Ticket
ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Host_Request(
ID INT IDENTITY CONSTRAINT PK_Host_Request PRIMARY KEY ,
representative_ID INT,
manager_ID INT,
match_ID INT,
status VARCHAR(20) DEFAULT 'unhandled',
CONSTRAINT FK_HostReqClubRepID FOREIGN KEY(representative_ID) REFERENCES Club_Representative
ON DELETE CASCADE ON UPDATE CASCADE,
CONSTRAINT FK_HostReqStadMangerID FOREIGN KEY(manager_ID) REFERENCES Stadium_Manager,
CONSTRAINT FK_HostReqMatchID FOREIGN KEY(match_ID) REFERENCES Matches,
CONSTRAINT Cons_HostReqStatus CHECK(status IN('unhandled','accepted','rejected'))
);

GO



go

CREATE PROCEDURE dropAllTables

AS

DROP TABLE Ticket_Buying_Transactions
DROP TABLE Host_Request
DROP TABLE Ticket
DROP TABLE Matches
DROP TABLE System_Admin
DROP TABLE Sports_Association_Manager
DROP TABLE Fan
DROP TABLE Club_Representative
DROP TABLE Club
DROP TABLE Stadium_Manager
DROP TABLE Stadium
DROP TABLE SystemUser

GO


CREATE PROC dropAllProceduresFunctionsViews AS

DROP PROC createAllTables
DROP PROC dropAllTables
DROP PROC clearAllTables
DROP PROC addAssociationManager
DROP PROC addNewMatch
DROP PROC deleteMatch
DROP PROC deleteMatchesOnStadium
DROP PROC addClub
DROP PROC addTicket
DROP PROC deleteClub
DROP PROC addStadium
DROP PROC deleteStadium
DROP PROC blockFan
DROP PROC unblockFan
DROP PROC addRepresentative
DROP PROC addHostRequest
DROP PROC addStadiumManager
DROP PROC acceptRequest
DROP PROC rejectRequest
DROP PROC addFan
DROP PROC purchaseTicket
DROP PROC updateMatchHost


DROP FUNCTION viewAvailableStadiumsOn
DROP FUNCTION allUnassignedMatches
DROP FUNCTION allPendingRequests
DROP FUNCTION upcomingMatchesOfClub
DROP FUNCTION availableMatchesToAttend
DROP FUNCTION clubsNeverPlayed
DROP FUNCTION matchWithHighestAttendance
DROP FUNCTION matchesRankedByAttendance
DROP FUNCTION requestsFromClub


DROP VIEW allAssocManagers
DROP VIEW allClubRepresentatives
DROP VIEW allStadiumManagers
DROP VIEW allFans
DROP VIEW allMatches
DROP VIEW allTickets
DROP VIEW allCLubs
DROP VIEW allStadiums
DROP VIEW allRequests
DROP VIEW clubsWithNoMatches
DROP VIEW matchesPerTeam
DROP VIEW clubsNeverMatched


GO


go
CREATE PROCEDURE clearAllTables

AS

EXEC dropAllTables
exec createAllTables

GO


go
CREATE VIEW allAssocManagers

AS

SELECT SAM.username AS username, SU.password AS password, SAM.name AS name
FROM Sports_Association_Manager SAM INNER JOIN SystemUser SU ON SAM.username=SU.username

GO

CREATE VIEW allClubRepresentatives AS
SELECT S1.username,S1.password,C1.name,	C2.name AS 'Represented Club'
FROM SystemUser S1 INNER JOIN Club_Representative C1 ON S1.username=C1.username
INNER JOIN Club C2 ON C1.club_id=C2.club_ID 

GO 

CREATE VIEW allStadiumManagers

AS

SELECT SM.username AS username, SU.password AS password, SM.name AS name, S.name AS stadium_name
FROM Stadium_Manager SM INNER JOIN SystemUser SU ON SM.username=SU.username
     INNER JOIN Stadium S ON SM.stadium_id=S.ID

GO


CREATE VIEW allFans AS
SELECT S1.username,S1.password,F.name, F.national_id,F.birth_date,F.status
FROM SystemUser S1 INNER JOIN FAN F ON S1.username=F.username

GO

CREATE VIEW allMatches 

AS

SELECT C2.name AS host_club, C1.name AS guest_club, M.start_time AS start_time
FROM Matches M INNER JOIN Club C1 ON M.guest_club_ID=C1.Club_ID
     INNER JOIN Club C2 ON M.host_club_ID=C2.Club_ID

GO

CREATE VIEW allTickets AS
SELECT C2.name AS 'Host Club',C1.name AS 'Guest Club',S.name AS 'Stadium',M.start_time
FROM Club C1 INNER JOIN Matches M ON C1.club_ID= M.guest_club_ID
INNER JOIN Club C2 ON C2.club_ID=M.host_club_ID
INNER JOIN Stadium S ON S.ID=M.stadium_ID

GO

CREATE VIEW allCLubs

AS

SELECT C.name AS name, C.location AS location
FROM Club C

GO

CREATE VIEW allStadiums AS
SELECT S.name,S.location,S.capacity,S.status
FROM Stadium S

GO

CREATE VIEW allRequests

AS

SELECT C.username AS club_representative, S.username AS stadium_manager, R.status AS status
FROM Host_Request R INNER JOIN Club_Representative C ON R.representative_ID=C.ID
     INNER JOIN Stadium_Manager S ON R.manager_ID=S.ID

GO

CREATE PROCEDURE addAssociationManager
@name varchar(20),
@username varchar(20),
@password varchar(20)

AS

IF (@username IN (SELECT S.username
FROM SystemUser S))
BEGIN
PRINT 'USERNAME ALREADY EXISTS'
END
ELSE
BEGIN
INSERT INTO SystemUser VALUES(@username,@password)

INSERT INTO Sports_Association_Manager VALUES(@name,@username)
END
GO



CREATE PROC addNewMatch

@host VARCHAR(20),
@guest VARCHAR(20),
@start DATETIME,
@end DATETIME

AS

DECLARE @host_id INT
DECLARE @guest_id INT

SELECT @guest_id=C.Club_ID
FROM Club C
WHERE C.name=@guest

SELECT @host_id=C.Club_ID
FROM Club C
WHERE C.name=@host

INSERT INTO Matches (start_time, end_time, host_club_ID, guest_club_ID) VALUES(@start,@end,@host_id,@guest_id)

GO




CREATE VIEW clubsWithNoMatches AS
SELECT C.name
FROM Club C
WHERE NOT EXISTS (
SELECT *
FROM Matches M1
WHERE C.club_ID=M1.guest_club_ID) 
AND 
NOT EXISTS (
SELECT *
FROM Matches M2
WHERE C.club_ID=M2.host_club_ID) 

GO




CREATE PROC deleteMatch

@host VARCHAR(20),
@guest VARCHAR(20)

AS

DECLARE @host_id INT
DECLARE @guest_id INT

SELECT @guest_id=C.Club_ID
FROM Club C
WHERE C.name=@guest

SELECT @host_id=C.Club_ID
FROM Club C
WHERE C.name=@host

DELETE FROM Host_Request 
WHERE match_ID IN (SELECT M.match_ID
                   FROM Matches M 
                   WHERE M.guest_club_ID=@guest_id AND M.host_club_ID=@host_id)

DELETE FROM Matches 
WHERE guest_club_ID=@guest_id AND host_club_ID=@host_id

GO




CREATE PROC deleteMatchesOnStadium
@stadium VARCHAR(20)
AS

DELETE FROM Host_Request
WHERE match_ID IN 
(SELECT M1.match_ID
FROM Matches M1 INNER JOIN
(SELECT S.ID
FROM Stadium S
WHERE S.name=@stadium) AS T ON M1.stadium_ID= T.ID
WHERE M1.start_time>CURRENT_TIMESTAMP)

DELETE FROM Matches 
WHERE match_ID IN 
(SELECT M2.match_ID
FROM Matches M2 INNER JOIN
(SELECT S2.ID
FROM Stadium S2
WHERE S2.name=@stadium) AS T2 ON M2.stadium_ID= T2.ID
WHERE M2.start_time>CURRENT_TIMESTAMP)

GO


CREATE PROC addClub

@name VARCHAR(20),
@location VARCHAR(20)

AS

INSERT INTO Club VALUES(@name,@location)

GO


CREATE PROC addTicket
@hostclub VARCHAR(20),
@guestclub VARCHAR(20),
@starttime DATETIME
AS



declare @HID INT 
SELECT @HID=C.club_ID
FROM Club C
WHERE C.name=@hostclub


declare @GID INT 
SELECT @GID=C1.club_ID
FROM Club C1
WHERE C1.name=@guestclub

DECLARE @MID INT

SELECT @MID=M.match_ID 
FROM Matches M
WHERE M.guest_club_ID=@GID AND M.host_club_ID=@HID AND M.start_time=@starttime

INSERT INTO Ticket VALUES(DEFAULT,@MID)

GO




CREATE PROC deleteClub

@name VARCHAR(20)

AS

DECLARE @id INT

SELECT @id=C.Club_ID
FROM Club C
WHERE C.name=@name

DELETE FROM Host_Request 
WHERE match_ID IN (SELECT M.match_ID
                   FROM Matches M 
                   WHERE M.guest_club_ID=@id OR M.host_club_ID=@id)

DELETE FROM Matches
WHERE guest_club_ID=@id OR host_club_ID=@id

DELETE FROM Club
WHERE name=@name

GO




CREATE PROC addStadium
@name VARCHAR(20),
@location VARCHAR(20),
@capacity INT

AS 
INSERT INTO Stadium VALUES (@name,@location,@capacity,DEFAULT)

GO



CREATE PROC deleteStadium

@name VARCHAR(20)

AS

DECLARE @stadium_id INT
DECLARE @manager_id INT

SELECT @stadium_id=S.ID
FROM Stadium S
WHERE S.name=@name

SELECT @manager_id=SM.ID
FROM Stadium_Manager SM
WHERE SM.stadium_id=@stadium_id

DELETE FROM Host_Request
WHERE manager_ID=@manager_id

DELETE FROM Stadium
WHERE name=@name

GO




CREATE PROC blockFan
@national_id VARCHAR(20)

AS

UPDATE Fan
SET status=0
WHERE national_id=@national_id

GO



CREATE PROC unblockFan

@id VARCHAR(20)

AS

Update Fan
Set status = '1'
Where national_id=@id

GO




CREATE PROC addRepresentative
@name VARCHAR(20) ,
@clubname VARCHAR(20), 
@username VARCHAR(20),
@password VARCHAR(20) 

AS

IF (@username IN (SELECT S.username
FROM SystemUser S))
BEGIN
PRINT 'USERNAME ALREADY EXISTS'
END
ELSE
BEGIN
INSERT INTO SystemUser VALUES (@username,@password)

DECLARE @CID INT
SELECT @CID=C.club_ID
FROM Club C
WHERE C.name=@clubname

INSERT INTO Club_Representative VALUES (@name,@CID,@username)
END
GO

CREATE FUNCTION viewAvailableStadiumsOn
(@when DATETIME)
Returns TABLE
AS
Return (SELECT S.name AS name, S.location AS location, S.capacity AS capacity
        FROM Stadium S
        WHERE NOT EXISTS(SELECT *
                         FROM Matches M
                         WHERE M.stadium_ID=S.ID AND M.start_time<=@when AND M.end_time>@when))

GO

CREATE PROC addHostRequest
@clubname VARCHAR(20) ,
@stadiumname VARCHAR(20) ,
@starttime DATETIME

AS

DECLARE @RID INT
SELECT @RID=CR.ID
FROM Club C INNER JOIN Club_Representative CR ON C.club_ID=CR.club_id
WHERE C.name=@clubname


DECLARE @MID INT
SELECT @MID=SM.ID
FROM Stadium S INNER JOIN Stadium_Manager SM ON S.ID=SM.stadium_id
WHERE S.name=@stadiumname

DECLARE @MaID INT 
SELECT @MaID=M.match_ID
FROM Matches M 
WHERE M.start_time=@starttime


INSERT INTO Host_Request VALUES (@RID,@MID,@MaID,DEFAULT)

GO



CREATE FUNCTION allUnassignedMatches
(@name VARCHAR(20))
RETURNS TABLE
AS
RETURN (SELECT Guest.name AS guest_club, M.start_time AS start_time
        FROM Matches M INNER JOIN Club Host ON M.host_club_ID=Host.Club_ID
             INNER JOIN Club Guest ON M.guest_club_ID=Guest.Club_ID
        WHERE Host.name=@name AND (M.stadium_ID IS NULL))

GO



CREATE PROC addStadiumManager
@name varchar(20) ,
@stadiumname varchar(20), 
@username varchar(20),
@password varchar(20)

AS 
IF (@username IN (SELECT S.username
FROM SystemUser S))
BEGIN
PRINT 'USERNAME ALREADY EXISTS'
END
ELSE
BEGIN

INSERT INTO SystemUser VALUES(@username,@password)

DECLARE @SID INT
SELECT @SID=S.ID
FROM Stadium S 
WHERE S.name=@stadiumname

INSERT INTO Stadium_Manager VALUES (@name,@SID,@username)
END
GO



CREATE FUNCTION allPendingRequests
(@manager_username VARCHAR(20))
RETURNS TABLE
AS
RETURN (SELECT CR.name AS club_representative, C.name AS guest_club, M.start_time AS start_time
        FROM Stadium_Manager SM INNER JOIN Host_Request R ON SM.ID=R.manager_ID
             INNER JOIN Club_Representative CR ON R.representative_ID=CR.ID
             INNER JOIN Matches M ON R.match_ID=M.match_ID
             INNER JOIN Club C ON M.guest_club_ID=C.Club_ID
        WHERE SM.username=@manager_username AND R.status='unhandled')

GO



CREATE PROC acceptRequest
@StadiumManagerUsername varchar(20) ,
@hostingclub varchar(20) ,
@guestclub varchar(20) , 
@starttime DATETIME

AS 

DECLARE @MangerID INT
SELECT @MangerID=SM.ID
FROM Stadium_Manager SM
WHERE SM.username=@StadiumManagerUsername


declare @HID INT 
SELECT @HID=C.club_ID
FROM Club C
WHERE C.name=@hostingclub


declare @GID INT 
SELECT @GID=C1.club_ID
FROM Club C1
WHERE C1.name=@guestclub



DECLARE @MatchID INT
SELECT @MatchID= M.match_ID
FROM Matches M
WHERE M.guest_club_ID=@GID AND M.host_club_ID=@HID AND M.start_time=@starttime

UPDATE Host_Request
SET status='accepted'
WHERE match_ID=@MatchID AND manager_ID=@MangerID

DECLARE @SID INT 
DECLARE @SCPACITY INT
SELECT @SID=S.ID, @SCPACITY=S.capacity
FROM Stadium S INNER JOIN Stadium_Manager SM1 ON S.ID=SM1.stadium_id
WHERE SM1.ID=@MangerID

UPDATE Matches
SET stadium_ID = @SID
WHERE match_ID=@MatchID


DECLARE @i INT=0
WHILE @i<@SCPACITY
BEGIN
EXEC addTicket @hostingclub ,@guestclub ,@starttime

END

Go

CREATE PROCEDURE rejectRequest
@manager_username VARCHAR(20),
@host VARCHAR(20),
@guest VARCHAR(20),
@start_time DATETIME
AS

DECLARE @manager_id INT
DECLARE @representative_id INT
DECLARE @match_id INT
DECLARE @host_id INT
DECLARE @guest_id INT

SELECT @manager_id=SM.ID
FROM Stadium_Manager SM
WHERE SM.username=@manager_username

SELECT @representative_id=CR.ID
FROM Club C INNER JOIN Club_Representative CR ON C.Club_ID=CR.club_id
WHERE C.name=@host

SELECT @guest_id=C.Club_ID
FROM Club C
WHERE C.name=@guest

SELECT @host_id=C.Club_ID
FROM Club C
WHERE C.name=@host

SELECT @match_id=M.match_ID
FROM Matches M
WHERE M.start_time=@start_time AND M.host_club_ID=@host_id AND M.guest_club_ID=@guest_id

Update Host_Request
Set status = 'rejected'
Where representative_ID=@representative_id AND manager_ID=@manager_id AND match_ID=@match_id

GO




CREATE PROC addFan
@name varchar(20) ,
@username varchar(20) ,
@password varchar(20),
@national_id_number varchar(20),
@birthdate datetime,
@address varchar(20), 
@phone_number int 

AS

IF (@username IN (SELECT S.username
FROM SystemUser S))
BEGIN
PRINT 'USERNAME ALREADY EXISTS'
END
ELSE
BEGIN

INSERT INTO SystemUser VALUES(@username,@password)

INSERT INTO Fan VALUES(@national_id_number,@name,@birthdate,@address,
@phone_number,DEFAULT,@username)
END
Go



CREATE FUNCTION upcomingMatchesOfClub
(@name VARCHAR(20))
RETURNS TABLE
AS
RETURN ((SELECT Host.name AS club, Guest.name AS other_club, M.start_time AS start_time, S.name AS stadium
        FROM Matches M INNER JOIN Club Host ON M.host_club_ID=Host.Club_ID
        INNER JOIN Club Guest ON M.guest_club_ID=Guest.Club_ID
        INNER JOIN Stadium S ON M.stadium_ID=S.ID
        WHERE Host.name=@name AND M.start_time>CURRENT_TIMESTAMP)
        UNION
        (SELECT Guest.name AS club, Host.name AS other_club, M.start_time AS start_time, S.name AS stadium
        FROM Matches M INNER JOIN Club Host ON M.host_club_ID=Host.Club_ID
        INNER JOIN Club Guest ON M.guest_club_ID=Guest.Club_ID
        INNER JOIN Stadium S ON M.stadium_ID=S.ID
        WHERE Guest.name=@name AND M.start_time>CURRENT_TIMESTAMP))

GO

CREATE FUNCTION availableMatchesToAttend
(@starttime DATETIME)
RETURNS TABLE 
AS
RETURN (
SELECT DISTINCT C2.name AS 'Host Club', C1.name AS 'Guest Club',M.start_time,S.name AS 'Stadium'
FROM Matches M INNER JOIN Ticket T ON M.match_ID=T.match_ID
INNER JOIN CLUB C1 ON C1.club_ID=M.guest_club_ID
INNER JOIN CLUB C2 ON C2.club_ID=M.host_club_ID
INNER JOIN Stadium S ON M.stadium_ID=S.ID
WHERE T.status=1 AND M.start_time>=@starttime

)

Go


CREATE PROCEDURE purchaseTicket
@national_id VARCHAR(20),
@host VARCHAR(20),
@guest VARCHAR(20),
@start_time DATETIME
AS

DECLARE @match_id INT
DECLARE @host_id INT
DECLARE @guest_id INT
DECLARE @ticket_id INT

SELECT @guest_id=C.Club_ID
FROM Club C
WHERE C.name=@guest

SELECT @host_id=C.Club_ID
FROM Club C
WHERE C.name=@host

SELECT @match_id=M.match_ID
FROM Matches M
WHERE M.start_time=@start_time AND M.host_club_ID=@host_id AND M.guest_club_ID=@guest_id

SET @ticket_id = (SELECT TOP 1 T.ID
                  FROM Ticket T
                  WHERE T.match_ID=@match_id AND T.status='1')

UPDATE Ticket
SET status='0'
WHERE ID=@ticket_id

INSERT INTO Ticket_Buying_Transactions VALUES(@national_id,@ticket_id)

GO


CREATE PROC updateMatchHost
@hostclub varchar(20),
@guestclub varchar(20), 
@starttime datetime
as

DECLARE @MID INT 
SELECT @MID=M.match_ID
FROM CLUB C INNER JOIN Matches M ON C.club_ID=M.host_club_ID
WHERE M.start_time=@starttime AND C.name=@hostclub

DECLARE @GuestID INT
SELECT @GuestID=C1.club_ID
FROM CLUB C1
WHERE C1.name=@guestclub

DECLARE @HostID INT
SELECT @HostID=C2.club_ID
FROM CLUB C2    
WHERE C2.name=@hostclub



UPDATE Matches
SET host_club_ID =@GuestID
WHERE match_ID=@MID



UPDATE Matches
SET guest_club_ID =@HostID
WHERE match_ID=@MID

GO

CREATE FUNCTION Helper
(@id INT)
Returns INT
AS
Begin
Return (SELECT COUNT(*)
        FROM Matches M 
        WHERE (M.guest_club_ID=@id OR M.host_club_ID=@id) AND M.end_time<=CURRENT_TIMESTAMP)
END

GO



CREATE VIEW matchesPerTeam AS
SELECT C.name AS name, dbo.Helper(C.Club_ID) AS matches_played
FROM Club C

GO

CREATE VIEW clubsNeverMatched AS
(SELECT C1.club_ID AS Club1, C2.club_ID AS Club2
FROM Club C1, Club C2  
WHERE C1.club_ID!=C2.club_ID
)
EXCEPT

(
SELECT M1.host_club_ID AS M1H,M1.guest_club_ID AS M1G
FROM Matches M1
WHERE M1.end_time<=CURRENT_TIMESTAMP

UNION

SELECT M2.guest_club_ID AS M2G, M2.host_club_ID AS M2H
FROM Matches M2
WHERE M2.end_time<=CURRENT_TIMESTAMP

)

GO

CREATE FUNCTION Helper2
(@id INT)
Returns INT
AS
Begin
Return (SELECT COUNT(*)
        FROM Ticket T 
        WHERE T.match_ID=@id AND T.status='0')
END

GO



CREATE FUNCTION clubsNeverPlayed
(@name VARCHAR(20))
RETURNS TABLE
AS
RETURN (SELECT C1.name AS name
        FROM Club C1
        WHERE C1.name<>@name AND NOT EXISTS(SELECT *
                                            FROM Matches M
                                            WHERE ((M.host_club_ID=C1.Club_ID AND M.guest_club_ID=(SELECT C.Club_ID FROM Club C WHERE C.name=@name)) OR (M.guest_club_ID=C1.Club_ID AND M.host_club_ID=(SELECT C.Club_ID FROM Club C WHERE C.name=@name))) AND M.end_time<=CURRENT_TIMESTAMP))

GO



CREATE FUNCTION matchWithHighestAttendance()
RETURNS TABLE 
AS 
RETURN
(
SELECT C2.name AS 'Host Club',C1.name AS 'Guest Club'
FROM Club C1 INNER JOIN Matches M ON C1.club_ID=M.guest_club_ID
INNER JOIN Club C2 ON C2.club_ID=M.host_club_ID
INNER JOIN Ticket T ON T.match_ID=M.match_ID
WHERE T.status=0
GROUP BY M.match_ID,C2.name,C1.name
HAVING COUNT(T.ID)=
					(
					SELECT MAX(TEMP.COUN)
					FROM
					(SELECT (COUNT(T1.ID))AS COUN
					FROM Matches M1 INNER JOIN Ticket T1 ON T1.match_ID=M1.match_ID
					WHERE T1.status=0
					GROUP BY M1.match_ID) AS TEMP
					)
)

GO


/*
CREATE FUNCTION matchesRankedByAttendance ()
RETURNS TABLE
AS
RETURN (SELECT Helper.host AS host, Helper.guest AS guest
        FROM (SELECT TOP 100 PERCENT Host.name AS host, Guest.name AS guest, dbo.Helper2(M.match_ID) AS attendance
              FROM Matches M INNER JOIN Club Host ON M.host_club_ID=Host.Club_ID
              INNER JOIN Club Guest ON M.guest_club_ID=Guest.Club_ID
              WHERE M.end_time<=CURRENT_TIMESTAMP
              ORDER BY attendance DESC) Helper)

GO
*/

CREATE FUNCTION matchesRankedByAttendance
()
RETURNS TABLE
AS 
RETURN 
(

SELECT  TOP 100 PERCENT TEMPO.[Host Club],TEMPO.[Guest Club]
FROM

(SELECT TOP 100 PERCENT C1.name AS 'Host Club',C2.name AS 'Guest Club', COUNT(T.ID) AS SoldTickets
FROM Club C1 INNER JOIN Matches M ON C1.club_ID=M.host_club_ID
INNER JOIN Club C2 ON C2.club_ID=M.guest_club_ID
INNER JOIN Ticket T ON T.match_ID=M.match_ID
WHERE T.status=0
GROUP BY M.match_ID,C1.name,C2.name
ORDER BY SoldTickets --COUNT(T.ID)


UNION 

SELECT TOP 100 PERCENT C3.name AS 'Host Club',C4.name AS 'Guest Club',0 AS SoldTickets
FROM Club C3 INNER JOIN Matches M1 ON C3.club_ID=M1.host_club_ID
INNER JOIN Club C4 ON C4.club_ID=M1.guest_club_ID
INNER JOIN Ticket T5 ON T5.match_ID=M1.match_ID
WHERE T5.status=1
GROUP BY M1.match_ID,C3.name,C4.name) AS TEMPO
ORDER BY TEMPO.SoldTickets

)



CREATE FUNCTION requestsFromClub
(@stadium VARCHAR(20),@club VARCHAR(20))
RETURNS @result TABLE (c1name VARCHAR(20), C2name VARCHAR(20))
AS
BEGIN
DECLARE @SM INT
SELECT @SM=SMA.ID
FROM Stadium S INNER JOIN Stadium_Manager SMA ON S.ID=SMA.stadium_id
WHERE S.name=@stadium

DECLARE @CR INT
SELECT @CR=CREP.ID
FROM Club C INNER JOIN Club_Representative CREP ON C.club_ID=CREP.club_id
WHERE C.name=@club

INSERT INTO @result
SELECT C1.name AS 'Host Club', C2.name AS 'Guest Club'
FROM Host_Request HR INNER JOIN Matches M ON HR.match_ID=M.match_ID
INNER JOIN Club C1 ON M.host_club_ID=C1.club_ID
INNER JOIN Club C2 ON M.guest_club_ID=C2.club_ID
WHERE HR.manager_ID=@SM AND HR.representative_ID=@CR

RETURN

END

GO

