Choo-Choo Charles Save Slot Manager
=================================

A lightweight Windows GUI tool for managing multiple Choo-Choo Charles save states,
designed especially for Archipelago multiworld play.

This tool allows you to create, back up, and swap save slots safely without manually
copying files each time.

------------------------------------------------------------
FEATURES
------------------------------------------------------------

- Create unlimited save slots
- Backup the active SaveGames folder into a named slot
- Swap between save slots safely
- Optional deletion of SaveGames after backup
- Archipelago slot name notes per save slot
- Prevents save corruption by blocking actions while the game is running
- Warns if files are still transferring before closing
- Open the save directory directly from the main menu
- Clean, resizable Windows Forms GUI
- Designed to work with Archipelago multiworld setups

------------------------------------------------------------
REQUIREMENTS
------------------------------------------------------------

- Windows
- Choo-Choo Charles (PC version)
- PowerShell 5.1 or newer
- Default save location (see below)

------------------------------------------------------------
DEFAULT SAVE LOCATION
------------------------------------------------------------

The program assumes Choo-Choo Charles saves are located at:

C:\Users\<USERNAME>\AppData\Local\Obscure\Saved

Inside this folder:
- SaveGames\        -> active game save files
- <Slot Name>\      -> backed-up save slot folders
- <Slot Name> AP Info.txt -> optional Archipelago slot notes

If your game uses a custom save location, the script will need to be edited.

------------------------------------------------------------
USAGE
------------------------------------------------------------

1. Launch the program (PowerShell script or compiled EXE)
2. Make sure Choo-Choo Charles is NOT running
3. Choose one of the following:

MAIN MENU OPTIONS:
- Create / Backup Save Slot
- Swap Save Slots
- Open Save Folder

------------------------------------------------------------
CREATE / BACKUP SAVE SLOT
------------------------------------------------------------

- Enter a save slot folder name (required)
- Optionally enter an Archipelago slot name
- Choose whether to:
  - Backup the current SaveGames folder
  - Delete SaveGames after backup
- Click "Run"

Notes:
- Slot folders are always created, even if backup is unchecked
- Existing slot contents are cleared before re-backup (no duplicates)
- After completion, fields are cleared and you stay on the Create screen

------------------------------------------------------------
SWAP SAVE SLOTS
------------------------------------------------------------

- Select the currently active slot
- Select the slot you want to load
- Click "Swap"

Order of operations:
1. Backup SaveGames to the active slot
2. Clear SaveGames
3. Restore files from the target slot

If the target slot is empty, the game will generate new save files automatically.

------------------------------------------------------------
ARCHIPELAGO SUPPORT NOTES
------------------------------------------------------------

- Each save slot is isolated via file backups
- Archipelago item syncing remains correct per slot
- AP slot names are stored in "<Slot Name> AP Info.txt"

------------------------------------------------------------
KNOWN LIMITATIONS / CAVEATS
------------------------------------------------------------

- Assumes default save path
- Does not support concurrent game instances
- Not an official Archipelago or Choo-Choo Charles tool

------------------------------------------------------------
LICENSE
------------------------------------------------------------

Recommended License: MIT License

You are free to:
- Use the software
- Modify the software
- Distribute the software

Requirements:
- Credit the original author

------------------------------------------------------------
CREDITS
------------------------------------------------------------

Created by: Su1table1

Inspired by:
- Choo-Choo Charles created by Two Star Games
- Archipelago Multiworld Project
- CCCharles-Random Archipelago Mod created by Yaranorgoth

------------------------------------------------------------
DISCLAIMER
------------------------------------------------------------

This tool modifies game save files.
Always back up your saves before use.
Use at your own risk.

------------------------------------------------------------
