# UEFN Verse Snippets

Welcome! This repository is a place to store my Verse code for **Unreal Editor for Fortnite (UEFN)**. It contains reusable modules, standalone devices, utility tools and various experiments that I develop and test over time.

## 📂 Overview

The codebase is primarily split into specialized modules (The organization may change over time depending on libraries provided and the language evolution):

### 🧩 ExtraModules
A collection of utility libraries and helpers, usually to handle functionality that is not available natively in Verse:
*   **BitMath**: Utilities for bitwise operations, shifting and comparisons.
*   **Crypto** & **Hashing**: Implementations for cryptographic functions and hashing algorithms (Ex. AES, SHA1, SHA256, MD5, RSA, etc).
*   **DateTime**: Contains stuff related to handling dates, periods, time conversions and management of time in general.
*   **Encoding**: Libraries for various encoding formats (Ex. Base64, Base32, Hex, Binary, JSON, UUID, etc).
*   **StringProcessing**: Utility features for string manipulation from basic usages to more advanced ones.
*   **Math Utilities**: Several Math related libraries to expand Verse native math capabilities and handle more complex usages (See `HexagonMath`, `NoiseUtils`, `MathFeatures`, etc).
*   **Core Features**: Includes snippets to improve development with Verse in general, such as QoL utility functions, implementations and specific usages (See `Wrappers`, `VerseFeatures`, `DebugFeatures`, `Concurrency`, etc)
*   **TextLocalization**: A dedicated file containing many commonly used strings and localizable tables for usage across UEFN Projects

### 🎮 GameFeatures
Modules focused on gameplay implementation and game related logic:
*   **DataManagement**: Template Systems for player and session data management, including session/round and persistable usages.
*   **GameplayClasses**: Data definitions and examples for gameplay related features (Ex. Creative Devices, enemies/npcs, interfaces, Scene Graph Components, Prefabs, etc).
*   **GameplayCore**: Definitions and Utility of general importance for the functionality of the project (Ex. Gameplay Tags, Scene Queries, Team Definitions, etc.)
*   **GameplayInterfaces**: Common reusable interfaces that can be useful for easier development of projects

### 📐 Algorithms
General-purpose algorithm implementations. (WIP)

---

## ℹ️ Naming Conventions & Syntax

To help you navigate the files and folders, please note the following conventions that I am following (Note that these conventions are made by me without any specific external standard or style guide):

### 📄 File Names, Types & Extensions
*   **`*.verse.disabled`**: Verse files that are currently disabled (treated as plain text/comments) to prevent compilation by UEFN.
*   **`_test.*`**: Files specifically created for testing or asserting functionality.
*   **`references.txt`**: Found in various folders, these contain links to blog posts, reference repositories, or documentation relevant to understand or describe the code in that directory. (TODO: Change these to a better looking Readme file with more details and info)
*   **Utility Scripts**: Some folders may contain non-Verse files (e.g., `.txt`, `.go`, `.js`, `.csv`, `.py`, `.json`, etc) used for data generation, tables, quick notes or additional tools.

> **⚠️ Note:** Some Verse Scripts may depend on external UEFN/Unreal Engine assets (Meshes, Materials, etc.). These dependencies will be mentioned where applicable.

### 📁 Extra Convention Rules
*   🧪 **`_EXPERIMENTS` Folders:**
    *   Contains random ideas, prototypes, and experimental code.
    *   **Not** considered part of the main stable libraries, but can be looked for ideas and reference usages
*   📜 **`_OBSOLETE` Folders & Files:**
    *   Holds deprecated versions of modules and old functionality.
    *   Kept strictly for historical reference.
*   🗑️ **`_TEMP` / `__TEMP` Folders & Files:**
    *   Temporary folders or files intended to be deleted later.
    *   `__TEMP` is ignored by Git (Excluded from version control).
    *   `_TEMP` is tracked normally by Git.

## 📚 General References & Credits

(**WIP**)

Third Party Contributions and references will be listed here _(Feel free to contact me about it!)_.

Additional resources, references, and contributions will be listed at their respective folders within this repository.

---
*Be the best version of yourself!* 🐝
