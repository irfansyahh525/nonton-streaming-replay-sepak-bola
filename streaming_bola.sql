-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Dec 12, 2025 at 07:15 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `streaming_bola`
--

-- --------------------------------------------------------

--
-- Table structure for table `matches`
--

CREATE TABLE `matches` (
  `id` int(11) NOT NULL,
  `team_a` varchar(100) NOT NULL,
  `team_b` varchar(100) NOT NULL,
  `league` varchar(100) DEFAULT NULL,
  `match_date` datetime NOT NULL,
  `status` enum('upcoming','live','finished') DEFAULT 'upcoming',
  `stream_url` varchar(500) DEFAULT NULL,
  `is_replay` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `matches`
--

INSERT INTO `matches` (`id`, `team_a`, `team_b`, `league`, `match_date`, `status`, `stream_url`, `is_replay`, `created_at`) VALUES
(1, 'Manchester United', 'Manchester City', 'Premier League', '2024-01-15 20:00:00', 'live', 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8\r\n', 0, '2025-12-12 05:29:11'),
(2, 'Barcelona', 'Real Madrid', 'La Liga', '2024-01-14 21:00:00', 'finished', 'https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8\r\n', 1, '2025-12-12 05:29:11'),
(3, 'Bayern Munich', 'Borussia Dortmund', 'Bundesliga', '2024-01-16 19:30:00', 'upcoming', NULL, 0, '2025-12-12 05:29:11'),
(4, 'PSG', 'Marseille', 'Ligue 1', '2024-01-13 18:00:00', 'finished', 'https://sample-stream.com/replay2', 1, '2025-12-12 05:29:11'),
(5, 'Liverpool', 'Chelsea', 'Premier League', '2024-01-17 20:45:00', 'live', 'https://storage.googleapis.com/shaka-demo-assets/angel-one-hls/hls.m3u8\r\n', 0, '2025-12-12 05:29:11');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `password`, `email`, `created_at`, `updated_at`) VALUES
(1, 'admin', '123', 'admin@streamingbola.com', '2025-12-12 05:29:11', '2025-12-12 05:32:34'),
(2, '1', '123', 'user1@email.com', '2025-12-12 05:29:11', '2025-12-12 05:32:19'),
(3, '2', '123', 'test@email.com', '2025-12-12 05:29:11', '2025-12-12 05:32:28');

-- --------------------------------------------------------

--
-- Table structure for table `user_history`
--

CREATE TABLE `user_history` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `match_id` int(11) DEFAULT NULL,
  `watched_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `matches`
--
ALTER TABLE `matches`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- Indexes for table `user_history`
--
ALTER TABLE `user_history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `match_id` (`match_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `matches`
--
ALTER TABLE `matches`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `user_history`
--
ALTER TABLE `user_history`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `user_history`
--
ALTER TABLE `user_history`
  ADD CONSTRAINT `user_history_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `user_history_ibfk_2` FOREIGN KEY (`match_id`) REFERENCES `matches` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
