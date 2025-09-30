--
-- PostgreSQL database dump
--

-- Dumped from database version 16.10 (Ubuntu 16.10-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 17.1

-- Started on 2025-09-30 09:47:17

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
-- TOC entry 5 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: kardly_prod_user
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO kardly_prod_user;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 218 (class 1259 OID 21415)
-- Name: albums; Type: TABLE; Schema: public; Owner: kardly_prod_user
--

CREATE TABLE public.albums (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    group_id uuid,
    title character varying(200) NOT NULL,
    cover_image_url text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.albums OWNER TO kardly_prod_user;

--
-- TOC entry 217 (class 1259 OID 21400)
-- Name: group_members; Type: TABLE; Schema: public; Owner: kardly_prod_user
--

CREATE TABLE public.group_members (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    group_id uuid,
    name character varying(100) NOT NULL,
    stage_name character varying(100),
    image_url text,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.group_members OWNER TO kardly_prod_user;

--
-- TOC entry 216 (class 1259 OID 21390)
-- Name: kpop_groups; Type: TABLE; Schema: public; Owner: kardly_prod_user
--

CREATE TABLE public.kpop_groups (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(100) NOT NULL,
    image_url text,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.kpop_groups OWNER TO kardly_prod_user;

--
-- TOC entry 219 (class 1259 OID 21429)
-- Name: photocards; Type: TABLE; Schema: public; Owner: kardly_prod_user
--

CREATE TABLE public.photocards (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    group_id uuid,
    member_id uuid,
    album_id uuid,
    image_url text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.photocards OWNER TO kardly_prod_user;

--
-- TOC entry 222 (class 1259 OID 21491)
-- Name: user_album_cards; Type: TABLE; Schema: public; Owner: kardly_prod_user
--

CREATE TABLE public.user_album_cards (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    album_id uuid,
    photocard_id uuid,
    "position" integer DEFAULT 0,
    added_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.user_album_cards OWNER TO kardly_prod_user;

--
-- TOC entry 221 (class 1259 OID 21476)
-- Name: user_albums; Type: TABLE; Schema: public; Owner: kardly_prod_user
--

CREATE TABLE public.user_albums (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    title character varying(200) NOT NULL,
    cover_image_urls text[],
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.user_albums OWNER TO kardly_prod_user;

--
-- TOC entry 220 (class 1259 OID 21454)
-- Name: user_collections; Type: TABLE; Schema: public; Owner: kardly_prod_user
--

CREATE TABLE public.user_collections (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    photocard_id uuid,
    is_owned boolean DEFAULT false,
    is_wishlisted boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.user_collections OWNER TO kardly_prod_user;

--
-- TOC entry 215 (class 1259 OID 21374)
-- Name: users; Type: TABLE; Schema: public; Owner: kardly_prod_user
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email character varying(255) NOT NULL,
    username character varying(50) NOT NULL,
    password_hash character varying(255) NOT NULL,
    bio text,
    is_premium boolean DEFAULT false,
    premium_expires_at timestamp without time zone,
    email_verified boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.users OWNER TO kardly_prod_user;

--
-- TOC entry 3319 (class 2606 OID 21423)
-- Name: albums albums_pkey; Type: CONSTRAINT; Schema: public; Owner: kardly_prod_user
--

ALTER TABLE ONLY public.albums
    ADD CONSTRAINT albums_pkey PRIMARY KEY (id);


--
-- TOC entry 3317 (class 2606 OID 21409)
-- Name: group_members group_members_pkey; Type: CONSTRAINT; Schema: public; Owner: kardly_prod_user
--

ALTER TABLE ONLY public.group_members
    ADD CONSTRAINT group_members_pkey PRIMARY KEY (id);


--
-- TOC entry 3315 (class 2606 OID 21399)
-- Name: kpop_groups kpop_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: kardly_prod_user
--

ALTER TABLE ONLY public.kpop_groups
    ADD CONSTRAINT kpop_groups_pkey PRIMARY KEY (id);


--
-- TOC entry 3324 (class 2606 OID 21438)
-- Name: photocards photocards_pkey; Type: CONSTRAINT; Schema: public; Owner: kardly_prod_user
--

ALTER TABLE ONLY public.photocards
    ADD CONSTRAINT photocards_pkey PRIMARY KEY (id);


--
-- TOC entry 3336 (class 2606 OID 21500)
-- Name: user_album_cards user_album_cards_album_id_photocard_id_key; Type: CONSTRAINT; Schema: public; Owner: kardly_prod_user
--

ALTER TABLE ONLY public.user_album_cards
    ADD CONSTRAINT user_album_cards_album_id_photocard_id_key UNIQUE (album_id, photocard_id);


--
-- TOC entry 3338 (class 2606 OID 21498)
-- Name: user_album_cards user_album_cards_pkey; Type: CONSTRAINT; Schema: public; Owner: kardly_prod_user
--

ALTER TABLE ONLY public.user_album_cards
    ADD CONSTRAINT user_album_cards_pkey PRIMARY KEY (id);


--
-- TOC entry 3334 (class 2606 OID 21485)
-- Name: user_albums user_albums_pkey; Type: CONSTRAINT; Schema: public; Owner: kardly_prod_user
--

ALTER TABLE ONLY public.user_albums
    ADD CONSTRAINT user_albums_pkey PRIMARY KEY (id);


--
-- TOC entry 3330 (class 2606 OID 21463)
-- Name: user_collections user_collections_pkey; Type: CONSTRAINT; Schema: public; Owner: kardly_prod_user
--

ALTER TABLE ONLY public.user_collections
    ADD CONSTRAINT user_collections_pkey PRIMARY KEY (id);


--
-- TOC entry 3332 (class 2606 OID 21465)
-- Name: user_collections user_collections_user_id_photocard_id_key; Type: CONSTRAINT; Schema: public; Owner: kardly_prod_user
--

ALTER TABLE ONLY public.user_collections
    ADD CONSTRAINT user_collections_user_id_photocard_id_key UNIQUE (user_id, photocard_id);


--
-- TOC entry 3309 (class 2606 OID 21387)
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: kardly_prod_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- TOC entry 3311 (class 2606 OID 21385)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: kardly_prod_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 3313 (class 2606 OID 21389)
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: kardly_prod_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- TOC entry 3320 (class 1259 OID 21522)
-- Name: idx_photocards_album_id; Type: INDEX; Schema: public; Owner: kardly_prod_user
--

CREATE INDEX idx_photocards_album_id ON public.photocards USING btree (album_id);


--
-- TOC entry 3321 (class 1259 OID 21520)
-- Name: idx_photocards_group_id; Type: INDEX; Schema: public; Owner: kardly_prod_user
--

CREATE INDEX idx_photocards_group_id ON public.photocards USING btree (group_id);


--
-- TOC entry 3322 (class 1259 OID 21521)
-- Name: idx_photocards_member_id; Type: INDEX; Schema: public; Owner: kardly_prod_user
--

CREATE INDEX idx_photocards_member_id ON public.photocards USING btree (member_id);


--
-- TOC entry 3325 (class 1259 OID 21525)
-- Name: idx_user_collections_is_owned; Type: INDEX; Schema: public; Owner: kardly_prod_user
--

CREATE INDEX idx_user_collections_is_owned ON public.user_collections USING btree (is_owned);


--
-- TOC entry 3326 (class 1259 OID 21526)
-- Name: idx_user_collections_is_wishlisted; Type: INDEX; Schema: public; Owner: kardly_prod_user
--

CREATE INDEX idx_user_collections_is_wishlisted ON public.user_collections USING btree (is_wishlisted);


--
-- TOC entry 3327 (class 1259 OID 21524)
-- Name: idx_user_collections_photocard_id; Type: INDEX; Schema: public; Owner: kardly_prod_user
--

CREATE INDEX idx_user_collections_photocard_id ON public.user_collections USING btree (photocard_id);


--
-- TOC entry 3328 (class 1259 OID 21523)
-- Name: idx_user_collections_user_id; Type: INDEX; Schema: public; Owner: kardly_prod_user
--

CREATE INDEX idx_user_collections_user_id ON public.user_collections USING btree (user_id);


--
-- TOC entry 3305 (class 1259 OID 21517)
-- Name: idx_users_email; Type: INDEX; Schema: public; Owner: kardly_prod_user
--

CREATE INDEX idx_users_email ON public.users USING btree (email);


--
-- TOC entry 3306 (class 1259 OID 21519)
-- Name: idx_users_is_premium; Type: INDEX; Schema: public; Owner: kardly_prod_user
--

CREATE INDEX idx_users_is_premium ON public.users USING btree (is_premium);


--
-- TOC entry 3307 (class 1259 OID 21518)
-- Name: idx_users_username; Type: INDEX; Schema: public; Owner: kardly_prod_user
--

CREATE INDEX idx_users_username ON public.users USING btree (username);


--
-- TOC entry 3340 (class 2606 OID 21424)
-- Name: albums albums_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kardly_prod_user
--

ALTER TABLE ONLY public.albums
    ADD CONSTRAINT albums_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.kpop_groups(id) ON DELETE CASCADE;


--
-- TOC entry 3339 (class 2606 OID 21410)
-- Name: group_members group_members_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kardly_prod_user
--

ALTER TABLE ONLY public.group_members
    ADD CONSTRAINT group_members_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.kpop_groups(id) ON DELETE CASCADE;


--
-- TOC entry 3341 (class 2606 OID 21449)
-- Name: photocards photocards_album_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kardly_prod_user
--

ALTER TABLE ONLY public.photocards
    ADD CONSTRAINT photocards_album_id_fkey FOREIGN KEY (album_id) REFERENCES public.albums(id) ON DELETE CASCADE;


--
-- TOC entry 3342 (class 2606 OID 21439)
-- Name: photocards photocards_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kardly_prod_user
--

ALTER TABLE ONLY public.photocards
    ADD CONSTRAINT photocards_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.kpop_groups(id) ON DELETE CASCADE;


--
-- TOC entry 3343 (class 2606 OID 21444)
-- Name: photocards photocards_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kardly_prod_user
--

ALTER TABLE ONLY public.photocards
    ADD CONSTRAINT photocards_member_id_fkey FOREIGN KEY (member_id) REFERENCES public.group_members(id) ON DELETE CASCADE;


--
-- TOC entry 3347 (class 2606 OID 21501)
-- Name: user_album_cards user_album_cards_album_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kardly_prod_user
--

ALTER TABLE ONLY public.user_album_cards
    ADD CONSTRAINT user_album_cards_album_id_fkey FOREIGN KEY (album_id) REFERENCES public.user_albums(id) ON DELETE CASCADE;


--
-- TOC entry 3348 (class 2606 OID 21506)
-- Name: user_album_cards user_album_cards_photocard_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kardly_prod_user
--

ALTER TABLE ONLY public.user_album_cards
    ADD CONSTRAINT user_album_cards_photocard_id_fkey FOREIGN KEY (photocard_id) REFERENCES public.photocards(id) ON DELETE CASCADE;


--
-- TOC entry 3346 (class 2606 OID 21486)
-- Name: user_albums user_albums_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kardly_prod_user
--

ALTER TABLE ONLY public.user_albums
    ADD CONSTRAINT user_albums_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 3344 (class 2606 OID 21471)
-- Name: user_collections user_collections_photocard_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kardly_prod_user
--

ALTER TABLE ONLY public.user_collections
    ADD CONSTRAINT user_collections_photocard_id_fkey FOREIGN KEY (photocard_id) REFERENCES public.photocards(id) ON DELETE CASCADE;


--
-- TOC entry 3345 (class 2606 OID 21466)
-- Name: user_collections user_collections_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kardly_prod_user
--

ALTER TABLE ONLY public.user_collections
    ADD CONSTRAINT user_collections_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 2066 (class 826 OID 21312)
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO kardly_prod_user;


--
-- TOC entry 2065 (class 826 OID 21311)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO kardly_prod_user;


-- Completed on 2025-09-30 09:47:18

--
-- PostgreSQL database dump complete
--

