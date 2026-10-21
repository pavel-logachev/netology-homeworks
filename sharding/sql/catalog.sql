\set ON_ERROR_STOP on
CREATE ROLE catalog_writer LOGIN;
CREATE TABLE public.stores (
    store_id bigint PRIMARY KEY,
    name text NOT NULL,
    city text NOT NULL
);
CREATE TABLE public.books (
    book_id bigint PRIMARY KEY,
    title text NOT NULL,
    store_id bigint NOT NULL REFERENCES public.stores(store_id),
    price numeric(10,2) NOT NULL CHECK (price >= 0)
);
CREATE INDEX books_store_id_idx ON public.books(store_id);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.stores, public.books TO catalog_writer;
