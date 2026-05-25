CREATE TABLE IF NOT EXISTS `categories` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(255) NOT NULL,
    PRIMARY KEY (`id`)
);

CREATE TABLE IF NOT EXISTS `lots` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(255) NOT NULL,
    `description` VARCHAR(511),
    FOREIGN KEY(`category_id`) REFERENCES categories(`id`),
    PRIMARY KEY(`id`)
    );

CREATE TABLE IF NOT EXISTS `categories_lots` (
    `lot_id` INT UNSIGNED NOT NULL,
    `category_id` INT UNSIGNED NOT NULL,
    PRIMARY KEY(`lot_id`, `category_id`),
    FOREIGN KEY (`lot_id`) REFERENCES lots(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`category_id`) REFERENCES categories(`id`) ON DELETE CASCADE
);
    
CREATE TABLE IF NOT EXISTS `min_stakes` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `lot_id` INT UNSIGNED NOT NULL,
    `costs` DECIMAL(15, 2) NOT NULL,
    `step` DECIMAL(15, 2) NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY (`lot_id`),
    FOREIGN KEY (`lot_id`) REFERENCES lots(id)
    ON DELETE CASCADE
    );

CREATE TABLE IF NOT EXISTS `clients` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(255) NOT NULL,
    `lastname` VARCHAR(255) NOT NULL,
    PRIMARY KEY(`id`)
    );

CREATE TABLE IF NOT EXISTS `statuses` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `status` VARCHAR(255) NOT NULL,
    PRIMARY KEY(`id`)
);   

CREATE TABLE IF NOT EXISTS `stake_history` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `min_stake_id` INT UNSIGNED NOT NULL,
    `client_id` INT UNSIGNED NOT NULL,
    `created_at` DATETIME,
    `money_amount` DECIMAL(15, 2),
    `status_code` INT UNSIGNED NOT NULL,
    PRIMARY KEY (`id`),
    FOREIGN KEY (`min_stake_id`) REFERENCES min_stakes(`id`),
    FOREIGN KEY (`client_id`) REFERENCES clients(`id`),
    FOREIGN KEY (`status_code`) REFERENCES statuses(`id`),
    ON DELETE CASCADE
    );