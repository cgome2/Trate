--
-- File generated with SQLiteStudio v3.0.7 on Wed May 22 14:44:46 2019
--
-- Text encoding used: UTF-8
--
PRAGMA foreign_keys = off;
BEGIN TRANSACTION;

-- Table: indexes
DELETE FROM indexes WHERE TABLE_NAME='devices';
INSERT INTO indexes (NAME, id, TABLE_NAME, field_name) VALUES ('device_id', 200100019, 'devices', 'id');
DELETE FROM indexes WHERE TABLE_NAME='buses';
INSERT INTO indexes (NAME, id, TABLE_NAME, field_name) VALUES ('bus_id', 200100012, 'buses', 'id');
DELETE FROM indexes WHERE TABLE_NAME='rules';
INSERT INTO indexes (NAME, id, TABLE_NAME, field_name) VALUES ('rule_id', 200100001, 'rules', 'id');
DELETE FROM indexes WHERE TABLE_NAME='nozzles';
INSERT INTO indexes (NAME, id, TABLE_NAME, field_name) VALUES ('nozzle_id', 200100005, 'nozzles', 'id');
DELETE FROM indexes WHERE TABLE_NAME='ps_clusters';
INSERT INTO indexes (NAME, id, TABLE_NAME, field_name) VALUES ('ps_clusters', 200100002, 'ps_clusters', 'id');
DELETE FROM indexes WHERE TABLE_NAME='probes';
INSERT INTO indexes (NAME, id, TABLE_NAME, field_name) VALUES ('probe_id', 200100001, 'probes', 'id');
DELETE FROM indexes WHERE TABLE_NAME='tanks';
INSERT INTO indexes (NAME, id, TABLE_NAME, field_name) VALUES ('tank_id', 200100002, 'tanks', 'id');
DELETE FROM indexes WHERE TABLE_NAME='users';
INSERT INTO indexes (NAME, id, TABLE_NAME, field_name) VALUES ('user_id', 200100003, 'users', 'id');
DELETE FROM indexes WHERE TABLE_NAME='alarms_log';
INSERT INTO indexes (NAME, id, TABLE_NAME, field_name) VALUES ('alarms_log', 200100002, 'alarms_log', 'id');
DELETE FROM indexes WHERE TABLE_NAME='products';
INSERT INTO indexes (NAME, id, TABLE_NAME, field_name) VALUES ('products', 200100002, 'products', 'id');
DELETE FROM indexes WHERE TABLE_NAME='means';
INSERT INTO indexes (NAME, id, TABLE_NAME, field_name) VALUES ('means', 200100674, 'means', 'id');
DELETE FROM indexes WHERE TABLE_NAME='history_log_t';
INSERT INTO indexes (NAME, id, TABLE_NAME, field_name) VALUES ('history_log_t', 200100152, 'history_log_t', 'history_id');
DELETE FROM indexes WHERE TABLE_NAME='fleets';
INSERT INTO indexes (NAME, id, TABLE_NAME, field_name) VALUES ('fleets', 200100002, 'fleets', 'id');
DELETE FROM indexes WHERE TABLE_NAME='error_log_t';
INSERT INTO indexes (NAME, id, TABLE_NAME, field_name) VALUES ('error_log_t', 200100481, 'error_log_t', 'id');
DELETE FROM indexes WHERE TABLE_NAME='depts';
INSERT INTO indexes (NAME, id, TABLE_NAME, field_name) VALUES ('depts', 200100002, 'depts', 'id');
DELETE FROM indexes WHERE TABLE_NAME='cms_rom';
INSERT INTO indexes (NAME, id, TABLE_NAME, field_name) VALUES ('cms_rom', 200100001, 'cms_rom', 'rid');
DELETE FROM indexes WHERE TABLE_NAME='inventory_t';
INSERT INTO indexes (NAME, id, TABLE_NAME, field_name) VALUES ('inventory_t', 200103844, 'inventory_t', 'inventory_id');
DELETE FROM indexes WHERE TABLE_NAME='export_template_d';
INSERT INTO indexes (NAME, id, TABLE_NAME, field_name) VALUES ('export_template_d', 200100001, 'export_template_d', 'id');
DELETE FROM indexes WHERE TABLE_NAME='tank_delivery_readings_t';
INSERT INTO indexes (NAME, id, TABLE_NAME, field_name) VALUES ('tank_delivery_readings_t', 200100281, 'tank_delivery_readings_t', 'reception_unique_id');
DELETE FROM indexes WHERE TABLE_NAME='wp_registration';
INSERT INTO indexes (NAME, id, TABLE_NAME, field_name) VALUES ('wp_registration', 200100001, 'wp_registration', 'id');
DELETE FROM indexes WHERE TABLE_NAME='cms_scheduler';
INSERT INTO indexes (NAME, id, TABLE_NAME, field_name) VALUES ('cms_scheduler', 200100007, 'cms_scheduler', 'id');

COMMIT TRANSACTION;
PRAGMA foreign_keys = on;
