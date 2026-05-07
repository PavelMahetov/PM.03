-- ============================================================
-- Создание ролей СУБД (PostgreSQL)
-- ============================================================

DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'role_reader') THEN
        CREATE ROLE role_reader;
    END IF;
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'role_manager') THEN
        CREATE ROLE role_manager;
    END IF;
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'role_admin') THEN
        CREATE ROLE role_admin;
    END IF;
END
$$;

-- Предоставление прав на схему и таблицы
GRANT USAGE ON SCHEMA public TO role_reader, role_manager, role_admin;

-- Привилегии роли 1 (Чтение для исполнителей)
GRANT SELECT ON departments, users, projects, task_types, tasks TO role_reader;
-- Исполнители могут добавлять отчеты и комментарии
GRANT INSERT, SELECT ON reports, comments TO role_reader;
GRANT USAGE, SELECT ON SEQUENCE reports_id_seq, comments_id_seq TO role_reader;

-- Привилегии роли 2 (Менеджер - полный доступ к рабочим данным)
GRANT SELECT, INSERT, UPDATE, DELETE ON tasks, projects TO role_manager;
GRANT SELECT ON departments, users, task_types TO role_manager;
GRANT SELECT, INSERT, UPDATE ON reports, comments TO role_manager;
GRANT USAGE, SELECT ON SEQUENCE tasks_id_seq, projects_id_seq, reports_id_seq, comments_id_seq TO role_manager;

-- Доступ к процедурам для менеджера
GRANT EXECUTE ON PROCEDURE sp_assign_task(INT, INT) TO role_manager;
GRANT EXECUTE ON PROCEDURE sp_complete_task(INT, INT, TEXT) TO role_manager;
GRANT EXECUTE ON PROCEDURE sp_archive_completed_projects(INT) TO role_manager;

-- Привилегии роли 3 (Администратор - полный доступ)
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO role_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO role_admin;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO role_admin;
GRANT SELECT ON audit_log TO role_admin; -- Только админ читает логи

-- Создание пользователей БД и назначение ролей

CREATE USER db_executor WITH PASSWORD 'exec_pass_123';
GRANT role_reader TO db_executor;

CREATE USER db_manager WITH PASSWORD 'mgr_pass_123';
GRANT role_manager TO db_manager;

CREATE USER db_admin WITH PASSWORD 'admin_pass_123';
GRANT role_admin TO db_admin;