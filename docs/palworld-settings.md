# Palworld Settings Reference

Complete reference for all parameters written to `PalWorldSettings.ini`.

**How to override**: add keys under `palworld_settings_overrides` in
`ansible/group_vars/palworld/palworld.yml`. Only the keys you list are changed;
everything else keeps the default below.

```yaml
palworld_settings_overrides:
  exp_rate: 2.0
  death_penalty: Item
```

**Key naming**: official PascalCase INI names map to snake_case Ansible keys
(`ExpRate` → `exp_rate`, `bIsPvP` → `b_is_pvp`).

**Defaults listed here are the project defaults** (shipped in
`ansible/roles/palworld/vars/main.yml`), which may differ from the vanilla game
defaults in a few intentional places (noted in the Description column).

---

## Randomizer

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `randomizer_type` | Pal spawn randomization mode. `None` = no randomization, `Region` = randomize per region, `All` = fully randomized. | string | `None` |
| `randomizer_seed` | Seed string for the randomizer. Empty string = random seed each time. | string | `""` |
| `b_is_randomizer_pal_level_random` | Randomize Pal levels when the randomizer is active. | boolean | `false` |

---

## World

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `difficulty` | Difficulty preset applied on top of individual rate settings. `None` means rates below govern everything. | string | `None` |
| `day_time_speed_rate` | Speed multiplier for daytime. Higher = shorter days. | float | `1.0` |
| `night_time_speed_rate` | Speed multiplier for nighttime. Higher = shorter nights. | float | `1.0` |

---

## Pal

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `pal_capture_rate` | Multiplier on Pal capture success probability. | float | `1.0` |
| `pal_spawn_num_rate` | Multiplier on the number of Pals that spawn in the world. | float | `1.0` |
| `pal_damage_rate_attack` | Multiplier on damage dealt by Pals. | float | `1.0` |
| `pal_damage_rate_defense` | Multiplier on damage received by Pals. | float | `1.0` |
| `pal_stomach_decrease_rate` | Rate at which Pal hunger decreases. Lower = Pals eat less often. | float | `1.0` |
| `pal_stamina_decrease_rate` | Rate at which Pal stamina decreases during actions. | float | `1.0` |
| `pal_auto_hp_regene_rate` | Pal HP regeneration rate multiplier. | float | `1.0` |
| `pal_auto_hp_regene_rate_in_sleep` | Pal HP regeneration rate while resting in the Palbox. | float | `1.0` |
| `pal_egg_default_hatching_time` | Time to hatch a Huge Egg (hours). Note: Other eggs also require time to incubate. | float | `72` |
| `b_active_unko` | Enables UNKO drops from Pals. | boolean | `false` |
| `enable_predator_boss_pal` | Spawns predator boss Pals in the open world. | boolean | `true` |
| `monster_farm_action_speed_rate` | Action speed multiplier for Pals assigned to a monster farm. | float | `1.0` |

---

## Player

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `exp_rate` | Experience points gain multiplier. | float | `1.0` |
| `work_speed_rate` | Pal work speed multiplier at base camps. | float | `1.0` |
| `player_damage_rate_attack` | Multiplier on damage dealt by players. | float | `1.0` |
| `player_damage_rate_defense` | Multiplier on damage received by players. | float | `1.0` |
| `player_stomach_decrease_rate` | Rate at which player hunger decreases. Lower = less food needed. | float | `1.0` |
| `player_stamina_decrease_rate` | Rate at which player stamina decreases during actions. | float | `1.0` |
| `player_auto_hp_regene_rate` | Player HP regeneration rate multiplier. | float | `1.0` |
| `player_auto_hp_regene_rate_in_sleep` | Player HP regeneration rate while sleeping in a bed. | float | `1.0` |
| `item_weight_rate` | Multiplier on item weight. Lower = players can carry more. | float | `1.0` |
| `equipment_durability_damage_rate` | Rate at which equipment durability decreases. | float | `1.0` |
| `item_corruption_multiplier` | Item corruption speed multiplier. | float | `1.0` |

---

## Building

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `build_object_hp_rate` | HP multiplier for constructed structures. | float | `1.0` |
| `build_object_damage_rate` | Damage multiplier applied to constructed structures. | float | `1.0` |
| `build_object_deterioration_damage_rate` | Rate at which structures passively deteriorate over time. | float | `1.0` |
| `b_build_area_limit` | Restricts building to designated areas. | boolean | `false` |
| `max_building_limit_num` | Maximum total number of buildings in the world. `0` = unlimited. | integer | `0` |
| `b_enable_building_player_uid_display` | Displays the owning player's UID on structures. | boolean | `false` |
| `building_name_display_cache_ttl_seconds` | How long (seconds) the building name/owner display is cached. | integer | `60` |

---

## Collection & Resources

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `collection_drop_rate` | Amount of resources dropped from gathering nodes multiplier. | float | `1.0` |
| `collection_object_hp_rate` | HP of gatherable objects (trees, rocks, …) multiplier. | float | `1.0` |
| `collection_object_respawn_speed_rate` | Respawn speed of gatherable objects multiplier. | float | `1.0` |
| `enemy_drop_item_rate` | Item drop rate from enemies multiplier. | float | `1.0` |

---

## Items & Drops

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `death_penalty` | What is lost on player death. `None` \| `Item` \| `ItemAndEquipment` \| `All`.| string | `All` |
| `drop_item_max_num` | Maximum number of dropped item stacks present in the world at once. | integer | `3000` |
| `physics_active_drop_item_max_num` | Maximum number of physics-simulated dropped items. `-1` = unlimited. | integer | `-1` |
| `drop_item_max_num_unko` | Maximum number of UNKO item stacks in the world. | integer | `100` |
| `drop_item_alive_max_hours` | Hours before a dropped item despawns. | float | `1.0` |
| `auto_save_span` | Auto-save interval in seconds. | float | `30.0` |

---

## Base Camp

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `base_camp_max_num` | Maximum number of base camps across the entire world. | integer | `128` |
| `base_camp_max_num_in_guild` | Maximum number of base camps a single guild can own. | integer | `4` |
| `base_camp_worker_max_num` | Maximum number of Pals assigned to work at a single base camp. | integer | `15` |

---

## Guild

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `guild_player_max_num` | Maximum number of players per guild. | integer | `20` |
| `b_auto_reset_guild_no_online_players` | Automatically disband a guild when no member has been online for the threshold below. | boolean | `false` |
| `auto_reset_guild_time_no_online_players` | Hours of inactivity before a guild is automatically disbanded. | float | `72` |
| `guild_rejoin_cooldown_minutes` | Cooldown in minutes before a player can rejoin a guild after leaving. | integer | `0` |
| `auto_transfer_master_check_interval_seconds` | How often (seconds) the server checks whether a guild master transfer should occur. | float | `3600.0` |
| `auto_transfer_master_threshold_days` | Days of inactivity before guild master role is transferred to another member. | integer | `14` |
| `max_guilds_per_frame` | Maximum number of guilds processed per server frame (performance tuning). | integer | `10` |

---

## Gameplay Modes

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `b_is_multiplay` | Enables multiplayer mode. | boolean | `false` |
| `b_is_pvp` | Enables PvP mode. | boolean | `false` |
| `b_hardcore` | Enables hardcore mode. | boolean | `false` |
| `b_pal_lost` | In hardcore mode, Pals are permanently lost when they die. | boolean | `false` |
| `b_character_recreate_in_hardcore` | Allows character recreation in hardcore mode after death. | boolean | `false` |
| `coop_player_max_num` | Maximum number of players in co-op mode. | integer | `4` |

---

## PvP

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `b_display_pvp_item_num_on_world_map_base_camp` | Shows the item count of guild base camps on the world map in PvP mode. | boolean | `false` |
| `b_display_pvp_item_num_on_world_map_player` | Shows the item count of players on the world map in PvP mode. | boolean | `false` |
| `b_additional_drop_item_when_player_killing_in_pvp_mode` | Enables an extra item drop when killing a player in PvP. | boolean | `false` |
| `additional_drop_item_when_player_killing_in_pvp_mode` | Type of the extra item dropped on a PvP kill. | string | `PlayerDropItem` |
| `additional_drop_item_num_when_player_killing_in_pvp_mode` | Number of extra items dropped on a PvP kill. | integer | `1` |

---

## Combat & Encounters

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `b_enable_player_to_player_damage` | Allows players to damage each other. | boolean | `false` |
| `b_enable_friendly_fire` | Allows players to damage guild members. | boolean | `false` |
| `b_enable_invader_enemy` | Enables random raid events on base camps. | boolean | `true` |
| `b_enable_defense_other_guild_player` | — | boolean | `false` |
| `b_can_pickup_other_guild_death_penalty_drop` | Allows picking up death-penalty drops belonging to other guilds. | boolean | `false` |
| `supply_drop_span` | Interval in minutes between supply drop events. | integer | `180` |

---

## Respawn & Penalties

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `b_enable_non_login_penalty` | Applies penalties to players who have not logged in recently. | boolean | `true` |
| `block_respawn_time` | — | float | `5.0` |
| `respawn_penalty_duration_threshold` | — | float | `0.0` |
| `respawn_penalty_time_scale` | — | float | `2.0` |

---

## Aim Assist

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `b_enable_aim_assist_pad` | Enables aim assist for controller (gamepad) players. | boolean | `true` |
| `b_enable_aim_assist_keyboard` | Enables aim assist for keyboard and mouse players. | boolean | `false` |

---

## Travel

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `b_enable_fast_travel` | Enables fast travel between discovered locations. | boolean | `true` |
| `b_enable_fast_travel_only_base_camp` | Restricts fast travel destinations to base camps only. | boolean | `false` |
| `b_is_start_location_select_by_map` | Allows players to select their spawn location on the map. | boolean | `false` |

---

## Visibility

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `b_exist_player_after_logout` | Player character remains in the world after the player logs out. | boolean | `false` |
| `b_invisible_other_guild_base_camp_area_fx` | Hides the visual area boundary effects of other guilds' base camps. | boolean | `false` |

---

## Technology

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `deny_technology_list` | Comma-separated list of technology IDs to disable. Empty string = nothing denied. | string | `""` |

---

## Stat Enhancement

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `b_allow_enhance_stat_health` | Allows players to upgrade the Health stat. | boolean | `true` |
| `b_allow_enhance_stat_attack` | Allows players to upgrade the Attack stat. | boolean | `true` |
| `b_allow_enhance_stat_stamina` | Allows players to upgrade the Stamina stat. | boolean | `true` |
| `b_allow_enhance_stat_weight` | Allows players to upgrade the Weight (carry capacity) stat. | boolean | `true` |
| `b_allow_enhance_stat_work_speed` | Allows players to upgrade the Work Speed stat. | boolean | `true` |

---

## Voice Chat

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `b_enable_voice_chat` | Enables proximity voice chat. | boolean | `false` |
| `voice_chat_max_volume_distance` | Distance (cm) at which voice chat is at maximum volume. | float | `3000.0` |
| `voice_chat_zero_volume_distance` | Distance (cm) at which voice chat volume reaches zero. | float | `15000.0` |

---

## Server

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `server_player_max_num` | Maximum number of players on the server simultaneously. | integer | `32` |
| `server_name` | Server name shown in the server browser. | string | *(from `palworld_server_name`)* |
| `server_description` | Short description shown in the server browser. | string | *(from `palworld_server_description`)* |
| `admin_password` | Password for admin commands and RCON. Set via `PALWORLD_ADMIN_PASSWORD`. | string | *(from env)* |
| `server_password` | Password players must enter to join. Set via `PALWORLD_SERVER_PASSWORD`. | string | *(from env)* |
| `b_allow_client_mod` | Allows clients to connect while running mods. | boolean | `true` |
| `public_port` | UDP port the game server listens on. | integer | `8211` |
| `public_ip` | Public IP address announced to clients. Auto-detected if empty. | string | *(auto-detected)* |
| `b_show_player_list` | Exposes the player list via the REST API. | boolean | `false` |
| `b_is_show_join_left_message` | Shows join/leave messages in the in-game chat. | boolean | `true` |
| `chat_post_limit_per_minute` | Maximum chat messages a player can send per minute. | integer | `30` |
| `crossplay_platforms` | Platforms allowed for crossplay. Format: `(Steam,Xbox,PS5,Mac)`. | string | `(Steam,Xbox,PS5,Mac)` |
| `b_is_use_backup_save_data` | Enables automatic backup of save data on the server. | boolean | `true` |
| `log_format_type` | Server log format. `Text` or `Json`. | string | `Text` |
| `auto_save_span` | Auto-save interval in seconds. | float | `30.0` |
| `b_allow_global_palbox_export` | Allows players to export Pals to the global Palbox. | boolean | `true` |
| `b_allow_global_palbox_import` | Allows players to import Pals from the global Palbox. | boolean | `false` |

---

## RCON

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `rcon_enabled` | Enables the RCON remote console. Also requires port `25575/tcp` to be open in the firewall. | boolean | `false` |
| `rcon_port` | TCP port for RCON connections. | integer | `25575` |

---

## REST API

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `rest_api_enabled` | Enables the HTTP REST API. | boolean | `false` |
| `rest_api_port` | TCP port the REST API listens on. | integer | `8212` |

---

## Region & Auth

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `region` | Region tag for the server browser. Empty string = no region set. | string | `""` |
| `b_use_auth` | Requires Steam authentication to join. Disable only for LAN/offline setups. | boolean | `true` |
| `ban_list_url` | URL of a remote ban list fetched by the server. | string | `https://api.palworldgame.com/api/banlist.txt` |

---

## Performance

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `server_replicate_pawn_cull_distance` | Distance (cm) beyond which the server stops replicating pawns to clients. Lower values reduce network load. | float | `15000.0` |
| `item_container_force_mark_dirty_interval` | — | float | `1.0` |
| `player_data_pal_storage_update_check_tick_interval` | — | float | `1.0` |
