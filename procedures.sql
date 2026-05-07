CREATE OR REPLACE PROCEDURE sp_assign_task(
    IN p_task_id INT,
    IN p_user_id INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_current_status VARCHAR(20);
    v_user_role VARCHAR(20);
BEGIN
    -- Проверка существования задачи и получение текущего статуса
    SELECT status INTO v_current_status FROM tasks WHERE id = p_task_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Задача с ID % не найдена', p_task_id;
    END IF;

    -- Проверка роли пользователя
    SELECT role INTO v_user_role FROM users WHERE id = p_user_id;
    
    IF v_user_role != 'executor' AND v_user_role != 'manager' THEN
        RAISE EXCEPTION 'Пользователь с ID % не может быть исполнителем', p_user_id;
    END IF;

    -- Проверка возможности изменения статуса
    IF v_current_status IN ('done', 'rejected') THEN
        RAISE EXCEPTION 'Нельзя изменить исполнителя для задачи со статусом %', v_current_status;
    END IF;

    -- Обновление задачи
    UPDATE tasks 
    SET executor_id = p_user_id,
        status = 'in_progress',
        updated_at = CURRENT_TIMESTAMP
    WHERE id = p_task_id;

END;
$$;

CREATE OR REPLACE PROCEDURE sp_complete_task(
    IN p_task_id INT,
    IN p_executor_id INT,
    IN p_report_content TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_current_status VARCHAR(20);
BEGIN
    -- Проверка текущего статуса задачи
    SELECT status INTO v_current_status 
    FROM tasks 
    WHERE id = p_task_id AND executor_id = p_executor_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Задача не найдена или не принадлежит данному исполнителю';
    END IF;

    IF v_current_status != 'in_progress' THEN
        RAISE EXCEPTION 'Задача должна быть в статусе "in_progress" для завершения. Текущий статус: %', v_current_status;
    END IF;

    -- Обновление статуса задачи
    UPDATE tasks 
    SET status = 'review',
        updated_at = CURRENT_TIMESTAMP
    WHERE id = p_task_id;

    -- Автоматическое создание отчета
    INSERT INTO reports (task_id, author_id, content, submitted_at, is_accepted)
    VALUES (p_task_id, p_executor_id, p_report_content, CURRENT_TIMESTAMP, FALSE);

END;
$$;

CREATE OR REPLACE PROCEDURE sp_archive_completed_projects(
    IN p_days_after_deadline INT DEFAULT 7
)
LANGUAGE plpgsql
AS $$
DECLARE
    proj_record RECORD;
BEGIN
    -- Поиск проектов, где все задачи выполнены и прошел срок после дедлайна
    FOR proj_record IN 
        SELECT p.id, p.name
        FROM projects p
        WHERE p.status = 'active'
          AND p.end_date < CURRENT_DATE - INTERVAL '1 day' * p_days_after_deadline
          AND NOT EXISTS (
              SELECT 1 FROM tasks t 
              WHERE t.project_id = p.id 
              AND t.status != 'done'
          )
    LOOP
        -- Обновление статуса проекта
        UPDATE projects 
        SET status = 'archived'
        WHERE id = proj_record.id;

        -- Логирование действия (опционально, если есть триггер или вручную)
        INSERT INTO audit_log (action, table_name, record_id, new_values, performed_at)
        VALUES ('UPDATE', 'projects', proj_record.id, '{"status": "archived"}', CURRENT_TIMESTAMP);
        
        RAISE NOTICE 'Проект "%" архивирован.', proj_record.name;
    END LOOP;

END;
$$;