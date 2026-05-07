-- Departments
INSERT INTO departments (name, description) VALUES
    ('Отдел разработки', 'Разработка программного обеспечения и поддержка'),
    ('Отдел тестирования', 'Контроль качества и тестирование ПО'),
    ('Отдел аналитики', 'Бизнес-анализ и проектирование требований');

-- Users
INSERT INTO users (username, email, password_hash, role, department_id) VALUES
    ('ivanov_dev', 'ivanov@company.com', '$2b$10$hash_placeholder_1', 'executor', 1),
    ('petrova_qa', 'petrova@company.com', '$2b$10$hash_placeholder_2', 'executor', 2),
    ('sidorov_mgr', 'sidorov@company.com', '$2b$10$hash_placeholder_3', 'manager', 1);

-- Projects
INSERT INTO projects (name, start_date, end_date, status, manager_id) VALUES
    ('CRM Система v2.0', '2026-01-15', '2026-06-30', 'active', 3),
    ('Мобильное приложение', '2026-02-01', '2026-08-01', 'active', 3),
    ('Внутренний портал', '2025-11-01', '2026-03-01', 'completed', 3);

-- Task Types
INSERT INTO task_types (name, color_code) VALUES
    ('Feature', '#4CAF50'),
    ('Bug', '#F44336'),
    ('Documentation', '#2196F3');

-- Tasks
INSERT INTO tasks (project_id, type_id, title, description, priority, status, executor_id, deadline) VALUES
    (1, 1, 'Реализация авторизации', 'Разработать модуль входа через OAuth2', 'high', 'in_progress', 1, '2026-05-20'),
    (1, 2, 'Исправление бага в отчете', 'Ошибка при экспорте PDF', 'critical', 'new', NULL, '2026-05-10'),
    (2, 3, 'Написание ТЗ', 'Подготовить документацию по API', 'medium', 'done', 2, '2026-04-30');

-- Reports
INSERT INTO reports (task_id, author_id, content, is_accepted, manager_comment) VALUES
    (3, 2, 'Документация подготовлена и загружена в репозиторий', TRUE, 'Принято, отличная работа'),
    (1, 1, 'Реализован базовый функционал входа, требуется код-ревью', FALSE, NULL),
    (1, 1, 'Добавлены юнит-тесты для модуля авторизации', FALSE, NULL);

-- Comments
INSERT INTO comments (task_id, author_id, content) VALUES
    (1, 3, 'Иван, уточни требования по безопасности паролей'),
    (2, 3, 'Нужно срочно назначить исполнителя, дедлайн горит'),
    (3, 1, 'Есть вопросы по формату JSON в примерах');

-- Audit Log (Эмуляция истории изменений)
INSERT INTO audit_log (user_id, action, table_name, record_id, old_values, new_values) VALUES
    (3, 'INSERT', 'tasks', 1, NULL, '{"title": "Реализация авторизации", "status": "new"}'),
    (1, 'UPDATE', 'tasks', 1, '{"status": "new"}', '{"status": "in_progress"}'),
    (2, 'INSERT', 'reports', 1, NULL, '{"content": "Документация подготовлена..."}');