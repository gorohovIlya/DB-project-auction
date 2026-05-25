# Отчет по базе данных "Аукцион"

## Описание

База данных предназначена для проведения онлайн-аукционов с возможностью отслеживания лотов, ставок, клиентов и категорий товаров.

## Особенности структуры

- Связь многие-ко-многим между лотами и категориями через таблицу `categories_lots`
- Триггер `incorrect_stake_trigger` автоматически проверяет корректность ставок и обновляет статусы
- Уникальный ключ `lot_id` в таблице `min_stakes` гарантирует, что у каждого лота только одна минимальная ставка и шаг
- `ON DELETE CASCADE` обеспечивает каскадное удаление связанных данных (при удалении лота удаляются его ставки)

## Связи между таблицами

- `lots` → `categories`: many-to-many (Через `categories_lots`)
- `stake_history` → `min_stakes`: many-to-one (История ставок может хранить    несколько ставок для каждой минимальной ставки)
- `stake_history` → `clients`: many-to-one (У одного клиента может быть несколько ставок)
- `stake_history` → `statuses`: many-to-one (В истории ставок может храниться несколько ставок с одинаковым статусом)
- `min_stakes` → `lots`: one-to-one (У каждого лота одна минимальная ставка)

## Типовые запросы

### INSERT (Добавление данных)

### Простые вставки

```sql
-- Новая категория
INSERT INTO categories (name) VALUES ('Антиквариат');

-- Новый статус
INSERT INTO statuses (status) VALUES ('pending');

-- Новый клиент
INSERT INTO clients (name, lastname) VALUES ('Илья', 'Горохов');
```

### Добавление лота с категориями

```sql
-- Добавление лота
INSERT INTO lots (name, description) 
VALUES ('Винтажные часы', 'Швейцарские часы 1950 года');

-- Добавление минимальной ставки
INSERT INTO min_stakes (lot_id, costs, step) 
VALUES (LAST_INSERT_ID(), 10000.00, 500.00);

-- Привязка к категориям
INSERT INTO categories_lots (lot_id, category_id) VALUES
(LAST_INSERT_ID(), 1),  -- Антиквариат
(LAST_INSERT_ID(), 5);  -- Часы
```

### Добавление новых строк в историю ставок

```sql
INSERT INTO stake_history (min_stake_id, client_id, money_amount, status_code) VALUES
(1, 1, 52500.00, (SELECT id FROM statuses WHERE status = 'active' LIMIT 1)),
(1, 2, 55000.00, (SELECT id FROM statuses WHERE status = 'active' LIMIT 1)),
(2, 3, 80000.00, (SELECT id FROM statuses WHERE status = 'active' LIMIT 1));
```

### SELECT (Выборка данных)

#### Простые выборки

```sql
-- Все лоты определенной категории (Живопись - id=1)
SELECT l.* FROM lots l
JOIN categories_lots cl ON l.id = cl.lot_id
WHERE cl.category_id = 1;

-- Все активные ставки
SELECT * FROM stake_history 
WHERE status_code = (SELECT id FROM statuses WHERE status = 'active');

-- Топ-5 самых дорогих ставок
SELECT * FROM stake_history 
ORDER BY money_amount DESC 
LIMIT 5;

-- Аукционы с ценой от 50000 до 100000
SELECT l.name, ms.costs, ms.step 
FROM lots l
JOIN min_stakes ms ON l.id = ms.lot_id
WHERE ms.costs BETWEEN 50000 AND 100000;
```

### Использование VIEW

```sql
-- Категории для первых 10 лотов
SELECT * FROM view_lots_categories;

-- Количество ставок по статусам
SELECT * FROM view_stakes_by_status;

-- Топ-3 клиента по ставкам
SELECT * FROM view_top_clients_by_stakes;

-- Категории по количеству лотов
SELECT * FROM view_categories_by_lots_count;

-- Разница между финальной и стартовой ставкой
SELECT * FROM view_stakes_delta;
```

### UPDATE (обновление данных)

```sql
-- Изменить название категории
UPDATE categories SET name = 'Современное искусство' WHERE name = 'Живопись';

-- Обновить шаг аукциона для лота
UPDATE min_stakes SET step = 3000.00 WHERE lot_id = 1;
```

### DELETE (удаление данных)

```sql
-- Удалить неактивные ставки старше года
DELETE FROM stake_history 
WHERE created_at < DATE_SUB(NOW(), INTERVAL 1 YEAR)
AND status_code = (SELECT id FROM statuses WHERE status = 'cancelled');

-- Удалить категорию без лотов
DELETE FROM categories 
WHERE id NOT IN (SELECT DISTINCT category_id FROM categories_lots);
```

### Триггер проверки ставок

```sql
-- Триггер автоматически проверяет:
-- 1. Ставка не меньше минимальной стоимости
-- 2. Ставка кратна шагу аукциона
-- 3. Ставка выше текущей максимальной
-- При нарушении условий устанавливается статус 'cancelled'
```
