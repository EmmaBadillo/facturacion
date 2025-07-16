SET NOCOUNT ON;

DECLARE @i INT = 1;
DECLARE @max INT = 10000;

DECLARE @CategoryId INT;
DECLARE @Name VARCHAR(150);
DECLARE @Description VARCHAR(300);
DECLARE @Price DECIMAL(12,2);
DECLARE @Stock INT;
DECLARE @ImageUrl VARCHAR(255);
DECLARE @isActive INT;

-- Tablas temporales con productos + imagenes por categoría
DECLARE @Electronics TABLE (Name VARCHAR(100), Description VARCHAR(300), ImageUrl VARCHAR(255));
INSERT INTO @Electronics VALUES
('Smart TV 55" 4K Ultra HD', 'Televisor inteligente con resolución 4K y HDR.', 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&w=400&q=80'),
('Smartphone Android 128GB', 'Teléfono inteligente con gran capacidad y cámara avanzada.', 'https://images.unsplash.com/photo-1512499617640-c2f999018b72?auto=format&fit=crop&w=400&q=80'),
('Auriculares Bluetooth', 'Auriculares inalámbricos con cancelación de ruido.', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=400&q=80'),
('Laptop Gaming 16GB RAM', 'Portátil para juegos con alto rendimiento y gráficos dedicados.', 'https://images.unsplash.com/photo-1523475496153-3af3845709e7?auto=format&fit=crop&w=400&q=80'),
('Cámara Digital Profesional', 'Cámara con lentes intercambiables para fotografía profesional.', 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=400&q=80'),
('Smartwatch Deportivo', 'Reloj inteligente para seguimiento de actividad física.', 'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?auto=format&fit=crop&w=400&q=80'),
('Tablet 10 pulgadas', 'Tablet ligera y potente para uso diario.', 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?auto=format&fit=crop&w=400&q=80'),
('Parlante Bluetooth', 'Altavoz inalámbrico con sonido envolvente.', 'https://images.unsplash.com/photo-1486312338219-ce68d2c6f44d?auto=format&fit=crop&w=400&q=80'),
('Monitor LED 27 pulgadas', 'Pantalla para computadora con alta resolución.', 'https://images.unsplash.com/photo-1519389950473-47ba0277781c?auto=format&fit=crop&w=400&q=80'),
('Disco Duro SSD 1TB', 'Almacenamiento rápido y confiable para tus archivos.', 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=400&q=80');

DECLARE @Clothing TABLE (Name VARCHAR(100), Description VARCHAR(300), ImageUrl VARCHAR(255));
INSERT INTO @Clothing VALUES
('Camiseta de algodón', 'Camiseta cómoda y transpirable para uso diario.', 'https://images.unsplash.com/photo-1521334884684-d80222895322?auto=format&fit=crop&w=400&q=80'),
('Jeans ajustados', 'Pantalones vaqueros con corte moderno.', 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?auto=format&fit=crop&w=400&q=80'),
('Chaqueta impermeable', 'Chaqueta para lluvia, ligera y resistente.', 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?auto=format&fit=crop&w=400&q=80'),
('Sudadera con capucha', 'Prenda cómoda para el día a día.', 'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?auto=format&fit=crop&w=400&q=80'),
('Vestido casual', 'Vestido elegante y cómodo.', 'https://images.unsplash.com/photo-1520975913136-42fbc70b148e?auto=format&fit=crop&w=400&q=80'),
('Zapatos deportivos', 'Calzado para entrenamiento y deporte.', 'https://images.unsplash.com/photo-1495121605193-b116b5b09a12?auto=format&fit=crop&w=400&q=80'),
('Bufanda de lana', 'Accesorio cálido para invierno.', 'https://images.unsplash.com/photo-1474631245212-32dc3c8310c6?auto=format&fit=crop&w=400&q=80'),
('Pantalones cortos', 'Perfectos para clima cálido.', 'https://images.unsplash.com/photo-1520975913136-42fbc70b148e?auto=format&fit=crop&w=400&q=80'),
('Camisa formal', 'Camisa para ocasiones especiales.', 'https://images.unsplash.com/photo-1512436991641-6745cdb1723f?auto=format&fit=crop&w=400&q=80'),
('Gorra deportiva', 'Para protegerse del sol durante actividades.', 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?auto=format&fit=crop&w=400&q=80');

DECLARE @Foods TABLE (Name VARCHAR(100), Description VARCHAR(300), ImageUrl VARCHAR(255));
INSERT INTO @Foods VALUES
('Fruta fresca assorted', 'Selección de frutas frescas y saludables.', 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=400&q=80'),
('Producto lácteo natural', 'Leche y derivados frescos.', 'https://images.unsplash.com/photo-1495195134817-aeb325a55b65?auto=format&fit=crop&w=400&q=80'),
('Café orgánico molido', 'Café de alta calidad, tostado natural.', 'https://images.unsplash.com/photo-1466637574441-749b8f19452f?auto=format&fit=crop&w=400&q=80'),
('Chocolate negro premium', 'Chocolate con alto porcentaje de cacao.', 'https://images.unsplash.com/photo-1447078806655-40579c2520d6?auto=format&fit=crop&w=400&q=80'),
('Pan artesanal integral', 'Pan horneado con ingredientes naturales.', 'https://images.unsplash.com/photo-1473093295043-cdd812d0e601?auto=format&fit=crop&w=400&q=80'),
('Aceite de oliva extra virgen', 'Aceite puro para cocinar y aderezar.', 'https://images.unsplash.com/photo-1506354666786-959d6d497f1a?auto=format&fit=crop&w=400&q=80'),
('Snack saludable', 'Botana baja en calorías y rica en sabor.', 'https://images.unsplash.com/photo-1490645935967-10de6ba17061?auto=format&fit=crop&w=400&q=80'),
('Jugo natural sin azúcar', 'Bebida refrescante sin azúcar añadida.', 'https://images.unsplash.com/photo-1504754524776-8f4f37790ca0?auto=format&fit=crop&w=400&q=80'),
('Miel pura de abeja', 'Miel natural recolectada cuidadosamente.', 'https://images.unsplash.com/photo-1484981138541-3d074aa97716?auto=format&fit=crop&w=400&q=80'),
('Cereal integral', 'Cereal para un desayuno saludable.', 'https://images.unsplash.com/photo-1506354666786-959d6d497f1a?auto=format&fit=crop&w=400&q=80');

DECLARE @Home TABLE (Name VARCHAR(100), Description VARCHAR(300), ImageUrl VARCHAR(255));
INSERT INTO @Home VALUES
('Juego de sábanas 100% algodón', 'Sábanas suaves y transpirables para tu cama.', 'https://images.unsplash.com/photo-1493666438817-866a91353ca9?auto=format&fit=crop&w=400&q=80'),
('Silla ergonómica para oficina', 'Silla diseñada para comodidad prolongada.', 'https://images.unsplash.com/photo-1505692794403-1c42bfaf35f0?auto=format&fit=crop&w=400&q=80'),
('Lámpara de mesa moderna', 'Lámpara con diseño elegante y funcional.', 'https://images.unsplash.com/photo-1472220625704-91e1462799b2?auto=format&fit=crop&w=400&q=80'),
('Set de utensilios de cocina', 'Kit completo para preparar tus recetas.', 'https://images.unsplash.com/photo-1519710164239-da123dc03ef4?auto=format&fit=crop&w=400&q=80'),
('Mueble organizador modular', 'Solución práctica para organizar espacios.', 'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?auto=format&fit=crop&w=400&q=80'),
('Alfombra decorativa', 'Alfombra con diseño único y materiales de calidad.', 'https://images.unsplash.com/photo-1472214103451-9374bd1c798e?auto=format&fit=crop&w=400&q=80'),
('Cortina blackout', 'Cortinas para bloquear la luz y mejorar el descanso.', 'https://images.unsplash.com/photo-1470163395405-d2b94f43e0f5?auto=format&fit=crop&w=400&q=80'),
('Reloj de pared minimalista', 'Reloj moderno para decoración de interiores.', 'https://images.unsplash.com/photo-1484154218962-a197022b5858?auto=format&fit=crop&w=400&q=80'),
('Colchón ortopédico', 'Colchón que brinda soporte y comodidad.', 'https://images.unsplash.com/photo-1468777675496-5782faaea55b?auto=format&fit=crop&w=400&q=80'),
('Estantería de madera', 'Estante robusto para almacenamiento y decoración.', 'https://images.unsplash.com/photo-1505692794403-1c42bfaf35f0?auto=format&fit=crop&w=400&q=80');

WHILE @i <= @max
BEGIN
    IF @i <= 2500 SET @CategoryId = 1;
    ELSE IF @i <= 5000 SET @CategoryId = 2;
    ELSE IF @i <= 7500 SET @CategoryId = 3;
    ELSE SET @CategoryId = 4;

    IF @CategoryId = 1
    BEGIN
        SELECT TOP 1 @Name = Name, @Description = Description, @ImageUrl = ImageUrl
        FROM @Electronics
        ORDER BY NEWID();

        SET @Name = @Name + ' Modelo ' + CAST((100 + (@i % 900)) AS VARCHAR);
        SET @Price = ROUND((RAND(CHECKSUM(NEWID())) * 1900) + 100, 2);
        SET @Stock = CAST((RAND(CHECKSUM(NEWID())) * 100) AS INT);
    END
    ELSE IF @CategoryId = 2
    BEGIN
        SELECT TOP 1 @Name = Name, @Description = Description, @ImageUrl = ImageUrl
        FROM @Clothing
        ORDER BY NEWID();

        SET @Name = @Name + ' Talla ' + CASE (1 + (@i % 5))
            WHEN 1 THEN 'S' WHEN 2 THEN 'M' WHEN 3 THEN 'L' WHEN 4 THEN 'XL' ELSE 'XXL' END;
        SET @Price = ROUND((RAND(CHECKSUM(NEWID())) * 190) + 10, 2);
        SET @Stock = CAST((RAND(CHECKSUM(NEWID())) * 200) AS INT);
    END
    ELSE IF @CategoryId = 3
    BEGIN
        SELECT TOP 1 @Name = Name, @Description = Description, @ImageUrl = ImageUrl
        FROM @Foods
        ORDER BY NEWID();

        SET @Price = ROUND((RAND(CHECKSUM(NEWID())) * 49) + 1, 2);
        SET @Stock = CAST((RAND(CHECKSUM(NEWID())) * 500) AS INT);
    END
    ELSE
    BEGIN
        SELECT TOP 1 @Name = Name, @Description = Description, @ImageUrl = ImageUrl
        FROM @Home
        ORDER BY NEWID();

        SET @Price = ROUND((RAND(CHECKSUM(NEWID())) * 480) + 20, 2);
        SET @Stock = CAST((RAND(CHECKSUM(NEWID())) * 150) AS INT);
    END

    SET @isActive = CASE WHEN RAND(CHECKSUM(NEWID())) < 0.8 THEN 1 ELSE 0 END;

    INSERT INTO Products (CategoryId, Name, Description, Price, Stock, ImageUrl, isActive)
    VALUES (@CategoryId, @Name, @Description, @Price, @Stock, @ImageUrl, @isActive);

    SET @i += 1;
END
select * from products