CREATE OR REPLACE VIEW v_task_details AS
SELECT
    t.id AS task_id,
    t.title,
    t.status,
    t.priority,
    t.deadline,
    p.name AS project_name,
    tt.name AS task_type,
    u.username AS executor_name
FROM tasks t
JOIN projects p ON t.project_id = p.id
JOIN task_types tt ON t.type_id = tt.id
LEFT JOIN users u ON t.executor_id = u.id;

CREATE OR REPLACE VIEW v_project_stats AS
SELECT
    p.id AS project_id,
    p.name AS project_name,
    COUNT(t.id) AS total_tasks,
    COUNT(CASE WHEN t.status = 'done' THEN 1 END) AS completed_tasks,
    ROUND(
        (COUNT(CASE WHEN t.status = 'done' THEN 1 END)::NUMERIC / NULLIF(COUNT(t.id), 0)) * 100, 
        2
    ) AS completion_percentage
FROM projects p
LEFT JOIN tasks t ON p.id = t.project_id
GROUP BY p.id, p.name;