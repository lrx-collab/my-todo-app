# VeroEat Safety Todo (Jac + Ollama)

Name: <Ruoxi Liu>
UMID: <78023036>

## Overview
A Todo app built with Jac. When you add a food/ingredient, the app uses a local Ollama model to normalize:
- allergens (list)
- trace risk (“may contain”)
- safety verdict (safe/caution/avoid/unknown)

## Custom Feature
**Food Safety Verdict Normalization**
- On every new todo, AI extracts a standardized allergen list and detects “may contain / trace risk”.
- The UI renders allergen tags and a trace-risk badge.

### Where the code is
- AI analysis + normalization logic: `main.jac` (`analyze_food` prompt + todo creation)
- UI rendering (allergen chips / trace risk badge): `main.jac` client UI section (the todo item rendering)

## Requirements
- Python environment with Jac installed
- Ollama installed and running locally
- Model pulled: `ollama/llama3.2:1b` (or your configured model)

## Run Instructions
```bash
# 1) start ollama (in a separate terminal)
ollama serve

# 2) (optional) pull the model
ollama pull llama3.2:1b

# 3) start the Jac dev server
jac clean --all
jac start main.jac

# 4) open the app
# http://localhost:8000