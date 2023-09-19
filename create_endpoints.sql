DROP TABLE IF EXISTS hold_endpoints;
CREATE TABLE hold_endpoints (
  id INT AUTO_INCREMENT NOT NULL,
  endpoint_path VARCHAR(100) NOT NULL,
  verb VARCHAR(10) NOT NULL,
  code INT NOT NULL,
  headers JSON,
  body JSON,
  PRIMARY KEY(`id`),
  UNIQUE INDEX(`endpoint_path`, `verb`)
);

INSERT INTO hold_endpoints(endpoint_path, verb, code, headers, body) 
VALUES("greeting", 'GET', 200, NULL, '{"message":"Hello, world"}');
