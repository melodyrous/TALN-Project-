//  1:  Placer le fichier .csv dans le dossier import du graphe
//  2:  Compiler dans le browser les commandes suivantes en supprimant les commentaires

//Creation d'index afin d'ameliorer les performances et d'une contrainte d'unicite
CREATE CONSTRAINT ON (t:Tweet) ASSERT t.num IS UNIQUE;
CREATE INDEX ON :Hashtag(name);
CREATE INDEX ON :Word(name);
//Import
USING PERIODIC COMMIT //Importe les donnees du csv par paquet
LOAD CSV WITH HEADERS // Avec les entetes
FROM 'file:///tweetsAnalyse.csv' AS line
WITH line
CREATE (tweet: Tweet) //Cree le noeud Tweet
SET tweet.date = line.date, tweet.text = line.text, tweet.num = TOINT(line.num); //Ajoute les proprietes au noeud

USING PERIODIC COMMIT 
LOAD CSV WITH HEADERS
FROM 'file:///tweetsAnalyse.csv' AS line
WITH line, split(line.hashtags, ',') as subjects //Decoupe la chaine de caractere hashtags pour en faire une liste
MATCH (t:Tweet{num:TOINT(line.num)}) //Selectionne le noeud (Tweet) de la BDD correspondant au num de la ligne du csv, et le stocke dans 't'
UNWIND subjects AS sub //Transforme la liste 'subjects' en ligne individuelles 'sub' (elements de la liste)
MERGE (h:Hashtag {name: CASE line.hashtags WHEN 'NO HASHTAG' THEN 'NO HASHTAG' ELSE UPPER(TRIM(sub)) END}) // Cree le noeud Hashtag
CREATE (t)-[:ABOUT{feeling:LOWER(line.sentiment)}]->(h); //Cree la relation [:ABOUT] entre le Tweet selectionne et le ou les Hashtag.s cree.s

USING PERIODIC COMMIT 
LOAD CSV WITH HEADERS
FROM 'file:///tweetsAnalyse.csv' AS line
WITH line, split(line.words, ',') as words //Cree la liste words
MATCH (t:Tweet{num:TOINT(line.num)}) //Selectionne le Tweet correspondant
UNWIND words as w
MERGE (word: Word {name: LOWER(w)}) //Cree le noeud (Word)
CREATE (word)-[:IS_IN]->(t); //Cree la relation [:IS_IN]