DROP PROCEDURE IF EXISTS sleep_and_return;
DELIMITER //
CREATE PROCEDURE sleep_and_return(IN seconds INT)
BEGIN
    DO SLEEP(seconds);
    SELECT seconds;
END //
DELIMITER ;
