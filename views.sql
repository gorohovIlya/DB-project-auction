-- Список категорий для первых 10 лотов
CREATE VIEW `view_lots_categories` AS
SELECT
    l.name,
    GROUP_CONCAT(DISTINCT c.name SEPARATOR ', ') AS categories
FROM lots AS l
JOIN categories_lots AS cl ON l.id = cl.lot_id
JOIN categories AS c ON cl.category_id = c.id
GROUP BY l.id, l.name
ORDER BY l.id ASC
LIMIT 10;

-- Количество всех ставок по статусам
CREATE VIEW `view_stakes_by_status` AS
SELECT
    s.status,
    COUNT(*) AS cnt
FROM stake_history sh
JOIN statuses s ON sh.status_code = s.id
GROUP BY s.status
ORDER BY cnt DESC;

-- Топ-3 человека по количеству ставок
CREATE VIEW `view_top_clients_by_stakes` AS
SELECT
    CONCAT(c.name, ' ', c.lastname) AS full_name,
    COUNT(*) AS cnt
FROM stake_history sh
JOIN clients c ON sh.client_id = c.id
GROUP BY full_name
ORDER BY cnt DESC
LIMIT 3;

-- Категории по количеству лотов
CREATE VIEW `view_categories_by_lots_count` AS
SELECT
    ct.name,
    COUNT(*) AS cnt
FROM min_stakes ms
JOIN lots l ON ms.lot_id = l.id
JOIN categories_lots ctl ON l.id = ctl.lot_id
JOIN categories ct ON ctl.category_id = ct.id
GROUP BY ct.name
ORDER BY cnt DESC;

-- Сравнение минимальной и итоговой ставки для лотов
CREATE VIEW `view_stakes_delta` AS
SELECT
    l.name,
    MAX(sh.money_amount) - ms.costs AS delta,
    ROUND((MAX(sh.money_amount) - ms.costs) * 100 / ms.costs, 2) AS delta_proc
FROM stake_history sh
JOIN min_stakes ms ON sh.min_stake_id = ms.id
JOIN lots l ON ms.lot_id = l.id
GROUP BY l.id, l.name, ms.costs
ORDER BY delta_proc DESC;

-- Текущие лидеры по каждому лоту (максимальные ставки)
CREATE VIEW `view_current_leaders` AS
SELECT
    l.name AS lot_name,
    CONCAT(c.name, ' ', c.lastname) AS leader_name,
    MAX(sh.money_amount) AS current_bid,
    ms.costs AS starting_price,
    ms.step AS bid_step
FROM stake_history sh
JOIN min_stakes ms ON sh.min_stake_id = ms.id
JOIN lots l ON ms.lot_id = l.id
JOIN clients c ON sh.client_id = c.id
JOIN statuses s ON sh.status_code = s.id
WHERE s.status IN ('active', 'win')
GROUP BY l.id, l.name, ms.costs, ms.step, c.id, c.name, c.lastname
ORDER BY current_bid DESC;