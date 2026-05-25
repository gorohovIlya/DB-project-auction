DELIMITER //

CREATE TRIGGER `incorrect_stake_trigger`
BEFORE INSERT ON `stake_history` 
FOR EACH ROW
BEGIN
    DECLARE v_min_cost DECIMAL(15, 2);
    DECLARE v_step DECIMAL(15, 2);
    DECLARE v_current_max DECIMAL(15, 2);
    DECLARE v_active_status_id INT UNSIGNED;
    DECLARE v_cancelled_status_id INT UNSIGNED;
    
    SELECT id INTO v_active_status_id FROM statuses WHERE status = 'active' LIMIT 1;
    SELECT id INTO v_cancelled_status_id FROM statuses WHERE status = 'cancelled' LIMIT 1;
    
    SELECT costs, step INTO v_min_cost, v_step
    FROM min_stakes
    WHERE id = NEW.min_stake_id;
    
    IF NEW.money_amount < v_min_cost THEN
        SET NEW.status_code = v_cancelled_status_id;
        SET NEW.created_at = NOW();
    ELSEIF (NEW.money_amount - v_min_cost) % v_step != 0 THEN
        SET NEW.status_code = v_cancelled_status_id;
        SET NEW.created_at = NOW();
    ELSE
        SELECT MAX(money_amount) INTO v_current_max
        FROM stake_history
        WHERE min_stake_id = NEW.min_stake_id 
          AND status_code = v_active_status_id;
        
        IF v_current_max IS NOT NULL AND NEW.money_amount <= v_current_max THEN
            SET NEW.status_code = v_cancelled_status_id;
        ELSE
            SET NEW.status_code = v_active_status_id;
            
            UPDATE stake_history 
            SET status_code = (SELECT id FROM statuses WHERE status = 'outbid' LIMIT 1)
            WHERE min_stake_id = NEW.min_stake_id 
              AND status_code = v_active_status_id
              AND money_amount = v_current_max;
        END IF;
        
        SET NEW.created_at = NOW();
    END IF;
END //

DELIMITER ;