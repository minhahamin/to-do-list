-- ============================================
-- todos 테이블에 새 컬럼 추가
-- ============================================

-- 기존 테이블에 컬럼 추가
ALTER TABLE todos 
ADD COLUMN IF NOT EXISTS links JSONB,
ADD COLUMN IF NOT EXISTS sub_tasks JSONB,
ADD COLUMN IF NOT EXISTS repeat_type TEXT DEFAULT 'none',
ADD COLUMN IF NOT EXISTS priority TEXT DEFAULT 'medium',
ADD COLUMN IF NOT EXISTS project_id UUID;

-- 또는 테이블을 완전히 다시 만들기 (데이터 손실 주의!)
-- DROP TABLE IF EXISTS todos CASCADE;

-- CREATE TABLE todos (
--   id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
--   user_id UUID REFERENCES auth.users NOT NULL,
--   title TEXT NOT NULL,
--   is_completed BOOLEAN DEFAULT FALSE,
--   due_date TIMESTAMPTZ,
--   created_at TIMESTAMPTZ DEFAULT NOW(),
--   category TEXT DEFAULT 'other',
--   notes TEXT,
--   links JSONB,
--   sub_tasks JSONB,
--   repeat_type TEXT DEFAULT 'none',
--   priority TEXT DEFAULT 'medium',
--   project_id UUID
-- );

-- -- 인덱스 재생성
-- CREATE INDEX todos_user_id_idx ON todos(user_id);
-- CREATE INDEX todos_created_at_idx ON todos(created_at);

-- -- RLS 재설정
-- ALTER TABLE todos ENABLE ROW LEVEL SECURITY;

-- CREATE POLICY "Users can view their own todos"
--   ON todos FOR SELECT USING (auth.uid() = user_id);

-- CREATE POLICY "Users can insert their own todos"
--   ON todos FOR INSERT WITH CHECK (auth.uid() = user_id);

-- CREATE POLICY "Users can update their own todos"
--   ON todos FOR UPDATE USING (auth.uid() = user_id);

-- CREATE POLICY "Users can delete their own todos"
--   ON todos FOR DELETE USING (auth.uid() = user_id);
