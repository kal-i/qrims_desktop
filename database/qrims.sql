--
-- PostgreSQL database dump
--

-- Dumped from database version 17.2
-- Dumped by pg_dump version 17.1

-- Started on 2025-05-30 13:36:17

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
-- TOC entry 265 (class 1255 OID 18638)
-- Name: ensure_yearly_sequence(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ensure_yearly_sequence(year integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  EXECUTE format('
    CREATE SEQUENCE IF NOT EXISTS %I
    START WITH 1
    INCREMENT BY 1
    NO CYCLE',
    get_yearly_sequence(year)
  );
END;
$$;


ALTER FUNCTION public.ensure_yearly_sequence(year integer) OWNER TO postgres;

--
-- TOC entry 264 (class 1255 OID 18637)
-- Name: get_yearly_sequence(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_yearly_sequence(year integer) RETURNS text
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN 'ics_id_sequence_' || year;
END;
$$;


ALTER FUNCTION public.get_yearly_sequence(year integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 217 (class 1259 OID 16385)
-- Name: brands; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.brands (
    id character varying(50) NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE public.brands OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 16388)
-- Name: entities; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.entities (
    id character varying(50) NOT NULL,
    name character varying(100)
);


ALTER TABLE public.entities OWNER TO postgres;

--
-- TOC entry 240 (class 1259 OID 16877)
-- Name: inventoryitems; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.inventoryitems (
    id integer NOT NULL,
    base_item_id character varying(50) NOT NULL,
    manufacturer_id character varying(50),
    brand_id character varying(50),
    model_id character varying(50),
    serial_no character varying(100),
    asset_classification character varying(50),
    asset_sub_class character varying(50),
    estimated_useful_life integer
);


ALTER TABLE public.inventoryitems OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 16876)
-- Name: equipment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.equipment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.equipment_id_seq OWNER TO postgres;

--
-- TOC entry 5205 (class 0 OID 0)
-- Dependencies: 239
-- Name: equipment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.equipment_id_seq OWNED BY public.inventoryitems.id;


--
-- TOC entry 259 (class 1259 OID 18636)
-- Name: ics_id_sequence; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ics_id_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ics_id_sequence OWNER TO postgres;

--
-- TOC entry 260 (class 1259 OID 18639)
-- Name: ics_id_sequence_2025; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ics_id_sequence_2025
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ics_id_sequence_2025 OWNER TO postgres;

--
-- TOC entry 261 (class 1259 OID 18640)
-- Name: ics_id_sequences; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ics_id_sequences (
    year integer NOT NULL,
    last_value integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.ics_id_sequences OWNER TO postgres;

--
-- TOC entry 242 (class 1259 OID 16961)
-- Name: inventoryactivities; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.inventoryactivities (
    id integer NOT NULL,
    base_item_id character varying(50) NOT NULL,
    action character varying(50) NOT NULL,
    quantity integer NOT NULL,
    "timestamp" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.inventoryactivities OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 16960)
-- Name: inventoryactivities_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.inventoryactivities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.inventoryactivities_id_seq OWNER TO postgres;

--
-- TOC entry 5206 (class 0 OID 0)
-- Dependencies: 241
-- Name: inventoryactivities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.inventoryactivities_id_seq OWNED BY public.inventoryactivities.id;


--
-- TOC entry 248 (class 1259 OID 17655)
-- Name: inventorycustodianslips; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.inventorycustodianslips (
    id character varying(50) NOT NULL,
    issuance_id character varying(50) NOT NULL,
    supplier_id integer,
    inspection_and_acceptance_report_id character varying(255),
    contract_number character varying(255),
    purchase_order_id character varying(255),
    delivery_receipt_id character varying(50),
    pr_reference_id character varying(50),
    inventory_transfer_report_id character varying(50),
    date_acquired date
);


ALTER TABLE public.inventorycustodianslips OWNER TO postgres;

--
-- TOC entry 251 (class 1259 OID 17702)
-- Name: issuanceitems; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.issuanceitems (
    issuance_id character varying(50) NOT NULL,
    item_id character varying(50) NOT NULL,
    issued_quantity integer,
    status text DEFAULT 'received'::text,
    returned_date date,
    lost_date date,
    remarks text,
    disposed_date date
);


ALTER TABLE public.issuanceitems OWNER TO postgres;

--
-- TOC entry 247 (class 1259 OID 17630)
-- Name: issuances; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.issuances (
    id character varying(50) NOT NULL,
    issued_date timestamp without time zone,
    return_date timestamp without time zone,
    purchase_request_id character varying(50),
    entity_id character varying(50),
    fund_cluster character varying(50),
    receiving_officer_id character varying(50),
    issuing_officer_id character varying(50),
    qr_code_image_data text,
    status character varying(50) DEFAULT 'unreceived'::character varying,
    is_archived boolean DEFAULT false,
    received_date date,
    CONSTRAINT check_status CHECK (((status)::text = ANY ((ARRAY['unreceived'::character varying, 'received'::character varying, 'cancelled'::character varying, 'returned'::character varying])::text[])))
);


ALTER TABLE public.issuances OWNER TO postgres;

--
-- TOC entry 263 (class 1259 OID 18679)
-- Name: item_daily_counters; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.item_daily_counters (
    item_name text NOT NULL,
    product_description_id integer NOT NULL,
    date date NOT NULL,
    counter integer NOT NULL
);


ALTER TABLE public.item_daily_counters OWNER TO postgres;

--
-- TOC entry 244 (class 1259 OID 17368)
-- Name: item_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.item_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.item_id_seq OWNER TO postgres;

--
-- TOC entry 262 (class 1259 OID 18672)
-- Name: item_yearly_counters; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.item_yearly_counters (
    item_name text NOT NULL,
    year integer NOT NULL,
    counter integer NOT NULL
);


ALTER TABLE public.item_yearly_counters OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16404)
-- Name: items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.items (
    id character varying(50) NOT NULL,
    product_name_id integer,
    product_description_id integer,
    specification text,
    unit character varying(20),
    quantity integer,
    encrypted_id text,
    qr_code_image_data text,
    unit_cost numeric(10,2),
    acquired_date timestamp without time zone,
    fund_cluster character varying(50)
);


ALTER TABLE public.items OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 16409)
-- Name: manufacturerbrands; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.manufacturerbrands (
    manufacturer_id character varying(50) NOT NULL,
    brand_id character varying(50) NOT NULL
);


ALTER TABLE public.manufacturerbrands OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16412)
-- Name: manufacturers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.manufacturers (
    id character varying(50) NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE public.manufacturers OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 16415)
-- Name: messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.messages (
    id integer NOT NULL,
    recipient_id integer,
    sender_id integer,
    message text
);


ALTER TABLE public.messages OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16420)
-- Name: messages_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.messages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.messages_id_seq OWNER TO postgres;

--
-- TOC entry 5207 (class 0 OID 0)
-- Dependencies: 223
-- Name: messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.messages_id_seq OWNED BY public.messages.id;


--
-- TOC entry 224 (class 1259 OID 16421)
-- Name: mobileusers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mobileusers (
    id character varying(50) NOT NULL,
    user_id character varying(50),
    admin_approval_status character varying(20) DEFAULT 'pending'::character varying,
    CONSTRAINT mobileusers_admin_approval_status_check CHECK (((admin_approval_status)::text = ANY (ARRAY[('pending'::character varying)::text, ('accepted'::character varying)::text, ('rejected'::character varying)::text])))
);


ALTER TABLE public.mobileusers OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16426)
-- Name: models; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.models (
    id character varying(50) NOT NULL,
    product_name_id integer,
    brand_id character varying(50),
    model_name character varying(100) NOT NULL
);


ALTER TABLE public.models OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 17005)
-- Name: notifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notifications (
    id character varying(50) NOT NULL,
    recipient_id character varying(50),
    sender_id character varying(50),
    message text NOT NULL,
    type character varying(50) NOT NULL,
    reference_id character varying(50),
    read boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.notifications OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 16436)
-- Name: officers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.officers (
    id character varying(50) NOT NULL,
    user_id character varying(50),
    name character varying(100),
    position_id character varying(50),
    is_archived boolean DEFAULT false,
    officer_status character varying(20) DEFAULT 'active'::character varying
);


ALTER TABLE public.officers OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 16440)
-- Name: offices; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.offices (
    id character varying(50) NOT NULL,
    name character varying(50)
);


ALTER TABLE public.offices OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 16809)
-- Name: positionhistory; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.positionhistory (
    id integer NOT NULL,
    officer_id character varying(255) NOT NULL,
    position_id character varying(255) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.positionhistory OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 16808)
-- Name: positionhistory_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.positionhistory_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.positionhistory_id_seq OWNER TO postgres;

--
-- TOC entry 5208 (class 0 OID 0)
-- Dependencies: 235
-- Name: positionhistory_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.positionhistory_id_seq OWNED BY public.positionhistory.id;


--
-- TOC entry 228 (class 1259 OID 16443)
-- Name: positions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.positions (
    id character varying(50) NOT NULL,
    office_id character varying(50),
    position_name character varying(50)
);


ALTER TABLE public.positions OWNER TO postgres;

--
-- TOC entry 255 (class 1259 OID 18016)
-- Name: productdescriptions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.productdescriptions (
    id integer NOT NULL,
    description character varying(100)
);


ALTER TABLE public.productdescriptions OWNER TO postgres;

--
-- TOC entry 254 (class 1259 OID 18015)
-- Name: productdescriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.productdescriptions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.productdescriptions_id_seq OWNER TO postgres;

--
-- TOC entry 5209 (class 0 OID 0)
-- Dependencies: 254
-- Name: productdescriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.productdescriptions_id_seq OWNED BY public.productdescriptions.id;


--
-- TOC entry 253 (class 1259 OID 18009)
-- Name: productnames; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.productnames (
    id integer NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE public.productnames OWNER TO postgres;

--
-- TOC entry 252 (class 1259 OID 18008)
-- Name: productnames_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.productnames_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.productnames_id_seq OWNER TO postgres;

--
-- TOC entry 5210 (class 0 OID 0)
-- Dependencies: 252
-- Name: productnames_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.productnames_id_seq OWNED BY public.productnames.id;


--
-- TOC entry 256 (class 1259 OID 18022)
-- Name: productstocks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.productstocks (
    product_name_id integer NOT NULL,
    product_description_id integer NOT NULL,
    stock_no integer
);


ALTER TABLE public.productstocks OWNER TO postgres;

--
-- TOC entry 249 (class 1259 OID 17665)
-- Name: propertyacknowledgementreceipts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.propertyacknowledgementreceipts (
    id character varying(50) NOT NULL,
    issuance_id character varying(50) NOT NULL,
    supplier_id integer,
    inspection_and_acceptance_report_id character varying(255),
    contract_number character varying(255),
    purchase_order_id character varying(255),
    delivery_receipt_id character varying(50),
    pr_reference_id character varying(50),
    inventory_transfer_report_id character varying(50),
    date_acquired date
);


ALTER TABLE public.propertyacknowledgementreceipts OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 16458)
-- Name: purchaseorders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.purchaseorders (
    id character varying(50) NOT NULL,
    supplier_id character varying(50),
    date timestamp without time zone,
    procurement_mode character varying(50),
    gentleman character varying(50),
    delivery_place character varying(255),
    delivery_date timestamp without time zone,
    delivery_term integer,
    payment_term integer,
    description character varying(255),
    purchase_request_id character varying(50),
    conforme_officer_id character varying(50),
    conforme_date timestamp without time zone,
    superintendent_officer_id character varying(50),
    funds_holder_officer_id character varying(50),
    alobs_no character varying(50),
    is_archived boolean DEFAULT false
);


ALTER TABLE public.purchaseorders OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 16464)
-- Name: purchaserequests; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.purchaserequests (
    id character varying(50) NOT NULL,
    entity_id character varying(50),
    fund_cluster character varying(50),
    office_id character varying(50),
    responsibility_center_code character varying(50),
    date timestamp without time zone,
    purpose text,
    requesting_officer_id character varying(50),
    approving_officer_id character varying(50),
    status character varying(50) DEFAULT 'pending'::character varying,
    is_archived boolean DEFAULT false,
    CONSTRAINT purchaserequests_status_check CHECK (((status)::text = ANY (ARRAY[('cancelled'::character varying)::text, ('pending'::character varying)::text, ('partiallyFulfilled'::character varying)::text, ('fulfilled'::character varying)::text])))
);


ALTER TABLE public.purchaserequests OWNER TO postgres;

--
-- TOC entry 246 (class 1259 OID 17603)
-- Name: requesteditems; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.requesteditems (
    id integer NOT NULL,
    pr_id character varying(50) NOT NULL,
    product_name_id integer NOT NULL,
    product_description_id integer NOT NULL,
    specification character varying(255),
    unit character varying(50),
    quantity integer NOT NULL,
    remaining_quantity integer,
    unit_cost numeric(10,2),
    total_cost numeric(10,2),
    status character varying(20) DEFAULT 'notFulfilled'::character varying,
    CONSTRAINT requesteditems_quantity_check CHECK ((quantity > 0)),
    CONSTRAINT requesteditems_remaining_quantity_check CHECK ((remaining_quantity >= 0)),
    CONSTRAINT requesteditems_status_check CHECK (((status)::text = ANY ((ARRAY['notFulfilled'::character varying, 'partiallyFulfilled'::character varying, 'fulfilled'::character varying])::text[]))),
    CONSTRAINT requesteditems_total_cost_check CHECK ((total_cost >= (0)::numeric)),
    CONSTRAINT requesteditems_unit_cost_check CHECK ((unit_cost >= (0)::numeric))
);


ALTER TABLE public.requesteditems OWNER TO postgres;

--
-- TOC entry 245 (class 1259 OID 17602)
-- Name: requesteditems_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.requesteditems_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.requesteditems_id_seq OWNER TO postgres;

--
-- TOC entry 5211 (class 0 OID 0)
-- Dependencies: 245
-- Name: requesteditems_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.requesteditems_id_seq OWNED BY public.requesteditems.id;


--
-- TOC entry 250 (class 1259 OID 17675)
-- Name: requisitionandissueslips; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.requisitionandissueslips (
    id character varying(50) NOT NULL,
    issuance_id character varying(50) NOT NULL,
    division character varying(50),
    responsibility_center_code character varying(50),
    office_id character varying(50),
    purpose text,
    approving_officer_id character varying(50),
    requesting_officer_id character varying(50),
    approved_date date,
    request_date date
);


ALTER TABLE public.requisitionandissueslips OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 16473)
-- Name: sessions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sessions (
    token character varying(255) NOT NULL,
    user_id character varying(50),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    expires_at timestamp without time zone NOT NULL
);


ALTER TABLE public.sessions OWNER TO postgres;

--
-- TOC entry 258 (class 1259 OID 18199)
-- Name: suppliers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.suppliers (
    supplier_id integer NOT NULL,
    name character varying(255) NOT NULL
);


ALTER TABLE public.suppliers OWNER TO postgres;

--
-- TOC entry 257 (class 1259 OID 18198)
-- Name: suppliers_supplier_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.suppliers_supplier_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.suppliers_supplier_id_seq OWNER TO postgres;

--
-- TOC entry 5212 (class 0 OID 0)
-- Dependencies: 257
-- Name: suppliers_supplier_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.suppliers_supplier_id_seq OWNED BY public.suppliers.supplier_id;


--
-- TOC entry 238 (class 1259 OID 16853)
-- Name: supplies; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.supplies (
    id integer NOT NULL,
    base_item_id character varying(50) NOT NULL
);


ALTER TABLE public.supplies OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 16852)
-- Name: supplies_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.supplies_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.supplies_id_seq OWNER TO postgres;

--
-- TOC entry 5213 (class 0 OID 0)
-- Dependencies: 237
-- Name: supplies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.supplies_id_seq OWNED BY public.supplies.id;


--
-- TOC entry 232 (class 1259 OID 16480)
-- Name: supplydepartmentemployees; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.supplydepartmentemployees (
    id character varying(50) NOT NULL,
    user_id character varying(50),
    role character varying(50)
);


ALTER TABLE public.supplydepartmentemployees OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 16483)
-- Name: useractivities; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.useractivities (
    user_act_id character varying(50) NOT NULL,
    user_id character varying(50),
    description text,
    action_type character varying(20),
    target_id character varying(50),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.useractivities OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 16489)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id character varying(50) NOT NULL,
    name character varying(100) NOT NULL,
    email character varying(100) NOT NULL,
    password character varying(100) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone,
    auth_status character varying(20) DEFAULT 'unauthenticated'::character varying,
    is_archived boolean DEFAULT false,
    otp character varying(6) DEFAULT NULL::character varying,
    otp_expiry timestamp without time zone,
    profile_image text,
    CONSTRAINT users_auth_status_check CHECK (((auth_status)::text = ANY (ARRAY[('unauthenticated'::character varying)::text, ('authenticated'::character varying)::text, ('revoked'::character varying)::text])))
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 4908 (class 2604 OID 16964)
-- Name: inventoryactivities id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventoryactivities ALTER COLUMN id SET DEFAULT nextval('public.inventoryactivities_id_seq'::regclass);


--
-- TOC entry 4907 (class 2604 OID 16880)
-- Name: inventoryitems id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventoryitems ALTER COLUMN id SET DEFAULT nextval('public.equipment_id_seq'::regclass);


--
-- TOC entry 4891 (class 2604 OID 16499)
-- Name: messages id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages ALTER COLUMN id SET DEFAULT nextval('public.messages_id_seq'::regclass);


--
-- TOC entry 4904 (class 2604 OID 16812)
-- Name: positionhistory id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.positionhistory ALTER COLUMN id SET DEFAULT nextval('public.positionhistory_id_seq'::regclass);


--
-- TOC entry 4918 (class 2604 OID 18019)
-- Name: productdescriptions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productdescriptions ALTER COLUMN id SET DEFAULT nextval('public.productdescriptions_id_seq'::regclass);


--
-- TOC entry 4917 (class 2604 OID 18012)
-- Name: productnames id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productnames ALTER COLUMN id SET DEFAULT nextval('public.productnames_id_seq'::regclass);


--
-- TOC entry 4912 (class 2604 OID 17606)
-- Name: requesteditems id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.requesteditems ALTER COLUMN id SET DEFAULT nextval('public.requesteditems_id_seq'::regclass);


--
-- TOC entry 4919 (class 2604 OID 18202)
-- Name: suppliers supplier_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suppliers ALTER COLUMN supplier_id SET DEFAULT nextval('public.suppliers_supplier_id_seq'::regclass);


--
-- TOC entry 4906 (class 2604 OID 16856)
-- Name: supplies id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.supplies ALTER COLUMN id SET DEFAULT nextval('public.supplies_id_seq'::regclass);


--
-- TOC entry 4931 (class 2606 OID 16501)
-- Name: brands brands_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.brands
    ADD CONSTRAINT brands_name_key UNIQUE (name);


--
-- TOC entry 4933 (class 2606 OID 16503)
-- Name: brands brands_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.brands
    ADD CONSTRAINT brands_pkey PRIMARY KEY (id);


--
-- TOC entry 4935 (class 2606 OID 16505)
-- Name: entities entities_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entities
    ADD CONSTRAINT entities_pkey PRIMARY KEY (id);


--
-- TOC entry 4977 (class 2606 OID 16882)
-- Name: inventoryitems equipment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventoryitems
    ADD CONSTRAINT equipment_pkey PRIMARY KEY (id);


--
-- TOC entry 5005 (class 2606 OID 18645)
-- Name: ics_id_sequences ics_id_sequences_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ics_id_sequences
    ADD CONSTRAINT ics_id_sequences_pkey PRIMARY KEY (year);


--
-- TOC entry 4981 (class 2606 OID 16967)
-- Name: inventoryactivities inventoryactivities_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventoryactivities
    ADD CONSTRAINT inventoryactivities_pkey PRIMARY KEY (id);


--
-- TOC entry 4989 (class 2606 OID 17659)
-- Name: inventorycustodianslips inventorycustodianslips_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventorycustodianslips
    ADD CONSTRAINT inventorycustodianslips_pkey PRIMARY KEY (id);


--
-- TOC entry 4995 (class 2606 OID 17706)
-- Name: issuanceitems issuanceitems_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.issuanceitems
    ADD CONSTRAINT issuanceitems_pkey PRIMARY KEY (issuance_id, item_id);


--
-- TOC entry 4987 (class 2606 OID 17639)
-- Name: issuances issuances_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.issuances
    ADD CONSTRAINT issuances_pkey PRIMARY KEY (id);


--
-- TOC entry 5009 (class 2606 OID 18685)
-- Name: item_daily_counters item_daily_counters_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.item_daily_counters
    ADD CONSTRAINT item_daily_counters_pkey PRIMARY KEY (item_name, product_description_id, date);


--
-- TOC entry 5007 (class 2606 OID 18678)
-- Name: item_yearly_counters item_yearly_counters_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.item_yearly_counters
    ADD CONSTRAINT item_yearly_counters_pkey PRIMARY KEY (item_name, year);


--
-- TOC entry 4937 (class 2606 OID 16513)
-- Name: items items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT items_pkey PRIMARY KEY (id);


--
-- TOC entry 4939 (class 2606 OID 16517)
-- Name: manufacturerbrands manufacturerbrands_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.manufacturerbrands
    ADD CONSTRAINT manufacturerbrands_pkey PRIMARY KEY (manufacturer_id, brand_id);


--
-- TOC entry 4941 (class 2606 OID 16519)
-- Name: manufacturers manufacturers_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.manufacturers
    ADD CONSTRAINT manufacturers_name_key UNIQUE (name);


--
-- TOC entry 4943 (class 2606 OID 16521)
-- Name: manufacturers manufacturers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.manufacturers
    ADD CONSTRAINT manufacturers_pkey PRIMARY KEY (id);


--
-- TOC entry 4945 (class 2606 OID 16523)
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- TOC entry 4947 (class 2606 OID 16525)
-- Name: mobileusers mobileusers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mobileusers
    ADD CONSTRAINT mobileusers_pkey PRIMARY KEY (id);


--
-- TOC entry 4949 (class 2606 OID 16527)
-- Name: models models_model_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.models
    ADD CONSTRAINT models_model_name_key UNIQUE (model_name);


--
-- TOC entry 4951 (class 2606 OID 16529)
-- Name: models models_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.models
    ADD CONSTRAINT models_pkey PRIMARY KEY (id);


--
-- TOC entry 4983 (class 2606 OID 17013)
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- TOC entry 4953 (class 2606 OID 16533)
-- Name: officers officers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.officers
    ADD CONSTRAINT officers_pkey PRIMARY KEY (id);


--
-- TOC entry 4955 (class 2606 OID 16535)
-- Name: offices offices_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.offices
    ADD CONSTRAINT offices_pkey PRIMARY KEY (id);


--
-- TOC entry 4973 (class 2606 OID 16817)
-- Name: positionhistory positionhistory_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.positionhistory
    ADD CONSTRAINT positionhistory_pkey PRIMARY KEY (id);


--
-- TOC entry 4957 (class 2606 OID 16537)
-- Name: positions positions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.positions
    ADD CONSTRAINT positions_pkey PRIMARY KEY (id);


--
-- TOC entry 4999 (class 2606 OID 18021)
-- Name: productdescriptions productdescriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productdescriptions
    ADD CONSTRAINT productdescriptions_pkey PRIMARY KEY (id);


--
-- TOC entry 4997 (class 2606 OID 18014)
-- Name: productnames productnames_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productnames
    ADD CONSTRAINT productnames_pkey PRIMARY KEY (id);


--
-- TOC entry 5001 (class 2606 OID 18026)
-- Name: productstocks productstocks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productstocks
    ADD CONSTRAINT productstocks_pkey PRIMARY KEY (product_name_id, product_description_id);


--
-- TOC entry 4991 (class 2606 OID 17669)
-- Name: propertyacknowledgementreceipts propertyacknowledgementreceipts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.propertyacknowledgementreceipts
    ADD CONSTRAINT propertyacknowledgementreceipts_pkey PRIMARY KEY (id);


--
-- TOC entry 4959 (class 2606 OID 16551)
-- Name: purchaseorders purchaseorders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchaseorders
    ADD CONSTRAINT purchaseorders_pkey PRIMARY KEY (id);


--
-- TOC entry 4961 (class 2606 OID 16553)
-- Name: purchaserequests purchaserequests_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchaserequests
    ADD CONSTRAINT purchaserequests_pkey PRIMARY KEY (id);


--
-- TOC entry 4985 (class 2606 OID 17614)
-- Name: requesteditems requesteditems_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.requesteditems
    ADD CONSTRAINT requesteditems_pkey PRIMARY KEY (id);


--
-- TOC entry 4993 (class 2606 OID 17681)
-- Name: requisitionandissueslips requisitionandissueslips_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.requisitionandissueslips
    ADD CONSTRAINT requisitionandissueslips_pkey PRIMARY KEY (id);


--
-- TOC entry 4963 (class 2606 OID 16555)
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (token);


--
-- TOC entry 5003 (class 2606 OID 18204)
-- Name: suppliers suppliers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suppliers
    ADD CONSTRAINT suppliers_pkey PRIMARY KEY (supplier_id);


--
-- TOC entry 4975 (class 2606 OID 16858)
-- Name: supplies supplies_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.supplies
    ADD CONSTRAINT supplies_pkey PRIMARY KEY (id);


--
-- TOC entry 4965 (class 2606 OID 16559)
-- Name: supplydepartmentemployees supplydepartmentemployees_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.supplydepartmentemployees
    ADD CONSTRAINT supplydepartmentemployees_pkey PRIMARY KEY (id);


--
-- TOC entry 4979 (class 2606 OID 18307)
-- Name: inventoryitems unique_inventory_identity; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventoryitems
    ADD CONSTRAINT unique_inventory_identity UNIQUE (brand_id, model_id, serial_no);


--
-- TOC entry 4967 (class 2606 OID 16561)
-- Name: useractivities useractivities_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.useractivities
    ADD CONSTRAINT useractivities_pkey PRIMARY KEY (user_act_id);


--
-- TOC entry 4969 (class 2606 OID 16563)
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- TOC entry 4971 (class 2606 OID 16565)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 5034 (class 2606 OID 16883)
-- Name: inventoryitems equipment_base_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventoryitems
    ADD CONSTRAINT equipment_base_item_id_fkey FOREIGN KEY (base_item_id) REFERENCES public.items(id);


--
-- TOC entry 5047 (class 2606 OID 17692)
-- Name: requisitionandissueslips fk_approving_officer; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.requisitionandissueslips
    ADD CONSTRAINT fk_approving_officer FOREIGN KEY (approving_officer_id) REFERENCES public.officers(id) ON DELETE SET NULL;


--
-- TOC entry 5043 (class 2606 OID 17660)
-- Name: inventorycustodianslips fk_issuance; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventorycustodianslips
    ADD CONSTRAINT fk_issuance FOREIGN KEY (issuance_id) REFERENCES public.issuances(id) ON DELETE CASCADE;


--
-- TOC entry 5045 (class 2606 OID 17670)
-- Name: propertyacknowledgementreceipts fk_issuance; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.propertyacknowledgementreceipts
    ADD CONSTRAINT fk_issuance FOREIGN KEY (issuance_id) REFERENCES public.issuances(id) ON DELETE CASCADE;


--
-- TOC entry 5048 (class 2606 OID 17682)
-- Name: requisitionandissueslips fk_issuance; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.requisitionandissueslips
    ADD CONSTRAINT fk_issuance FOREIGN KEY (issuance_id) REFERENCES public.issuances(id) ON DELETE CASCADE;


--
-- TOC entry 5051 (class 2606 OID 17707)
-- Name: issuanceitems fk_issuance; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.issuanceitems
    ADD CONSTRAINT fk_issuance FOREIGN KEY (issuance_id) REFERENCES public.issuances(id) ON DELETE CASCADE;


--
-- TOC entry 5040 (class 2606 OID 17650)
-- Name: issuances fk_issuing_officer; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.issuances
    ADD CONSTRAINT fk_issuing_officer FOREIGN KEY (issuing_officer_id) REFERENCES public.officers(id) ON DELETE SET NULL;


--
-- TOC entry 5052 (class 2606 OID 17712)
-- Name: issuanceitems fk_item; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.issuanceitems
    ADD CONSTRAINT fk_item FOREIGN KEY (item_id) REFERENCES public.items(id) ON DELETE CASCADE;


--
-- TOC entry 5049 (class 2606 OID 17687)
-- Name: requisitionandissueslips fk_office; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.requisitionandissueslips
    ADD CONSTRAINT fk_office FOREIGN KEY (office_id) REFERENCES public.offices(id) ON DELETE SET NULL;


--
-- TOC entry 5037 (class 2606 OID 17615)
-- Name: requesteditems fk_pr; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.requesteditems
    ADD CONSTRAINT fk_pr FOREIGN KEY (pr_id) REFERENCES public.purchaserequests(id) ON DELETE CASCADE;


--
-- TOC entry 5041 (class 2606 OID 17640)
-- Name: issuances fk_purchase_request; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.issuances
    ADD CONSTRAINT fk_purchase_request FOREIGN KEY (purchase_request_id) REFERENCES public.purchaserequests(id) ON DELETE SET NULL;


--
-- TOC entry 5042 (class 2606 OID 17645)
-- Name: issuances fk_receiving_officer; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.issuances
    ADD CONSTRAINT fk_receiving_officer FOREIGN KEY (receiving_officer_id) REFERENCES public.officers(id) ON DELETE SET NULL;


--
-- TOC entry 5050 (class 2606 OID 17697)
-- Name: requisitionandissueslips fk_requesting_officer; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.requisitionandissueslips
    ADD CONSTRAINT fk_requesting_officer FOREIGN KEY (requesting_officer_id) REFERENCES public.officers(id) ON DELETE SET NULL;


--
-- TOC entry 5036 (class 2606 OID 17014)
-- Name: notifications fk_sender; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT fk_sender FOREIGN KEY (sender_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 5044 (class 2606 OID 18205)
-- Name: inventorycustodianslips fk_supplier; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventorycustodianslips
    ADD CONSTRAINT fk_supplier FOREIGN KEY (supplier_id) REFERENCES public.suppliers(supplier_id);


--
-- TOC entry 5046 (class 2606 OID 18212)
-- Name: propertyacknowledgementreceipts fk_supplier; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.propertyacknowledgementreceipts
    ADD CONSTRAINT fk_supplier FOREIGN KEY (supplier_id) REFERENCES public.suppliers(supplier_id);


--
-- TOC entry 5035 (class 2606 OID 16968)
-- Name: inventoryactivities inventoryactivities_base_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventoryactivities
    ADD CONSTRAINT inventoryactivities_base_item_id_fkey FOREIGN KEY (base_item_id) REFERENCES public.items(id);


--
-- TOC entry 5010 (class 2606 OID 18052)
-- Name: items items_product_description_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT items_product_description_id_fkey FOREIGN KEY (product_description_id) REFERENCES public.productdescriptions(id) ON DELETE CASCADE;


--
-- TOC entry 5011 (class 2606 OID 18047)
-- Name: items items_product_name_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT items_product_name_id_fkey FOREIGN KEY (product_name_id) REFERENCES public.productnames(id) ON DELETE CASCADE;


--
-- TOC entry 5012 (class 2606 OID 16616)
-- Name: manufacturerbrands manufacturerbrands_brand_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.manufacturerbrands
    ADD CONSTRAINT manufacturerbrands_brand_id_fkey FOREIGN KEY (brand_id) REFERENCES public.brands(id) ON DELETE CASCADE;


--
-- TOC entry 5013 (class 2606 OID 16621)
-- Name: manufacturerbrands manufacturerbrands_manufacturer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.manufacturerbrands
    ADD CONSTRAINT manufacturerbrands_manufacturer_id_fkey FOREIGN KEY (manufacturer_id) REFERENCES public.manufacturers(id) ON DELETE CASCADE;


--
-- TOC entry 5014 (class 2606 OID 16626)
-- Name: mobileusers mobileusers_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mobileusers
    ADD CONSTRAINT mobileusers_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 5015 (class 2606 OID 16631)
-- Name: models models_brand_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.models
    ADD CONSTRAINT models_brand_id_fkey FOREIGN KEY (brand_id) REFERENCES public.brands(id) ON DELETE CASCADE;


--
-- TOC entry 5016 (class 2606 OID 16651)
-- Name: officers officers_position_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.officers
    ADD CONSTRAINT officers_position_id_fkey FOREIGN KEY (position_id) REFERENCES public.positions(id) ON DELETE CASCADE;


--
-- TOC entry 5017 (class 2606 OID 16656)
-- Name: officers officers_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.officers
    ADD CONSTRAINT officers_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 5031 (class 2606 OID 16818)
-- Name: positionhistory positionhistory_officer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.positionhistory
    ADD CONSTRAINT positionhistory_officer_id_fkey FOREIGN KEY (officer_id) REFERENCES public.officers(id);


--
-- TOC entry 5032 (class 2606 OID 16823)
-- Name: positionhistory positionhistory_position_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.positionhistory
    ADD CONSTRAINT positionhistory_position_id_fkey FOREIGN KEY (position_id) REFERENCES public.positions(id);


--
-- TOC entry 5018 (class 2606 OID 16661)
-- Name: positions positions_office_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.positions
    ADD CONSTRAINT positions_office_id_fkey FOREIGN KEY (office_id) REFERENCES public.offices(id) ON DELETE CASCADE;


--
-- TOC entry 5053 (class 2606 OID 18032)
-- Name: productstocks productstocks_product_description_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productstocks
    ADD CONSTRAINT productstocks_product_description_id_fkey FOREIGN KEY (product_description_id) REFERENCES public.productdescriptions(id) ON DELETE CASCADE;


--
-- TOC entry 5054 (class 2606 OID 18027)
-- Name: productstocks productstocks_product_name_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productstocks
    ADD CONSTRAINT productstocks_product_name_id_fkey FOREIGN KEY (product_name_id) REFERENCES public.productnames(id) ON DELETE CASCADE;


--
-- TOC entry 5019 (class 2606 OID 16686)
-- Name: purchaseorders purchaseorders_conforme_officer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchaseorders
    ADD CONSTRAINT purchaseorders_conforme_officer_id_fkey FOREIGN KEY (conforme_officer_id) REFERENCES public.officers(id) ON DELETE CASCADE;


--
-- TOC entry 5020 (class 2606 OID 16691)
-- Name: purchaseorders purchaseorders_funds_holder_officer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchaseorders
    ADD CONSTRAINT purchaseorders_funds_holder_officer_id_fkey FOREIGN KEY (funds_holder_officer_id) REFERENCES public.officers(id) ON DELETE CASCADE;


--
-- TOC entry 5021 (class 2606 OID 16696)
-- Name: purchaseorders purchaseorders_purchase_request_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchaseorders
    ADD CONSTRAINT purchaseorders_purchase_request_id_fkey FOREIGN KEY (purchase_request_id) REFERENCES public.purchaserequests(id) ON DELETE CASCADE;


--
-- TOC entry 5022 (class 2606 OID 16701)
-- Name: purchaseorders purchaseorders_superintendent_officer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchaseorders
    ADD CONSTRAINT purchaseorders_superintendent_officer_id_fkey FOREIGN KEY (superintendent_officer_id) REFERENCES public.officers(id) ON DELETE CASCADE;


--
-- TOC entry 5023 (class 2606 OID 16711)
-- Name: purchaserequests purchaserequests_approving_officer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchaserequests
    ADD CONSTRAINT purchaserequests_approving_officer_id_fkey FOREIGN KEY (approving_officer_id) REFERENCES public.officers(id) ON DELETE CASCADE;


--
-- TOC entry 5024 (class 2606 OID 16716)
-- Name: purchaserequests purchaserequests_entity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchaserequests
    ADD CONSTRAINT purchaserequests_entity_id_fkey FOREIGN KEY (entity_id) REFERENCES public.entities(id) ON DELETE CASCADE;


--
-- TOC entry 5025 (class 2606 OID 16721)
-- Name: purchaserequests purchaserequests_office_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchaserequests
    ADD CONSTRAINT purchaserequests_office_id_fkey FOREIGN KEY (office_id) REFERENCES public.offices(id) ON DELETE CASCADE;


--
-- TOC entry 5026 (class 2606 OID 16736)
-- Name: purchaserequests purchaserequests_requesting_officer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchaserequests
    ADD CONSTRAINT purchaserequests_requesting_officer_id_fkey FOREIGN KEY (requesting_officer_id) REFERENCES public.officers(id) ON DELETE CASCADE;


--
-- TOC entry 5038 (class 2606 OID 18062)
-- Name: requesteditems requested_items_product_description_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.requesteditems
    ADD CONSTRAINT requested_items_product_description_id_fkey FOREIGN KEY (product_description_id) REFERENCES public.productdescriptions(id) ON DELETE CASCADE;


--
-- TOC entry 5039 (class 2606 OID 18057)
-- Name: requesteditems requested_items_product_name_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.requesteditems
    ADD CONSTRAINT requested_items_product_name_id_fkey FOREIGN KEY (product_name_id) REFERENCES public.productnames(id) ON DELETE CASCADE;


--
-- TOC entry 5027 (class 2606 OID 16741)
-- Name: sessions sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 5033 (class 2606 OID 16859)
-- Name: supplies supplies_base_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.supplies
    ADD CONSTRAINT supplies_base_item_id_fkey FOREIGN KEY (base_item_id) REFERENCES public.items(id);


--
-- TOC entry 5028 (class 2606 OID 16746)
-- Name: supplydepartmentemployees supplydepartmentemployees_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.supplydepartmentemployees
    ADD CONSTRAINT supplydepartmentemployees_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 5029 (class 2606 OID 16751)
-- Name: useractivities useractivities_target_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.useractivities
    ADD CONSTRAINT useractivities_target_id_fkey FOREIGN KEY (target_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 5030 (class 2606 OID 16756)
-- Name: useractivities useractivities_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.useractivities
    ADD CONSTRAINT useractivities_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


-- Completed on 2025-05-30 13:36:18

--
-- PostgreSQL database dump complete
--

