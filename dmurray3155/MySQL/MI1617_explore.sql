
SELECT * FROM claims_data;

/* 1617 */
SELECT * FROM claims_data WHERE TestStudentsScoresSummativeId = 3305961868;

/* 1516 */
SELECT * FROM claims_data WHERE TestStudentsScoresSummativeId = 1360459;

SELECT * FROM student_data;
SELECT * FROM content_data;
SELECT * FROM accom_data;
SELECT * FROM claims_data;
SELECT * FROM item_resp;
SELECT * FROM item_scores;
SELECT DISTINCT TestedGrade, COUNT(*) FROM mi1617.student_data GROUP BY TestedGrade;


SELECT * FROM mi1516.stud_cont_data_ela_3;
SELECT * FROM mi1516.student_data;
SELECT * FROM mi1516.content_data;
SELECT * FROM mi1516.stud_cont_data;
SELECT DISTINCT TestedGrade, COUNT(*) FROM mi1516.student_data GROUP BY TestedGrade;