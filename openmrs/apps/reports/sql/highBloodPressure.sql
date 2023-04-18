SELECT pi.identifier AS 'Patient Identifier',
        concat(pn.given_name, ' ', IF(pn.middle_name IS NULL OR pn.middle_name = '', '', concat(pn.middle_name, ' ')), 
        IF(pn.family_name IS NULL OR pn.family_name = '', '', pn.family_name)) AS "Patient Name",
        TIMESTAMPDIFF(YEAR, p.birthdate, CURDATE()) AS "Age",
        pa.value AS 'Phone Number',
        MAX(CASE WHEN c.uuid = '5085AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' THEN recent_o.value_numeric ELSE NULL END) AS 'Systolic (mm Hg)',
        MAX(CASE WHEN c.uuid = '5086AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' THEN recent_o.value_numeric ELSE NULL END) AS 'Diastolic (mm Hg)'
FROM person p
JOIN patient_identifier pi ON p.person_id = pi.patient_id
JOIN person_name pn ON p.person_id = pn.person_id
JOIN (
    SELECT obs1.*
    FROM obs obs1
    INNER JOIN (
        SELECT person_id, concept_id, MAX(date_created) as max_date_created
        FROM obs
        GROUP BY person_id, concept_id
    ) obs2 ON obs1.person_id = obs2.person_id AND obs1.concept_id = obs2.concept_id AND obs1.date_created = obs2.max_date_created
) recent_o ON p.person_id = recent_o.person_id
JOIN person_attribute pa ON p.person_id = pa.person_id
JOIN concept c ON recent_o.concept_id = c.concept_id
WHERE c.uuid IN ('5085AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA', '5086AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA')
GROUP BY pi.identifier, pn.given_name, p.birthdate
HAVING MAX(CASE WHEN c.uuid = '5085AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' THEN recent_o.value_numeric ELSE NULL END) > 140
AND MAX(CASE WHEN c.uuid = '5086AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' THEN recent_o.value_numeric ELSE NULL END) > 85;