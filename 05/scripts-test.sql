
-- 3)Напишите запрос на добавление данных с выводом информации о добавленных строках.
-- сгененировать 3 пользователей
INSERT INTO public.users(password, email, name, last_name, phone_number)
VALUES(md5(random()::text), 'test1@mail.ru', 'Konstantin', 'Kuptsov', '+751235123'),
        (md5(random()::text), 'test2@mail.ru', 'Nikolay', 'Tuzov', '+741235123'),
        (md5(random()::text), 'test3@mail.ru', 'Aleksei', 'Reshetnikov', '+112335123'),
        (md5(random()::text), 'test4@mail.ru', 'Maxim', 'Olha', '+312335123')
RETURNING user_id, name, last_name;

-- добавить бизовые пермиссии
INSERT INTO public.permissions
VALUES ('RO'),('RW');

-- добавить по 1 кошельку к юзерам кроме последнего
INSERT INTO public.wallets(owner_id, title, balance, period_start)
SELECT
    user_id,
    'walletTitle' || substr(md5(random()::text),1,5),
    (random() * 10000)::numeric(15,6),
    floor(random()*31)+1
FROM generate_series(1,3) as user_id;

-- сделать общими кошельки с id=2,3 для юзера с id=1.
INSERT INTO public.users_wallets(wallet_id, user_id, p_key)
VALUES (2,1,'RO'),(3,1,'RW');

-- 1) Напишите запрос по своей базе с регулярным выражением, добавьте пояснение, что вы хотите найти.
-- Получить список юзеров у которых номер начинается с +7
SELECT users.user_id, users.name, users.last_name, users.phone_number
    FROM public.users as users
    WHERE users.phone_number LIKE '+7%';

-- 2) Напишите запрос по своей базе с использованием LEFT JOIN и INNER JOIN, как порядок соединений в FROM влияет на результат? Почему?
-- для INNER JOIN не имеет значимости порядок соеденений, но для внешних LEFT/RIGH/OUTER да, т.к результаты множества будут разные на каждом этапе.
-- получить список кошельков к которым есть доступ у юзера с id = 1
SELECT uw.user_id, w.wallet_id, uw.p_key FROM public.users_wallets as uw
    JOIN public.wallets as w using(wallet_id)
    WHERE uw.user_id = 1;

-- получить юзеров у которых еще нет ни 1 своего кошелька
SELECT u.user_id, u.name, w.wallet_id FROM public.users as u
    LEFT JOIN public.wallets as w ON u.user_id = w.owner_id
    WHERE w.wallet_id is NULL;

-- 4)Напишите запрос с обновлением данные используя UPDATE FROM.
CREATE TABLE public.users_wallets_stats (
    user_id INTEGER NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
    wallet_count SMALLINT DEFAULT 0 NOT NULL
);

INSERT INTO public.users_wallets_stats(user_id, wallet_count)
    VALUES (1,0), (2,0), (3,0), (4,0)
RETURNING user_id, wallet_count;

-- посчитать кол-во кошельков по каждому юзеру и занести их в колонку wallet_count
UPDATE public.users_wallets_stats as uws
SET wallet_count = (SELECT count(*)
	FROM public.users_wallets as uw
	WHERE uw.user_id = uws.user_id)
WHERE uws.user_id in (1,2,3,4)
RETURNING uws.user_id, uws.wallet_count;

-- 5)Напишите запрос для удаления данных с оператором DELETE используя join с другой таблицей с помощью using.
DELETE FROM public.users_wallets_stats as uws
    USING public.users as u
    WHERE u.user_id = uws.user_id
    RETURNING uws.*;
-- SELECT * FROM public.users as u, public.users_wallets_stats as uws WHERE u.user_id = uws.user_id;

-- 6) Приведите пример использования утилиты COPY (по желанию)
COPY (SELECT * FROM public.users) TO '/copies/users.copy';
COPY public.users FROM '/copies/users.copy';
