-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Máy chủ: 8386.fun:3307
-- Thời gian đã tạo: Th8 10, 2026 lúc 09:03 AM
-- Phiên bản máy phục vụ: 8.0.44
-- Phiên bản PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Cơ sở dữ liệu: `apebond`
--

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `aerodrome_pool_epoch_state`
--

CREATE TABLE `aerodrome_pool_epoch_state` (
  `id` int NOT NULL,
  `chain` varchar(10) NOT NULL,
  `pool_address` varchar(42) NOT NULL,
  `gauge_address` varchar(42) NOT NULL,
  `epoch_start` int NOT NULL,
  `epoch_finish` int NOT NULL,
  `reward_address` varchar(42) NOT NULL,
  `reward_symbol` varchar(10) NOT NULL,
  `reward_decimals` int NOT NULL,
  `reward_rate` float NOT NULL,
  `reward_per_day` float NOT NULL,
  `period_finish` int NOT NULL,
  `vote_weight` float NOT NULL,
  `total_vote_weight` float NOT NULL,
  `vote_share` float NOT NULL,
  `farm_active` tinyint(1) NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_at` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `aerodrome_pool_info`
--

CREATE TABLE `aerodrome_pool_info` (
  `id` int NOT NULL,
  `pool_address` varchar(42) COLLATE utf8mb3_unicode_ci NOT NULL,
  `chain` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  `factory_address` varchar(42) COLLATE utf8mb3_unicode_ci NOT NULL,
  `factory_index` int NOT NULL,
  `token0_address` varchar(42) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `token1_address` varchar(42) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `token0_symbol` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `token1_symbol` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `token0_decimals` int DEFAULT NULL,
  `token1_decimals` int DEFAULT NULL,
  `fee` int DEFAULT NULL,
  `tick_spacing` int DEFAULT NULL,
  `aero_reward_1h` float DEFAULT '0',
  `total_value_lock` double DEFAULT '0',
  `cake_reward_1h` float DEFAULT '0',
  `total_current_liquidity` double DEFAULT '0',
  `total_staked_liquidity` double DEFAULT '0',
  `total_inactive_staked_liquidity` double DEFAULT '0',
  `farm_apr` double DEFAULT '0',
  `is_stake_tracked` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `aerodrome_pool_reward_history`
--

CREATE TABLE `aerodrome_pool_reward_history` (
  `id` bigint NOT NULL,
  `chain` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  `pool_address` varchar(42) COLLATE utf8mb3_unicode_ci NOT NULL,
  `epoch_start` bigint NOT NULL,
  `epoch_finish` bigint NOT NULL,
  `reward_rate` decimal(65,0) NOT NULL,
  `reward_per_day` decimal(65,0) NOT NULL,
  `reward_decimals` int NOT NULL,
  `vote_weight` decimal(65,0) NOT NULL,
  `vote_share` decimal(30,18) NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `binance_account_wallet_links`
--

CREATE TABLE `binance_account_wallet_links` (
  `account_alias` varchar(64) COLLATE utf8mb3_unicode_ci NOT NULL,
  `wallet_type` varchar(16) COLLATE utf8mb3_unicode_ci NOT NULL,
  `wallet_address` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `binance_futures_positions_current`
--

CREATE TABLE `binance_futures_positions_current` (
  `id` bigint NOT NULL,
  `account_alias` varchar(64) COLLATE utf8mb3_unicode_ci NOT NULL,
  `market_type` varchar(16) COLLATE utf8mb3_unicode_ci NOT NULL,
  `symbol` varchar(40) COLLATE utf8mb3_unicode_ci NOT NULL,
  `pair` varchar(40) COLLATE utf8mb3_unicode_ci NOT NULL,
  `contract_type` varchar(32) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `delivery_date` bigint DEFAULT NULL,
  `raw_base_asset` varchar(32) COLLATE utf8mb3_unicode_ci NOT NULL,
  `base_asset` varchar(32) COLLATE utf8mb3_unicode_ci NOT NULL,
  `quote_asset` varchar(32) COLLATE utf8mb3_unicode_ci NOT NULL,
  `margin_asset` varchar(32) COLLATE utf8mb3_unicode_ci NOT NULL,
  `contract_multiplier` decimal(38,18) NOT NULL,
  `contract_size_quote` decimal(38,18) DEFAULT NULL,
  `position_side` varchar(16) COLLATE utf8mb3_unicode_ci NOT NULL,
  `position_amt` decimal(38,18) NOT NULL,
  `position_amt_unit` varchar(16) COLLATE utf8mb3_unicode_ci NOT NULL,
  `signed_base_exposure` decimal(38,18) NOT NULL,
  `entry_price` decimal(38,18) DEFAULT NULL,
  `break_even_price` decimal(38,18) DEFAULT NULL,
  `mark_price` decimal(38,18) NOT NULL,
  `unrealized_pnl` decimal(38,18) DEFAULT NULL,
  `pnl_asset` varchar(32) COLLATE utf8mb3_unicode_ci NOT NULL,
  `notional_value` decimal(38,18) DEFAULT NULL,
  `notional_asset` varchar(32) COLLATE utf8mb3_unicode_ci NOT NULL,
  `liquidation_price` decimal(38,18) DEFAULT NULL,
  `isolated_margin` decimal(38,18) DEFAULT NULL,
  `leverage` int DEFAULT NULL,
  `margin_type` varchar(16) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `binance_update_time` bigint DEFAULT NULL,
  `synced_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `binance_futures_sync_state`
--

CREATE TABLE `binance_futures_sync_state` (
  `account_alias` varchar(64) COLLATE utf8mb3_unicode_ci NOT NULL,
  `market_type` varchar(16) COLLATE utf8mb3_unicode_ci NOT NULL,
  `status` varchar(16) COLLATE utf8mb3_unicode_ci NOT NULL,
  `stale_after_seconds` int NOT NULL DEFAULT '180',
  `last_attempt_at` datetime DEFAULT NULL,
  `last_success_at` datetime DEFAULT NULL,
  `error_code` varchar(64) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `error_message` varchar(500) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `bond`
--

CREATE TABLE `bond` (
  `id` int NOT NULL,
  `wallet_id` int NOT NULL,
  `bond_id` int NOT NULL,
  `bond_type` enum('claim','buy') NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `bond_buy`
--

CREATE TABLE `bond_buy` (
  `id` int NOT NULL,
  `bond_id` int NOT NULL,
  `chain` varchar(20) DEFAULT NULL,
  `chain_name` varchar(50) DEFAULT NULL,
  `contract` varchar(255) DEFAULT NULL,
  `buy_enabled` tinyint(1) DEFAULT NULL,
  `blocked` tinyint(1) DEFAULT NULL,
  `min_buy` float DEFAULT NULL,
  `buy_price` float DEFAULT NULL,
  `min_bonus` float DEFAULT NULL,
  `slippage` float DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `bond_claim`
--

CREATE TABLE `bond_claim` (
  `id` int NOT NULL,
  `bond_id` int NOT NULL,
  `chain` varchar(20) DEFAULT NULL,
  `chain_name` varchar(50) DEFAULT NULL,
  `contract` varchar(255) DEFAULT NULL,
  `claim_enabled` tinyint(1) DEFAULT NULL,
  `blocked` tinyint(1) DEFAULT NULL,
  `min_claimable` float DEFAULT NULL,
  `min_price` float DEFAULT NULL,
  `claim_time` json DEFAULT NULL,
  `after_claim` json DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `bond_history`
--

CREATE TABLE `bond_history` (
  `id` int NOT NULL,
  `bond_name` varchar(255) COLLATE utf8mb3_unicode_ci NOT NULL,
  `bond_chain` varchar(50) COLLATE utf8mb3_unicode_ci NOT NULL,
  `contract_address` varchar(255) COLLATE utf8mb3_unicode_ci NOT NULL,
  `date_time` datetime NOT NULL,
  `min_bonus` decimal(10,2) NOT NULL,
  `max_bonus` decimal(10,2) NOT NULL,
  `min_price` decimal(18,2) NOT NULL,
  `max_price` decimal(18,2) NOT NULL,
  `max_buy` decimal(18,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `bond_runtime_status`
--

CREATE TABLE `bond_runtime_status` (
  `id` int NOT NULL,
  `bond_id` int NOT NULL,
  `bond_type` enum('claim','buy') NOT NULL,
  `chain` varchar(50) DEFAULT NULL,
  `bond_name` varchar(50) DEFAULT NULL,
  `bond_contract` varchar(255) DEFAULT NULL,
  `max_buy` decimal(18,8) DEFAULT '0.00000000',
  `unclaimed` decimal(18,8) DEFAULT '0.00000000',
  `remain` decimal(18,8) DEFAULT '0.00000000',
  `dump_dex` decimal(18,8) DEFAULT '0.00000000',
  `lp_total` decimal(18,8) DEFAULT '0.00000000',
  `lp_base_symbol` varchar(50) DEFAULT NULL,
  `lp_quote_symbol` varchar(50) DEFAULT NULL,
  `lp_base_usd` decimal(18,8) DEFAULT '0.00000000',
  `lp_quote_usd` decimal(18,8) DEFAULT '0.00000000',
  `blocked` tinyint(1) DEFAULT '0',
  `front_run` tinyint(1) DEFAULT '0',
  `auto_claim` tinyint(1) DEFAULT '0',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `bot_pool_blacklist`
--

CREATE TABLE `bot_pool_blacklist` (
  `id` int NOT NULL,
  `chain` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  `pool_address` varchar(42) COLLATE utf8mb3_unicode_ci NOT NULL,
  `reason` varchar(200) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `bot_positions`
--

CREATE TABLE `bot_positions` (
  `id` int NOT NULL,
  `chain` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  `pool_address` varchar(42) COLLATE utf8mb3_unicode_ci NOT NULL,
  `detected_pool_id` int DEFAULT NULL,
  `token_id` bigint DEFAULT NULL,
  `wallet_address` varchar(42) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `tick_lower` int NOT NULL,
  `tick_upper` int NOT NULL,
  `tick_at_mint` int DEFAULT NULL,
  `liquidity` varchar(40) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `amount0_deposited_usd` decimal(20,4) DEFAULT NULL,
  `amount1_deposited_usd` decimal(20,4) DEFAULT NULL,
  `total_invested_usd` decimal(20,4) DEFAULT NULL,
  `total_cake_harvested` decimal(20,8) DEFAULT '0.00000000',
  `total_fees_earned_usd` decimal(20,4) DEFAULT '0.0000',
  `total_rebalance_count` int DEFAULT '0',
  `status` enum('ACTIVE','OUT_OF_RANGE','HARVESTED','ABANDONED','CLOSED','STOP_LOSS') COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `is_staked` tinyint(1) DEFAULT '1',
  `last_harvest_at` datetime DEFAULT NULL,
  `last_rebalance_at` datetime DEFAULT NULL,
  `mint_tx_hash` varchar(66) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `stake_tx_hash` varchar(66) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `open_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `closed_at` datetime DEFAULT NULL,
  `close_reason` varchar(200) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `consecutive_losses` tinyint DEFAULT '0',
  `net_pnl_usd` decimal(20,4) DEFAULT '0.0000',
  `last_pnl_usd` decimal(20,4) DEFAULT NULL,
  `last_pnl_at` datetime DEFAULT NULL,
  `stop_loss_at` datetime DEFAULT NULL,
  `is_blacklisted` tinyint(1) DEFAULT '0',
  `inherited_cake` decimal(20,8) DEFAULT '0.00000000',
  `inherited_fees_usd` decimal(20,4) DEFAULT '0.0000'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `bot_transactions`
--

CREATE TABLE `bot_transactions` (
  `id` int NOT NULL,
  `chain` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  `bot_position_id` int DEFAULT NULL,
  `tx_hash` varchar(66) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `action` varchar(30) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `swap_token_in` varchar(42) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `swap_token_out` varchar(42) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `swap_amount_in` varchar(40) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `swap_amount_out` varchar(40) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `swap_provider` varchar(30) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `status` enum('PENDING','SUCCESS','FAILED') COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `gas_used` bigint DEFAULT NULL,
  `gas_price_gwei` decimal(10,4) DEFAULT NULL,
  `gas_cost_usd` decimal(10,6) DEFAULT NULL,
  `block_number` bigint DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `cake_amount` decimal(20,8) DEFAULT '0.00000000',
  `cake_price_usd` decimal(10,4) DEFAULT '0.0000',
  `fees_earned_usd` decimal(20,4) DEFAULT '0.0000'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `configured_compound_jobs`
--

CREATE TABLE `configured_compound_jobs` (
  `id` bigint NOT NULL,
  `idempotency_key` varchar(160) COLLATE utf8mb3_unicode_ci NOT NULL,
  `chain` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  `pool_address` varchar(42) COLLATE utf8mb3_unicode_ci NOT NULL,
  `wallet_address` varchar(42) COLLATE utf8mb3_unicode_ci NOT NULL,
  `npm_address` varchar(42) COLLATE utf8mb3_unicode_ci NOT NULL,
  `token_id` bigint NOT NULL,
  `dex_type` varchar(40) COLLATE utf8mb3_unicode_ci NOT NULL,
  `stake_mode` varchar(20) COLLATE utf8mb3_unicode_ci NOT NULL,
  `status` varchar(40) COLLATE utf8mb3_unicode_ci NOT NULL,
  `current_action` varchar(40) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `retry_count` int NOT NULL DEFAULT '0',
  `error_reason` varchar(500) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `anchor_block` bigint DEFAULT NULL,
  `current_tick` int DEFAULT NULL,
  `tick_lower` int DEFAULT NULL,
  `tick_upper` int DEFAULT NULL,
  `liquidity_before` varchar(80) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `liquidity_added` varchar(80) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `liquidity_after` varchar(80) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `quoted_amount0_raw` varchar(80) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `quoted_amount1_raw` varchar(80) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `collected_amount0_raw` varchar(80) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `collected_amount1_raw` varchar(80) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `reserved_amount0_raw` varchar(80) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `reserved_amount1_raw` varchar(80) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `swap_token_in` varchar(42) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `swap_token_out` varchar(42) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `swap_amount_in_raw` varchar(80) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `swap_amount_out_raw` varchar(80) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `amount0_used_raw` varchar(80) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `amount1_used_raw` varchar(80) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `dust0_raw` varchar(80) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `dust1_raw` varchar(80) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `fee_value_usd` decimal(20,8) DEFAULT NULL,
  `estimated_gas_usd` decimal(20,8) DEFAULT NULL,
  `actual_gas_native` decimal(38,18) DEFAULT NULL,
  `swap_provider` varchar(30) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `collect_tx_hash` varchar(66) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `swap_approval_tx_hash` varchar(66) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `swap_tx_hash` varchar(66) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `increase_approval0_tx_hash` varchar(66) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `increase_approval1_tx_hash` varchar(66) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `increase_tx_hash` varchar(66) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `pending_action` varchar(40) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `pending_nonce` bigint DEFAULT NULL,
  `pending_signed_tx_hash` varchar(66) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `pending_broadcast_tx_hash` varchar(66) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `pending_since` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `completed_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `configured_position_cache_snapshots`
--

CREATE TABLE `configured_position_cache_snapshots` (
  `id` bigint NOT NULL,
  `chain` varchar(20) COLLATE utf8mb3_unicode_ci NOT NULL,
  `source` varchar(80) COLLATE utf8mb3_unicode_ci NOT NULL,
  `snapshot_json` longtext COLLATE utf8mb3_unicode_ci NOT NULL,
  `last_synced_block` bigint NOT NULL DEFAULT '0',
  `position_count` int NOT NULL DEFAULT '0',
  `content_hash` char(64) COLLATE utf8mb3_unicode_ci NOT NULL,
  `file_mtime` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `configured_rebalance_jobs`
--

CREATE TABLE `configured_rebalance_jobs` (
  `id` bigint NOT NULL,
  `chain` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  `pool_address` varchar(42) COLLATE utf8mb3_unicode_ci NOT NULL,
  `wallet_address` varchar(42) COLLATE utf8mb3_unicode_ci NOT NULL,
  `old_token_id` bigint NOT NULL,
  `new_token_id` bigint DEFAULT NULL,
  `status` varchar(40) COLLATE utf8mb3_unicode_ci NOT NULL,
  `old_tick_lower` int DEFAULT NULL,
  `old_tick_upper` int DEFAULT NULL,
  `new_tick_lower` int DEFAULT NULL,
  `new_tick_upper` int DEFAULT NULL,
  `amount0_desired` varchar(80) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `amount1_desired` varchar(80) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `swap_tx_hash` varchar(66) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `withdraw_tx_hash` varchar(66) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `mint_tx_hash` varchar(66) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `stake_tx_hash` varchar(66) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `burn_tx_hash` varchar(66) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `error_reason` varchar(500) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `new_mint_tick` int DEFAULT NULL,
  `new_mint_tick_lower` int DEFAULT NULL,
  `new_mint_tick_upper` int DEFAULT NULL,
  `range_lower_percent` decimal(12,6) DEFAULT NULL,
  `range_upper_percent` decimal(12,6) DEFAULT NULL,
  `range_percent_source` varchar(40) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `claimed_reward_token` varchar(42) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `claimed_reward_raw` varchar(80) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `claimed_reward_amount` decimal(38,18) DEFAULT NULL,
  `claimed_reward_price_usd` decimal(20,8) DEFAULT NULL,
  `claimed_reward_usd` decimal(20,8) DEFAULT NULL,
  `claimed_reward_source` varchar(40) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `discord_pnl_notified_at` datetime DEFAULT NULL,
  `discord_pending_notified_at` datetime DEFAULT NULL,
  `discord_notify_error` varchar(500) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `pre_balance0_raw` varchar(80) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `pre_balance1_raw` varchar(80) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `post_withdraw_balance0_raw` varchar(80) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `post_withdraw_balance1_raw` varchar(80) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `post_swap_balance0_raw` varchar(80) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `post_swap_balance1_raw` varchar(80) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `recovery_attempts` int NOT NULL DEFAULT '0',
  `last_recovery_error` varchar(500) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `reserved_token0_address` varchar(42) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `reserved_token1_address` varchar(42) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `reserved_token0_raw` varchar(80) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `reserved_token1_raw` varchar(80) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `reservation_updated_at` datetime DEFAULT NULL,
  `recovery_notified_at` datetime DEFAULT NULL,
  `discord_partial_notified_at` datetime DEFAULT NULL,
  `discord_partial_notify_key` varchar(180) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `discord_partial_notify_error` varchar(500) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `unstake_tx_hash` varchar(66) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `restore_stake_mode` varchar(10) COLLATE utf8mb3_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `configured_wallet_tx_guards`
--

CREATE TABLE `configured_wallet_tx_guards` (
  `chain` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  `wallet_address` varchar(42) COLLATE utf8mb3_unicode_ci NOT NULL,
  `nonce` bigint UNSIGNED NOT NULL,
  `signed_tx_hash` varchar(66) COLLATE utf8mb3_unicode_ci NOT NULL,
  `broadcast_tx_hash` varchar(66) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `action` varchar(40) COLLATE utf8mb3_unicode_ci NOT NULL,
  `pool_name` varchar(160) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `last_error` varchar(500) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `detail_token_transactions`
--

CREATE TABLE `detail_token_transactions` (
  `id` bigint NOT NULL,
  `hash` varchar(100) COLLATE utf8mb3_unicode_ci NOT NULL,
  `from_address` varchar(44) COLLATE utf8mb3_unicode_ci NOT NULL,
  `to_address` varchar(44) COLLATE utf8mb3_unicode_ci NOT NULL,
  `contract` varchar(44) COLLATE utf8mb3_unicode_ci NOT NULL,
  `amount` varchar(50) COLLATE utf8mb3_unicode_ci NOT NULL,
  `symbol` varchar(50) COLLATE utf8mb3_unicode_ci NOT NULL,
  `wallet` varchar(44) COLLATE utf8mb3_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `detected_pools`
--

CREATE TABLE `detected_pools` (
  `id` int NOT NULL,
  `chain` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  `pool_address` varchar(42) COLLATE utf8mb3_unicode_ci NOT NULL,
  `pool_info_id` int DEFAULT NULL,
  `pid` int DEFAULT NULL,
  `token0_address` varchar(42) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `token1_address` varchar(42) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `token0_symbol` varchar(20) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `token1_symbol` varchar(20) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `token0_decimals` int DEFAULT NULL,
  `token1_decimals` int DEFAULT NULL,
  `fee` int DEFAULT NULL,
  `tick_spacing` int DEFAULT NULL,
  `alloc_point` int DEFAULT NULL,
  `cake_per_day` decimal(20,8) DEFAULT NULL,
  `total_staked_liquidity_usd` decimal(20,4) DEFAULT NULL,
  `inactive_ratio` decimal(6,4) DEFAULT NULL,
  `estimated_apr` decimal(10,4) DEFAULT NULL,
  `tick_current` int DEFAULT NULL,
  `sqrt_price_x96` varchar(80) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `delta_tick_24h` int DEFAULT NULL,
  `sigma_reserve` decimal(14,4) DEFAULT NULL,
  `pool_type` enum('ZOMBIE','STABLE','SEMI_STABLE','VOLATILE','UNKNOWN') COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `zombie_score` decimal(5,4) DEFAULT NULL,
  `status` enum('CANDIDATE','APPROVED','WATCH','REJECTED','INVESTED') COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `consecutive_losses` int DEFAULT '0',
  `selection_source` enum('ZOMBIE','COPY_BOT') COLLATE utf8mb3_unicode_ci DEFAULT 'ZOMBIE',
  `reject_reason` varchar(200) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `last_analyzed_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `extreme_price_range_pool_sol`
--

CREATE TABLE `extreme_price_range_pool_sol` (
  `id` int NOT NULL,
  `pool_id` varchar(100) NOT NULL,
  `tick_lower` int DEFAULT NULL,
  `tick_upper` int DEFAULT NULL,
  `min_price` float DEFAULT '0',
  `max_price` float DEFAULT '0',
  `tick_array_bitmap_extension_account` varchar(100) NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `farm_state`
--

CREATE TABLE `farm_state` (
  `id` int NOT NULL,
  `pid` int NOT NULL,
  `chain` varchar(10) NOT NULL,
  `v3Pool` varchar(100) NOT NULL,
  `fee` float NOT NULL,
  `alloc_point` bigint NOT NULL,
  `timestamp` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `farm_state_sol`
--

CREATE TABLE `farm_state_sol` (
  `id` int NOT NULL,
  `chain` varchar(10) NOT NULL,
  `pool_account` varchar(100) NOT NULL,
  `reward_idx` int NOT NULL,
  `token_mint` varchar(100) NOT NULL,
  `reward_state` int NOT NULL,
  `open_time` bigint NOT NULL,
  `end_time` bigint NOT NULL,
  `reward_claimed` bigint NOT NULL,
  `reward_total_emissioned` bigint NOT NULL,
  `token_reward_symbol` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `token_reward_decimals` int NOT NULL,
  `weekly_rewards` double NOT NULL DEFAULT '0',
  `timestamp` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `futures_orders_binance`
--

CREATE TABLE `futures_orders_binance` (
  `id` bigint NOT NULL,
  `wallet_id` varchar(128) COLLATE utf8mb3_unicode_ci NOT NULL,
  `order_id` bigint NOT NULL,
  `symbol` varchar(16) COLLATE utf8mb3_unicode_ci NOT NULL,
  `status` varchar(32) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `client_order_id` varchar(64) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `price` decimal(30,10) DEFAULT NULL,
  `avg_price` decimal(30,10) DEFAULT NULL,
  `orig_qty` decimal(30,10) DEFAULT NULL,
  `executed_qty` decimal(30,10) DEFAULT NULL,
  `cum_quote` decimal(30,10) DEFAULT NULL,
  `type` varchar(32) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `side` enum('BUY','SELL') COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `position_side` enum('BOTH','LONG','SHORT') COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `time` bigint DEFAULT NULL,
  `update_time` bigint DEFAULT NULL,
  `futures_type` varchar(16) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `futures_positions_binance`
--

CREATE TABLE `futures_positions_binance` (
  `id` bigint NOT NULL,
  `wallet_id` varchar(128) COLLATE utf8mb3_unicode_ci NOT NULL,
  `symbol` varchar(16) COLLATE utf8mb3_unicode_ci NOT NULL,
  `position_amt` decimal(30,10) NOT NULL,
  `entry_price` decimal(30,10) DEFAULT NULL,
  `mark_price` decimal(30,10) DEFAULT NULL,
  `unrealized_pnl` decimal(30,10) DEFAULT NULL,
  `leverage` int DEFAULT NULL,
  `margin_type` enum('cross','isolated') COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `isolated_margin` decimal(30,10) DEFAULT NULL,
  `position_side` enum('BOTH','LONG','SHORT') COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `notional` decimal(30,10) DEFAULT NULL,
  `update_time` bigint DEFAULT NULL,
  `futures_type` varchar(16) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `hash_txs`
--

CREATE TABLE `hash_txs` (
  `id` bigint NOT NULL,
  `hash` varchar(100) COLLATE utf8mb3_unicode_ci NOT NULL,
  `block` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  `chain` varchar(3) COLLATE utf8mb3_unicode_ci NOT NULL,
  `tx_time` timestamp NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `list_bond_contract_notify`
--

CREATE TABLE `list_bond_contract_notify` (
  `id` int NOT NULL,
  `chain` varchar(10) NOT NULL,
  `contract_address` varchar(100) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `token_symbol` varchar(20) NOT NULL,
  `status` enum('active','sold') NOT NULL DEFAULT 'active',
  `notify_threshold` decimal(5,2) DEFAULT '20.00',
  `api_missing_count` int NOT NULL DEFAULT '0',
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `manual_fetch_jobs`
--

CREATE TABLE `manual_fetch_jobs` (
  `id` bigint NOT NULL,
  `wallet_address` varchar(80) COLLATE utf8mb3_unicode_ci NOT NULL,
  `chain` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  `status` varchar(20) COLLATE utf8mb3_unicode_ci NOT NULL,
  `message` text COLLATE utf8mb3_unicode_ci,
  `error` text COLLATE utf8mb3_unicode_ci,
  `rows_inserted` int NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL,
  `started_at` datetime DEFAULT NULL,
  `finished_at` datetime DEFAULT NULL,
  `expires_at` datetime DEFAULT NULL,
  `active_key` varchar(120) COLLATE utf8mb3_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `nft_blacklist`
--

CREATE TABLE `nft_blacklist` (
  `id` int NOT NULL,
  `wallet_address` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `chain` varchar(10) NOT NULL,
  `nft_id` varchar(60) NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `type_dex` varchar(20) NOT NULL DEFAULT '',
  `npm_address` varchar(42) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `nft_closed_cache`
--

CREATE TABLE `nft_closed_cache` (
  `wallet_address` varchar(100) NOT NULL,
  `chain_name` varchar(50) NOT NULL,
  `nft_id` varchar(100) NOT NULL,
  `status` varchar(20) DEFAULT NULL,
  `closed_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `type_dex` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `npm_address` varchar(42) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `nft_mint_scan_anchor`
--

CREATE TABLE `nft_mint_scan_anchor` (
  `id` bigint NOT NULL,
  `wallet_address` varchar(80) COLLATE utf8mb3_unicode_ci NOT NULL,
  `chain` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  `type_dex` varchar(20) COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '',
  `nft_id` varchar(100) COLLATE utf8mb3_unicode_ci NOT NULL,
  `npm_address` varchar(100) COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '',
  `pool_address` varchar(100) COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '',
  `anchor_block_number` bigint DEFAULT NULL,
  `anchor_slot` bigint DEFAULT NULL,
  `tx_hash` varchar(100) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `source` varchar(50) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `nft_token_transactions`
--

CREATE TABLE `nft_token_transactions` (
  `id` bigint NOT NULL,
  `hash` varchar(100) COLLATE utf8mb3_unicode_ci NOT NULL,
  `contract` varchar(44) COLLATE utf8mb3_unicode_ci NOT NULL,
  `token_id` varchar(100) COLLATE utf8mb3_unicode_ci NOT NULL,
  `wallet` varchar(44) COLLATE utf8mb3_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `pool_info`
--

CREATE TABLE `pool_info` (
  `id` int NOT NULL,
  `chain` varchar(10) NOT NULL,
  `pool_address` varchar(42) NOT NULL,
  `token0_address` varchar(42) DEFAULT NULL,
  `token1_address` varchar(42) DEFAULT NULL,
  `token0_symbol` varchar(20) DEFAULT NULL,
  `token1_symbol` varchar(20) DEFAULT NULL,
  `token0_decimals` int DEFAULT NULL,
  `token1_decimals` int DEFAULT NULL,
  `fee` int DEFAULT NULL,
  `alloc_point` int DEFAULT '0',
  `pid` int NOT NULL DEFAULT '0',
  `cake_per_day` double NOT NULL DEFAULT '0',
  `total_value_lock` double NOT NULL DEFAULT '0',
  `cake_reward_1h` float NOT NULL DEFAULT '0',
  `total_current_liquidity` double NOT NULL DEFAULT '0',
  `total_staked_liquidity` double NOT NULL DEFAULT '0',
  `total_inactive_staked_liquidity` double NOT NULL DEFAULT '0',
  `farm_apr` double NOT NULL DEFAULT '0',
  `is_stake_tracked` tinyint(1) NOT NULL DEFAULT '1',
  `is_bot_managed` tinyint(1) NOT NULL DEFAULT '0',
  `timestamp` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `narrow_range_count` int DEFAULT '0',
  `narrow_range_tvl_usd` double DEFAULT '0',
  `has_narrow_bot_flag` tinyint(1) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `pool_sol_info`
--

CREATE TABLE `pool_sol_info` (
  `id` int NOT NULL,
  `chain` varchar(10) NOT NULL,
  `pool_account` varchar(100) NOT NULL,
  `token0_mint` varchar(100) DEFAULT NULL,
  `token1_mint` varchar(100) DEFAULT NULL,
  `token0_symbol` varchar(50) DEFAULT NULL,
  `token1_symbol` varchar(50) DEFAULT NULL,
  `token0_decimals` int DEFAULT NULL,
  `token1_decimals` int DEFAULT NULL,
  `reward_state` int NOT NULL,
  `open_time` bigint NOT NULL,
  `end_time` bigint NOT NULL,
  `reward_claimed` bigint NOT NULL,
  `reward_total_emissioned` bigint NOT NULL,
  `reward_account` varchar(60) DEFAULT NULL,
  `reward_symbol` varchar(20) DEFAULT NULL,
  `weekly_rewards` double NOT NULL DEFAULT '0',
  `cake_reward_1h` float NOT NULL DEFAULT '0',
  `total_valid_liquidity` double NOT NULL DEFAULT '0',
  `total_inactive_staked_liquidity` double NOT NULL DEFAULT '0',
  `total_current_liquidity` double NOT NULL DEFAULT '0',
  `fee` int NOT NULL DEFAULT '0',
  `timestamp` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `pool_tick_history`
--

CREATE TABLE `pool_tick_history` (
  `id` bigint NOT NULL,
  `chain` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  `pool_address` varchar(42) COLLATE utf8mb3_unicode_ci NOT NULL,
  `pid` int DEFAULT NULL,
  `tick` int NOT NULL,
  `sqrt_price_x96` varchar(80) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `block_number` bigint DEFAULT NULL,
  `source` enum('SLOT0') COLLATE utf8mb3_unicode_ci DEFAULT 'SLOT0',
  `observed_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `token_cmc_map`
--

CREATE TABLE `token_cmc_map` (
  `id` int NOT NULL,
  `token_address` varchar(100) DEFAULT NULL,
  `chain` varchar(20) DEFAULT NULL,
  `cmc_id` varchar(20) DEFAULT NULL,
  `symbol` varchar(50) DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  `last_updated` datetime DEFAULT NULL,
  `market_cap_usd` decimal(38,8) DEFAULT NULL,
  `fdv_usd` decimal(38,8) DEFAULT NULL,
  `market_data_updated_at` datetime DEFAULT NULL,
  `cmc_rank` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `token_futures_market`
--

CREATE TABLE `token_futures_market` (
  `id` bigint NOT NULL,
  `chain` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  `token_address` varchar(100) COLLATE utf8mb3_unicode_ci NOT NULL,
  `token_symbol` varchar(50) COLLATE utf8mb3_unicode_ci NOT NULL,
  `exchange` varchar(30) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `market_pair` varchar(80) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `contract_type` varchar(20) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `volume_24h_usd` decimal(38,8) DEFAULT NULL,
  `mapping_status` varchar(20) COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT 'not_found',
  `source_updated_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `token_info_cache`
--

CREATE TABLE `token_info_cache` (
  `chain` varchar(32) NOT NULL,
  `token_address` varchar(42) NOT NULL,
  `decimals` int DEFAULT NULL,
  `symbol` varchar(32) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `token_transfer_summary_settings`
--

CREATE TABLE `token_transfer_summary_settings` (
  `id` bigint NOT NULL,
  `wallet` varchar(60) COLLATE utf8mb3_unicode_ci NOT NULL,
  `chain` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  `token_address` varchar(100) COLLATE utf8mb3_unicode_ci NOT NULL,
  `start_time` datetime NOT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `transactions`
--

CREATE TABLE `transactions` (
  `id` bigint NOT NULL,
  `hash` varchar(100) NOT NULL,
  `wallet` varchar(44) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `transaction_detail_v2`
--

CREATE TABLE `transaction_detail_v2` (
  `id` bigint NOT NULL,
  `hash` varchar(100) COLLATE utf8mb3_unicode_ci NOT NULL,
  `from_address` varchar(60) COLLATE utf8mb3_unicode_ci NOT NULL,
  `to_address` varchar(60) COLLATE utf8mb3_unicode_ci NOT NULL,
  `contract` varchar(100) COLLATE utf8mb3_unicode_ci NOT NULL,
  `amount` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `symbol` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `wallet` varchar(60) COLLATE utf8mb3_unicode_ci NOT NULL,
  `log_index` varchar(50) COLLATE utf8mb3_unicode_ci DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `transaction_detail_v2_bk`
--

CREATE TABLE `transaction_detail_v2_bk` (
  `id` bigint NOT NULL,
  `hash` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `from_address` varchar(60) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `to_address` varchar(60) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `contract` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `amount` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `symbol` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `wallet` varchar(60) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `log_index` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT '',
  `is_context` tinyint(1) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `transaction_history_v2`
--

CREATE TABLE `transaction_history_v2` (
  `id` bigint NOT NULL,
  `hash` varchar(100) COLLATE utf8mb3_unicode_ci NOT NULL,
  `block` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  `chain` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  `wallet` varchar(60) COLLATE utf8mb3_unicode_ci NOT NULL,
  `date_time` timestamp NOT NULL,
  `contract` varchar(100) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `token_id` varchar(100) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `transaction_fee` decimal(30,10) DEFAULT '0.0000000000',
  `gas_fee` decimal(30,10) DEFAULT '0.0000000000',
  `method_name` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `transaction_history_v2_bk`
--

CREATE TABLE `transaction_history_v2_bk` (
  `id` bigint NOT NULL,
  `hash` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `block` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `chain` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `wallet` varchar(60) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `date_time` timestamp NOT NULL,
  `contract` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `token_id` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `transaction_fee` decimal(30,10) DEFAULT '0.0000000000',
  `gas_fee` decimal(30,10) DEFAULT '0.0000000000',
  `method_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `wallets`
--

CREATE TABLE `wallets` (
  `id` int NOT NULL,
  `wallet_address` varchar(128) COLLATE utf8mb3_unicode_ci NOT NULL,
  `chain` varchar(32) COLLATE utf8mb3_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `wallet_nft_position`
--

CREATE TABLE `wallet_nft_position` (
  `id` int NOT NULL,
  `wallet_address` varchar(60) DEFAULT NULL,
  `chain` varchar(10) DEFAULT NULL,
  `nft_id` varchar(60) DEFAULT NULL,
  `token0_symbol` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `token1_symbol` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `pool_address` varchar(100) DEFAULT NULL,
  `price_token0` double DEFAULT NULL,
  `price_token1` double DEFAULT NULL,
  `status` varchar(20) DEFAULT NULL,
  `date_add_liquidity` datetime DEFAULT NULL,
  `initial_token0_amount` double DEFAULT NULL,
  `initial_token1_amount` double DEFAULT NULL,
  `initial_total_value` double DEFAULT NULL,
  `current_token0_amount` double DEFAULT NULL,
  `current_token1_amount` double DEFAULT NULL,
  `current_total_value` double DEFAULT NULL,
  `delta_amount` double DEFAULT NULL,
  `percent_change` double DEFAULT NULL,
  `unclaimed_fee_token0` double DEFAULT NULL,
  `unclaimed_fee_token1` double DEFAULT NULL,
  `total_unclaimed_fee` double DEFAULT NULL,
  `lp_fee_apr` double DEFAULT NULL,
  `lp_fee_apr_1h` double DEFAULT NULL,
  `pending_cake` double DEFAULT NULL,
  `reward_price` double NOT NULL DEFAULT '1.5',
  `cake_reward_1h` double DEFAULT NULL,
  `boost_multiplier` double DEFAULT NULL,
  `farm_apr_1h` double DEFAULT NULL,
  `farm_apr_all` double DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `wallet_url` varchar(255) DEFAULT NULL,
  `nft_id_url` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `has_invalid_price` tinyint(1) DEFAULT NULL,
  `lower_price` float NOT NULL DEFAULT '0',
  `upper_price` float NOT NULL DEFAULT '0',
  `current_price` float NOT NULL DEFAULT '0',
  `type_dex` varchar(20) NOT NULL DEFAULT 'pancakeswap',
  `pnl_value_base` decimal(36,18) DEFAULT '0.000000000000000000',
  `pnl_value_usd` decimal(36,18) DEFAULT '0.000000000000000000',
  `total_active_staked_usd` decimal(36,18) DEFAULT '0.000000000000000000',
  `total_pool_liquidity_usd` decimal(36,18) DEFAULT '0.000000000000000000',
  `npm_address` varchar(42) NOT NULL DEFAULT '',
  `time_reward_reset` datetime DEFAULT NULL,
  `time_fee_reset` datetime DEFAULT NULL,
  `pnl_token0` double DEFAULT '0',
  `pnl_token1` double DEFAULT '0',
  `accumulated_reward_usd` double DEFAULT '0',
  `aerodrome_mode` varchar(20) DEFAULT NULL,
  `is_adaptive_snapshot` tinyint(1) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `wallet_nft_position_bk`
--

CREATE TABLE `wallet_nft_position_bk` (
  `id` int NOT NULL,
  `wallet_address` varchar(42) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `chain` varchar(10) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `nft_id` bigint DEFAULT NULL,
  `token0_symbol` varchar(20) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `token1_symbol` varchar(20) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `price_token0` double DEFAULT NULL,
  `price_token1` double DEFAULT NULL,
  `status` varchar(20) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `date_add_liquidity` datetime DEFAULT NULL,
  `initial_token0_amount` double DEFAULT NULL,
  `initial_token1_amount` double DEFAULT NULL,
  `initial_total_value` double DEFAULT NULL,
  `current_token0_amount` double DEFAULT NULL,
  `current_token1_amount` double DEFAULT NULL,
  `current_total_value` double DEFAULT NULL,
  `delta_amount` double DEFAULT NULL,
  `percent_change` double DEFAULT NULL,
  `unclaimed_fee_token0` double DEFAULT NULL,
  `unclaimed_fee_token1` double DEFAULT NULL,
  `total_unclaimed_fee` double DEFAULT NULL,
  `lp_fee_apr` double DEFAULT NULL,
  `pending_cake` double DEFAULT NULL,
  `boost_multiplier` double DEFAULT NULL,
  `farm_apr_1h` double DEFAULT NULL,
  `farm_apr_all` double DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `wallet_url` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `nft_id_url` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `wallet_nft_summary`
--

CREATE TABLE `wallet_nft_summary` (
  `id` int NOT NULL,
  `nft_id` varchar(60) COLLATE utf8mb3_unicode_ci NOT NULL,
  `position_id` bigint DEFAULT NULL,
  `wallet_address` varchar(60) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `chain` varchar(10) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `token0_symbol` varchar(20) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `token1_symbol` varchar(20) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `net_invested_capital` double DEFAULT '0',
  `total_claimed_fee0` double DEFAULT '0',
  `total_claimed_fee1` double DEFAULT '0',
  `total_claimed_reward` double DEFAULT '0',
  `last_unclaimed_fee0` double DEFAULT '0',
  `last_unclaimed_fee1` double DEFAULT '0',
  `last_pending_reward` double DEFAULT '0',
  `status` varchar(20) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `total_claimed_fee_usd` double DEFAULT '0',
  `total_claimed_reward_usd` double DEFAULT '0',
  `total_cash_injected` double NOT NULL DEFAULT '0',
  `last_lp_token0` double DEFAULT '0',
  `last_lp_token1` double DEFAULT '0',
  `last_current_token0` decimal(38,18) DEFAULT '0.000000000000000000',
  `last_current_token1` decimal(38,18) DEFAULT '0.000000000000000000',
  `realized_pnl_token0` decimal(38,18) DEFAULT '0.000000000000000000',
  `realized_pnl_token1` decimal(38,18) DEFAULT '0.000000000000000000',
  `base_symbol` varchar(20) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `total_claimed_in_base` double DEFAULT '0',
  `invested_capital_base` double DEFAULT '0',
  `current_val_base` double DEFAULT '0',
  `pnl_base_percent` double DEFAULT '0',
  `pnl_value_usd` double DEFAULT '0',
  `pnl_value_base` double DEFAULT '0',
  `type_dex` varchar(20) COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '',
  `npm_address` varchar(42) COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '',
  `time_reward_reset` datetime DEFAULT NULL,
  `time_fee_reset` datetime DEFAULT NULL,
  `pnl_token0` double DEFAULT '0',
  `pnl_token1` double DEFAULT '0',
  `total_cash_injected_t0` decimal(36,18) NOT NULL DEFAULT '0.000000000000000000' COMMENT 'Vốn gốc tích lũy quy về T0 (pool_ratio tại từng injection event)',
  `total_cash_injected_t1` decimal(36,18) NOT NULL DEFAULT '0.000000000000000000' COMMENT 'Vốn gốc tích lũy quy về T1 (pool_ratio tại từng injection event)',
  `total_claimed_fee_in_t0` decimal(36,18) NOT NULL DEFAULT '0.000000000000000000' COMMENT 'Fee đã collect tích lũy quy về T0 (pool_ratio tại từng collect event)',
  `total_claimed_fee_in_t1` decimal(36,18) NOT NULL DEFAULT '0.000000000000000000' COMMENT 'Fee đã collect tích lũy quy về T1 (pool_ratio tại từng collect event)'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Chỉ mục cho các bảng đã đổ
--

--
-- Chỉ mục cho bảng `aerodrome_pool_epoch_state`
--
ALTER TABLE `aerodrome_pool_epoch_state`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `pool_address` (`pool_address`);

--
-- Chỉ mục cho bảng `aerodrome_pool_info`
--
ALTER TABLE `aerodrome_pool_info`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `pool_address` (`pool_address`);

--
-- Chỉ mục cho bảng `aerodrome_pool_reward_history`
--
ALTER TABLE `aerodrome_pool_reward_history`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_aerodrome_reward_epoch` (`chain`,`pool_address`,`epoch_start`),
  ADD KEY `idx_aerodrome_reward_previous` (`chain`,`pool_address`,`epoch_start`);

--
-- Chỉ mục cho bảng `binance_account_wallet_links`
--
ALTER TABLE `binance_account_wallet_links`
  ADD PRIMARY KEY (`account_alias`,`wallet_type`,`wallet_address`),
  ADD KEY `idx_binance_wallet_link` (`wallet_type`,`wallet_address`);

--
-- Chỉ mục cho bảng `binance_futures_positions_current`
--
ALTER TABLE `binance_futures_positions_current`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_binance_current_position` (`account_alias`,`market_type`,`symbol`,`position_side`),
  ADD KEY `idx_binance_current_account` (`account_alias`,`market_type`);

--
-- Chỉ mục cho bảng `binance_futures_sync_state`
--
ALTER TABLE `binance_futures_sync_state`
  ADD PRIMARY KEY (`account_alias`,`market_type`);

--
-- Chỉ mục cho bảng `bond`
--
ALTER TABLE `bond`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `bond_id` (`bond_id`),
  ADD UNIQUE KEY `bond_type` (`bond_type`),
  ADD KEY `wallet_id` (`wallet_id`);

--
-- Chỉ mục cho bảng `bond_buy`
--
ALTER TABLE `bond_buy`
  ADD PRIMARY KEY (`id`),
  ADD KEY `bond_id` (`bond_id`);

--
-- Chỉ mục cho bảng `bond_claim`
--
ALTER TABLE `bond_claim`
  ADD PRIMARY KEY (`id`),
  ADD KEY `bond_id` (`bond_id`);

--
-- Chỉ mục cho bảng `bond_history`
--
ALTER TABLE `bond_history`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `bond_runtime_status`
--
ALTER TABLE `bond_runtime_status`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_bond_id` (`bond_id`),
  ADD KEY `idx_bond_type` (`bond_type`);

--
-- Chỉ mục cho bảng `bot_pool_blacklist`
--
ALTER TABLE `bot_pool_blacklist`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `idx_chain_pool` (`chain`,`pool_address`);

--
-- Chỉ mục cho bảng `bot_positions`
--
ALTER TABLE `bot_positions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `token_id` (`token_id`);

--
-- Chỉ mục cho bảng `bot_transactions`
--
ALTER TABLE `bot_transactions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `tx_hash` (`tx_hash`),
  ADD KEY `bot_position_id` (`bot_position_id`);

--
-- Chỉ mục cho bảng `configured_compound_jobs`
--
ALTER TABLE `configured_compound_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_compound_idempotency` (`idempotency_key`),
  ADD KEY `idx_compound_position` (`chain`,`npm_address`,`token_id`,`status`),
  ADD KEY `idx_compound_wallet_pending` (`chain`,`wallet_address`,`pending_action`);

--
-- Chỉ mục cho bảng `configured_position_cache_snapshots`
--
ALTER TABLE `configured_position_cache_snapshots`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_chain_source` (`chain`,`source`),
  ADD KEY `idx_chain_updated` (`chain`,`updated_at`);

--
-- Chỉ mục cho bảng `configured_rebalance_jobs`
--
ALTER TABLE `configured_rebalance_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_chain_old_token` (`chain`,`old_token_id`),
  ADD KEY `idx_pool_status` (`chain`,`pool_address`,`status`);

--
-- Chỉ mục cho bảng `configured_wallet_tx_guards`
--
ALTER TABLE `configured_wallet_tx_guards`
  ADD PRIMARY KEY (`chain`,`wallet_address`),
  ADD UNIQUE KEY `uniq_wallet_guard_signed_hash` (`signed_tx_hash`);

--
-- Chỉ mục cho bảng `detail_token_transactions`
--
ALTER TABLE `detail_token_transactions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `hash` (`hash`);

--
-- Chỉ mục cho bảng `detected_pools`
--
ALTER TABLE `detected_pools`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_chain_pool` (`chain`,`pool_address`);

--
-- Chỉ mục cho bảng `extreme_price_range_pool_sol`
--
ALTER TABLE `extreme_price_range_pool_sol`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `tick_lower` (`tick_lower`,`tick_upper`,`min_price`,`max_price`,`tick_array_bitmap_extension_account`);

--
-- Chỉ mục cho bảng `farm_state`
--
ALTER TABLE `farm_state`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `farm_state_sol`
--
ALTER TABLE `farm_state_sol`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `futures_orders_binance`
--
ALTER TABLE `futures_orders_binance`
  ADD PRIMARY KEY (`id`),
  ADD KEY `wallet_id` (`wallet_id`);

--
-- Chỉ mục cho bảng `futures_positions_binance`
--
ALTER TABLE `futures_positions_binance`
  ADD PRIMARY KEY (`id`),
  ADD KEY `wallet_id` (`wallet_id`);

--
-- Chỉ mục cho bảng `hash_txs`
--
ALTER TABLE `hash_txs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `hash` (`hash`);

--
-- Chỉ mục cho bảng `list_bond_contract_notify`
--
ALTER TABLE `list_bond_contract_notify`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_bond_chain_address` (`chain`,`contract_address`);

--
-- Chỉ mục cho bảng `manual_fetch_jobs`
--
ALTER TABLE `manual_fetch_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_manual_fetch_active` (`active_key`),
  ADD KEY `idx_manual_fetch_wallet_chain` (`wallet_address`,`chain`),
  ADD KEY `idx_manual_fetch_status` (`status`);

--
-- Chỉ mục cho bảng `nft_blacklist`
--
ALTER TABLE `nft_blacklist`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_blacklist` (`wallet_address`,`chain`,`nft_id`);

--
-- Chỉ mục cho bảng `nft_closed_cache`
--
ALTER TABLE `nft_closed_cache`
  ADD PRIMARY KEY (`chain_name`,`wallet_address`,`nft_id`,`type_dex`);

--
-- Chỉ mục cho bảng `nft_mint_scan_anchor`
--
ALTER TABLE `nft_mint_scan_anchor`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_nft_mint_scan_anchor_identity` (`wallet_address`,`chain`,`type_dex`,`nft_id`,`npm_address`),
  ADD KEY `idx_nft_mint_scan_anchor_lookup` (`wallet_address`,`chain`,`type_dex`,`nft_id`,`npm_address`);

--
-- Chỉ mục cho bảng `nft_token_transactions`
--
ALTER TABLE `nft_token_transactions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `hash` (`hash`);

--
-- Chỉ mục cho bảng `pool_info`
--
ALTER TABLE `pool_info`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `pool_address` (`pool_address`),
  ADD UNIQUE KEY `uq_chain_pool` (`chain`,`pool_address`),
  ADD KEY `idx_alloc_point` (`alloc_point`);

--
-- Chỉ mục cho bảng `pool_sol_info`
--
ALTER TABLE `pool_sol_info`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `pool_account` (`pool_account`);

--
-- Chỉ mục cho bảng `pool_tick_history`
--
ALTER TABLE `pool_tick_history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_chain_pool_time` (`chain`,`pool_address`,`observed_at`),
  ADD KEY `idx_chain_time` (`chain`,`observed_at`);

--
-- Chỉ mục cho bảng `token_cmc_map`
--
ALTER TABLE `token_cmc_map`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_token_cmc_map_chain_address` (`chain`,`token_address`);

--
-- Chỉ mục cho bảng `token_futures_market`
--
ALTER TABLE `token_futures_market`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_token_futures_market` (`chain`,`token_address`),
  ADD KEY `idx_token_futures_symbol` (`token_symbol`);

--
-- Chỉ mục cho bảng `token_info_cache`
--
ALTER TABLE `token_info_cache`
  ADD PRIMARY KEY (`chain`,`token_address`);

--
-- Chỉ mục cho bảng `token_transfer_summary_settings`
--
ALTER TABLE `token_transfer_summary_settings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_wallet_chain_token` (`wallet`,`chain`,`token_address`);

--
-- Chỉ mục cho bảng `transactions`
--
ALTER TABLE `transactions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_wallet_hash` (`wallet`,`hash`),
  ADD KEY `hash` (`hash`);

--
-- Chỉ mục cho bảng `transaction_detail_v2`
--
ALTER TABLE `transaction_detail_v2`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `idx_unique_detail` (`hash`,`from_address`,`to_address`,`contract`,`amount`,`symbol`,`log_index`),
  ADD KEY `idx_hash_tmp` (`hash`);

--
-- Chỉ mục cho bảng `transaction_detail_v2_bk`
--
ALTER TABLE `transaction_detail_v2_bk`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `idx_unique_detail` (`hash`,`from_address`,`to_address`,`contract`,`amount`,`symbol`,`log_index`),
  ADD KEY `idx_hash_tmp` (`hash`);

--
-- Chỉ mục cho bảng `transaction_history_v2`
--
ALTER TABLE `transaction_history_v2`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_wallet_hash` (`wallet`,`hash`),
  ADD KEY `hash` (`hash`),
  ADD KEY `idx_wallet_chain_token_date` (`wallet`,`chain`,`token_id`,`date_time`);

--
-- Chỉ mục cho bảng `transaction_history_v2_bk`
--
ALTER TABLE `transaction_history_v2_bk`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_wallet_hash` (`wallet`,`hash`),
  ADD KEY `hash` (`hash`);

--
-- Chỉ mục cho bảng `wallets`
--
ALTER TABLE `wallets`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `wallet_address` (`wallet_address`);

--
-- Chỉ mục cho bảng `wallet_nft_position`
--
ALTER TABLE `wallet_nft_position`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_wallet_address` (`wallet_address`),
  ADD KEY `idx_nft_id` (`nft_id`),
  ADD KEY `idx_nft_created` (`nft_id`,`created_at`),
  ADD KEY `idx_wallet_chain_latest_identity` (`wallet_address`,`chain`,`type_dex`,`nft_id`,`npm_address`,`created_at`,`id`),
  ADD KEY `idx_wallet_latest_identity` (`wallet_address`,`type_dex`,`nft_id`,`npm_address`,`created_at`,`id`);

--
-- Chỉ mục cho bảng `wallet_nft_position_bk`
--
ALTER TABLE `wallet_nft_position_bk`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `wallet_nft_summary`
--
ALTER TABLE `wallet_nft_summary`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_wallet` (`wallet_address`),
  ADD KEY `idx_status` (`status`);

--
-- AUTO_INCREMENT cho các bảng đã đổ
--

--
-- AUTO_INCREMENT cho bảng `aerodrome_pool_epoch_state`
--
ALTER TABLE `aerodrome_pool_epoch_state`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `aerodrome_pool_info`
--
ALTER TABLE `aerodrome_pool_info`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `aerodrome_pool_reward_history`
--
ALTER TABLE `aerodrome_pool_reward_history`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `binance_futures_positions_current`
--
ALTER TABLE `binance_futures_positions_current`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `bond`
--
ALTER TABLE `bond`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `bond_buy`
--
ALTER TABLE `bond_buy`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `bond_claim`
--
ALTER TABLE `bond_claim`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `bond_history`
--
ALTER TABLE `bond_history`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `bond_runtime_status`
--
ALTER TABLE `bond_runtime_status`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `bot_pool_blacklist`
--
ALTER TABLE `bot_pool_blacklist`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `bot_positions`
--
ALTER TABLE `bot_positions`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `bot_transactions`
--
ALTER TABLE `bot_transactions`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `configured_compound_jobs`
--
ALTER TABLE `configured_compound_jobs`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `configured_position_cache_snapshots`
--
ALTER TABLE `configured_position_cache_snapshots`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `configured_rebalance_jobs`
--
ALTER TABLE `configured_rebalance_jobs`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `detail_token_transactions`
--
ALTER TABLE `detail_token_transactions`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `detected_pools`
--
ALTER TABLE `detected_pools`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `extreme_price_range_pool_sol`
--
ALTER TABLE `extreme_price_range_pool_sol`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `farm_state`
--
ALTER TABLE `farm_state`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `farm_state_sol`
--
ALTER TABLE `farm_state_sol`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `futures_orders_binance`
--
ALTER TABLE `futures_orders_binance`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `futures_positions_binance`
--
ALTER TABLE `futures_positions_binance`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `hash_txs`
--
ALTER TABLE `hash_txs`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `list_bond_contract_notify`
--
ALTER TABLE `list_bond_contract_notify`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `manual_fetch_jobs`
--
ALTER TABLE `manual_fetch_jobs`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `nft_blacklist`
--
ALTER TABLE `nft_blacklist`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `nft_mint_scan_anchor`
--
ALTER TABLE `nft_mint_scan_anchor`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `nft_token_transactions`
--
ALTER TABLE `nft_token_transactions`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `pool_info`
--
ALTER TABLE `pool_info`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `pool_sol_info`
--
ALTER TABLE `pool_sol_info`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `pool_tick_history`
--
ALTER TABLE `pool_tick_history`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `token_cmc_map`
--
ALTER TABLE `token_cmc_map`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `token_futures_market`
--
ALTER TABLE `token_futures_market`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `token_transfer_summary_settings`
--
ALTER TABLE `token_transfer_summary_settings`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `transactions`
--
ALTER TABLE `transactions`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `transaction_detail_v2`
--
ALTER TABLE `transaction_detail_v2`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `transaction_detail_v2_bk`
--
ALTER TABLE `transaction_detail_v2_bk`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `transaction_history_v2`
--
ALTER TABLE `transaction_history_v2`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `transaction_history_v2_bk`
--
ALTER TABLE `transaction_history_v2_bk`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `wallets`
--
ALTER TABLE `wallets`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `wallet_nft_position`
--
ALTER TABLE `wallet_nft_position`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `wallet_nft_position_bk`
--
ALTER TABLE `wallet_nft_position_bk`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `wallet_nft_summary`
--
ALTER TABLE `wallet_nft_summary`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- Các ràng buộc cho các bảng đã đổ
--

--
-- Các ràng buộc cho bảng `bond_buy`
--
ALTER TABLE `bond_buy`
  ADD CONSTRAINT `bond_buy_ibfk_1` FOREIGN KEY (`bond_id`) REFERENCES `bond` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `bond_claim`
--
ALTER TABLE `bond_claim`
  ADD CONSTRAINT `bond_claim_ibfk_1` FOREIGN KEY (`bond_id`) REFERENCES `bond` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `bond_runtime_status`
--
ALTER TABLE `bond_runtime_status`
  ADD CONSTRAINT `bond_runtime_status_ibfk_1` FOREIGN KEY (`bond_id`) REFERENCES `bond` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `bot_transactions`
--
ALTER TABLE `bot_transactions`
  ADD CONSTRAINT `bot_transactions_ibfk_1` FOREIGN KEY (`bot_position_id`) REFERENCES `bot_positions` (`id`);

--
-- Các ràng buộc cho bảng `detail_token_transactions`
--
ALTER TABLE `detail_token_transactions`
  ADD CONSTRAINT `detail_token_transactions_ibfk_1` FOREIGN KEY (`hash`) REFERENCES `hash_txs` (`hash`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Các ràng buộc cho bảng `futures_orders_binance`
--
ALTER TABLE `futures_orders_binance`
  ADD CONSTRAINT `futures_orders_binance_ibfk_1` FOREIGN KEY (`wallet_id`) REFERENCES `wallets` (`wallet_address`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `futures_positions_binance`
--
ALTER TABLE `futures_positions_binance`
  ADD CONSTRAINT `futures_positions_binance_ibfk_1` FOREIGN KEY (`wallet_id`) REFERENCES `wallets` (`wallet_address`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `nft_token_transactions`
--
ALTER TABLE `nft_token_transactions`
  ADD CONSTRAINT `nft_token_transactions_ibfk_1` FOREIGN KEY (`hash`) REFERENCES `hash_txs` (`hash`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Các ràng buộc cho bảng `transaction_detail_v2`
--
ALTER TABLE `transaction_detail_v2`
  ADD CONSTRAINT `transaction_detail_v2_ibfk_1` FOREIGN KEY (`hash`) REFERENCES `transaction_history_v2` (`hash`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
