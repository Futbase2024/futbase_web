<?php
/**
 * Database Connection Manager con Prepared Statements
 * Implementa connection pooling y manejo seguro de queries
 */
class Database {
    private static $instance = null;
    private $connection;

    private $host;
    private $username;
    private $password;
    private $database;
    private $charset = 'utf8mb4';

    private function __construct() {
        $config = require __DIR__ . '/../config/db_config.php';

        $this->host = $config['host'];
        $this->username = $config['username'];
        $this->password = $config['password'];
        $this->database = $config['database'];

        $this->connect();
    }

    /**
     * Singleton pattern para reutilizar la conexión
     */
    public static function getInstance() {
        if (self::$instance === null) {
            self::$instance = new self();
        }
        return self::$instance;
    }

    /**
     * Establece la conexión con MySQL usando PDO
     */
    private function connect() {
        try {
            $dsn = "mysql:host={$this->host};dbname={$this->database};charset={$this->charset}";

            $options = [
                PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES   => false,
                PDO::ATTR_PERSISTENT         => true, // Connection pooling
            ];

            $this->connection = new PDO($dsn, $this->username, $this->password, $options);

        } catch (PDOException $e) {
            error_log("Database connection error: " . $e->getMessage());
            throw new Exception("Error de conexión a la base de datos");
        }
    }

    /**
     * Obtiene la conexión PDO
     */
    public function getConnection() {
        if ($this->connection === null) {
            $this->connect();
        }
        return $this->connection;
    }

    /**
     * Ejecuta una query SELECT con prepared statements
     *
     * @param string $sql Query SQL con placeholders (?)
     * @param array $params Parámetros para bind
     * @return array Resultados de la query
     */
    public function select($sql, $params = []) {
        try {
            $stmt = $this->connection->prepare($sql);
            $stmt->execute($params);
            return $stmt->fetchAll();
        } catch (PDOException $e) {
            error_log("Select error: " . $e->getMessage() . " | SQL: " . $sql);
            throw new Exception("Error al ejecutar la consulta");
        }
    }

    /**
     * Ejecuta una query SELECT y retorna un único registro
     */
    public function selectOne($sql, $params = []) {
        try {
            $stmt = $this->connection->prepare($sql);
            $stmt->execute($params);
            return $stmt->fetch();
        } catch (PDOException $e) {
            error_log("SelectOne error: " . $e->getMessage() . " | SQL: " . $sql . " | Params: " . json_encode($params));
            throw new Exception("Error SQL en selectOne: " . $e->getMessage() . " | Query: " . $sql);
        }
    }

    /**
     * Ejecuta INSERT/UPDATE/DELETE
     *
     * @return int Número de filas afectadas
     */
    public function execute($sql, $params = []) {
        try {
            $stmt = $this->connection->prepare($sql);
            $stmt->execute($params);
            return $stmt->rowCount();
        } catch (PDOException $e) {
            error_log("Execute error: " . $e->getMessage() . " | SQL: " . $sql . " | Params: " . json_encode($params));
            throw new Exception("Error SQL: " . $e->getMessage() . " | Query: " . $sql);
        }
    }

    /**
     * Ejecuta INSERT y retorna el ID insertado
     */
    public function insert($sql, $params = []) {
        try {
            $stmt = $this->connection->prepare($sql);
            $stmt->execute($params);
            return $this->connection->lastInsertId();
        } catch (PDOException $e) {
            error_log("❌ Insert error: " . $e->getMessage() . " | SQL: " . $sql . " | Params: " . json_encode($params));
            throw new Exception("Error al insertar: " . $e->getMessage());
        }
    }

    /**
     * Ejecuta UPDATE
     * Alias de execute() para mayor claridad
     *
     * @return int Número de filas afectadas
     */
    public function update($sql, $params = []) {
        return $this->execute($sql, $params);
    }

    /**
     * Ejecuta DELETE
     * Alias de execute() para mayor claridad
     *
     * @return int Número de filas afectadas
     */
    public function delete($sql, $params = []) {
        return $this->execute($sql, $params);
    }

    /**
     * Inicia una transacción
     */
    public function beginTransaction() {
        return $this->connection->beginTransaction();
    }

    /**
     * Confirma una transacción
     */
    public function commit() {
        return $this->connection->commit();
    }

    /**
     * Revierte una transacción
     */
    public function rollback() {
        return $this->connection->rollBack();
    }

    /**
     * Prevenir clonación del singleton
     */
    private function __clone() {}

    /**
     * Prevenir unserialize del singleton
     */
    public function __wakeup() {
        throw new Exception("Cannot unserialize singleton");
    }
}
