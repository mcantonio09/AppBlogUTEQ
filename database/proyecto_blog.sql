-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Servidor: localhost:8889
-- Tiempo de generación: 18-11-2026 a las 18:36:22
-- Versión del servidor: 8.0.44
-- Versión de PHP: 8.3.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `proyecto_blog`
--
CREATE DATABASE IF NOT EXISTS `proyecto_blog` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE `proyecto_blog`;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `blog`
--

CREATE TABLE `blog` (
  `id_blog` int NOT NULL,
  `id_usr` int NOT NULL,
  `fecha_creacion` date NOT NULL DEFAULT (curdate()),
  `titulo` varchar(255) NOT NULL,
  `resumen` varchar(255) NOT NULL,
  `descripcion` text,
  `etiquetas` varchar(255) DEFAULT NULL,
  `url_img` varchar(500) DEFAULT NULL,
  `estado` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `blog`
--

INSERT INTO `blog` (`id_blog`, `id_usr`, `fecha_creacion`, `titulo`, `resumen`, `descripcion`, `etiquetas`, `url_img`, `estado`) VALUES
(3, 11, '2026-11-15', '5 tips para saber JAVA', 'Esto es un resumen del post', 'Esto es la descripcion del post', 'Programacion', 'img/blog_img/019be26d62.webp', 'Publicado'),
(4, 11, '2026-11-16', 'adsfadf', 'vaserbhtfdbrrtheaeghrtgbtb', 'adsfweDvrftbgrgbyghjndafsvgarewfvcargvrtsbv', 'afwdf', 'img/blog_img/1794890633_Captura de pantalla 2026-11-08 a la(s) 2.00.11 pm.png', 'Publicado'),
(6, 10, '2026-11-17', 'Prueba final CRUD final final fianl', 'prueba final del crud erb efabveeqrgh eabfvat', 'prueba final finalswfv aergqwerarvaqerer', 'Programación', 'img/blog_img/1794929429_Gemini_Generated_Image_4dxu8o4dxu8o4dxu.jpeg', 'Publicado');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `comentarios`
--

CREATE TABLE `comentarios` (
  `id_comentario` int NOT NULL,
  `id_usr` int NOT NULL,
  `id_blog` int NOT NULL,
  `comentario` text NOT NULL,
  `fecha_comentario` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `comentarios`
--

INSERT INTO `comentarios` (`id_comentario`, `id_usr`, `id_blog`, `comentario`, `fecha_comentario`) VALUES
(4, 11, 4, 'primer comentairo', '2026-11-16 22:52:47'),
(7, 11, 3, 'prueba comentrios', '2026-11-17 10:33:52');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

CREATE TABLE `usuario` (
  `id_usr` int NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `correo` varchar(100) NOT NULL,
  `passwd` varchar(255) NOT NULL,
  `tipo_usr` int DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`id_usr`, `nombre`, `correo`, `passwd`, `tipo_usr`) VALUES
(10, 'antonio moreno', 'antonio.moreno@gmail.com', '8c62825bf27a59c98f94f14f33b4ac53ec6eb6ff63edf0484ebe9a2ccb0442e863b420b9f0411af0096f09dfdd96e3bf3bd184de5defcbe53b83152d5bef2076', 1),
(11, 'Mario Mendoza', 'admin@uteq.edu.mx', 'ec77993175a2b992ee0a48169db6c3617bcc0f227db31714598873ab9fb0f328913e420bee1896c9535a2f3a65a7c844fb977c40287244c8d3490c519161468c', 2);

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `blog`
--
ALTER TABLE `blog`
  ADD PRIMARY KEY (`id_blog`),
  ADD KEY `fk_blog_usuario` (`id_usr`);

--
-- Indices de la tabla `comentarios`
--
ALTER TABLE `comentarios`
  ADD PRIMARY KEY (`id_comentario`),
  ADD KEY `fk_comentario_usuario` (`id_usr`),
  ADD KEY `fk_comentario_blog` (`id_blog`);

--
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`id_usr`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `blog`
--
ALTER TABLE `blog`
  MODIFY `id_blog` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de la tabla `comentarios`
--
ALTER TABLE `comentarios`
  MODIFY `id_comentario` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de la tabla `usuario`
--
ALTER TABLE `usuario`
  MODIFY `id_usr` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `blog`
--
ALTER TABLE `blog`
  ADD CONSTRAINT `fk_blog_usuario` FOREIGN KEY (`id_usr`) REFERENCES `usuario` (`id_usr`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `comentarios`
--
ALTER TABLE `comentarios`
  ADD CONSTRAINT `fk_comentario_blog` FOREIGN KEY (`id_blog`) REFERENCES `blog` (`id_blog`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_comentario_usuario` FOREIGN KEY (`id_usr`) REFERENCES `usuario` (`id_usr`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
