-- ============================================================
-- TPG316C GROUP ASSIGNMENT - SUPABASE DATABASE SCHEMA
-- Student Assistant Application System
-- ============================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- PROFILES TABLE (extends Supabase auth.users)
-- ============================================================
CREATE TABLE public.profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  full_name TEXT NOT NULL,
  student_number TEXT UNIQUE,
  email TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'student' CHECK (role IN ('student', 'admin')),
  year_of_study INT CHECK (year_of_study BETWEEN 1 AND 3),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- MODULES TABLE
-- ============================================================
CREATE TABLE public.modules (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  code TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  academic_level INT NOT NULL CHECK (academic_level BETWEEN 1 AND 3),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert default modules
INSERT INTO public.modules (code, name, academic_level) VALUES
  ('ITC111', 'Introduction to Programming', 1),
  ('ITC112', 'Computer Fundamentals', 1),
  ('ITC113', 'Web Design Fundamentals', 1),
  ('ITC121', 'Database Management', 1),
  ('ITC211', 'Object-Oriented Programming', 2),
  ('ITC212', 'Data Structures', 2),
  ('ITC213', 'Web Development', 2),
  ('ITC221', 'Systems Analysis & Design', 2),
  ('ITC311', 'Mobile Application Development', 3),
  ('ITC312', 'Software Engineering', 3),
  ('ITC313', 'Network Security', 3),
  ('TPG316C', 'Technical Programming III', 3);

-- ============================================================
-- APPLICATIONS TABLE
-- ============================================================
CREATE TABLE public.applications (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  student_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  year_of_study INT NOT NULL CHECK (year_of_study BETWEEN 1 AND 3),

  -- First module application
  module1_id UUID REFERENCES public.modules(id) NOT NULL,
  module1_level INT NOT NULL CHECK (module1_level BETWEEN 1 AND 3),

  -- Second module application (optional)
  module2_id UUID REFERENCES public.modules(id),
  module2_level INT CHECK (module2_level BETWEEN 1 AND 3),

  -- Eligibility & documentation
  meets_requirements BOOLEAN NOT NULL DEFAULT FALSE,
  document_url TEXT,
  document_name TEXT,

  -- Status
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  admin_comments TEXT,
  reviewed_by UUID REFERENCES public.profiles(id),
  reviewed_at TIMESTAMPTZ,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================

-- Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.modules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.applications ENABLE ROW LEVEL SECURITY;

-- PROFILES policies
CREATE POLICY "Users can view their own profile"
  ON public.profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Admins can view all profiles"
  ON public.profiles FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role = 'admin'
    )
  );

-- MODULES policies (all authenticated users can read)
CREATE POLICY "Authenticated users can view modules"
  ON public.modules FOR SELECT
  TO authenticated
  USING (TRUE);

-- APPLICATIONS policies
CREATE POLICY "Students can view their own applications"
  ON public.applications FOR SELECT
  USING (student_id = auth.uid());

CREATE POLICY "Students can create their own applications"
  ON public.applications FOR INSERT
  WITH CHECK (student_id = auth.uid());

CREATE POLICY "Students can update their own pending applications"
  ON public.applications FOR UPDATE
  USING (student_id = auth.uid() AND status = 'pending');

CREATE POLICY "Students can delete their own pending applications"
  ON public.applications FOR DELETE
  USING (student_id = auth.uid() AND status = 'pending');

CREATE POLICY "Admins can view all applications"
  ON public.applications FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role = 'admin'
    )
  );

CREATE POLICY "Admins can update all applications"
  ON public.applications FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role = 'admin'
    )
  );

CREATE POLICY "Admins can delete applications"
  ON public.applications FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role = 'admin'
    )
  );

-- ============================================================
-- STORAGE BUCKET for supporting documents
-- ============================================================
INSERT INTO storage.buckets (id, name, public) VALUES ('documents', 'documents', FALSE);

CREATE POLICY "Students can upload their own documents"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'documents' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Students can view their own documents"
  ON storage.objects FOR SELECT
  TO authenticated
  USING (bucket_id = 'documents' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Admins can view all documents"
  ON storage.objects FOR SELECT
  TO authenticated
  USING (
    bucket_id = 'documents' AND
    EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role = 'admin'
    )
  );

-- ============================================================
-- TRIGGER: auto-update updated_at
-- ============================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_applications_updated_at
  BEFORE UPDATE ON public.applications
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================
-- FUNCTION: auto-create profile on signup
-- ============================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, email, role)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', 'Unknown'),
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'role', 'student')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
