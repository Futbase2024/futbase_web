<?php
/**
 * Validador de datos de entrada
 * Previene SQL injection y valida tipos de datos
 */
class Validator {

    /**
     * Valida y sanitiza un entero
     */
    public static function validateInt($value, $min = null, $max = null) {
        $value = filter_var($value, FILTER_VALIDATE_INT);

        if ($value === false) {
            return null;
        }

        if ($min !== null && $value < $min) {
            return null;
        }

        if ($max !== null && $value > $max) {
            return null;
        }

        return $value;
    }

    /**
     * Valida un email
     */
    public static function validateEmail($email) {
        $email = filter_var($email, FILTER_VALIDATE_EMAIL);
        return $email !== false ? $email : null;
    }

    /**
     * Valida una fecha en formato YYYY-MM-DD
     */
    public static function validateDate($date) {
        $d = DateTime::createFromFormat('Y-m-d', $date);
        return $d && $d->format('Y-m-d') === $date ? $date : null;
    }

    /**
     * Valida un string y lo sanitiza
     */
    public static function validateString($value, $minLength = 0, $maxLength = 1000) {
        // Validar que sea un string o convertible a string
        if ($value === null || $value === false) {
            return null;
        }

        // Convertir a string si no lo es
        $value = (string)$value;
        $value = trim($value);
        $length = mb_strlen($value);

        if ($length < $minLength || $length > $maxLength) {
            return null;
        }

        // Eliminar caracteres peligrosos
        $value = htmlspecialchars($value, ENT_QUOTES, 'UTF-8');

        return $value;
    }

    /**
     * Valida un booleano
     */
    public static function validateBool($value) {
        return filter_var($value, FILTER_VALIDATE_BOOLEAN, FILTER_NULL_ON_FAILURE);
    }

    /**
     * Valida un array de IDs
     */
    public static function validateIdArray($array) {
        if (!is_array($array)) {
            return null;
        }

        $validated = [];
        foreach ($array as $id) {
            $validId = self::validateInt($id, 1);
            if ($validId !== null) {
                $validated[] = $validId;
            }
        }

        return empty($validated) ? null : $validated;
    }

    /**
     * Valida campos requeridos en un array
     *
     * @param array $data Datos a validar
     * @param array $required Campos requeridos
     * @return array|false Array con errores o false si todo está bien
     */
    public static function validateRequired($data, $required) {
        $errors = [];

        foreach ($required as $field) {
            if (!isset($data[$field]) || empty($data[$field])) {
                $errors[] = "El campo '$field' es requerido";
            }
        }

        return empty($errors) ? false : $errors;
    }

    /**
     * Valida un UID de Firebase
     */
    public static function validateUID($uid) {
        // Los UIDs de Firebase tienen 28 caracteres alfanuméricos
        if (preg_match('/^[a-zA-Z0-9]{20,30}$/', $uid)) {
            return $uid;
        }
        return null;
    }

    /**
     * Valida parámetros de paginación
     */
    public static function validatePagination($page, $limit) {
        $page = self::validateInt($page, 1);
        $limit = self::validateInt($limit, 1, 100);

        return [
            'page' => $page ?? 1,
            'limit' => $limit ?? 20,
            'offset' => (($page ?? 1) - 1) * ($limit ?? 20)
        ];
    }

    /**
     * Valida que un valor esté en una lista de valores permitidos
     */
    public static function validateEnum($value, $allowedValues) {
        return in_array($value, $allowedValues, true) ? $value : null;
    }

    /**
     * Valida coordenadas GPS
     */
    public static function validateCoordinates($lat, $lng) {
        $lat = filter_var($lat, FILTER_VALIDATE_FLOAT);
        $lng = filter_var($lng, FILTER_VALIDATE_FLOAT);

        if ($lat === false || $lng === false) {
            return null;
        }

        if ($lat < -90 || $lat > 90 || $lng < -180 || $lng > 180) {
            return null;
        }

        return ['lat' => $lat, 'lng' => $lng];
    }

    /**
     * Sanitiza datos de entrada general
     */
    public static function sanitizeInput($data) {
        if (is_array($data)) {
            return array_map([self::class, 'sanitizeInput'], $data);
        }

        if (is_string($data)) {
            return htmlspecialchars(trim($data), ENT_QUOTES, 'UTF-8');
        }

        return $data;
    }
}
