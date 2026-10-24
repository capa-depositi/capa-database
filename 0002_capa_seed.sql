-- Migration: 0002_capa_seed.sql — Seed data for CAPA: legal_rates and questions

-- legal_rates
INSERT INTO legal_rates (year, rate) VALUES
  (2020, 0.2),
  (2021, 0.2),
  (2022, 1.25),
  (2023, 5.0),
  (2024, 2.5),
  (2025, 1.5),
  (2026, 0.8)
ON CONFLICT (year) DO NOTHING;

-- questions (role: affittuario)
INSERT INTO questions (id, role, question_text, question_type, options, required, depends_on, depends_value) VALUES
  ('Q1_AFF', 'affittuario', 'Quanto paghi al mese di affitto per la casa in cui vivi ora?', 'number', NULL, TRUE, NULL, NULL),
  ('Q2_AFF', 'affittuario', 'In che città si trova la casa che hai in affitto?', 'text', NULL, TRUE, NULL, NULL),
  ('Q3_AFF', 'affittuario', 'Qual è la durata del tuo contratto di affitto?', 'select', 'Meno di 1 anno,1-3 anni,4 anni,5 anni,Più di 5 anni', TRUE, NULL, NULL),
  ('Q4_AFF', 'affittuario', 'Al momento della stipula del contratto, ti è stato richiesto di pagare un deposito cauzionale?', 'select', 'Sì,No', TRUE, NULL, NULL),
  ('Q5_AFF', 'affittuario', 'Quando è stato versato il deposito cauzionale?', 'date', NULL, TRUE, 'Q4_AFF', 'Sì'),
  ('Q6_AFF', 'affittuario', 'A quante mensilità corrisponde?', 'select', '1,2,3,4', TRUE, 'Q4_AFF', 'Sì'),
  ('Q7_AFF', 'affittuario', 'Sai se il deposito cauzionale versato per il tuo contratto di affitto è soggetto a una qualche forma di remunerazione (interessi)?', 'select', 'Sì,No,Non ne sono a conoscenza', TRUE, 'Q4_AFF', 'Sì'),
  ('Q8_AFF', 'affittuario', 'Preferiresti:', 'select', 'Un deposito cauzionale non investito ma totalmente sicuro,Un deposito investito a basso rischio con possibile rendimento,Un deposito investito con rischio maggiore e rendimento più alto,Non ho preferenze', TRUE, 'Q4_AFF', 'Sì'),
  ('Q9_AFF', 'affittuario', 'Affidereste i depositi cauzionali ad una società per gestire la remunerazione degli interessi?', 'select', 'Sì,No, preferisco lasciare la gestione al proprietario,Non sono interessato a chi gestisce il deposito', TRUE, 'Q4_AFF', 'Sì')
ON CONFLICT (id) DO NOTHING;
