# AI Todo App (Jac + Ollama)

Name: <Ruoxi Liu>  
UMID: <48023036>

## Overview

This project is an AI-powered Todo App built with Jac.

It supports:

- Creating, toggling, and deleting todos
- Automatic AI categorization using Ollama
- A custom AI memory feature (🧠) that summarizes each todo into a helpful reminder

## Custom Feature: AI Memory Button 🧠

Each todo includes a brain button.

When clicked:

- The server calls `remember_todo`
- Ollama generates a short memory summary
- The summary is stored in the Todo node
- The frontend displays it under the task

### Example:

Buy grocery  
→ 🧠 “Remember to purchase food items from the store.”

## How It Works

### Backend

- Added `memory` field to `Todo` node
- Added `summarize()` LLM function
- Added `remember_todo()` endpoint

### Frontend

- Added 🧠 button per todo
- Calls `remember()`
- Displays memory text dynamically

Relevant code:

- `main.jac`: Todo node, remember_todo function, summarize()
- Client `remember()` method
- UI 🧠 button + memory-text div
- styles.css for memory display

## Run Instructions

Requirements:

- Jac
- Ollama
- llama3 model

Steps:

```bash
ollama serve
jac start main.jac