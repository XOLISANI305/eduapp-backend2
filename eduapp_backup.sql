--
-- PostgreSQL database dump
--

-- Dumped from database version 17.4
-- Dumped by pg_dump version 17.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: question_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.question_type AS ENUM (
    'multiple_choice',
    'true_false',
    'short_answer'
);


ALTER TYPE public.question_type OWNER TO postgres;

--
-- Name: user_role; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.user_role AS ENUM (
    'student',
    'teacher',
    'admin'
);


ALTER TYPE public.user_role OWNER TO postgres;

--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_updated_at_column() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: activities; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.activities (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    student_id uuid NOT NULL,
    type character varying(100) NOT NULL,
    title character varying(255) NOT NULL,
    assessment_type character varying(100),
    score numeric(5,2),
    max_score numeric(5,2) DEFAULT 100.00,
    date date NOT NULL,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.activities OWNER TO postgres;

--
-- Name: answers_for_qna; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.answers_for_qna (
    id integer NOT NULL,
    question_id integer,
    body text NOT NULL,
    author_id uuid,
    is_accepted boolean DEFAULT false,
    votes integer DEFAULT 0,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.answers_for_qna OWNER TO postgres;

--
-- Name: answers_for_qna_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.answers_for_qna_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.answers_for_qna_id_seq OWNER TO postgres;

--
-- Name: answers_for_qna_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.answers_for_qna_id_seq OWNED BY public.answers_for_qna.id;


--
-- Name: assessment_answers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.assessment_answers (
    id integer NOT NULL,
    submission_id integer,
    question_id integer,
    selected_option integer
);


ALTER TABLE public.assessment_answers OWNER TO postgres;

--
-- Name: assessment_answers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.assessment_answers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.assessment_answers_id_seq OWNER TO postgres;

--
-- Name: assessment_answers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.assessment_answers_id_seq OWNED BY public.assessment_answers.id;


--
-- Name: assessment_submissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.assessment_submissions (
    id integer NOT NULL,
    assessment_id integer,
    student_id integer,
    submitted_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.assessment_submissions OWNER TO postgres;

--
-- Name: assessment_submissions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.assessment_submissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.assessment_submissions_id_seq OWNER TO postgres;

--
-- Name: assessment_submissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.assessment_submissions_id_seq OWNED BY public.assessment_submissions.id;


--
-- Name: assessments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.assessments (
    title character varying(255) NOT NULL,
    description text,
    subject_id integer NOT NULL,
    group_id integer NOT NULL,
    created_by uuid,
    type character varying(50),
    total_marks integer,
    duration_minutes integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    id integer NOT NULL,
    status character varying(20) DEFAULT 'pending'::character varying,
    approved boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT assessments_type_check CHECK (((type)::text = ANY ((ARRAY['quiz'::character varying, 'test'::character varying, 'exam'::character varying])::text[])))
);


ALTER TABLE public.assessments OWNER TO postgres;

--
-- Name: assessments_id_new_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.assessments ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.assessments_id_new_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: attendance_records; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.attendance_records (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    student_id uuid,
    date date NOT NULL,
    attendance_rate numeric(5,2),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.attendance_records OWNER TO postgres;

--
-- Name: comments_for_qna; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.comments_for_qna (
    id integer NOT NULL,
    answer_id integer NOT NULL,
    body text NOT NULL,
    author_id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.comments_for_qna OWNER TO postgres;

--
-- Name: comments_for_qna_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.comments_for_qna_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.comments_for_qna_id_seq OWNER TO postgres;

--
-- Name: comments_for_qna_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.comments_for_qna_id_seq OWNED BY public.comments_for_qna.id;


--
-- Name: groups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.groups (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    subject_id integer
);


ALTER TABLE public.groups OWNER TO postgres;

--
-- Name: groups_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.groups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.groups_id_seq OWNER TO postgres;

--
-- Name: groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.groups_id_seq OWNED BY public.groups.id;


--
-- Name: options; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.options (
    question_id integer NOT NULL,
    option_text text NOT NULL,
    is_correct boolean DEFAULT false,
    id integer NOT NULL
);


ALTER TABLE public.options OWNER TO postgres;

--
-- Name: options_id_new_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.options ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.options_id_new_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: parent_children; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.parent_children (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    parent_id uuid NOT NULL,
    child_id uuid NOT NULL,
    relationship_type character varying(50) DEFAULT 'parent'::character varying,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.parent_children OWNER TO postgres;

--
-- Name: password_reset_tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.password_reset_tokens (
    user_id uuid NOT NULL,
    token text NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE public.password_reset_tokens OWNER TO postgres;

--
-- Name: question_options; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.question_options (
    id integer NOT NULL,
    question_id integer NOT NULL,
    option_text text NOT NULL,
    is_correct boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.question_options OWNER TO postgres;

--
-- Name: question_options_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.question_options_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.question_options_id_seq OWNER TO postgres;

--
-- Name: question_options_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.question_options_id_seq OWNED BY public.question_options.id;


--
-- Name: question_views; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.question_views (
    id integer NOT NULL,
    question_id integer,
    user_id uuid,
    viewed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.question_views OWNER TO postgres;

--
-- Name: question_views_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.question_views_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.question_views_id_seq OWNER TO postgres;

--
-- Name: question_views_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.question_views_id_seq OWNED BY public.question_views.id;


--
-- Name: questions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.questions (
    assessment_id integer NOT NULL,
    question_text text NOT NULL,
    question_type character varying(50),
    marks integer NOT NULL,
    id integer NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT questions_question_type_check CHECK (((question_type)::text = ANY ((ARRAY['multiple_choice'::character varying, 'true_false'::character varying, 'short_answer'::character varying])::text[])))
);


ALTER TABLE public.questions OWNER TO postgres;

--
-- Name: questions_for_qna; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.questions_for_qna (
    id integer NOT NULL,
    title character varying(255) NOT NULL,
    body text NOT NULL,
    author_id uuid,
    subject_id integer,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.questions_for_qna OWNER TO postgres;

--
-- Name: questions_for_qna_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.questions_for_qna_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.questions_for_qna_id_seq OWNER TO postgres;

--
-- Name: questions_for_qna_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.questions_for_qna_id_seq OWNED BY public.questions_for_qna.id;


--
-- Name: questions_id_new_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.questions ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.questions_id_new_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: resources; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.resources (
    id integer NOT NULL,
    topic_id integer NOT NULL,
    type character varying(50) NOT NULL,
    title character varying(255) NOT NULL,
    url text,
    file_path text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.resources OWNER TO postgres;

--
-- Name: resources_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.resources_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.resources_id_seq OWNER TO postgres;

--
-- Name: resources_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.resources_id_seq OWNED BY public.resources.id;


--
-- Name: student_app_visits; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.student_app_visits (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    student_id uuid,
    login_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    logout_time timestamp without time zone,
    session_duration integer,
    pages_visited text[],
    device_type character varying(50),
    app_version character varying(20),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.student_app_visits OWNER TO postgres;

--
-- Name: student_assessments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.student_assessments (
    id integer NOT NULL,
    student_id uuid NOT NULL,
    assessment_id integer NOT NULL,
    submitted_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    score integer,
    answers jsonb
);


ALTER TABLE public.student_assessments OWNER TO postgres;

--
-- Name: student_assessments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.student_assessments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.student_assessments_id_seq OWNER TO postgres;

--
-- Name: student_assessments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.student_assessments_id_seq OWNED BY public.student_assessments.id;


--
-- Name: student_subjects; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.student_subjects (
    id integer NOT NULL,
    student_id uuid NOT NULL,
    subject_id integer NOT NULL,
    enrolled_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.student_subjects OWNER TO postgres;

--
-- Name: student_subjects_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.student_subjects_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.student_subjects_id_seq OWNER TO postgres;

--
-- Name: student_subjects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.student_subjects_id_seq OWNED BY public.student_subjects.id;


--
-- Name: students; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.students (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    full_name character varying(100) NOT NULL,
    email character varying(100) NOT NULL,
    phone_number character varying(20),
    password_hash text,
    role character varying(20) NOT NULL,
    is_verified boolean DEFAULT false,
    grade_level integer,
    class_name character varying(100),
    parent_id uuid,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    google_id text,
    facebook_id text,
    verification_token character varying(255),
    CONSTRAINT students_role_check CHECK (((role)::text = ANY ((ARRAY['parent'::character varying, 'teacher'::character varying, 'admin'::character varying, 'student'::character varying])::text[])))
);


ALTER TABLE public.students OWNER TO postgres;

--
-- Name: subjects; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.subjects (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    grade text,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.subjects OWNER TO postgres;

--
-- Name: subjects_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.subjects_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.subjects_id_seq OWNER TO postgres;

--
-- Name: subjects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.subjects_id_seq OWNED BY public.subjects.id;


--
-- Name: submissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.submissions (
    assessment_id integer NOT NULL,
    student_id uuid NOT NULL,
    score integer,
    submitted_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    id integer NOT NULL
);


ALTER TABLE public.submissions OWNER TO postgres;

--
-- Name: submissions_id_new_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.submissions ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.submissions_id_new_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: suggested_questions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.suggested_questions (
    id integer NOT NULL,
    subject_id integer,
    question_text text NOT NULL,
    options jsonb NOT NULL,
    correct_option text NOT NULL,
    suggested_by uuid,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.suggested_questions OWNER TO postgres;

--
-- Name: suggested_questions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.suggested_questions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.suggested_questions_id_seq OWNER TO postgres;

--
-- Name: suggested_questions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.suggested_questions_id_seq OWNED BY public.suggested_questions.id;


--
-- Name: topics; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.topics (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    group_id integer,
    subject_id integer
);


ALTER TABLE public.topics OWNER TO postgres;

--
-- Name: topics_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.topics_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.topics_id_seq OWNER TO postgres;

--
-- Name: topics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.topics_id_seq OWNED BY public.topics.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    full_name character varying(100) NOT NULL,
    email character varying(100) NOT NULL,
    phone_number character varying(20),
    password_hash text,
    role character varying(20) DEFAULT NULL::character varying,
    is_verified boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    google_id text,
    facebook_id text,
    verification_token character varying(255),
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    secondary_email text,
    phone text,
    bio text,
    CONSTRAINT users_role_check CHECK (((role)::text = ANY ((ARRAY['student'::character varying, 'teacher'::character varying, 'parent'::character varying, 'admin'::character varying])::text[])))
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: verification_tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.verification_tokens (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    token character varying(255) NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.verification_tokens OWNER TO postgres;

--
-- Name: answers_for_qna id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.answers_for_qna ALTER COLUMN id SET DEFAULT nextval('public.answers_for_qna_id_seq'::regclass);


--
-- Name: assessment_answers id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assessment_answers ALTER COLUMN id SET DEFAULT nextval('public.assessment_answers_id_seq'::regclass);


--
-- Name: assessment_submissions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assessment_submissions ALTER COLUMN id SET DEFAULT nextval('public.assessment_submissions_id_seq'::regclass);


--
-- Name: comments_for_qna id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comments_for_qna ALTER COLUMN id SET DEFAULT nextval('public.comments_for_qna_id_seq'::regclass);


--
-- Name: groups id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groups ALTER COLUMN id SET DEFAULT nextval('public.groups_id_seq'::regclass);


--
-- Name: question_options id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.question_options ALTER COLUMN id SET DEFAULT nextval('public.question_options_id_seq'::regclass);


--
-- Name: question_views id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.question_views ALTER COLUMN id SET DEFAULT nextval('public.question_views_id_seq'::regclass);


--
-- Name: questions_for_qna id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.questions_for_qna ALTER COLUMN id SET DEFAULT nextval('public.questions_for_qna_id_seq'::regclass);


--
-- Name: resources id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resources ALTER COLUMN id SET DEFAULT nextval('public.resources_id_seq'::regclass);


--
-- Name: student_assessments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_assessments ALTER COLUMN id SET DEFAULT nextval('public.student_assessments_id_seq'::regclass);


--
-- Name: student_subjects id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_subjects ALTER COLUMN id SET DEFAULT nextval('public.student_subjects_id_seq'::regclass);


--
-- Name: subjects id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subjects ALTER COLUMN id SET DEFAULT nextval('public.subjects_id_seq'::regclass);


--
-- Name: suggested_questions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suggested_questions ALTER COLUMN id SET DEFAULT nextval('public.suggested_questions_id_seq'::regclass);


--
-- Name: topics id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.topics ALTER COLUMN id SET DEFAULT nextval('public.topics_id_seq'::regclass);


--
-- Data for Name: activities; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.activities (id, student_id, type, title, assessment_type, score, max_score, date, created_at) FROM stdin;
\.


--
-- Data for Name: answers_for_qna; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.answers_for_qna (id, question_id, body, author_id, is_accepted, votes, created_at) FROM stdin;
7	5	Mathematics	1ba29a2b-18ff-424e-80fc-7be85f35fe88	t	1	2025-10-04 02:47:13.765674
8	10	none!	f7b14aa3-bd9f-4ad9-95bf-525f504dcc47	f	1	2025-10-04 03:28:10.070059
9	11	It is called....	f7b14aa3-bd9f-4ad9-95bf-525f504dcc47	t	1	2025-10-04 03:30:12.690691
10	9	2,45	1ba29a2b-18ff-424e-80fc-7be85f35fe88	f	2	2025-10-04 04:14:08.346649
6	4	2	1ba29a2b-18ff-424e-80fc-7be85f35fe88	f	1	2025-10-04 01:18:11.675049
5	8	see answer 2	1ba29a2b-18ff-424e-80fc-7be85f35fe88	t	3	2025-10-03 23:38:45.85061
11	12	yes, thank you!	f7b14aa3-bd9f-4ad9-95bf-525f504dcc47	t	2	2025-10-06 20:58:56.811939
12	12	Thank you Luvo!	1ba29a2b-18ff-424e-80fc-7be85f35fe88	t	2	2025-10-06 20:59:57.227748
2	3	It states that aý + bý = cý for right-angled triangles.	1ba29a2b-18ff-424e-80fc-7be85f35fe88	t	1	2025-09-24 18:01:55.323307
4	7	12	1ba29a2b-18ff-424e-80fc-7be85f35fe88	t	0	2025-10-03 23:20:30.235086
3	6	1	1ba29a2b-18ff-424e-80fc-7be85f35fe88	t	0	2025-10-03 23:17:06.693104
14	14	Life is life!	f7b14aa3-bd9f-4ad9-95bf-525f504dcc47	t	1	2025-10-07 18:21:29.646597
16	13	thank you!	1ba29a2b-18ff-424e-80fc-7be85f35fe88	f	0	2025-10-20 14:10:19.111575
17	11	Thank you!	1ba29a2b-18ff-424e-80fc-7be85f35fe88	f	1	2026-03-10 15:14:03.811077
15	15	sgdusfhsibvcj fwyifryuwe	1ba29a2b-18ff-424e-80fc-7be85f35fe88	f	0	2025-10-09 18:47:59.11788
13	13	Thank you for this question,WIll get back to you later!	1ba29a2b-18ff-424e-80fc-7be85f35fe88	t	1	2025-10-06 21:06:15.721779
\.


--
-- Data for Name: assessment_answers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.assessment_answers (id, submission_id, question_id, selected_option) FROM stdin;
\.


--
-- Data for Name: assessment_submissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.assessment_submissions (id, assessment_id, student_id, submitted_at) FROM stdin;
\.


--
-- Data for Name: assessments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.assessments (title, description, subject_id, group_id, created_by, type, total_marks, duration_minutes, created_at, id, status, approved, updated_at) FROM stdin;
LO Quiz 1	Life Orientation quiz	33	6	1fd1d960-ee5d-40f7-882f-c8f6d43ae32a	quiz	100	30	2025-09-18 16:09:22.655645	17	pending	f	2025-09-24 10:08:21.557879
isiZulu Test 1	isiZulu chapter test	34	6	1fd1d960-ee5d-40f7-882f-c8f6d43ae32a	test	100	45	2025-09-18 16:09:22.655645	18	pending	f	2025-09-24 10:08:21.557879
Test1	\N	34	9	5deb41da-2a17-4f2f-b1c3-193594b96ed4	\N	\N	\N	2025-09-23 13:23:09.063457	21	pending	f	2025-09-24 10:08:21.557879
Quiz 1	\N	36	10	5deb41da-2a17-4f2f-b1c3-193594b96ed4	\N	\N	\N	2025-09-23 14:34:36.977977	22	pending	f	2025-09-24 10:08:21.557879
Grade 12 Algebra Test	\N	1	11	5deb41da-2a17-4f2f-b1c3-193594b96ed4	\N	\N	\N	2025-09-23 17:56:21.263163	28	pending	t	2025-09-24 10:13:06.748485
Test one	\N	1	7	74160f33-5fc8-431a-9d10-a8365662a230	\N	\N	\N	2025-09-23 16:59:04.901678	26	pending	t	2025-09-24 17:16:37.191675
Test1	\N	35	8	5deb41da-2a17-4f2f-b1c3-193594b96ed4	\N	\N	\N	2025-09-23 13:03:00.485118	20	pending	f	2025-10-14 16:07:20.735819
First assessment	\N	1	11	74160f33-5fc8-431a-9d10-a8365662a230	\N	\N	\N	2025-10-15 08:56:04.83873	55	active	t	2025-10-15 09:12:22.829929
test11	\N	35	8	5deb41da-2a17-4f2f-b1c3-193594b96ed4	\N	\N	\N	2025-10-13 21:27:10.209143	31	pending	f	2025-10-20 12:08:05.478425
test3	\N	35	8	5deb41da-2a17-4f2f-b1c3-193594b96ed4	\N	\N	\N	2025-10-14 12:43:19.717282	32	pending	f	2025-10-20 12:08:06.251771
English Exam 1	Mid-term English exam	35	6	1fd1d960-ee5d-40f7-882f-c8f6d43ae32a	exam	100	60	2025-09-18 16:09:22.655645	19	pending	f	2025-10-14 16:16:30.358634
exam test	\N	1	11	74160f33-5fc8-431a-9d10-a8365662a230	\N	\N	\N	2025-10-15 18:23:25.140885	56	active	t	2026-01-24 12:01:49.543791
Test1	\N	1	11	\N	\N	\N	\N	2025-09-23 16:13:42.732739	23	pending	f	2026-02-26 17:40:13.710496
Test 3	\N	1	11	\N	\N	\N	\N	2025-09-23 18:08:38.866097	29	pending	f	2026-02-26 17:40:13.710496
Test 1	\N	36	12	\N	\N	\N	\N	2025-09-23 18:24:30.46695	30	pending	f	2026-02-26 17:40:13.710496
mock test	\N	36	10	\N	\N	\N	\N	2025-10-14 16:16:58.283999	34	active	t	2026-02-26 17:40:13.710496
HOMEWORK	\N	35	15	\N	\N	\N	\N	2025-10-14 23:56:20.704052	35	active	t	2026-02-26 17:40:13.710496
Final test	\N	34	9	74160f33-5fc8-431a-9d10-a8365662a230	\N	\N	\N	2026-06-09 17:27:27.727292	57	pending	f	2026-06-09 17:27:27.727292
\.


--
-- Data for Name: attendance_records; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.attendance_records (id, student_id, date, attendance_rate, created_at) FROM stdin;
4b5583d1-a699-4f38-8d10-2b7ac1691303	fe6fb89b-f367-486a-a479-ef6c8cc4afb4	2025-09-18	95.50	2025-09-18 16:09:23.15724
fa0b49b9-3e15-42bb-a7ab-9fdd1f067619	fe6fb89b-f367-486a-a479-ef6c8cc4afb4	2025-09-17	88.20	2025-09-17 16:09:23.15724
089ac083-6024-49c7-a158-4ae132eea6d6	fe6fb89b-f367-486a-a479-ef6c8cc4afb4	2025-09-16	92.70	2025-09-16 16:09:23.15724
\.


--
-- Data for Name: comments_for_qna; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.comments_for_qna (id, answer_id, body, author_id, created_at) FROM stdin;
1	5	Thank you!	1ba29a2b-18ff-424e-80fc-7be85f35fe88	2025-10-04 01:46:17.467777
2	9	Thank you!	1ba29a2b-18ff-424e-80fc-7be85f35fe88	2025-10-04 03:32:27.371668
3	13	No problem!	f7b14aa3-bd9f-4ad9-95bf-525f504dcc47	2025-10-06 21:07:48.806656
4	14	Thank you Luvo!	1ba29a2b-18ff-424e-80fc-7be85f35fe88	2025-10-07 18:22:52.002693
5	14	No problem!	f7b14aa3-bd9f-4ad9-95bf-525f504dcc47	2025-10-07 18:25:48.370505
\.


--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.groups (id, name, subject_id) FROM stdin;
6	Default Group	\N
7	Carl Malcomes	12
8	A	35
9	Test1	34
10	Data Structures	36
11	Group 1	1
12	Group 5	36
14	a	35
15	a	35
16	A	35
17	Test1	35
\.


--
-- Data for Name: options; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.options (question_id, option_text, is_correct, id) FROM stdin;
\.


--
-- Data for Name: parent_children; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.parent_children (id, parent_id, child_id, relationship_type, created_at) FROM stdin;
\.


--
-- Data for Name: password_reset_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.password_reset_tokens (user_id, token, expires_at, id) FROM stdin;
\.


--
-- Data for Name: question_options; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.question_options (id, question_id, option_text, is_correct, created_at, updated_at) FROM stdin;
1	6	a	f	2025-10-14 13:29:59.145665	2025-10-14 13:29:59.145665
2	6	b	t	2025-10-14 13:30:06.618919	2025-10-14 13:30:06.618919
3	6	c	f	2025-10-14 13:30:11.837903	2025-10-14 13:30:11.837903
4	6	d	f	2025-10-14 13:30:20.161753	2025-10-14 13:30:20.161753
7	9	by adding 4	t	2025-10-14 23:57:24.726656	2025-10-14 23:57:24.726656
8	9	by adding 6	f	2025-10-14 23:57:39.460021	2025-10-14 23:57:39.460021
9	9	by adding 9	f	2025-10-14 23:57:47.599473	2025-10-14 23:57:47.599473
10	9	by adding 10	f	2025-10-14 23:57:58.822097	2025-10-14 23:57:58.822097
11	10	2	t	2025-10-15 08:56:57.889779	2025-10-15 08:56:57.889779
12	10	3	f	2025-10-15 08:57:04.379853	2025-10-15 08:57:04.379853
13	11	4	t	2025-10-15 08:57:14.118902	2025-10-15 08:57:14.118902
14	11	22	f	2025-10-15 08:57:23.666204	2025-10-15 08:57:23.666204
15	12	1	t	2025-10-15 18:19:26.968316	2025-10-15 18:19:26.968316
16	12	3	f	2025-10-15 18:19:34.922919	2025-10-15 18:19:34.922919
17	12	5	f	2025-10-15 18:19:41.380765	2025-10-15 18:19:41.380765
18	12	6	f	2025-10-15 18:19:54.177485	2025-10-15 18:19:54.177485
19	13	34	f	2025-10-15 18:23:53.916108	2025-10-15 18:23:53.916108
20	13	25	t	2025-10-15 18:24:01.495681	2025-10-15 18:24:01.495681
21	13	67	f	2025-10-15 18:24:07.708541	2025-10-15 18:24:07.708541
\.


--
-- Data for Name: question_views; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.question_views (id, question_id, user_id, viewed_at) FROM stdin;
213	16	1ba29a2b-18ff-424e-80fc-7be85f35fe88	2026-03-25 22:16:58.774289
163	15	1ba29a2b-18ff-424e-80fc-7be85f35fe88	2026-03-25 22:16:58.780461
79	12	f7b14aa3-bd9f-4ad9-95bf-525f504dcc47	2025-10-14 23:02:57.384111
5	9	f7b14aa3-bd9f-4ad9-95bf-525f504dcc47	2025-10-14 23:03:02.167002
317	10	1ba29a2b-18ff-424e-80fc-7be85f35fe88	2026-05-20 18:34:13.307415
238	3	74160f33-5fc8-431a-9d10-a8365662a230	2025-10-15 18:38:13.958786
206	17	1ba29a2b-18ff-424e-80fc-7be85f35fe88	2025-10-16 08:58:32.792276
131	3	1ba29a2b-18ff-424e-80fc-7be85f35fe88	2025-10-16 08:58:32.883545
285	10	f7b14aa3-bd9f-4ad9-95bf-525f504dcc47	2025-10-21 11:37:00.129963
91	11	f7b14aa3-bd9f-4ad9-95bf-525f504dcc47	2025-10-06 21:00:36.224819
132	14	f7b14aa3-bd9f-4ad9-95bf-525f504dcc47	2025-10-07 18:24:06.859014
222	16	f7b14aa3-bd9f-4ad9-95bf-525f504dcc47	2025-10-14 23:02:57.28357
7	4	f7b14aa3-bd9f-4ad9-95bf-525f504dcc47	2025-10-14 23:03:02.170228
239	17	74160f33-5fc8-431a-9d10-a8365662a230	2025-10-15 18:38:13.926219
349	11	1ba29a2b-18ff-424e-80fc-7be85f35fe88	2026-03-10 15:14:11.912238
101	13	1ba29a2b-18ff-424e-80fc-7be85f35fe88	2026-03-25 22:16:58.804692
223	15	f7b14aa3-bd9f-4ad9-95bf-525f504dcc47	2025-10-14 23:02:57.381734
6	5	f7b14aa3-bd9f-4ad9-95bf-525f504dcc47	2025-10-14 23:03:02.16885
242	19	1ba29a2b-18ff-424e-80fc-7be85f35fe88	2025-10-16 08:58:32.787619
133	14	1ba29a2b-18ff-424e-80fc-7be85f35fe88	2026-03-10 15:13:33.302387
2	8	f7b14aa3-bd9f-4ad9-95bf-525f504dcc47	2025-10-14 23:02:57.385384
108	13	f7b14aa3-bd9f-4ad9-95bf-525f504dcc47	2025-10-14 23:02:57.379601
240	18	1ba29a2b-18ff-424e-80fc-7be85f35fe88	2025-10-16 08:58:32.79006
3	6	f7b14aa3-bd9f-4ad9-95bf-525f504dcc47	2025-10-14 23:03:02.164136
54	9	1ba29a2b-18ff-424e-80fc-7be85f35fe88	2026-03-25 22:16:58.806817
50	12	1ba29a2b-18ff-424e-80fc-7be85f35fe88	2026-03-25 22:16:58.808144
53	8	1ba29a2b-18ff-424e-80fc-7be85f35fe88	2026-03-25 22:16:58.811089
52	7	1ba29a2b-18ff-424e-80fc-7be85f35fe88	2026-03-25 22:16:58.834626
51	6	1ba29a2b-18ff-424e-80fc-7be85f35fe88	2026-03-25 22:16:58.836439
49	5	1ba29a2b-18ff-424e-80fc-7be85f35fe88	2026-03-25 22:16:58.838022
55	4	1ba29a2b-18ff-424e-80fc-7be85f35fe88	2026-03-25 22:16:58.840625
1	7	f7b14aa3-bd9f-4ad9-95bf-525f504dcc47	2025-10-14 23:02:57.386199
\.


--
-- Data for Name: questions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.questions (assessment_id, question_text, question_type, marks, id, created_at, updated_at) FROM stdin;
26	Simplify: 2x + 3x	multiple_choice	2	5	2025-09-24 17:40:53.98972	2025-09-24 17:40:53.98972
32	what is math?	multiple_choice	1	6	2025-10-14 13:29:39.61976	2025-10-14 13:29:39.61976
35	How did you Complete this?	multiple_choice	3	9	2025-10-14 23:57:07.229786	2025-10-14 23:57:07.229786
55	1+1	multiple_choice	2	10	2025-10-15 08:56:28.930381	2025-10-15 08:56:28.930381
55	2+2	multiple_choice	1	11	2025-10-15 08:56:36.549296	2025-10-15 08:56:36.549296
35	My mock test	multiple_choice	2	12	2025-10-15 18:18:52.701374	2025-10-15 18:18:52.701374
56	what is 5*5?	multiple_choice	3	13	2025-10-15 18:23:44.471962	2025-10-15 18:23:44.471962
57	What's need to get everything done on time?	multiple_choice	1	14	2026-06-09 17:27:56.681727	2026-06-09 17:27:56.681727
\.


--
-- Data for Name: questions_for_qna; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.questions_for_qna (id, title, body, author_id, subject_id, created_at, updated_at) FROM stdin;
3	What is the Pythagorean theorem?	Can someone explain it with a simple example?	fb660273-0b1d-4e81-bab0-750375a0dabb	1	2025-09-24 18:00:29.367335	2025-09-24 18:00:29.367335
4	what is 1+1?	mathematics	1ba29a2b-18ff-424e-80fc-7be85f35fe88	36	2025-10-03 22:48:07.541332	2025-10-03 22:48:07.541332
5	what math	please it  this ASAP!	1ba29a2b-18ff-424e-80fc-7be85f35fe88	36	2025-10-03 22:54:54.935711	2025-10-03 22:54:54.935711
6	3/3	division	1ba29a2b-18ff-424e-80fc-7be85f35fe88	36	2025-10-03 23:16:55.416517	2025-10-03 23:16:55.416517
7	4*4		1ba29a2b-18ff-424e-80fc-7be85f35fe88	36	2025-10-03 23:20:26.184178	2025-10-03 23:20:26.184178
8	How do I solve quadratic equations?	Topic 1	1ba29a2b-18ff-424e-80fc-7be85f35fe88	36	2025-10-03 23:38:30.644373	2025-10-03 23:38:30.644373
9	356/54		f7b14aa3-bd9f-4ad9-95bf-525f504dcc47	36	2025-10-04 03:24:00.572004	2025-10-04 03:24:00.572004
10	IsiZulu okanye Isixhosa		f7b14aa3-bd9f-4ad9-95bf-525f504dcc47	34	2025-10-04 03:28:01.520363	2025-10-04 03:28:01.520363
11	Newton's law, Any one please explain!		f7b14aa3-bd9f-4ad9-95bf-525f504dcc47	6	2025-10-04 03:29:28.211351	2025-10-04 03:29:28.211351
12	ww	ff	f7b14aa3-bd9f-4ad9-95bf-525f504dcc47	36	2025-10-04 04:37:35.117701	2025-10-04 04:37:35.117701
13	Tell me the difference between Objects and methos. Any one please 		f7b14aa3-bd9f-4ad9-95bf-525f504dcc47	36	2025-10-06 21:02:00.795401	2025-10-06 21:02:00.795401
14	What is life ??	LO TOPIC 1	1ba29a2b-18ff-424e-80fc-7be85f35fe88	33	2025-10-07 18:12:39.283971	2025-10-07 18:12:39.283971
15	what is Data Structures	please help	1ba29a2b-18ff-424e-80fc-7be85f35fe88	36	2025-10-09 18:47:46.055618	2025-10-09 18:47:46.055618
16	test question		1ba29a2b-18ff-424e-80fc-7be85f35fe88	36	2025-10-13 21:08:37.76288	2025-10-13 21:08:37.76288
17	What is 3*3=?		1ba29a2b-18ff-424e-80fc-7be85f35fe88	1	2025-10-13 21:11:20.200352	2025-10-13 21:11:20.200352
18	hfhfhfhfh		74160f33-5fc8-431a-9d10-a8365662a230	1	2025-10-15 18:38:45.013681	2025-10-15 18:38:45.013681
19	uehfjhkdsvbjcv		74160f33-5fc8-431a-9d10-a8365662a230	1	2025-10-15 18:39:34.753224	2025-10-15 18:39:34.753224
\.


--
-- Data for Name: resources; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.resources (id, topic_id, type, title, url, file_path, created_at) FROM stdin;
25	37	pdf	Slides 	\N	uploads\\1757675783290-986338806-Mr%20jamjam%20resume%20.pdf	2025-09-12 13:16:23.463691
27	37	word	My resume 	\N	uploads\\1757675838778-420002288-Mr-jamjam-resume.docx	2025-09-12 13:17:19.08515
28	36	pdf	Slides	\N	uploads\\1757678878112-323135629-Odyssey-past-Question.pdf	2025-09-12 14:08:07.502141
29	37	pdf	My files 	\N	uploads\\1757680335487-246772054-Get_Your_Device_Ready.pdf	2025-09-12 14:32:16.670905
32	38	pdf	Slides 	\N	uploads\\1759839986268-509915552-Mr%20jamjam%20resume%20.pdf	2025-10-07 14:26:26.438244
33	36	pdf	File 2	\N	uploads\\1759843995060-315439352-Get_Your_Device_Ready.pdf	2025-10-07 15:33:15.508609
34	38	pdf	Topic1 slides	\N	uploads\\1759849667367-740964107-Get_Your_Device_Ready%202.pdf	2025-10-07 17:07:47.970619
35	36	video	Video 1	\N	uploads\\1759855606317-556575225-8c075eb5-dbe8-41d4-b37d-683dcebd4589.MP4	2025-10-07 18:46:47.428792
36	36	document	Word file	\N	uploads\\1759866144203-174807888-Developer%20Task%20Assignment.docx	2025-10-07 21:42:24.534601
37	43	pdf	Slides	\N	uploads\\1760987802800-928792556-Careers.pdf	2025-10-20 21:16:44.745335
39	46	pdf	Slides	\N	uploads\\1781612025048-365233841-Tickets_Prices_%20pdf.pdf	2026-06-16 14:13:48.244832
\.


--
-- Data for Name: student_app_visits; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.student_app_visits (id, student_id, login_time, logout_time, session_duration, pages_visited, device_type, app_version, created_at) FROM stdin;
\.


--
-- Data for Name: student_assessments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.student_assessments (id, student_id, assessment_id, submitted_at, score, answers) FROM stdin;
5	1ba29a2b-18ff-424e-80fc-7be85f35fe88	32	2025-10-14 23:04:56.514638	1	[{"question_id": 6, "selected_option_id": 2}]
6	1ba29a2b-18ff-424e-80fc-7be85f35fe88	55	2025-10-15 09:58:55.843868	3	[{"question_id": 10, "selected_option_id": 11}, {"question_id": 11, "selected_option_id": 13}]
7	1ba29a2b-18ff-424e-80fc-7be85f35fe88	35	2025-10-15 18:33:48.133431	5	[{"question_id": 9, "selected_option_id": 7}, {"question_id": 12, "selected_option_id": 15}]
8	1ba29a2b-18ff-424e-80fc-7be85f35fe88	56	2025-10-15 18:34:51.617818	5	[{"question_id": 9, "selected_option_id": 7}, {"question_id": 12, "selected_option_id": 15}, {"question_id": 13, "selected_option_id": 21}]
\.


--
-- Data for Name: student_subjects; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.student_subjects (id, student_id, subject_id, enrolled_at) FROM stdin;
6	1ba29a2b-18ff-424e-80fc-7be85f35fe88	12	2025-09-12 10:06:51.492655
10	1ba29a2b-18ff-424e-80fc-7be85f35fe88	1	2025-09-12 10:07:59.853735
11	1ba29a2b-18ff-424e-80fc-7be85f35fe88	6	2025-09-12 10:08:02.543584
21	1ba29a2b-18ff-424e-80fc-7be85f35fe88	35	2025-09-18 16:40:45.444367
24	f7b14aa3-bd9f-4ad9-95bf-525f504dcc47	36	2025-10-04 02:49:02.301604
26	f7b14aa3-bd9f-4ad9-95bf-525f504dcc47	33	2025-10-07 18:11:04.603696
27	f7b14aa3-bd9f-4ad9-95bf-525f504dcc47	35	2025-10-15 00:03:08.651871
29	f7b14aa3-bd9f-4ad9-95bf-525f504dcc47	1	2025-10-15 18:26:56.083593
30	f7b14aa3-bd9f-4ad9-95bf-525f504dcc47	34	2025-10-15 18:28:56.9141
39	1ba29a2b-18ff-424e-80fc-7be85f35fe88	34	2026-03-10 16:30:41.358305
\.


--
-- Data for Name: students; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.students (id, full_name, email, phone_number, password_hash, role, is_verified, grade_level, class_name, parent_id, created_at, google_id, facebook_id, verification_token) FROM stdin;
fe6fb89b-f367-486a-a479-ef6c8cc4afb4	Test Student	test.student@example.com	\N	\N	student	f	10	Grade 10A	\N	2025-09-18 15:38:21.856583	\N	\N	\N
f7b14aa3-bd9f-4ad9-95bf-525f504dcc47	luvo	luvo@mail.com	\N	\N	student	t	\N	\N	1fd1d960-ee5d-40f7-882f-c8f6d43ae32a	2025-10-13 22:43:28.023993	\N	\N	\N
1ba29a2b-18ff-424e-80fc-7be85f35fe88	alice	alice@test.com	\N	\N	student	t	\N	\N	1fd1d960-ee5d-40f7-882f-c8f6d43ae32a	2025-10-13 22:43:45.827517	\N	\N	\N
93212f46-d9a7-4f5f-93d8-ad377cbfdafa	ajaymaurice	ajaymaurice305@gmail.com	\N	\N	student	t	\N	\N	1fd1d960-ee5d-40f7-882f-c8f6d43ae32a	2025-10-13 22:49:39.519545	\N	\N	\N
\.


--
-- Data for Name: subjects; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subjects (id, name, description, grade, updated_at, created_at) FROM stdin;
12	Life sciences	\N	\N	2025-10-21 13:21:12.050996	2025-10-21 13:21:23.190315
33	LO	\N	\N	2025-10-21 13:21:12.050996	2025-10-21 13:21:23.190315
34	isiZulu	\N	\N	2025-10-21 13:21:12.050996	2025-10-21 13:21:23.190315
36	Java	\N	\N	2025-10-21 13:21:12.050996	2025-10-21 13:21:23.190315
37	Python	\N	\N	2025-10-21 13:21:12.050996	2025-10-21 13:21:23.190315
35	English	\N	12	2025-10-21 13:23:35.704975	2025-10-21 13:21:23.190315
38	Fullstake	\N	\N	2026-06-09 17:14:49.06673	2026-06-09 17:14:49.06673
1	Mathematics 	\N	Grade 10	2025-10-21 13:21:12.050996	2025-10-21 13:21:23.190315
6	Physical Science	\N	\N	2025-10-21 13:21:12.050996	2025-10-21 13:21:23.190315
\.


--
-- Data for Name: submissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.submissions (assessment_id, student_id, score, submitted_at, id) FROM stdin;
\.


--
-- Data for Name: suggested_questions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.suggested_questions (id, subject_id, question_text, options, correct_option, suggested_by, created_at) FROM stdin;
\.


--
-- Data for Name: topics; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topics (id, name, description, group_id, subject_id) FROM stdin;
36	Yyyy	\N	\N	1
37	my topic	\N	\N	12
38	My first topic	\N	\N	35
39	How to speak fluently 	\N	\N	35
40	algi	\N	\N	1
41	102	\N	\N	36
42	Zulu101	\N	\N	34
43	Comp100	\N	\N	37
46	Reading	\N	\N	35
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, full_name, email, phone_number, password_hash, role, is_verified, created_at, google_id, facebook_id, verification_token, updated_at, secondary_email, phone, bio) FROM stdin;
d4a85808-f9de-4597-8364-b957d71ffe3e	ukzn durban	jamjamx@ukzn.ac.za	\N	$2b$10$Rq8u6W8eKoZXXAzox0206.EAnAtZ4zSXzmSPXAv.iRoMI5Z/dhSYi	admin	t	2025-08-21 22:20:20.173252	\N	\N	\N	2025-09-21 15:20:27.657473	\N	\N	\N
fb660273-0b1d-4e81-bab0-750375a0dabb	jamjam xolisani	jayxolisani@gmail.com	\N	$2b$10$4FFEeGDT8bYSaRAfBcPcieezpp7yQwR4y9EJwh.6wFmRJfU6Iia.2	admin	t	2025-08-21 22:36:07.125653	\N	\N	\N	2025-09-21 15:20:27.657473	\N	\N	\N
74160f33-5fc8-431a-9d10-a8365662a230	Bob	bob@test.com	\N	$2b$10$YtyyBl4FtjoZpGOiDC2gJ.hZ50EpD126jxHOiyxvwhNVSAaQV7uIq	teacher	t	2025-08-22 12:08:16.658086	\N	\N	\N	2025-09-21 15:20:27.657473	\N	\N	\N
1fd1d960-ee5d-40f7-882f-c8f6d43ae32a	Carol	carol@test.com	\N	$2b$10$LFTZ/f4hNd8Ei1PA8UXIm.JPh/YFQ4HxyRaO//.p0DW5W48tGL0Dm	parent	t	2025-08-22 12:09:59.356636	\N	\N	\N	2025-09-21 15:20:27.657473	\N	\N	\N
5deb41da-2a17-4f2f-b1c3-193594b96ed4	jay	jay@test.com	\N	$2b$10$Y7oEuRNXKVQff.2NxLhbRe8C5CMGKrHDMlTJsKN5yo8k.4eM21kiy	admin	t	2025-08-22 12:11:44.100692	\N	\N	\N	2025-09-21 15:20:27.657473	\N	\N	\N
93212f46-d9a7-4f5f-93d8-ad377cbfdafa	ajaymaurice	ajaymaurice305@gmail.com	\N	$2b$10$C6xpeBrDIfH4PBTpX3JF9O3uBW6zn2w4fYP.V/HB6e5YWhFl7tFaK	student	t	2025-09-01 17:49:35.988845	\N	\N	\N	2025-09-21 15:20:27.657473	\N	\N	\N
b629eadb-6ffc-4286-bcc6-da12380ca044	LindoKuhle 	lindokuhlesbekezelonsele@gmail.com	\N	$2b$10$o22P3A1I6s0CnMLVJD6tlelCph6VhISBTbkHg2PMQTOl0sgl.EmjC	admin	f	2025-09-02 18:28:17.274155	\N	\N	91ff72545c752ffa4b128ce1521859afe435ced7d3afb0feb0dfb67e5885fd6f	2025-09-21 15:20:27.657473	\N	\N	\N
8a510f0d-fc1e-41af-996d-e592e9e295f7	Xolisani JamJam	lindokuhlesibekezelonsele@gmail.com	\N	$2b$10$2V769cIUJgFMf.xpZPKXmeO.6wENghv5JZABp6khy2BWi9bv4Ugx2	admin	t	2025-09-02 18:14:39.977067	\N	\N	\N	2025-09-21 15:20:27.657473	\N	\N	\N
40d6785b-7515-45a7-a68b-9cbffc51335b	zandi jamjam	zandi@mail.com	\N	$2b$10$L41mEk.Abx2NnIG0ZOZBxeyR2nYlSvaOETnX7C5Gfk5NHcHqCcaQu	parent	t	2025-09-21 15:13:38.763009	\N	\N	\N	2025-09-21 15:21:44.75334	\N	\N	\N
b71294dc-bf22-430b-90da-42b878a52b20	Yolanda Hlofela	yolanda@mail.com	\N	$2b$10$ivTN5iL0vz1a/WWqNW6APeybGRwlS5ZOH1evxbkdRpjJdSCdzvsgi	parent	t	2025-09-22 15:23:27.190476	\N	\N	\N	2025-09-22 15:24:29.740651	\N	\N	\N
f7b14aa3-bd9f-4ad9-95bf-525f504dcc47	luvo	luvo@mail.com	\N	$2b$10$sZIBmX1s3KSYNhYDhIkG3.fkh.fBMY0cMBh/l1YUYMeaAKrQlRrCm	student	t	2025-10-03 22:57:29.760863	\N	\N	\N	2025-10-03 23:01:34.19564	\N	\N	\N
1ba29a2b-18ff-424e-80fc-7be85f35fe88	alice John	alice@test.com	\N	$2b$10$oXSUG6jmypv6AT9aHHX8OeAuh6tkwqpBmqXsUJLgIvJIGWmsVcj9q	student	t	2025-08-22 12:06:19.860132	\N	\N	\N	2026-03-10 12:14:35.966299	aliceJohn@test.com	0661839801	I am Alice John
ee6257ea-0bef-4593-9e6d-fdfb664eadcb	XOLISANI JAMJAM	jamjamxolisani@gmail.com	\N	\N	\N	f	2026-03-31 18:16:29.049941	\N	\N	\N	2026-03-31 18:16:29.049941	\N	\N	\N
2be43be4-1058-4832-b805-f8186f81e8dc	Lindokuhle	uthandolwemfundo25@gmail.com	\N	\N	\N	f	2026-03-31 18:18:47.460258	\N	\N	\N	2026-03-31 18:18:47.460258	\N	\N	\N
\.


--
-- Data for Name: verification_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.verification_tokens (id, user_id, token, expires_at, created_at) FROM stdin;
\.


--
-- Name: answers_for_qna_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.answers_for_qna_id_seq', 17, true);


--
-- Name: assessment_answers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.assessment_answers_id_seq', 1, false);


--
-- Name: assessment_submissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.assessment_submissions_id_seq', 1, false);


--
-- Name: assessments_id_new_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.assessments_id_new_seq', 57, true);


--
-- Name: comments_for_qna_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.comments_for_qna_id_seq', 5, true);


--
-- Name: groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.groups_id_seq', 17, true);


--
-- Name: options_id_new_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.options_id_new_seq', 4, true);


--
-- Name: question_options_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.question_options_id_seq', 21, true);


--
-- Name: question_views_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.question_views_id_seq', 386, true);


--
-- Name: questions_for_qna_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.questions_for_qna_id_seq', 19, true);


--
-- Name: questions_id_new_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.questions_id_new_seq', 14, true);


--
-- Name: resources_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.resources_id_seq', 39, true);


--
-- Name: student_assessments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.student_assessments_id_seq', 8, true);


--
-- Name: student_subjects_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.student_subjects_id_seq', 40, true);


--
-- Name: subjects_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.subjects_id_seq', 38, true);


--
-- Name: submissions_id_new_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.submissions_id_new_seq', 1, false);


--
-- Name: suggested_questions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.suggested_questions_id_seq', 1, false);


--
-- Name: topics_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.topics_id_seq', 46, true);


--
-- Name: activities activities_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_pkey PRIMARY KEY (id);


--
-- Name: answers_for_qna answers_for_qna_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.answers_for_qna
    ADD CONSTRAINT answers_for_qna_pkey PRIMARY KEY (id);


--
-- Name: assessment_answers assessment_answers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assessment_answers
    ADD CONSTRAINT assessment_answers_pkey PRIMARY KEY (id);


--
-- Name: assessment_submissions assessment_submissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assessment_submissions
    ADD CONSTRAINT assessment_submissions_pkey PRIMARY KEY (id);


--
-- Name: assessments assessments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assessments
    ADD CONSTRAINT assessments_pkey PRIMARY KEY (id);


--
-- Name: attendance_records attendance_records_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance_records
    ADD CONSTRAINT attendance_records_pkey PRIMARY KEY (id);


--
-- Name: comments_for_qna comments_for_qna_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comments_for_qna
    ADD CONSTRAINT comments_for_qna_pkey PRIMARY KEY (id);


--
-- Name: groups groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: options options_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.options
    ADD CONSTRAINT options_pkey PRIMARY KEY (id);


--
-- Name: parent_children parent_children_parent_id_child_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parent_children
    ADD CONSTRAINT parent_children_parent_id_child_id_key UNIQUE (parent_id, child_id);


--
-- Name: parent_children parent_children_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parent_children
    ADD CONSTRAINT parent_children_pkey PRIMARY KEY (id);


--
-- Name: password_reset_tokens password_reset_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.password_reset_tokens
    ADD CONSTRAINT password_reset_tokens_pkey PRIMARY KEY (id);


--
-- Name: question_options question_options_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.question_options
    ADD CONSTRAINT question_options_pkey PRIMARY KEY (id);


--
-- Name: question_views question_views_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.question_views
    ADD CONSTRAINT question_views_pkey PRIMARY KEY (id);


--
-- Name: question_views question_views_question_id_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.question_views
    ADD CONSTRAINT question_views_question_id_user_id_key UNIQUE (question_id, user_id);


--
-- Name: questions_for_qna questions_for_qna_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.questions_for_qna
    ADD CONSTRAINT questions_for_qna_pkey PRIMARY KEY (id);


--
-- Name: questions questions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.questions
    ADD CONSTRAINT questions_pkey PRIMARY KEY (id);


--
-- Name: resources resources_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resources
    ADD CONSTRAINT resources_pkey PRIMARY KEY (id);


--
-- Name: student_app_visits student_app_visits_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_app_visits
    ADD CONSTRAINT student_app_visits_pkey PRIMARY KEY (id);


--
-- Name: student_assessments student_assessments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_assessments
    ADD CONSTRAINT student_assessments_pkey PRIMARY KEY (id);


--
-- Name: student_assessments student_assessments_student_id_assessment_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_assessments
    ADD CONSTRAINT student_assessments_student_id_assessment_id_key UNIQUE (student_id, assessment_id);


--
-- Name: student_subjects student_subjects_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_subjects
    ADD CONSTRAINT student_subjects_pkey PRIMARY KEY (id);


--
-- Name: student_subjects student_subjects_student_id_subject_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_subjects
    ADD CONSTRAINT student_subjects_student_id_subject_id_key UNIQUE (student_id, subject_id);


--
-- Name: students students_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_email_key UNIQUE (email);


--
-- Name: students students_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_pkey PRIMARY KEY (id);


--
-- Name: subjects subjects_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT subjects_pkey PRIMARY KEY (id);


--
-- Name: submissions submissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.submissions
    ADD CONSTRAINT submissions_pkey PRIMARY KEY (id);


--
-- Name: suggested_questions suggested_questions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suggested_questions
    ADD CONSTRAINT suggested_questions_pkey PRIMARY KEY (id);


--
-- Name: topics topics_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.topics
    ADD CONSTRAINT topics_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: verification_tokens verification_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.verification_tokens
    ADD CONSTRAINT verification_tokens_pkey PRIMARY KEY (id);


--
-- Name: idx_assessments_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_assessments_created_by ON public.assessments USING btree (created_by);


--
-- Name: idx_assessments_subject_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_assessments_subject_id ON public.assessments USING btree (subject_id);


--
-- Name: idx_comments_answer_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_comments_answer_id ON public.comments_for_qna USING btree (answer_id);


--
-- Name: idx_comments_author_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_comments_author_id ON public.comments_for_qna USING btree (author_id);


--
-- Name: idx_question_options_question_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_question_options_question_id ON public.question_options USING btree (question_id);


--
-- Name: idx_question_views_question; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_question_views_question ON public.question_views USING btree (question_id);


--
-- Name: idx_question_views_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_question_views_user ON public.question_views USING btree (user_id);


--
-- Name: idx_questions_assessment_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_questions_assessment_id ON public.questions USING btree (assessment_id);


--
-- Name: idx_student_assessments_assessment; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_student_assessments_assessment ON public.student_assessments USING btree (assessment_id);


--
-- Name: idx_student_assessments_student; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_student_assessments_student ON public.student_assessments USING btree (student_id);


--
-- Name: idx_student_visits_login_time; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_student_visits_login_time ON public.student_app_visits USING btree (login_time);


--
-- Name: idx_student_visits_student_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_student_visits_student_date ON public.student_app_visits USING btree (student_id, login_time);


--
-- Name: idx_student_visits_student_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_student_visits_student_id ON public.student_app_visits USING btree (student_id);


--
-- Name: users set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: assessments update_assessments_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_assessments_updated_at BEFORE UPDATE ON public.assessments FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: questions update_questions_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_questions_updated_at BEFORE UPDATE ON public.questions FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: subjects update_subjects_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_subjects_updated_at BEFORE UPDATE ON public.subjects FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: users update_users_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: activities activities_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.students(id) ON DELETE CASCADE;


--
-- Name: answers_for_qna answers_for_qna_author_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.answers_for_qna
    ADD CONSTRAINT answers_for_qna_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: answers_for_qna answers_for_qna_question_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.answers_for_qna
    ADD CONSTRAINT answers_for_qna_question_id_fkey FOREIGN KEY (question_id) REFERENCES public.questions_for_qna(id) ON DELETE CASCADE;


--
-- Name: assessment_answers assessment_answers_question_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assessment_answers
    ADD CONSTRAINT assessment_answers_question_id_fkey FOREIGN KEY (question_id) REFERENCES public.questions(id);


--
-- Name: assessment_answers assessment_answers_selected_option_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assessment_answers
    ADD CONSTRAINT assessment_answers_selected_option_fkey FOREIGN KEY (selected_option) REFERENCES public.options(id);


--
-- Name: assessment_answers assessment_answers_submission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assessment_answers
    ADD CONSTRAINT assessment_answers_submission_id_fkey FOREIGN KEY (submission_id) REFERENCES public.assessment_submissions(id) ON DELETE CASCADE;


--
-- Name: assessment_submissions assessment_submissions_assessment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assessment_submissions
    ADD CONSTRAINT assessment_submissions_assessment_id_fkey FOREIGN KEY (assessment_id) REFERENCES public.assessments(id) ON DELETE CASCADE;


--
-- Name: assessments assessments_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assessments
    ADD CONSTRAINT assessments_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: assessments assessments_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assessments
    ADD CONSTRAINT assessments_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups(id) ON DELETE CASCADE;


--
-- Name: assessments assessments_subject_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assessments
    ADD CONSTRAINT assessments_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES public.subjects(id) ON DELETE CASCADE;


--
-- Name: attendance_records attendance_records_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance_records
    ADD CONSTRAINT attendance_records_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.students(id) ON DELETE CASCADE;


--
-- Name: comments_for_qna comments_for_qna_answer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comments_for_qna
    ADD CONSTRAINT comments_for_qna_answer_id_fkey FOREIGN KEY (answer_id) REFERENCES public.answers_for_qna(id) ON DELETE CASCADE;


--
-- Name: comments_for_qna comments_for_qna_author_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comments_for_qna
    ADD CONSTRAINT comments_for_qna_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: groups groups_subject_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES public.subjects(id) ON DELETE CASCADE;


--
-- Name: options options_question_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.options
    ADD CONSTRAINT options_question_id_fkey FOREIGN KEY (question_id) REFERENCES public.questions(id) ON DELETE CASCADE;


--
-- Name: parent_children parent_children_child_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parent_children
    ADD CONSTRAINT parent_children_child_id_fkey FOREIGN KEY (child_id) REFERENCES public.students(id) ON DELETE CASCADE;


--
-- Name: parent_children parent_children_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parent_children
    ADD CONSTRAINT parent_children_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: password_reset_tokens password_reset_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.password_reset_tokens
    ADD CONSTRAINT password_reset_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: question_options question_options_question_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.question_options
    ADD CONSTRAINT question_options_question_id_fkey FOREIGN KEY (question_id) REFERENCES public.questions(id) ON DELETE CASCADE;


--
-- Name: question_views question_views_question_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.question_views
    ADD CONSTRAINT question_views_question_id_fkey FOREIGN KEY (question_id) REFERENCES public.questions_for_qna(id) ON DELETE CASCADE;


--
-- Name: question_views question_views_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.question_views
    ADD CONSTRAINT question_views_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: questions questions_assessment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.questions
    ADD CONSTRAINT questions_assessment_id_fkey FOREIGN KEY (assessment_id) REFERENCES public.assessments(id) ON DELETE CASCADE;


--
-- Name: questions_for_qna questions_for_qna_author_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.questions_for_qna
    ADD CONSTRAINT questions_for_qna_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: questions_for_qna questions_for_qna_subject_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.questions_for_qna
    ADD CONSTRAINT questions_for_qna_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES public.subjects(id) ON DELETE CASCADE;


--
-- Name: resources resources_topic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resources
    ADD CONSTRAINT resources_topic_id_fkey FOREIGN KEY (topic_id) REFERENCES public.topics(id) ON DELETE CASCADE;


--
-- Name: student_app_visits student_app_visits_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_app_visits
    ADD CONSTRAINT student_app_visits_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.students(id) ON DELETE CASCADE;


--
-- Name: student_assessments student_assessments_assessment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_assessments
    ADD CONSTRAINT student_assessments_assessment_id_fkey FOREIGN KEY (assessment_id) REFERENCES public.assessments(id) ON DELETE CASCADE;


--
-- Name: student_assessments student_assessments_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_assessments
    ADD CONSTRAINT student_assessments_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: student_subjects student_subjects_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_subjects
    ADD CONSTRAINT student_subjects_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: student_subjects student_subjects_subject_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_subjects
    ADD CONSTRAINT student_subjects_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES public.subjects(id) ON DELETE CASCADE;


--
-- Name: students students_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: submissions submissions_assessment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.submissions
    ADD CONSTRAINT submissions_assessment_id_fkey FOREIGN KEY (assessment_id) REFERENCES public.assessments(id) ON DELETE CASCADE;


--
-- Name: submissions submissions_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.submissions
    ADD CONSTRAINT submissions_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: suggested_questions suggested_questions_subject_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suggested_questions
    ADD CONSTRAINT suggested_questions_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES public.subjects(id) ON DELETE CASCADE;


--
-- Name: suggested_questions suggested_questions_suggested_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suggested_questions
    ADD CONSTRAINT suggested_questions_suggested_by_fkey FOREIGN KEY (suggested_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: topics topics_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.topics
    ADD CONSTRAINT topics_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups(id) ON DELETE CASCADE;


--
-- Name: topics topics_subject_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.topics
    ADD CONSTRAINT topics_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES public.subjects(id) ON DELETE CASCADE;


--
-- Name: verification_tokens verification_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.verification_tokens
    ADD CONSTRAINT verification_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT ALL ON SCHEMA public TO jamjamx;


--
-- Name: TABLE activities; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.activities TO jamjamx;


--
-- Name: TABLE answers_for_qna; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.answers_for_qna TO jamjamx;


--
-- Name: SEQUENCE answers_for_qna_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.answers_for_qna_id_seq TO jamjamx;


--
-- Name: TABLE assessment_answers; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.assessment_answers TO jamjamx;


--
-- Name: SEQUENCE assessment_answers_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.assessment_answers_id_seq TO jamjamx;


--
-- Name: TABLE assessment_submissions; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.assessment_submissions TO jamjamx;


--
-- Name: SEQUENCE assessment_submissions_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.assessment_submissions_id_seq TO jamjamx;


--
-- Name: TABLE assessments; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.assessments TO jamjamx;


--
-- Name: SEQUENCE assessments_id_new_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.assessments_id_new_seq TO jamjamx;


--
-- Name: TABLE attendance_records; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.attendance_records TO jamjamx;


--
-- Name: TABLE comments_for_qna; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.comments_for_qna TO jamjamx;


--
-- Name: SEQUENCE comments_for_qna_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.comments_for_qna_id_seq TO jamjamx;


--
-- Name: TABLE groups; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.groups TO jamjamx;


--
-- Name: SEQUENCE groups_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.groups_id_seq TO jamjamx;


--
-- Name: TABLE options; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.options TO jamjamx;


--
-- Name: SEQUENCE options_id_new_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.options_id_new_seq TO jamjamx;


--
-- Name: TABLE parent_children; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.parent_children TO jamjamx;


--
-- Name: TABLE password_reset_tokens; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.password_reset_tokens TO jamjamx;


--
-- Name: TABLE question_options; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.question_options TO jamjamx;


--
-- Name: SEQUENCE question_options_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.question_options_id_seq TO jamjamx;


--
-- Name: TABLE question_views; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.question_views TO jamjamx;


--
-- Name: SEQUENCE question_views_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.question_views_id_seq TO jamjamx;


--
-- Name: TABLE questions; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.questions TO jamjamx;


--
-- Name: TABLE questions_for_qna; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.questions_for_qna TO jamjamx;


--
-- Name: SEQUENCE questions_for_qna_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.questions_for_qna_id_seq TO jamjamx;


--
-- Name: SEQUENCE questions_id_new_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.questions_id_new_seq TO jamjamx;


--
-- Name: TABLE resources; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.resources TO jamjamx;


--
-- Name: SEQUENCE resources_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.resources_id_seq TO jamjamx;


--
-- Name: TABLE student_app_visits; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.student_app_visits TO jamjamx;


--
-- Name: TABLE student_assessments; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.student_assessments TO jamjamx;


--
-- Name: SEQUENCE student_assessments_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.student_assessments_id_seq TO jamjamx;


--
-- Name: TABLE student_subjects; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.student_subjects TO jamjamx;


--
-- Name: SEQUENCE student_subjects_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.student_subjects_id_seq TO jamjamx;


--
-- Name: TABLE students; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.students TO jamjamx;


--
-- Name: TABLE subjects; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.subjects TO jamjamx;


--
-- Name: SEQUENCE subjects_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.subjects_id_seq TO jamjamx;


--
-- Name: TABLE submissions; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.submissions TO jamjamx;


--
-- Name: SEQUENCE submissions_id_new_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.submissions_id_new_seq TO jamjamx;


--
-- Name: TABLE suggested_questions; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.suggested_questions TO jamjamx;


--
-- Name: SEQUENCE suggested_questions_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.suggested_questions_id_seq TO jamjamx;


--
-- Name: TABLE topics; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.topics TO jamjamx;


--
-- Name: SEQUENCE topics_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.topics_id_seq TO jamjamx;


--
-- Name: TABLE users; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.users TO jamjamx;


--
-- Name: TABLE verification_tokens; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.verification_tokens TO jamjamx;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT,USAGE ON SEQUENCES TO jamjamx;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO jamjamx;


--
-- PostgreSQL database dump complete
--

