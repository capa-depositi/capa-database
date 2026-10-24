-- CAPA project schema baseline (PostgreSQL / Supabase).

CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY,
  nome TEXT NOT NULL,
  cognome TEXT NOT NULL,
  eta INTEGER NOT NULL,
  email TEXT UNIQUE NOT NULL,
  ruolo TEXT NOT NULL CHECK (ruolo IN ('affittuario')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_profiles_email ON profiles(email);
CREATE INDEX IF NOT EXISTS idx_profiles_ruolo ON profiles(ruolo);
CREATE INDEX IF NOT EXISTS idx_profiles_created_at ON profiles(created_at);

CREATE TABLE IF NOT EXISTS questionnaire_submissions (
  id UUID PRIMARY KEY,
  profile_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'in_progress' CHECK (status IN ('in_progress', 'completed')),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  completed_at TIMESTAMP WITH TIME ZONE,
  email_status TEXT NOT NULL DEFAULT 'not_sent' CHECK (email_status IN ('not_sent', 'sending', 'sent', 'failed')),
  email_attempted_at TIMESTAMP WITH TIME ZONE,
  email_attempt_id UUID,
  email_error TEXT
);

CREATE INDEX IF NOT EXISTS idx_questionnaire_submissions_profile_id ON questionnaire_submissions(profile_id);
CREATE INDEX IF NOT EXISTS idx_questionnaire_submissions_status ON questionnaire_submissions(status);

CREATE TABLE IF NOT EXISTS answers (
  id SERIAL PRIMARY KEY,
  submission_id UUID NOT NULL REFERENCES questionnaire_submissions(id) ON DELETE CASCADE,
  question_id TEXT NOT NULL,
  answer_value TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  CONSTRAINT uq_submission_question UNIQUE (submission_id, question_id)
);

CREATE INDEX IF NOT EXISTS idx_answers_submission_id ON answers(submission_id);
CREATE INDEX IF NOT EXISTS idx_answers_question_id ON answers(question_id);
CREATE INDEX IF NOT EXISTS idx_answers_created_at ON answers(created_at);

CREATE TABLE IF NOT EXISTS questions (
  id TEXT PRIMARY KEY,
  role TEXT NOT NULL CHECK (role IN ('affittuario')),
  question_text TEXT NOT NULL,
  question_type TEXT NOT NULL CHECK (question_type IN ('text','number','date','select')),
  options TEXT,
  required BOOLEAN DEFAULT TRUE,
  depends_on TEXT REFERENCES questions(id),
  depends_value TEXT
);

CREATE INDEX IF NOT EXISTS idx_questions_role ON questions(role);
CREATE INDEX IF NOT EXISTS idx_questions_type ON questions(question_type);
CREATE INDEX IF NOT EXISTS idx_questions_depends_on ON questions(depends_on);

CREATE TABLE IF NOT EXISTS legal_rates (
  year INTEGER PRIMARY KEY,
  rate REAL NOT NULL CHECK (rate >= 0)
);

CREATE TABLE IF NOT EXISTS result_tokens (
  id SERIAL PRIMARY KEY,
  submission_id UUID NOT NULL REFERENCES questionnaire_submissions(id) ON DELETE CASCADE,
  token_hash TEXT NOT NULL UNIQUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
  view_count INTEGER NOT NULL DEFAULT 0,
  last_viewed_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX IF NOT EXISTS idx_result_tokens_submission ON result_tokens(submission_id);
