# Labyrinth
A roguelike game built in Godot 3.5 to train adversarial reinforcement learning (RL) agents—Daedalus and Theseus. Designed for AI experimentation and adversarial agent training.

## Features
- **Procedural Labyrinth Generation**: Every playthrough presents a new maze.
- **AI Training Environment**: Supports adversarial RL between Daedalus and Theseus.
- **Godot 3.5 Engine**: Lightweight and easy to extend.

## Requirements
- [Godot 3.5 (Stable)](https://godotengine.org/download/archive/3.5-stable/)

## Setup
1. **Install Godot 3.5** if not already installed.
2. **Import the project**:
   - Open Godot 3.5.
   - Click the `Import` button in the UI.
   - Navigate to the repository folder and select `project.godot`.
   - Click `Import & Edit`.
3. **Run the game**:
   - Press `F5` or click the `Run` button in the UI.

## Running the RL Agent
1. Clone and set up the [Theseus repository](https://github.com/team-lazarus/theseus):
   ```sh
   git clone https://github.com/team-lazarus/theseus.git
   cd theseus
   # Follow the setup instructions in the Theseus repository
   ```
2. Start **Labyrinth** first.
3. Run the **Theseus** agent.
4. Observe the AI making random movements within the game.

## Contribution Guidelines
- **Use [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)** for commit messages.
- **Always create a branch** before making changes—do not push directly to `master`.
- Open a pull request (PR) for review before merging.

---

_"Through the labyrinth, we train our minds."_ 🌀


