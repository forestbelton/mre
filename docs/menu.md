# List/grid menu + cursor subsystem (`$c561`–`$c56d`)

The engine's selectable menus — in-game lists *and* the level editor's room
menus — share one cursor/state struct in WRAM (`$c561`–`$c56d`, defined in
`include/wram.inc` as the `wram_menu` section) and one driver loop. This document
records what's decoded; a few adjacent bytes remain raw (see "Not yet decoded").

## The loop

Menus run inside the generic blocking UI loop (`wUiState`/`wUiTimer`, see the
`wram_ui_loop` section and `docs`-less `Func_00_1b29` family): each frame does
`WaitForNextFrame → ReadJoypad → cursor handler → render`, looping while
`wUiState != 0`. Input is read through `hJoyRepeat` (the auto-repeat pulse, so a
held d-pad steps the cursor at the menu repeat rate — see `include/hram.inc`).

## Selecting a menu definition

A menu is chosen by **`wMenuId`** (`$c561`). `Func_00_1a6c` uses it to index two
parallel tables in bank `$00`:

| table | indexed by | yields |
|---|---|---|
| `$1873` | `wMenuId` | `wMenuItemCount` (`$c56a`) — number of items |
| `$1877` | `wMenuId * 2` | `wMenuItemPtr` (`$c56b/$c56c`) — pointer to the item-value list |

`wMenuItemValue` (`$c568`) is then the value of the list entry **under the
cursor**, refreshed by the render path (`Func_00_3268`); the loop checks it
against the sentinel `$fd` (blank / non-selectable slot) to decide whether a
confirm is valid. The editor also copies `wMenuItemValue` into the room grid when
placing a cell.

## The three cursor modes

The struct supports three cursor shapes; a given menu uses one.

1. **Linear list** — handler `Func_00_1be5`.
   - `wMenuCursor` (`$c562`): selected index, Up/Down, wraps `0..wMenuItemCount-1`.
   - `wMenuCursorRow` (`$c563`): visible row `0-3` for lists taller than the window
     (the cursor scrolls within the list once the count exceeds the window).

2. **2D grid menu** — handler `Func_00_28fb` (room-arrange editor).
   - `wGridRow` (`$c566`): Up/Down, wraps at `wMenuItemCount` (rows).
   - `wGridCol` (`$c567`): Left/Right, wraps at `wGridColCount` (`$c56d`), which is
     looked up per-row (indexed by `wGridRow`) — rows can differ in width.
   - The live `(row,col)` is written into the grid buffer `$c7d3`.

3. **Floor-edit grid** — handler `Func_00_1e72` (and `Func_00_1eb0`).
   - `wEditCursorX` (`$c564`): Left/Right, wraps at `wFloorWidth`.
   - `wEditCursorY` (`$c565`): Up/Down, wraps at `wFloorHeight`.
   - Saved/restored from the per-room state `$c2ea/$c2eb` across far-calls
     (`Func_00_1afc`/`Func_00_1b15`).

## Sharing with the level editor

The "Room" menus (`OpenRoomSelectMenu`, `OpenRoomArrangeMenu`,
`SetupExchangeRoomSelect`) reset `$c55d=0` on entry and drive the same struct via
bank-`$12`/`$15` routines. `wMenuItemValue` doubles as the editor's
place-this-cell value. (The editor is the same subsystem that owns the
"V03ROOM1/2/3" saved rooms in the `.sav` image.)

## Not yet decoded

These nearby bytes are part of the menu/editor state but lack a confident
single-purpose reading, so they keep raw `$c5xx` addresses for now:

- `$c55d`: reset to 0 by the menu-open routines; also read into `wScreenAnim`
  ($d0f7) on the room-start screen — looks like a page/mode selector but is
  overloaded across screens.
- `$c55e`/`$c55f`/`$c560`: small per-menu counters/toggles (a yes/no or
  multi-state selector, an animation frame, a numeric parameter).
- `$c569`: written by the bank-`$12` editor when a cell is placed (a "last
  value" of some kind).
