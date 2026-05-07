CREATE OR REPLACE FUNCTION fn_tasks_audit()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status IS DISTINCT FROM NEW.status 
       OR OLD.executor_id IS DISTINCT FROM NEW.executor_id 
       OR OLD.deadline IS DISTINCT FROM NEW.deadline THEN
        
        INSERT INTO audit_log (user_id, action, table_name, record_id, old_values, new_values, performed_at)
        VALUES (
            NULL, -- ID пользователя можно передать через session variable, здесь упрощено
            'UPDATE',
            'tasks',
            NEW.id,
            to_jsonb(OLD),
            to_jsonb(NEW),
            CURRENT_TIMESTAMP
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_tasks_audit
AFTER UPDATE ON tasks
FOR EACH ROW
EXECUTE FUNCTION fn_tasks_audit();


CREATE OR REPLACE FUNCTION fn_update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_timestamp
BEFORE UPDATE ON tasks
FOR EACH ROW
EXECUTE FUNCTION fn_update_timestamp();