-- Rebuild SExI: create and populate EXPENSE table in the memory.default schema

USE memory.default;

-- Expenses table: tracks individual employee expenses
DROP TABLE IF EXISTS expense;
CREATE TABLE expense (
    employee_id TINYINT NOT NULL,
    unit_price DECIMAL(8,2) NOT NULL,
    quantity TINYINT NOT NULL
);

-- Populate the EXPENSE table with initial data
INSERT INTO expense (employee_id, unit_price, quantity) VALUES
    (3, 6.50, 14),   -- Alex Jacobson
    (3, 11.00, 20),  -- Alex Jacobson
    (3, 22.00, 18),  -- Alex Jacobson
    (3, 13.00, 75),  -- Alex Jacobson
    (9, 300.00, 1),  -- Andrea Ghibaudi
    (4, 40.00, 9),   -- Darren Poynton
    (2, 17.50, 4);   -- Umberto Torrielli
