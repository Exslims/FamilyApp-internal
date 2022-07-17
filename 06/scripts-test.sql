
DROP TABLE IF EXISTS public.transactions
CREATE TABLE public.transactions (
    transaction_id SERIAL PRIMARY KEY,
    amount NUMERIC(15,6) NOT NULL,
    category_id INTEGER REFERENCES public.categories(category_id) ON DELETE SET NULL,
    wallet_id INTEGER NOT NULL REFERENCES public.wallets(wallet_id) ON DELETE CASCADE,
    transaction_date DATE NOT NULL,
    user_id INTEGER NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
    comment VARCHAR(200)
);

-- нагенерить 5000 тразакций
INSERT INTO public.transactions(amount, category_id, wallet_id, transaction_date, user_id, comment)
SELECT
    (random() * 10000)::numeric(15,6),
    (CASE
        WHEN random() < 1::real/2 THEN 1
        ELSE 2
     END) as category_id,
    1,
    current_date + floor((random() * 15))::int,
    1,
    (CASE
        WHEN i % 5 = 0 THEN 'Большая покупка'
        WHEN i % 3 = 0 THEN 'Билеты для отпуска'
        WHEN i % 2 = 0 THEN 'Продукты в перекрестке'
        ELSE NULL
     END) as comment
FROM generate_series(1,5000) as i;

-- Создать индекс к какой-либо из таблиц вашей БД
-- индекс на поле transaction_date
EXPLAIN (costs, verbose, format json) SELECT comment, category_id, transaction_date FROM public.transactions WHERE transaction_date BETWEEN '2022-07-25' and '2022-07-25';
 Seq Scan on public.transactions as transactions (cost=0..137 rows=351 width=41) -- без индекса

CREATE INDEX idx_transactions_transaction_date ON public.transactions(transaction_date);
ANALYZE public.transactions;
-- Прислать текстом результат команды explain, в которой используется данный индекс
 Bitmap Index Scan using idx_transactions_transaction_date (cost=0..7.79 rows=351 width=0) -- с индексом

-- Реализовать индекс на часть таблицы или индекс на поле с функцией
-- Выгрузка записей с суммой больше 8000
EXPLAIN (costs, verbose, format json) SELECT comment, category_id, transaction_date FROM public.transactions WHERE amount > 8000;
 Seq Scan on public.transactions as transactions (cost=0..118.5 rows=1015 width=44) -- без индекса

CREATE INDEX idx_transactions_amount ON public.transactions(amount) WHERE amount > 8000;
  Bitmap Index Scan using idx_transactions_amount (cost=0..29.35 rows=1015 width=0)	 -- с индексом

-- Реализовать индекс для полнотекстового поиска
SELECT comment, category_id, transaction_date, comment_lexemme from public.transactions WHERE comment IS NOT NULL;

ALTER TABLE public.transactions ADD COLUMN comment_lexemme tsvector;
UPDATE public.transactions
SET comment_lexemme = to_tsvector(comment);

EXPLAIN (costs, verbose, format json) SELECT comment, category_id, transaction_date, comment_lexemme from public.transactions
WHERE comment_lexemme @@ to_tsquery('билеты | покупка' );
 Seq Scan on public.transactions as transactions (cost=0..1449.5 rows=1969 width=104) -- без индекса

CREATE INDEX idx_comment_lexemme_gin ON public.transactions USING GIN (comment_lexemme);
ANALYZE public.transactions;
 Bitmap Index Scan using idx_comment_lexemme_gin (cost=0..27.02 rows=1969 width=0) -- с индексом

-- Создать индекс на несколько полей
-- сложно пока было придумать, этот вряд ли будет использоваться
CREATE INDEX idx_select_transactions_wallet_id_category_id_transactions_date ON public.transactions(wallet_id, transaction_date);
