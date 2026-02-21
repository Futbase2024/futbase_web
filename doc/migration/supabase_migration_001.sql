-- ============================================================================
-- MIGRACIÓN SUPABASE: Tablas maestras FutBase
-- Fecha: 2026-02-20
-- Descripción: Creación de tablas y datos iniciales para FutBase 3.0
-- ============================================================================

-- ============================================================================
-- 1. TABLA: taplicacion (Información de la aplicación)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.taplicacion (
    id INTEGER PRIMARY KEY,
    aplicacion VARCHAR(100) NOT NULL,
    versionandroid INTEGER NOT NULL DEFAULT 0,
    versionios INTEGER NOT NULL DEFAULT 0,
    linkios VARCHAR(500),
    linkandroid VARCHAR(500),
    novedades TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Datos iniciales taplicacion
INSERT INTO public.taplicacion (id, aplicacion, versionandroid, versionios, linkios, linkandroid, novedades) VALUES
(2, 'PlayFutbol', 71, 72, 'https://apps.apple.com/es/app/futbase/id6563150138', 'https://play.google.com/store/apps/details?id=com.futbase.futbaseapp', 'Nuevo diseño y actualizaciones...')
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- 2. TABLA: tappconfig (Configuración de la aplicación)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.tappconfig (
    id INTEGER PRIMARY KEY,
    appname VARCHAR(100) NOT NULL,
    calidadimagen INTEGER NOT NULL DEFAULT 1200,
    testing BOOLEAN NOT NULL DEFAULT FALSE,
    token VARCHAR(255),
    fcmkey TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Datos iniciales tappconfig
INSERT INTO public.tappconfig (id, appname, calidadimagen, testing, token, fcmkey) VALUES
(1, 'FutBase', 1200, FALSE, '0c6c8a3809045223962a66654ff785f6d187d993', 'AAAADy3gKwc:APA91bFVUW6D3HtQ9hezp07FXz_96UVdJpmFRJuoC5UitS3MMVjYGbtngokeoUUY0IJK57BrI5h8W1IcN0oJP2wq4Fs7mEXopqebYfFDUpOE4JaBa3yBOsQVWKg_bvIoI0kok6Npcw9e')
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- 3. TABLA: tcategorias (Categorías de edad)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.tcategorias (
    id INTEGER PRIMARY KEY,
    categoria VARCHAR(50) NOT NULL UNIQUE,
    edad1 INTEGER NOT NULL,
    edad2 INTEGER NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Datos iniciales tcategorias
INSERT INTO public.tcategorias (id, categoria, edad1, edad2) VALUES
(1, 'BEBE', 4, 5),
(2, 'PREBENJAMIN', 6, 7),
(3, 'BENJAMIN', 8, 9),
(4, 'ALEVIN', 10, 11),
(5, 'INFANTIL', 12, 13),
(6, 'CADETE', 14, 15),
(7, 'JUVENIL', 16, 18),
(8, 'SENIOR', 18, 40)
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- 4. TABLA: tcamisetas (Camisetas/Jerseys)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.tcamisetas (
    id INTEGER PRIMARY KEY,
    url VARCHAR(500) NOT NULL,
    idcolor INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Crear índice para búsquedas por color
CREATE INDEX IF NOT EXISTS idx_tcamisetas_color ON public.tcamisetas (idcolor);

-- ============================================================================
-- 5. TABLA: tcampos (Estadios/Campos de fútbol)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.tcampos (
    id INTEGER PRIMARY KEY,
    campo VARCHAR(200) NOT NULL,
    direccion VARCHAR(300),
    cesped VARCHAR(50) DEFAULT 'ARTIFICIAL',
    tipo VARCHAR(50) DEFAULT 'FUTBOL 11',
    idprovincia INTEGER,
    idlocalidad INTEGER,
    posX DECIMAL(10, 5),
    posY DECIMAL(10, 5),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Crear índices para búsquedas comunes
CREATE INDEX IF NOT EXISTS idx_tcampos_provincia ON public.tcampos (idprovincia);
CREATE INDEX IF NOT EXISTS idx_tcampos_localidad ON public.tcampos (idlocalidad);
CREATE INDEX IF NOT EXISTS idx_tcampos_tipo ON public.tcampos (tipo);

-- ============================================================================
-- 6. TABLA: tclubes (Clubes de fútbol)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.tclubes (
    id INTEGER PRIMARY KEY,
    idprovincia INTEGER,
    idlocalidad INTEGER,
    idcampo INTEGER,
    club VARCHAR(200) NOT NULL,
    codigo VARCHAR(20),
    cif VARCHAR(50),
    cpostal INTEGER,
    domicilio VARCHAR(300),
    email VARCHAR(200),
    escudo VARCHAR(500),
    telefono VARCHAR(50),
    web VARCHAR(300),
    ncorto VARCHAR(50),
    validado BOOLEAN DEFAULT FALSE,
    asociado BOOLEAN DEFAULT FALSE,
    primeraeq INTEGER,
    segundaeq INTEGER,
    terceraeq INTEGER,
    primeraeqpor INTEGER,
    segundaeqpor INTEGER,
    terceraeqpor INTEGER,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Crear índices para búsquedas comunes
CREATE INDEX IF NOT EXISTS idx_tclubes_provincia ON public.tclubes (idprovincia);
CREATE INDEX IF NOT EXISTS idx_tclubes_localidad ON public.tclubes (idlocalidad);
CREATE INDEX IF NOT EXISTS idx_tclubes_campo ON public.tclubes (idcampo);
CREATE INDEX IF NOT EXISTS idx_tclubes_codigo ON public.tclubes (codigo);
CREATE INDEX IF NOT EXISTS idx_tclubes_validado ON public.tclubes (validado);
CREATE INDEX IF NOT EXISTS idx_tclubes_asociado ON public.tclubes (asociado);

-- ============================================================================
-- 7. HABILITAR RLS (Row Level Security)
-- ============================================================================
ALTER TABLE public.taplicacion ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tappconfig ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tcategorias ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tcamisetas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tcampos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tclubes ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 8. POLÍTICAS RLS - Lectura pública para tablas maestras
-- ============================================================================
CREATE POLICY "Lectura pública taplicacion" ON public.taplicacion
    FOR SELECT USING (true);

CREATE POLICY "Lectura pública tappconfig" ON public.tappconfig
    FOR SELECT USING (true);

CREATE POLICY "Lectura pública tcategorias" ON public.tcategorias
    FOR SELECT USING (true);

CREATE POLICY "Lectura pública tcamisetas" ON public.tcamisetas
    FOR SELECT USING (true);

CREATE POLICY "Lectura pública tcampos" ON public.tcampos
    FOR SELECT USING (true);

CREATE POLICY "Lectura pública tclubes" ON public.tclubes
    FOR SELECT USING (true);

-- ============================================================================
-- 9. FUNCIONES PARA updated_at automático
-- ============================================================================
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers para updated_at
CREATE TRIGGER set_taplicacion_updated_at
    BEFORE UPDATE ON public.taplicacion
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_tappconfig_updated_at
    BEFORE UPDATE ON public.tappconfig
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_tcampos_updated_at
    BEFORE UPDATE ON public.tcampos
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_tclubes_updated_at
    BEFORE UPDATE ON public.tclubes
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- ============================================================================
-- 10. COMENTARIOS EN TABLAS
-- ============================================================================
COMMENT ON TABLE public.taplicacion IS 'Información de versiones y links de la aplicación';
COMMENT ON TABLE public.tappconfig IS 'Configuración general de la aplicación';
COMMENT ON TABLE public.tcategorias IS 'Categorías de edad para jugadores y equipos';
COMMENT ON TABLE public.tcamisetas IS 'Catálogo de camisetas/jerseys disponibles';
COMMENT ON TABLE public.tcampos IS 'Estadios y campos de fútbol';
COMMENT ON TABLE public.tclubes IS 'Clubes de fútbol registrados';
