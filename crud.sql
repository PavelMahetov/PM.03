-- ============================================================
-- Демонстрация CRUD-операций для таблицы tasks
-- ============================================================

-- 1. CREATE: Создание новой задачи
-- В реальном приложении значения подставляются через параметры (%s)
INSERT INTO tasks (project_id, type_id, title, description, priority, status, executor_id, deadline)
VALUES (
    1,                  -- project_id (CRM Система v2.0)
    1,                  -- type_id (Feature)
    'Интеграция API',   -- title
    'Подключить внешний сервис уведомлений', -- description
    'high',             -- priority
    'new',              -- status
    NULL,               -- executor_id (пока не назначен)
    '2026-06-15'        -- deadline
);

-- 2. READ: Чтение данных через VIEW
-- Получаем список всех задач с подробной информацией
SELECT * FROM v_task_details ORDER BY deadline ASC;

-- Фильтрация: только активные задачи проекта CRM
SELECT * FROM v_task_details 
WHERE project_name = 'CRM Система v2.0' AND status != 'done';

-- 3. UPDATE: Обновление задачи
-- Назначаем исполнителя и меняем статус на 'in_progress'
-- Триггер trg_update_timestamp автоматически обновит поле updated_at
UPDATE tasks 
SET status = 'in_progress',
    executor_id = 1     -- ivanov_dev
WHERE id = LASTVAL();   -- Используем ID последней вставленной записи (для демо)

-- Проверка результата обновления
SELECT title, status, executor_id, updated_at 
FROM tasks 
WHERE id = LASTVAL();

-- 4. DELETE: Удаление задачи
-- Удаляем задачу. Благодаря CASCADE удалятся связанные отчеты и комментарии
DELETE FROM tasks 
WHERE id = LASTVAL();

-- Проверка удаления (задача должна исчезнуть из списка)
SELECT COUNT(*) AS remaining_tasks_count 
FROM tasks 
WHERE title = 'Интеграция API';