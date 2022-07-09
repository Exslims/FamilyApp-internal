DROP TRIGGER IF EXISTS new_wallet_was_added ON public.wallets;
DROP TABLE IF EXISTS public.users_wallets_stats;
DROP TABLE IF EXISTS public.transactions;
DROP TABLE IF EXISTS public.categories_budgets;
DROP TABLE IF EXISTS public.budgets;
DROP TABLE IF EXISTS public.categories_tags;
DROP TABLE IF EXISTS public.tags;
DROP TABLE IF EXISTS public.categories;
DROP TABLE IF EXISTS public.users_wallets;
DROP TABLE IF EXISTS public.permissions;
DROP TABLE IF EXISTS public.wallets;
DROP TABLE IF EXISTS public.users;

DROP INDEX IF EXISTS idx_select_transactions_wallet_id_category_id_transactions_date;
DROP INDEX IF EXISTS idx_select_user_wallets_user_id;
DROP INDEX IF EXISTS idx_select_users_wallet_wallet_id;
DROP INDEX IF EXISTS idx_select_categories_budget_id;

CREATE TABLE public.users (
    user_id SERIAL PRIMARY KEY,
    password VARCHAR(250) NOT NULL,
    email VARCHAR(60) UNIQUE NOT NULL,
    name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50),
    phone_number varchar(20)
);

CREATE TABLE public.permissions (
    p_key VARCHAR(10) NOT NULL PRIMARY KEY
);

CREATE TABLE public.wallets (
    wallet_id SERIAL PRIMARY KEY,
    owner_id INTEGER NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
    title VARCHAR(50) NOT NULL,
    balance NUMERIC(15,6) NOT NULL,
    period_start SMALLINT NOT NULL
);

CREATE TABLE public.users_wallets (
    wallet_id INTEGER NOT NULL REFERENCES public.wallets(wallet_id) ON DELETE CASCADE,
    user_id INTEGER NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
    p_key varchar(10) NOT NULL REFERENCES public.permissions(p_key) ON DELETE SET NULL
);

CREATE TABLE public.categories (
    category_id SERIAL PRIMARY KEY,
    title VARCHAR(50) NOT NULL,
    wallet_id INTEGER NOT NULL REFERENCES public.wallets(wallet_id) ON DELETE CASCADE
);

CREATE TABLE public.tags (
    tag_id SERIAL PRIMARY KEY,
    title VARCHAR(50) NOT NULL,
    color VARCHAR(7) NOT NULL,
    wallet_id INTEGER NOT NULL REFERENCES public.wallets(wallet_id) ON DELETE CASCADE
);

CREATE TABLE public.categories_tags (
    category_id INTEGER NOT NULL REFERENCES public.categories(category_id) ON DELETE CASCADE,
    tag_id INTEGER NOT NULL REFERENCES public.tags(tag_id) ON DELETE CASCADE
);

CREATE TABLE public.budgets (
    budget_id SERIAL PRIMARY KEY,
    title VARCHAR(50) NOT NULL,
    threshold INTEGER NOT NULL,
    wallet_id INTEGER NOT NULL REFERENCES public.wallets(wallet_id) ON DELETE CASCADE
);

CREATE TABLE public.categories_budgets (
    category_id INTEGER NOT NULL REFERENCES public.categories(category_id) ON DELETE CASCADE,
    budget_id INTEGER NOT NULL REFERENCES public.budgets(budget_id) ON DELETE CASCADE
);

CREATE TABLE public.transactions (
    transaction_id SERIAL PRIMARY KEY,
    amount NUMERIC(15,6) NOT NULL,
    category_id INTEGER REFERENCES public.categories(category_id) ON DELETE SET NULL,
    wallet_id INTEGER NOT NULL REFERENCES public.wallets(wallet_id) ON DELETE CASCADE,
    transaction_date DATE NOT NULL,
    user_id INTEGER NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
    comment VARCHAR(200)
);

CREATE INDEX idx_select_transactions_wallet_id_category_id_transactions_date ON transactions(wallet_id, category_id, transaction_date);
CREATE INDEX idx_select_user_wallets_user_id ON users_wallets(user_id);
CREATE INDEX idx_select_users_wallet_wallet_id ON users_wallets(wallet_id);
CREATE INDEX idx_select_categories_budget_id ON categories_budgets(budget_id);

-- triggers

CREATE OR REPLACE FUNCTION add_wallet_id_with_owner_to_users_wallets()
    RETURNS TRIGGER
    LANGUAGE PLPGSQL
    AS
$$
BEGIN
    INSERT INTO public.users_wallets(wallet_id, user_id, p_key)
    VALUES(NEW.wallet_id,NEW.owner_id,'RW');
    RETURN NULL;
END;
$$;

CREATE TRIGGER new_wallet_was_added
  AFTER INSERT
  ON public.wallets
  FOR EACH ROW
  EXECUTE PROCEDURE add_wallet_id_with_owner_to_users_wallets();
