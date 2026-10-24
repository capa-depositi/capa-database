-- List completed submissions that have a final interest calculation.
SELECT
  s.id AS submission_id,
  s.created_at AS submission_created_at,
  s.completed_at,
  p.id AS profile_id,
  p.nome,
  p.cognome,
  p.email,
  p.created_at AS profile_created_at,
  jsonb_object_agg(
    a.question_id,
    jsonb_build_object(
      'question', q.question_text,
      'answer', a.answer_value
    )
    ORDER BY a.question_id
  ) AS answers
FROM profiles p
JOIN questionnaire_submissions s ON s.profile_id = p.id
JOIN answers a ON a.submission_id = s.id
LEFT JOIN questions q ON q.id = a.question_id
WHERE s.status = 'completed'
GROUP BY s.id, p.id
ORDER BY s.completed_at DESC;
